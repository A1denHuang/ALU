class alu_coverage;
  covergroup op_cg with function sample(input logic [2:0] op);
    option.per_instance = 1;

    op_cp: coverpoint op {
      bins each_op[] = {[3'd0:3'd5]};
    }
  endgroup

  function new();
    op_cg = new();
  endfunction
endclass