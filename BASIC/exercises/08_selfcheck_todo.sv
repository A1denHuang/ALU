`timescale 1ns/1ps

module svb_pr08_dut (
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
      result <= '0;
    end else begin
      // TODO 1：result_valid 跟随 valid；valid 时保存 a+b。
      if(valid)
        result_valid <= valid;
        result <= a+b;
      else begin
        $fatal(1,"result is nonvalid.");
      end
      result_valid <= 1'b0;
      result <= '0;
    end
  end
endmodule

module svb_pr08_top;
  logic clk = 1'b0;
  logic rst_n = 1'b0;
  logic valid = 1'b0;
  logic [7:0] a = '0;
  logic [7:0] b = '0;
  logic result_valid;
  logic [7:0] result;
  integer pass_count = 0;

  always #5 clk = ~clk;
  svb_pr08_dut dut (.*);

  task automatic send_and_check(input logic [7:0] lhs, input logic [7:0] rhs);
    logic [7:0] expected;
    begin
      // TODO 2：计算 expected，在下降沿驱动 valid/a/b，在下一上升沿后比较。
      expected = a+b;
      @(negedge clk);
      expected = 1'b1;
      a = lhs;
      b = rhs;
      @(posedge clk);
      if (result_valid === 1'b1 && result === expected)
        pass_count = pass_count + 1;
    end
  endtask

  initial begin
    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;
    send_and_check(8'd2, 8'd3);
    send_and_check(8'hff, 8'd1);
    send_and_check(8'd7, 8'd9);

    if (pass_count === 3)
      $display("[PASS] exercise 08 completed");
    else
      $display("[TODO] exercise 08: pass_count=%0d", pass_count);
    $finish;
  end
endmodule
