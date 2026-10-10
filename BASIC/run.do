transcript on

set mode "examples"
if {[info exists env(SV_BASICS_MODE)]} {
  set mode $env(SV_BASICS_MODE)
}

if {$mode eq "examples"} {
  set tests {
    {examples/01_types_ops.sv       svb_ex01_top}
    {examples/02_mux.sv             svb_ex02_top}
    {examples/03_case_alu.sv        svb_ex03_top}
    {examples/04_counter.sv         svb_ex04_top}
    {examples/05_parameter_adder.sv svb_ex05_top}
    {examples/06_function_array.sv  svb_ex06_top}
    {examples/07_task_stimulus.sv   svb_ex07_top}
    {examples/08_selfcheck.sv       svb_ex08_top}
  }
} elseif {$mode eq "exercises"} {
  set tests {
    {exercises/01_types_ops_todo.sv       svb_pr01_top}
    {exercises/02_mux_todo.sv             svb_pr02_top}
    {exercises/03_case_alu_todo.sv        svb_pr03_top}
    {exercises/04_counter_todo.sv         svb_pr04_top}
    {exercises/05_parameter_adder_todo.sv svb_pr05_top}
    {exercises/06_function_array_todo.sv  svb_pr06_top}
    {exercises/07_task_stimulus_todo.sv   svb_pr07_top}
    {exercises/08_selfcheck_todo.sv       svb_pr08_top}
  }
} else {
  echo "ERROR: mode must be examples or exercises"
  quit -code 2 -f
}

if {[file exists work_basics]} {
  vdel -lib work_basics -all
}
vlib work_basics
vmap work_basics work_basics

foreach test $tests {
  set source [lindex $test 0]
  set top    [lindex $test 1]
  echo "===== $source ====="
  if {[catch {vlog -sv -work work_basics $source} compile_error]} {
    echo "COMPILE FAILED: $source"
    quit -code 1 -f
  }
  if {[catch {vsim -c -onfinish stop work_basics.$top} load_error]} {
    echo "LOAD FAILED: $top"
    quit -code 1 -f
  }
  run -all
  quit -sim
}

echo "===== Finished $mode ====="
quit -f
