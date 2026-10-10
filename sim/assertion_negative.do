# Negative test for one SVA property at a time.
# Usage examples from the sim directory:
#   vsim -c -do "set fault_case valid_response; do assertion_negative.do"
#   vsim -c -do "set fault_case spurious_response; do assertion_negative.do"
#   vsim -c -do "set fault_case result_hold; do assertion_negative.do"

if {![info exists fault_case]} {
  set fault_case valid_response
}

if {[file exists work]} {
  vdel -lib work -all
}
vlib work
vmap work work

vlog -sv +incdir+../tb ../rtl/simple_alu.sv ../tb/alu_if.sv ../tb/alu_assertions.sv ../tb/alu_pkg.sv ../tb/tb_top.sv
vsim -onfinish stop -sv_seed 12345 work.tb_top

switch -- $fault_case {
  valid_response {
    run 41ns
    force -freeze /tb_top/vif/rsp_valid 1'b0
  }
  spurious_response {
    run 41ns
    force -freeze /tb_top/vif/rsp_valid 1'b1
  }
  result_hold {
    run 46ns
    force -freeze /tb_top/vif/result 8'h00
  }
  default {
    error "Unknown fault_case: $fault_case"
  }
}

run -all
