class alu_driver;
  virtual alu_if #(8) vif;

  function new(virtual alu_if #(8) vif);
    this.vif = vif;
    if (vif == null)
      $fatal(1, "alu_driver received a null interface");
  endfunction

  task drive(alu_transaction tr);
    if (tr == null)
      $fatal(1, "alu_driver received a null transaction");

    @(negedge vif.clk);
    vif.req_valid = 1'b1;
    vif.op        = tr.op;
    vif.a         = tr.a;
    vif.b         = tr.b;

    // 等待 DUT 在上升沿更新输出
    @(posedge vif.clk);
    #1;
  endtask
  
  task idle();
    @(negedge vif.clk);
    vif.req_valid = 1'b0;
  endtask
endclass
