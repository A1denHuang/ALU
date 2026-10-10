module alu_assertions (
  input logic clk,
  input logic rst_n,
  input logic req_valid,
  input logic rsp_valid,
  input logic [7:0] result
);

  property p_valid_response;
    @(posedge clk) disable iff (!rst_n)
      req_valid |=> rsp_valid;
  endproperty

  a_valid_response: assert property (p_valid_response)
    else $fatal(1, "Request was not followed by a valid response");

  // No request may produce a response on the following sample.
  property p_no_spurious_response;
    @(posedge clk) disable iff (!rst_n)
      !req_valid |=> !rsp_valid;
  endproperty

  a_no_spurious_response: assert property (p_no_spurious_response)
    else $fatal(1, "Spurious response detected when no request was made");

  // The registered result must remain stable while the interface is idle.
  property p_result_hold;
    @(posedge clk) disable iff (!rst_n)
      !req_valid |=> $stable(result);
  endproperty

  a_result_hold: assert property (p_result_hold)
    else $fatal(1, "Result changed while no request was active");

endmodule
