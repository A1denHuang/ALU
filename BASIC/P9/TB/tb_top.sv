`timescale 1ns/1ps

module tb;
    localparam int WIDTH = 8;

    logic             clk   = 1'b0;
    logic             rst_n = 1'b0;
    logic             valid = 1'b0;
    logic [WIDTH-1:0] data  = '0;
    logic [WIDTH-1:0] sum;
    integer           pass_count = 0;

    // 5 ns 翻转一次，时钟周期为 10 ns。
    always #5 clk = ~clk;

    tiny_accumulator #(.WIDTH(WIDTH)) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .valid (valid),
        .data  (data),
        .sum   (sum)
    );

    task automatic reset_dut;
        begin
            rst_n = 1'b0;
            valid = 1'b0;
            data  = '0;

            // 异步复位不需要等待时钟沿，但留出 1 ns 让信号更新。
            #1;
            if (sum !== '0)
                $fatal(1, "Reset failed: expected sum=0, actual sum=%0d", sum);

            repeat (2) @(posedge clk);
            @(negedge clk);
            rst_n = 1'b1;
        end
    endtask

    task automatic send_and_check(
        input logic [WIDTH-1:0] input_data,
        input logic [WIDTH-1:0] expected_sum
    );
        begin
            // 在下降沿驱动，使输入在下一个上升沿之前保持稳定。
            @(negedge clk);
            valid = 1'b1;
            data  = input_data;

            @(posedge clk);
            #1;
            if (sum !== expected_sum)
                $fatal(1,
                       "Accumulate failed: data=%0d expected=%0d actual=%0d",
                       input_data, expected_sum, sum);

            pass_count = pass_count + 1;
            $display("[PASS] data=%0d sum=%0d", input_data, sum);

            @(negedge clk);
            valid = 1'b0;
            data  = '0;
        end
    endtask

    task automatic check_hold(input logic [WIDTH-1:0] expected_sum);
        begin
            // valid=0 时，即使 data 改变，sum 也必须保持不变。
            @(negedge clk);
            valid = 1'b0;
            data  = 8'hff;

            @(posedge clk);
            #1;
            if (sum !== expected_sum)
                $fatal(1,
                       "Hold failed: expected=%0d actual=%0d",
                       expected_sum, sum);

            pass_count = pass_count + 1;
            $display("[PASS] valid=0 holds sum=%0d", sum);
        end
    endtask

    initial begin
        reset_dut();

        send_and_check(8'd3,   8'd3);
        send_and_check(8'd5,   8'd8);
        send_and_check(8'd250, 8'd2); // 8 + 250 = 258，8 位截断为 2
        check_hold(8'd2);

        $display("\n================================");
        $display("[PASS] tiny accumulator: %0d checks passed", pass_count);
        $display("================================");
        $finish;
    end

endmodule
