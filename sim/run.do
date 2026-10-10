transcript on

# 创建仿真库
if {[file exists work]} {
  vdel -lib work -all
}
vlib work
vmap work work

# 编译（interface+package+top）
vlog -sv +incdir+../tb ../rtl/simple_alu.sv ../tb/alu_if.sv ../tb/alu_assertions.sv ../tb/alu_pkg.sv ../tb/tb_top.sv

foreach seed {12345 67890 24212} {
    echo "===== SEED: $seed ====="
    # -onfinish stop must be set when loading the design, not before elaboration.
    vsim -onfinish stop -sv_seed $seed work.tb_top
    run -all
    quit -sim
}

quit -f
