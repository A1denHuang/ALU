`timescale 1ns/1ps

module svb_pr04_counter #(
  parameter int WIDTH = 4
) (
  input  logic             clk,
  input  logic             rst_n,
  input  logic             enable,
  output logic [WIDTH-1:0] count
);
  always_ff @(posedge clk or negedge rst_n) begin
    // TODO：低有效复位时清零；否则 enable=1 时加一。
    if(!rst_n)
      count <= '0;
    else if (enable)
      count+=1'b1;
  end
endmodule

module svb_pr04_top;
  logic clk = 1'b0;
  logic rst_n = 1'b0;
  logic enable = 1'b0;
  logic [3:0] count;
  logic all_correct = 1'b1;

  always #5 clk = ~clk;
  svb_pr04_counter #(.WIDTH(4)) dut (.*);

  initial begin
    repeat (2) @(negedge clk);
    if (count !== 4'd0) all_correct = 1'b0;
    rst_n = 1'b1;
    enable = 1'b1;
    repeat (3) @(posedge clk);
    #1;
    if (count !== 4'd3) all_correct = 1'b0;
    if (all_correct)
      $display("[PASS] exercise 04 completed");
    else
      $display("[TODO] exercise 04: reset and count behavior are incomplete");
    $finish;
  end
endmodule
