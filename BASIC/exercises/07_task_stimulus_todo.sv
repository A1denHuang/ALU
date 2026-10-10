`timescale 1ns/1ps

module svb_pr07_equal (
  input  logic [7:0] a,
  input  logic [7:0] b,
  output logic       equal
);
  assign equal = (a == b);
endmodule

module svb_pr07_top;
  logic [7:0] a, b;
  logic equal;
  integer pass_count = 0;

  svb_pr07_equal dut (.*);

  task automatic drive_and_check(
    input logic [7:0] lhs,
    input logic [7:0] rhs,
    input logic       expected
  );
    begin
      // TODO：驱动 a、b，等待 #1，比较 equal 和 expected；正确时 pass_count 加一。
      a = lhs;
      b = rhs;
      if (equal !== expected)
        $fatal(1,"lhs=%0d,rhs=%0d,equal=%0b,expected=%0b,incorrect. ",
              lhs,rhs,equal,expected);
      else if (equal == expected)
        pass_count+=1;
      #1;
    end
  endtask

  initial begin
    drive_and_check(8'd5, 8'd5, 1'b1);
    drive_and_check(8'd5, 8'd6, 1'b0);
    if (pass_count === 2)
      $display("[PASS] exercise 07 completed");
    else
      $display("[TODO] exercise 07: pass_count=%0d", pass_count);
    $finish;
  end
endmodule
