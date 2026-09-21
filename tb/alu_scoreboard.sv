class alu_scoreboard;
  int pass_count = 0;
  int fail_count = 0;

  // 把 top 中现有的 reference_model 函数搬到这里。
  // 返回类型和 a、b 的类型改用 logic [7:0]。
function automatic logic [7:0] reference_model(
    input logic [2:0] op,
    input logic [7:0] a,
    input logic [7:0] b
  );
    case (op)
      3'd0: reference_model = a + b;
      3'd1: reference_model = a - b;
      3'd2: reference_model = a & b;
      3'd3: reference_model = a | b;
      3'd4: reference_model = a ^ b;
      3'd5: reference_model = a << b;//添加左偏计算式.
      default: reference_model = '0;
    endcase
  endfunction

  function void check(
    alu_transaction sent,
    alu_transaction observed
  );
    logic [7:0] expected;

    if (sent == null || observed == null)
      $fatal(1, "scoreboard received a null transaction");

    expected = reference_model(sent.op, sent.a, sent.b);

    if (observed.rsp_valid !== 1'b1) begin
      $error("Response is not valid");
      fail_count++;
    end else if (observed.result !== expected) begin
      $error("Mismatch: op=%0d a=%0d b=%0d expected=%0d actual=%0d",
             sent.op, sent.a, sent.b, expected, observed.result);
      fail_count++;
    end else begin
      $display("[PASS] op=%0d a=%0d b=%0d result=%0d",
               sent.op, sent.a, sent.b, observed.result);
      pass_count++;
    end
  endfunction
endclass