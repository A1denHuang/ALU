`timescale 1ns/1ps

module svb_ex06_top;
  logic [7:0] data [0:2];
  logic       parity [0:2];
  integer i;

  function automatic logic even_parity(input logic [7:0] value);
    integer bit_index;
    begin
      even_parity = 1'b0;
      for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1)
        even_parity = even_parity ^ value[bit_index];
    end
  endfunction

  initial begin
    data[0] = 8'b0000_0000;
    data[1] = 8'b0000_0001;
    data[2] = 8'b1010_1010;

    for (i = 0; i < 3; i = i + 1)
      parity[i] = even_parity(data[i]);

    if (parity[0] !== 1'b0) $fatal(1, "parity[0] mismatch");
    if (parity[1] !== 1'b1) $fatal(1, "parity[1] mismatch");
    if (parity[2] !== 1'b0) $fatal(1, "parity[2] mismatch");

    $display("[PASS] array, for loop and function");
    $finish;
  end
endmodule
