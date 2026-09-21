transcript on

# 创建仿真库
if {[file exists work]} {
  vdel -lib work -all
}
vlib work
vmap work work

# 编译（interface+package+top）
vlog -sv +incdir+../tb ../rtl/simple_alu.sv ../tb/alu_if.sv ../tb/alu_assertions.sv ../tb/alu_pkg.sv ../tb/tb_top.sv

vsim -c -sv_seed 12345 work.tb_top

run -all

