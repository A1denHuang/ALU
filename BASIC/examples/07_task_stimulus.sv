`timescale 1ns/1ps

module svb_ex07_equal (
  input  logic [7:0] a,
  input  logic [7:0] b,
  output logic       equal
);
  assign equal = (a == b);
endmodule

module svb_ex07_top;
  logic [7:0] a, b;
  logic equal;
  integer pass_count = 0;

  svb_ex07_equal dut (.*);

  task automatic drive_and_check(
    input logic [7:0] lhs,
    input logic [7:0] rhs,
    input logic       expected
  );
    begin
      a = lhs;
      b = rhs;
      #1;
      if (equal !== expected)
        $fatal(1, "lhs=%0d rhs=%0d expected=%0b actual=%0b",
               lhs, rhs, expected, equal);
      pass_count = pass_count + 1;
    end
  endtask

  initial begin
    drive_and_check(8'd5, 8'd5, 1'b1);
    drive_and_check(8'd5, 8'd6, 1'b0);
    if (pass_count !== 2) $fatal(1, "task did not run twice");
    $display("[PASS] task stimulus and reusable checking");
    $finish;
  end
endmodule
