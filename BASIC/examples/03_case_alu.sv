`timescale 1ns/1ps

module svb_ex03_alu (
  input  logic [1:0] op,
  input  logic [7:0] a,
  input  logic [7:0] b,
  output logic [7:0] result
);
  always_comb begin
    case (op)
      2'd0: result = a + b;
      2'd1: result = a - b;
      2'd2: result = a & b;
      2'd3: result = a ^ b;
      default: result = '0;
    endcase
  end
endmodule

module svb_ex03_top;
  logic [1:0] op;
  logic [7:0] a, b, result;

  svb_ex03_alu dut (.*);

  initial begin
    a = 8'h0f;
    b = 8'h03;

    op = 2'd0; #1; if (result !== 8'h12) $fatal(1, "ADD mismatch");
    op = 2'd1; #1; if (result !== 8'h0c) $fatal(1, "SUB mismatch");
    op = 2'd2; #1; if (result !== 8'h03) $fatal(1, "AND mismatch");
    op = 2'd3; #1; if (result !== 8'h0c) $fatal(1, "XOR mismatch");

    $display("[PASS] case and combinational ALU");
    $finish;
  end
endmodule
