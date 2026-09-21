module simple_alu #(
  parameter int WIDTH = 8
) (
  input  logic                 clk,
  input  logic                 rst_n,
  input  logic                 req_valid,
  input  logic [2:0]           op,
  input  logic [WIDTH-1:0]     a,
  input  logic [WIDTH-1:0]     b,
  output logic                 rsp_valid,
  output logic [WIDTH-1:0]     result
);

  localparam logic [2:0] OP_ADD = 3'd0;
  localparam logic [2:0] OP_SUB = 3'd1;
  localparam logic [2:0] OP_AND = 3'd2;
  localparam logic [2:0] OP_OR  = 3'd3;
  localparam logic [2:0] OP_XOR = 3'd4;
  localparam logic [2:0] OP_LEFTSHIFT = 3'd5;//新增操作模式：左移.

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rsp_valid <= 1'b0;
      result    <= '0;
    end else begin
      rsp_valid <= req_valid;
      if (req_valid) begin
        unique case (op)
          OP_ADD: result <= a + b;
          OP_SUB: result <= a - b;
          OP_AND: result <= a & b;
          OP_OR : result <= a | b;
          OP_XOR: result <= a ^ b;
	  OP_LEFTSHIFT: result <=  a<< b; //添加op5的对应计算式.
          default: result <= '0;//'0指把目标即result变量的所有位填为0.
        endcase
      end
    end
  end

endmodule
