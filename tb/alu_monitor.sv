// monitor 只读取接口，不驱动信号，也不判断结果对错。每次采样创建新对象，保存当时的快照。
class alu_monitor;
  virtual alu_if #(8) vif;

  function new(virtual alu_if #(8) vif);
    this.vif = vif;
    if (vif == null)
      $fatal(1, "alu_monitor received a null interface");
  endfunction

  function alu_transaction sample();
    alu_transaction observed;

    observed = new(vif.op, vif.a, vif.b);
    observed.rsp_valid = vif.rsp_valid;
    observed.result    = vif.result;

    return observed;
  endfunction
endclass