`timescale 1ns/1ps

module svb_ex02_mux (
  input  logic [7:0] d0,
  input  logic [7:0] d1,
  input  logic       sel,
  output logic [7:0] y
);
  always_comb begin
    if (sel)
      y = d0;
    else
      y = d1;
  end
endmodule

module svb_ex02_top;
  logic [7:0] d0, d1, y;
  logic sel;

  svb_ex02_mux dut (.d0(d0), .d1(d1), .sel(sel), .y(y));

  initial begin
    d0 = 8'h35;
    d1 = 8'hca;

    sel = 1'b0; #1;
    if (y !== d0) $fatal(1, "sel=0 should choose d0");

    sel = 1'b1; #1;
    if (y !== d1) $fatal(1, "sel=1 should choose d1");

    $display("[PASS] always_comb, if/else and module ports");
    $finish;
  end
endmodule
