`timescale 1ns/1ps
module uart_tx #(
    parameter integer CLOCK_FREQ = 100_000_000, // e.g., 100 MHz
    parameter integer BAUD       = 57600       // 115200
)(
    input  logic        clk,        // system clock
    input  logic        rstn,       // active-low reset (synchronous reset used)
    input  logic        send,       // pulse/level to start a one-bit send (sampled when idle)
    input  logic [7:0]  bit_value,  // the single data bit to transmit (LSB semantics irrelevant here)
    output logic        tx,         // UART TX output (idle = 1)
    output logic        busy,       // asserted while transmitting (start..stop)
    output logic        ready       // asserted when module is idle and ready to accept send
);

    // integer cycles per one UART bit interval (start/data/stop)
    localparam integer CYCLES_PER_BIT = CLOCK_FREQ / BAUD; // truncates fractional part

    // State machine states
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11
    } state_t;

    state_t state, next_state;

    // counters
    localparam WIDTH = $clog2(CYCLES_PER_BIT);
    logic [WIDTH:0] cycle_cnt;
    int index, index_next; // To send bits one by one
    // combinational next-state + datapath
    always_comb begin
        // defaults for outputs (they are registered in always_ff)
        index_next = index;
        busy       = (state != IDLE);
        ready      = (state == IDLE);

        case (state)
            IDLE: begin
                tx = 1'b1; // idle
            end

            START: begin
                tx = 1'b0; // start bit (low)
                // increment cycle counter on each clock in sequential block below
                // when we've held start bit for CYCLES_PER_BIT clocks -> DATA
            end

            DATA: begin
                tx        = bit_value[index]; // send the one data bit
                index_next = (index==8)?0:index + 1;
            end

            STOP: begin
                busy = 1'b0;
                tx   = 1'b1; // stop bit (high)
            end

            default: begin
                tx = 1'b1;
            end
        endcase
    end

    // synchronous counter & state timing
    always_ff @(posedge clk or posedge rstn) begin
        if (rstn) begin
            cycle_cnt  <= 0;
            next_state <= IDLE;
            index      <= 0;
            state      <= IDLE;
        end
        else begin
            case (state)
                IDLE: begin
                    cycle_cnt <= 0;
                    if (send) begin
                        next_state <= START;
                        index      <= 0;
                    end
                end

                START: begin
                    if (cycle_cnt < (WIDTH+1)'(CYCLES_PER_BIT - 1)) begin
                        cycle_cnt <= cycle_cnt + 1;
                    end
                    else begin
                        cycle_cnt  <= 0;
                        next_state <= DATA;
                    end
                end

                DATA: begin
                    if (cycle_cnt < (WIDTH+1)'(CYCLES_PER_BIT - 1)) begin
                        cycle_cnt <= cycle_cnt + 1;
                    end
                    else if (index == 8) begin
                        cycle_cnt  <= 0;
                        next_state <= STOP;
                        index      <= 0;
                    end
                    else begin
                        cycle_cnt <= 0;
                        index     <= index_next;
                    end
                end

                STOP: begin
                    if (cycle_cnt < (WIDTH+1)'(CYCLES_PER_BIT - 1)) begin
                        cycle_cnt <= cycle_cnt + 1;
                    end
                    else begin
                        cycle_cnt  <= 0;
                        next_state <= IDLE;
                    end
                end

                default: begin
                    cycle_cnt  <= 0;
                    next_state <= IDLE;
                end
            endcase

            state <= next_state;
        end
    end

endmodule
