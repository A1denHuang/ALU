class alu_transaction;
  rand logic [2:0] op;
  rand logic [7:0] a;
  rand logic [7:0] b;
  logic [7:0] result;
  logic      rsp_valid;

  constraint legal_op_c {
    op inside {[3'd0:3'd5]};
    if (op == 3'd5) {
      b inside {[8'd0:8'd8]};
    }
  }

  function new(
    logic [2:0] op = 0,
    logic [7:0] a = 0,
    logic [7:0] b = 0
  );
    this.op = op;
    this.a  = a;
    this.b  = b;
  endfunction

  function void display();
    $display("[TRANS] op=%0d a=%0d b=%0d", op, a, b);
  endfunction
endclass
