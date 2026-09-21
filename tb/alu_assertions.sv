module alu_assertions (
  input logic clk,
  input logic rst_n,
  input logic req_valid,
  input logic rsp_valid
);

  property p_valid_response;
    @(posedge clk) disable iff (!rst_n)
      req_valid |=> rsp_valid;// DUT 在某个上升沿用非阻塞赋值更新 rsp_valid
      // '|=>'意思是 下一次采样时
  endproperty

  a_valid_response: assert property (p_valid_response)
    else $fatal(1, "Request was not followed by a valid response");

// 检查没有请求时，不能凭空产生有效响应
    property p_no_spurious_response;
        @(posedge clk) disable iff (!rst_n)
        !req_valid |=> !rsp_valid;
    endproperty
    
    a_no_spurious_response: assert property (p_no_spurious_response)
        else $fatal(1, "Spurious response detected when no request was made");

endmodule