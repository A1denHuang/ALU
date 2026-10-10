`timescale 1ns/1ps

module svb_pr01_top;
  logic [7:0] a, b;
  logic [7:0] sum;
  logic [3:0] high_nibble;
  logic [7:0] joined;

  initial begin
    a = 8'hc3;
    b = 8'd61;

    // TODO 1：计算 a + b，结果只保留 8 位。
    sum = '0;
    sum = a + b;
    // TODO 2：取出 a 的高 4 位。
    high_nibble = '0;
    high_nibble = a[7:4];
    // TODO 3：把 a 的高 4 位和 b 的低 4 位拼成 8 位。
    joined = '0;
    joined = {a[7:4],b[3:0]};
    if (sum === 8'h00 && high_nibble === 4'hc && joined === 8'hcd)
      $display("[PASS] exercise 01 completed");
    else
      $display("[TODO] exercise 01: sum=%h high=%h joined=%h", sum, high_nibble, joined);
    $finish;
  end
endmodule
