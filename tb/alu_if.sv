interface alu_if #(parameter int WIDTH = 8) (input logic clk);
  logic                 rst_n;
  logic                 req_valid;
  logic [2:0]           op;
  logic [WIDTH-1:0]     a;
  logic [WIDTH-1:0]     b;
  logic                 rsp_valid;
  logic [WIDTH-1:0]     result;
endinterface
