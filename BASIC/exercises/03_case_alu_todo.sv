`timescale 1ns/1ps

module svb_pr03_alu (
  input  logic [1:0] op,
  input  logic [7:0] a,
  input  logic [7:0] b,
  output logic [7:0] result
);
  always_comb begin
    // TODO：使用 case 实现 0:加，1:减，2:按位与，3:按位异或。
    case(op)
      2'd0: result = a+b;
      2'd1: result = a-b;
      2'd2: result = a&b;
      2'd3: result = a^b;
      default: result = '0;
    endcase
  end
endmodule

module svb_pr03_top;
  logic [1:0] op;
  logic [7:0] a = 8'h0f;
  logic [7:0] b = 8'h03;
  logic [7:0] result;
  logic all_correct = 1'b1;

  svb_pr03_alu dut (.*);

  initial begin
    op = 2'd0; #1; if (result !== 8'h12) all_correct = 1'b0;
    op = 2'd1; #1; if (result !== 8'h0c) all_correct = 1'b0;
    op = 2'd2; #1; if (result !== 8'h03) all_correct = 1'b0;
    op = 2'd3; #1; if (result !== 8'h0c) all_correct = 1'b0;
    if (all_correct)
      $display("[PASS] exercise 03 completed");
    else
      $display("[TODO] exercise 03: complete all four case branches");
    $finish;
  end
endmodule
