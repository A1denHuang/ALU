`timescale 1ns/1ps

module svb_pr02_mux (
  input  logic [7:0] d0,
  input  logic [7:0] d1,
  input  logic       sel,
  output logic [7:0] y
);
  always_comb begin
    // TODO：使用 if/else，让 sel=0 选择 d0，sel=1 选择 d1。
    if (sel)
      y = d0;
    else
      y = d1;
  end
endmodule

module svb_pr02_top;
  logic [7:0] d0 = 8'h12;
  logic [7:0] d1 = 8'h34;
  logic sel;
  logic [7:0] y;
  logic all_correct = 1'b1;

  svb_pr02_mux dut (.*);

  initial begin
    sel = 1'b0; #1; if (y !== d0) all_correct = 1'b0;
    sel = 1'b1; #1; if (y !== d1) all_correct = 1'b0;
    if (all_correct)
      $display("[PASS] exercise 02 completed");
    else
      $display("[TODO] exercise 02: complete the mux if/else");
    $finish;
  end
endmodule
