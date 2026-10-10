`timescale 1ns/1ps

module svb_ex08_dut (
  input  logic       clk,
  input  logic       rst_n,
  input  logic       valid,
  input  logic [7:0] a,
  input  logic [7:0] b,
  output logic       result_valid,
  output logic [7:0] result
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      result_valid <= 1'b0;
      result       <= '0;
    end else begin
      result_valid <= valid;
      if (valid)
        result <= a + b;
    end
  end
endmodule

module svb_ex08_top;
  logic clk = 1'b0;
  logic rst_n = 1'b0;
  logic valid = 1'b0;
  logic [7:0] a = '0;
  logic [7:0] b = '0;
  logic result_valid;
  logic [7:0] result;
  integer pass_count = 0;

  always #5 clk = ~clk;
  svb_ex08_dut dut (.*);

  task automatic send_and_check(input logic [7:0] lhs, input logic [7:0] rhs);
    logic [7:0] expected;
    begin
      expected = lhs + rhs;
      @(negedge clk);
      valid = 1'b1;
      a = lhs;
      b = rhs;
      @(posedge clk); #1;
      if (result_valid !== 1'b1 || result !== expected)
        $fatal(1, "a=%0d b=%0d expected=%0d actual=%0d",
               lhs, rhs, expected, result);
      pass_count = pass_count + 1;
      @(negedge clk);
      valid = 1'b0;
    end
  endtask

  initial begin
    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    send_and_check(8'd2, 8'd3);
    send_and_check(8'hff, 8'd1);
    send_and_check(8'd7, 8'd9);

    if (pass_count !== 3) $fatal(1, "not all tests ran");
    $display("[PASS] complete DUT and self-checking testbench");
    $finish;
  end
endmodule
