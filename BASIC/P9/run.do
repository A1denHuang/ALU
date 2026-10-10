transcript on

if {[file exists work_p9]} {
    vdel -lib work_p9 -all
}
vlib work_p9
vmap work_p9 work_p9

vlog -sv -work work_p9 RTL/DUT.sv TB/t_transaction.sv TB/tb_top.sv
vsim -c -onfinish stop work_p9.tb
run -all
quit -f
