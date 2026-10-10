module tiny_accumulator #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             valid,
    input  logic [WIDTH-1:0] data,
    output logic [WIDTH-1:0] sum
);

    // 低有效异步复位；valid=1 时在时钟上升沿累加。
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            sum <= '0;
        else if (valid)
            sum <= sum + data;
    end

endmodule
