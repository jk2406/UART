module rxlogic_handle(
    input  logic[7:0] r_data,
    input  logic clk,
    input logic rstp,
    input logic r_valid,
    output logic[7:0]  digit0,
    output logic[7:0]  digit1,
    output logic[7:0]  digit2,
    output logic[7:0]  digit3,
    output logic[7:0]  digit4,
    output logic[7:0]  digit5,
    output logic[7:0]  digit6,
    output logic[7:0]  digit7
);
logic[2:0] index;

always_ff @( posedge clk or posedge rstp ) begin : LogicHandler
    if(rstp) begin
      digit0<="0";
      digit1<="0";
      digit2<="0";
      digit3<="0";
      digit4<="0";
      digit5<="0";
      digit6<="0";
      digit7<="0";
      index<='1;
    end
    else begin
    if (r_valid) begin
        case (index)
            3'b111: begin
                digit7 <= r_data;
                index  <= index - 1;
            end
            3'b110: begin
                digit6 <= r_data;
                index  <= index - 1;
            end
            3'b101: begin
                digit5 <= r_data;
                index  <= index - 1;
            end
            3'b100: begin
                digit4 <= r_data;
                index  <= index - 1;
            end
            3'b011: begin
                digit3 <= r_data;
                index  <= index - 1;
            end
            3'b010: begin
                digit2 <= r_data;
                index  <= index - 1;
            end
            3'b001: begin
                digit1 <= r_data;
                index  <= index - 1;
            end
            3'b000: begin
                digit0 <= r_data;
                index  <= '1;
            end
            default:digit7<=r_data;
        endcase
    end
end
end
endmodule