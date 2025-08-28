module uart_rx #(
    parameter CLOCK_FREQ = 100_000_000, // e.g., 100 MHz
    parameter BAUD       = 57600 //115200
)(
    input  logic clk,
    input  logic rstn,
    input  logic rx,
    output logic [7:0] r_data,
    output logic       r_valid
);

    localparam int CYCLES_PER_BIT = CLOCK_FREQ / BAUD;
    localparam int CTR_WIDTH = $clog2(CYCLES_PER_BIT);

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        START= 2'b01,
        DATA = 2'b10,
        STOP = 2'b11
    } state_t;

    state_t state;
    logic [CTR_WIDTH-1:0] count_cycles;
    logic [2:0]           bit_index;  // counts 0..7
    logic [7:0]           rx_shift;
    
    logic hold_valid;
    always_ff @(posedge clk or posedge rstn) begin
        if (rstn) begin
            state        <= IDLE;
            count_cycles <= 0;
            bit_index    <= 0;
            rx_shift     <= 0;
            r_data       <= 0;
            r_valid      <= 0;
            hold_valid   <= 0;
        end else begin
            //Holding r_valid for  one more clock cycle for proper data capture for logic handling unit
            r_valid<=0;
            //End of hold code
            case (state)
                IDLE: begin
                    if (rx == 0) begin  // detect start bit
                        state        <= START;
                        count_cycles <= 0;
                    end
                end

                START: begin
                    if (count_cycles == CTR_WIDTH'(CYCLES_PER_BIT/2)) begin
                        // sample in the middle of start bit
                        if (rx == 0) begin
                            state        <= DATA;
                            count_cycles <= 0;
                            bit_index    <= 0;
                        end else begin
                            state <= IDLE; // false start
                        end
                    end else
                        count_cycles <= count_cycles + 1;
                end

                DATA: begin
                    if (count_cycles == CTR_WIDTH'(CYCLES_PER_BIT-1)) begin
                        count_cycles <= 0;
                        rx_shift[bit_index] <= rx; // LSB first
                        if (bit_index == 7) begin
                            state <= STOP;
                        end else
                            bit_index <= bit_index + 1;
                    end else
                        count_cycles <= count_cycles + 1;
                end

                STOP: begin
                    if (count_cycles == CTR_WIDTH'(CYCLES_PER_BIT-1)) begin
                        state        <= IDLE;
                        count_cycles <= 0;
                        r_data       <= rx_shift;
                        r_valid      <= 1; 
                    end else
                        count_cycles <= count_cycles + 1;
                end
            endcase
        end
    end
endmodule
