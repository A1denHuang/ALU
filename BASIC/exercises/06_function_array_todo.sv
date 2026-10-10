`timescale 1ns/1ps

module svb_pr06_top;
  logic [7:0] data [0:2];
  logic parity [0:2];
  integer i;

  function automatic logic parity8(input logic [7:0] value);
    integer bit_index;
    begin

      even_parity = 1'b0;
      // TODO：用 for 遍历 8 位，并用异或累计到 parity8。
      for (bit_index=0;bit_index<8;bit_index++)
        parity8=data[bit_index]^parity8;
    end
  endfunction

  initial begin
    data[0] = 8'b0000_0000;
    data[1] = 8'b0000_0001;
    data[2] = 8'b1010_1010;

    // TODO：用 for 为 parity[0] 到 parity[2] 调用 parity8。
    for (i = 0; i < 3; i = i + 1)
      parity8(parity[i]);

    if (parity[0] === 1'b0 && parity[1] === 1'b1 && parity[2] === 1'b0)
      $display("[PASS] exercise 06 completed");
    else
      $display("[TODO] exercise 06: function or array loop is incomplete");
    $finish;
  end
endmodule
