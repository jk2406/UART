`timescale 1ns/1ps

module tb_uart_tx;

  // Parameters
  localparam int CLOCK_FREQ = 100_000_000;
  localparam int BAUD       = 57600;

  // DUT signals
  logic clk;
  logic rstn;
  logic send;
  logic [7:0] bit_value;
  logic tx, busy, ready;

  // message array (declare OUTSIDE initial to avoid Verilator errors)
  logic [7:0] msg [0:1];

  // Clock gen (10ns = 100MHz)
  initial clk = 0;
  always #5 clk = ~clk;

  // DUT instance
  uart_tx #(
    .CLOCK_FREQ(CLOCK_FREQ),
    .BAUD(BAUD)
  ) dut (
    .clk(clk),
    .rstn(rstn),
    .send(send),
    .bit_value(bit_value),
    .tx(tx),
    .busy(busy),
    .ready(ready)
  );
integer i;
  // Stimulus
  initial begin
    // init
    rstn      = 0;
    send      = 1'b0;
    bit_value = 0;

    // release reset
    repeat (5) @(posedge clk);
    rstn = 1;

    // characters to print
    msg[0] = "H";
    msg[1] = "I";

    // send each char one by one when ready
    
    for (i = 0; i < 2; i++) begin
      @(posedge clk);
        // wait until transmitter idle
      bit_value = msg[i];  // load char
      
      $display("Time %t : Sent char '%s' (0x%h)", $time, msg[i], msg[i]);
    end

    // let simulation run long enough to finish transmission
    #200000 $stop;
  end

endmodule
