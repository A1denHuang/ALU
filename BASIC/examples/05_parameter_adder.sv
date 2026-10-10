`timescale 1ns/1ps

module svb_ex05_adder #(
  parameter int WIDTH = 8
) (
  input  logic [WIDTH-1:0] a,
  input  logic [WIDTH-1:0] b,
  output logic [WIDTH-1:0] sum,
  output logic             carry
);
  always_comb begin
    {carry, sum} = a + b;
  end
endmodule

module svb_ex05_top;
  logic [3:0] a, b, sum;
  logic carry;

  svb_ex05_adder #(.WIDTH(4)) dut (
    .a(a), .b(b), .sum(sum), .carry(carry)
  );

  initial begin
    a = 4'd9;
    b = 4'd8;
    #1;
    if ({carry, sum} !== 5'd17) $fatal(1, "parameterized adder mismatch");
    $display("[PASS] parameter and named port connection");
    $finish;
  end
endmodule
