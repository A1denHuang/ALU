`timescale 1ns/1ps

module svb_ex01_top;
  logic [7:0] a;
  logic [7:0] b;
  logic [7:0] sum;
  logic [3:0] low_nibble;
  logic [7:0] joined;
  logic signed [7:0] signed_value;

  initial begin
    a            = 8'hf0;
    b            = 8'd18;
    sum          = a + b;          // 240 + 18 = 258，只保留低 8 位
    low_nibble   = a[3:0];
    joined       = {a[7:4], b[3:0]};
    signed_value = 8'hfe;

    if (sum !== 8'h02)          $fatal(1, "sum should wrap to 8'h02");
    if (low_nibble !== 4'h0)    $fatal(1, "slice mismatch");
    if (joined !== 8'hf2)       $fatal(1, "concatenation mismatch");
    if (signed_value !== -8'sd2) $fatal(1, "signed value mismatch");

    $display("[PASS] types, literals, operators and concatenation");
    $finish;
  end
endmodule
