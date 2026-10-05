set project_name "asynch_fifo"
set fpga_part    "xc7a35tcpg236-1"

set script_dir  [file dirname [file normalize [info script]]]
set repo_dir    [file normalize "$script_dir/.."]
set project_dir "$repo_dir/vivado_project"

create_project $project_name $project_dir -part $fpga_part -force

# RTL (skip testbenches, same convention as MakerFaire)
set rtl_files {}
foreach f [glob -nocomplain "$repo_dir/*.sv"] {
    if {![string match "*_tb.sv" $f]} { lappend rtl_files $f }
}
add_files -fileset sources_1 $rtl_files
set_property top asynch_fifo [current_fileset]

# Clocks
add_files -fileset constrs_1 [glob -nocomplain "$repo_dir/constraints/*.xdc"]

# Synthesize as a block, not a whole chip (no I/O pin limits)
set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} \
             -value {-mode out_of_context} -objects [get_runs synth_1]

update_compile_order -fileset sources_1

# Run synthesis and write the CDC report
launch_runs synth_1
wait_on_run synth_1
open_run synth_1
file mkdir "$repo_dir/build"
report_cdc          -file "$repo_dir/build/cdc_summary.rpt"
report_cdc -details -file "$repo_dir/build/cdc_details.rpt"

close_project