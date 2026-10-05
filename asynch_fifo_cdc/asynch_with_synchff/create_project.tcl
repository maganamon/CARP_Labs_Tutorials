# ============================================================
# CARP at Calpoly SLO
# Async FIFO (with synch_ff synchronizers): Vivado CDC check
#
# Lives in the project root, next to the .sv files.
# Run from the project root with:
#
#   vivado -mode batch -source create_project.tcl
#
# Creates the project, synthesizes it as a block, and writes
# CDC reports to build/. Open the project afterwards with:
#
#   vivado vivado_project/asynch_fifo.xpr
# ============================================================


# ------------------------------------------------------------
# Settings
# ------------------------------------------------------------

set project_name "asynch_fifo"
set top_module   "asynch_fifo"
set fpga_part    "xc7a35tcpg236-1"    ;# Basys 3 (only used to synthesize)

set wr_period 10.0                    ;# ns, same as the testbenches
set rd_period  7.0

# Script lives in the root, so the root is its own folder
set repo_dir    [file dirname [file normalize [info script]]]
set project_dir "$repo_dir/vivado_project"
set build_dir   "$repo_dir/build"

file mkdir $build_dir


# ------------------------------------------------------------
# Create project
# ------------------------------------------------------------

create_project $project_name $project_dir -part $fpga_part -force


# ------------------------------------------------------------
# RTL: every .sv in the root except testbenches (*_tb*.sv)
# ------------------------------------------------------------

set rtl_files {}
foreach f [glob -nocomplain "$repo_dir/*.sv"] {
    if {![string match "*_tb*.sv" [file tail $f]]} {
        lappend rtl_files $f
    }
}

puts "RTL files:"
foreach f $rtl_files { puts "  [file tail $f]" }

add_files -fileset sources_1 $rtl_files
set_property top $top_module [current_fileset]
update_compile_order -fileset sources_1


# ------------------------------------------------------------
# Clocks: written into build/ so the source folder stays clean
# ------------------------------------------------------------

set xdc_file "$build_dir/clocks.xdc"
set fh [open $xdc_file w]
puts $fh "create_clock -name wr_clk -period $wr_period \[get_ports wr_clk\]"
puts $fh "create_clock -name rd_clk -period $rd_period \[get_ports rd_clk\]"
close $fh

add_files -fileset constrs_1 $xdc_file


# ------------------------------------------------------------
# Synthesize as a block, not a whole chip (no I/O pin limits)
# ------------------------------------------------------------

set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} \
             -value {-mode out_of_context} -objects [get_runs synth_1]

launch_runs synth_1
wait_on_run synth_1

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: synthesis failed. See $project_dir/$project_name.runs/synth_1/runme.log"
    exit 1
}

open_run synth_1


# ------------------------------------------------------------
# Synchronizer flops: find them and check ASYNC_REG
#
# The two synch_ff instances are named wptr_to_rclk and
# rptr_to_wclk in asynch_fifo.sv; their flops are "sync_reg*".
# ------------------------------------------------------------

set sync_cells [get_cells -quiet -hier -filter \
    {IS_SEQUENTIAL && (NAME =~ *wptr_to_rclk/* || NAME =~ *rptr_to_wclk/*)}]

puts ""
puts "Synchronizer flops found: [llength $sync_cells]"

if {[llength $sync_cells] == 0} {
    puts "WARNING: no synchronizer flops found. Check the synch_ff instance names."
} else {
    set missing [filter $sync_cells {ASYNC_REG != TRUE}]
    if {[llength $missing] > 0} {
        puts "NOTE: [llength $missing] synchronizer flops lack ASYNC_REG in the RTL."
        puts "      Tagging them now so report_cdc recognizes them."
        puts "      (Better: uncomment (* ASYNC_REG = \"TRUE\" *) in synch_ff.sv)"
        set_property ASYNC_REG TRUE $missing
    } else {
        puts "All synchronizer flops already have ASYNC_REG = TRUE."
    }
}


# ------------------------------------------------------------
# CDC reports
# ------------------------------------------------------------

report_cdc          -file "$build_dir/cdc_summary.rpt"
report_cdc -details -file "$build_dir/cdc_details.rpt"
write_checkpoint -force   "$build_dir/post_synth.dcp"

puts ""
puts "========================================"
puts "CDC reports written:"
puts "  build/cdc_summary.rpt"
puts "  build/cdc_details.rpt"
puts "Open the project with:"
puts "  vivado vivado_project/$project_name.xpr"
puts "========================================"

close_project