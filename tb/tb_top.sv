`timescale 1ns/1ps

module tb_top;
  import alu_pkg::*;
  localparam int WIDTH = 8;
  logic clk = 1'b0;
  alu_monitor mon;//定义监视类对象mon
  alu_transaction tr;//定义事务类对象tr
  alu_driver drv;//定义驱动类对象drv
  alu_scoreboard scb;//定义记分板类对象scb
  alu_coverage cov;//定义覆盖率类对象cov
  always #5 clk = ~clk;

  alu_if #(WIDTH) vif(clk);

  simple_alu #(.WIDTH(WIDTH)) dut (
    .clk       (clk),
    .rst_n     (vif.rst_n),
    .req_valid (vif.req_valid),
    .op        (vif.op),
    .a         (vif.a),
    .b         (vif.b),
    .rsp_valid (vif.rsp_valid),
    .result    (vif.result)
  );

  alu_assertions checks (
  .clk       (clk),
  .rst_n     (vif.rst_n),
  .req_valid (vif.req_valid),
  .rsp_valid (vif.rsp_valid)
);



  task automatic reset_dut;
    vif.rst_n     = 1'b0;
    vif.req_valid = 1'b0;
    vif.op        = '0;
    vif.a         = '0;
    vif.b         = '0;
    repeat (2) @(posedge clk);
    vif.rst_n = 1'b1;
    @(posedge clk);
  endtask

  task automatic drive_and_check( input alu_transaction tr );

    alu_transaction observed;

    // 空句柄保护
    if (tr == null) begin
      $fatal(1, "Transaction handle is null");
      return;
    end

    drv.drive(tr);
    observed = mon.sample();// 监视器采样，获取DUT的输出
    
    scb.check(tr, observed);// 检查DUT的输出是否与参考模型一致
    cov.op_cg.sample(tr.op);// 采样覆盖率
    // if (!observed.rsp_valid) begin
    //   $error("rsp_valid should be 1: op=%0d a=%0d b=%0d", tr.op, tr.a, tr.b);
    //   fail_count++;
    // end else if (observed.result !== expected) begin
    //   $error("Mismatch: op=%0d a=%0d b=%0d expected=%0d actual=%0d",
    //          tr.op, tr.a, tr.b, expected, observed.result);
    //   fail_count++;
    // end else begin
    //   $display("[PASS] op=%0d a=%0d b=%0d result=%0d", tr.op, tr.a, tr.b, observed.result);
    //   pass_count++;
    // end

    drv.idle();// 任务用于在驱动器中设置空闲状态
  endtask
  

  initial begin
    drv = new(vif);//创建驱动类对象drv
    mon = new(vif);//创建监视类对象mon
    scb = new();//创建记分板类对象scb
    cov = new();//创建覆盖率类对象cov
    reset_dut();

    tr = new(3'd0,8'h07,8'h09);//添加“7+9”这一测试用例.创建事务对象tr
    tr.display();//显示事务对象tr的内容
    drive_and_check(tr);//驱动事务对象tr的内容
    tr = new(3'd1,8'h0a,8'h03);//添加“10-3”这一测试用例.创建事务对象tr
    tr.display();//显示事务对象tr的内容
    drive_and_check(tr);//驱动事务对象tr的内容
    tr = new(3'd5,8'h03,8'h02);//添加“3左移2位”这一测试用例.创建事务对象tr
    tr.display();//显示事务对象tr的内容
    drive_and_check(tr);//驱动事务对象tr的内容
    
    tr = new(3'd0, 8'd10,  8'd20);
    drive_and_check(tr);
    tr = new(3'd0, 8'hff,  8'd1);
    drive_and_check(tr);
    tr = new(3'd0, 8'h07,  8'h09);//添加“7+9”这一测试用例.
    drive_and_check(tr);
    tr = new(3'd1, 8'd3,   8'd5);
    drive_and_check(tr);
    tr = new(3'd2, 8'hf0,  8'h5a);
    drive_and_check(tr);
    tr = new(3'd3, 8'hf0,  8'h5a);
    drive_and_check(tr);
    tr = new(3'd4, 8'hf0,  8'h5a);
    drive_and_check(tr);
    tr = new(3'd5, 8'h01,  8'h02);//添加“1左移2位”这一测试用例
    drive_and_check(tr);
    tr = new(3'd5, 8'h81, 8'd0); // 不移位：81
    drive_and_check(tr);
    tr = new(3'd5, 8'h81, 8'd1); // 最高位移出：02
    drive_and_check(tr);
    tr = new(3'd5, 8'hff, 8'd8); // 全部移出：00
    drive_and_check(tr);

    // 20条随机化事务测试
    repeat (20) begin
      tr = new();
      if(!tr.randomize())
        $fatal(1,"Failed to randomize transaction");

      tr.display();
      drive_and_check(tr);
    end

    repeat (2) @(posedge clk);
    $display("\n================================");
    $display("TEST SUMMARY: PASS=%0d FAIL=%0d", scb.pass_count, scb.fail_count);
    $display("================================");
    $display("OP COVERAGE: %0.1f%%", cov.op_cg.get_inst_coverage());
    if (scb.fail_count == 0) begin
      $display("TEST PASSED");
      $finish;
    end else begin
      $fatal(1, "TEST FAILED");
    end
  end

endmodule
