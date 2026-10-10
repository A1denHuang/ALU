`timescale 1ns/1ps

module svb_ex04_counter #(
  parameter int WIDTH = 4
) (
  input  logic             clk,
  input  logic             rst_n,
  input  logic             enable,
  output logic [WIDTH-1:0] count
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      count <= '0;
    else if (enable)
      count <= count + 1'b1;
  end
endmodule

module svb_ex04_top;
  logic clk = 1'b0;
  logic rst_n = 1'b0;
  logic enable = 1'b0;
  logic [3:0] count;

  always #5 clk = ~clk;
  svb_ex04_counter #(.WIDTH(4)) dut (.*);

  initial begin
    repeat (2) @(negedge clk);
    if (count !== 4'd0) $fatal(1, "reset mismatch");

    rst_n = 1'b1;
    enable = 1'b1;
    repeat (3) @(posedge clk);
    #1;
    if (count !== 4'd3) $fatal(1, "counter should be 3");

    @(negedge clk);
    enable = 1'b0;
    @(posedge clk); #1;
    if (count !== 4'd3) $fatal(1, "counter should hold");

    $display("[PASS] always_ff, reset and nonblocking assignment");
    $finish;
  end
endmodule
