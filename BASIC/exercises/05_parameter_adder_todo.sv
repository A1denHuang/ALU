`timescale 1ns/1ps

module svb_pr05_adder #(
  parameter int WIDTH = 8
) (
  input  logic [WIDTH-1:0] a,
  input  logic [WIDTH-1:0] b,
  output logic [WIDTH-1:0] sum,
  output logic             carry
);
  always_comb begin
    // TODO：一次赋值同时得到进位和 WIDTH 位结果。
    {carry, sum} = a+b;
  end
endmodule

module svb_pr05_top;
  logic [3:0] a = 4'd9;
  logic [3:0] b = 4'd8;
  logic [3:0] sum;
  logic carry;

  svb_pr05_adder #(.WIDTH(4)) dut (
    .a(a), .b(b), .sum(sum), .carry(carry)
  );

  initial begin
    #1;
    if ({carry, sum} === 5'd17)
      $display("[PASS] exercise 05 completed");
    else
      $display("[TODO] exercise 05: carry=%0b sum=%0d", carry, sum);
    $finish;
  end
endmodule
