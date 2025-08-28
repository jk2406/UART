

import ssdDisplay::*;
module NDigitDisplay #(
    parameter N_DIGITS=8
)(
    input  logic        clk,
    input  logic        rstn, 
    input logic         rx,
    input logic         send,
    output logic        tx, 
    output logic [7:0]  an,
    output logic [6:0]  seg
);
    //DIGITS
    logic [7:0]  digit0;
    logic [7:0]  digit1;
    logic [7:0]  digit2;
    logic [7:0]  digit3;
    logic [7:0]  digit4;
    logic [7:0]  digit5;
    logic [7:0]  digit6;
    logic [7:0]  digit7;

    //HANDSHAKE DECLARATIONS
    logic [7:0] message;
    logic ready;
    logic r_valid;
    logic [7:0] r_data;
    // MODULE INSTANTIATIONS
    uart_tx UART_TX(
        .clk(clk),
        .tx(tx),
        .rstn(rstn),
        .send(send),
        .bit_value(message),
        .busy(),
        .ready(ready)
    );

    uart_rx UART_RX(
        .clk(clk),
        .rstn(rstn),
        .rx(rx),
        .r_data(r_data),
        .r_valid(r_valid)
    );
    send_message Message(
        .clk(clk),
        .rstn(rstn),
        .message(message),
        .ready(ready)
    );
    rxlogic_handle RxLogic(
        .clk(clk),
        .rstp(rstn),
        .r_data(r_data),
        .digit0(digit0),
        .digit1(digit1),
        .digit2(digit2),
        .digit3(digit3),
        .digit4(digit4),
        .digit5(digit5),
        .digit6(digit6),
        .digit7(digit7),
        .r_valid(r_valid)
    );

    // END OF MODULE INSTANTIATIONS
    

    // Per second refreshes i.e. refreshes count
    localparam int refresh_cnt = 1000;
    // On time for each digit (based on 100 MHz clock, your original formula)
    localparam int ON_TIME = 100_000_000 / (refresh_cnt * N_DIGITS);
    localparam int CW = $clog2((ON_TIME > 1) ? ON_TIME : 2)+1;

    logic [CW-1:0] cnt;
    int index;

    always_ff @(posedge clk or posedge rstn) begin : ClockBlock
        if (rstn) begin
            cnt   <= '0;
            index <= 0;
            an    <= 8'b11111110;   // all off except first
            seg   <= 7'b1111111;    // all segments off
        end
        else begin : MainLogicBlock
            if (cnt == CW'(ON_TIME - 1)) begin
                cnt <= '0;

                an[index]      <= 1'b1;  // disable current
                an[(index==8)?0:index+1] <= 1'b0;  // enable next
                index          <= (index==8)?0:index+1;
            end
            else begin
                cnt <= cnt + 1;          // Increment hold-time counter
            end

            // Display Logic
            case (index)
                0: seg <= CharToSSD(digit0);
                1: seg <= CharToSSD(digit1);
                2: seg <= CharToSSD(digit2);
                3: seg <= CharToSSD(digit3);
                4: seg <= CharToSSD(digit4);
                5: seg <= CharToSSD(digit5);
                6: seg <= CharToSSD(digit6);
                7: seg <= CharToSSD(digit7);
                default: seg <= CharToSSD(digit0);
            endcase
        
        end : MainLogicBlock
    end : ClockBlock
endmodule
