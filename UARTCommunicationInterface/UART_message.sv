`timescale 1ns/1ps
module send_message #(
    parameter logic[2:0] message_count=3
) (
    output logic[7:0] message,
    input logic  clk,
    input logic rstn,
    input logic ready
);


int index;

always_ff @( posedge clk or posedge rstn ) begin 
    if(rstn) begin
        index<=0;
    end
    else begin
        if (ready) begin
             message<="E";
        end        
        end   
    end     
         

endmodule