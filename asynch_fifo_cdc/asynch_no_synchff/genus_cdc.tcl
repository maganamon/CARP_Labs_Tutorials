# ============================================================
# CARP at Calpoly SLO
# Genus CDC crossing check for the async FIFO examples
#
# Lives in asynch_fifo_cdc/ (shared by both versions).
# Run it from INSIDE a project folder:
#
#   cd asynch_no_synchff      (or asynch_with_synchff)
#   mkdir -p build
#   genus -files ../genus_cdc.tcl -log build/genus
#
# Genus does not judge whether a crossing is synchronized.
# It lists every path between the two clocks; the endpoint
# names tell you where the crossings land.
# ============================================================


# ------------------------------------------------------------
# Library: SkyWater 130 typical corner from the SerDes lab
# (path is relative to the project folder you run from)
# ------------------------------------------------------------

set lib_file "../../SerDes_Labs/Lab1_Parallel_vs_Serial/sky130_orfs/flow/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib"

if {![file exists $lib_file]} {
    puts "ERROR: library not found: $lib_file"
    puts "       Run this from inside asynch_no_synchff/ or asynch_with_synchff/"
    exit 1
}

set_db library $lib_file


# ------------------------------------------------------------
# RTL: every .sv in this folder except testbenches
# ------------------------------------------------------------

set rtl_files {}
foreach f [lsort [glob -nocomplain *.sv]] {
    if {![string match "*_tb*.sv" $f]} { lappend rtl_files $f }
}

puts "RTL files: $rtl_files"

read_hdl -sv $rtl_files
elaborate asynch_fifo


# ------------------------------------------------------------
# Two clocks, deliberately NOT declared asynchronous,
# so Genus reports every path between them
# ------------------------------------------------------------

create_clock -name wr_clk -period 10 [get_ports wr_clk]
create_clock -name rd_clk -period 7  [get_ports rd_clk]
#set_clock_groups -asynchronous -group wr_clk -group rd_clk

# ------------------------------------------------------------
# Synthesize
# ------------------------------------------------------------

syn_generic
syn_map


# ------------------------------------------------------------
# Crossing reports (ignore the slack numbers; read the endpoints)
# ------------------------------------------------------------

file mkdir build
report_timing -from [get_clocks wr_clk] -to [get_clocks rd_clk] -max_paths 500 > build/wr2rd.rpt
report_timing -from [get_clocks rd_clk] -to [get_clocks wr_clk] -max_paths 500 > build/rd2wr.rpt

puts ""
puts "Reports written: build/wr2rd.rpt  build/rd2wr.rpt"

exit