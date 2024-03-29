set start_time [clock seconds] 

if {[file exists /proc/cpuinfo]} {
  sh grep "model name" /proc/cpuinfo
  sh grep "cpu MHz"    /proc/cpuinfo
}

puts "Hostname : [info hostname]"

##############################################################################
## Preset global variables and attributes
##############################################################################

set DESIGN arith
set GEN_EFF high
set MAP_OPT_EFF high
set DATE [clock format [clock seconds] -format "%b%d-%T"] 
set SYNDIR synthesis;
set _OUTPUTS_PATH $SYNDIR/outputs_${DATE}
set _REPORTS_PATH $SYNDIR/reports_${DATE}
set _LOG_PATH $SYNDIR/logs_${DATE}
##set ET_WORKDIR <ET work directory>
#set_db / .script_search_path {. <path>} 

#Leitura da lista de arquivos a serem sintetizados
set rtl_list [glob ../../rtl/src/*.sv]

##Uncomment and specify machine names to enable super-threading.
##set_db / .super_thread_servers {<machine names>} 
##For design size of 1.5M - 5M gates, use 8 to 16 CPUs. For designs > 5M gates, use 16 to 32 CPUs
##set_db / .max_cpus_per_server 8

##Default undriven/unconnected setting is 'none'.  
##set_db / .hdl_unconnected_input_port_value 0 | 1 | x | none 
##set_db / .hdl_undriven_output_port_value   0 | 1 | x | none
##set_db / .hdl_undriven_signal_value        0 | 1 | x | none 

##set_db / .wireload_mode <value> 
set_db / .information_level 5

###############################################################
## Library setup
###############################################################

###  Caminho geral para o PDK  ###
set TECHLIBBASE "|-TECHLIBBASE-|"

###  Caminhos para os arquivos do PDK - D_CELLS_HD  ###
set TECHLIB_S_PATH "$TECHLIBBASEbloblo/blabla \ 
                    $TECHLIBBASEblablo/blablu"
                    
###  LEF: MET4+METMID+METTHK e D_CELLS_HD  ###
#set LEF_LIST "{xh018_xx43_HD_MET4_METMID_METTHK.lef \
               xh018_D_CELLS_HD.lef"

###  Lib: D_CELLS_HD e XSPRAM_1024X32  ###
set TIME_LIST "D_CELLS_HD_LPMOS_slow_1_62V_125C.lib" 

###  CapTbl: MET4_METMID_METTHK  ###
set CAPTBL_LIST "xh018_xx43_MET4_METMID_METTHK_max.capTbl"

set_db / .init_lib_search_path $TECHLIB_S_PATH
set_db / .library $TIME_LIST
## PLE
#set_db / .lef_library $LEF_LIST
## Provide either cap_table_file or the qrc_tech_file
set_db / .cap_table_file $CAPTBL_LIST
#set_db / .qrc_tech_file <file>
##generates <signal>_reg[<bit_width>] format
#set_db / .hdl_array_naming_style %s\[%d\] 
## 
#set_db / .interconnect_mode ple ### 
#Optimizations
set_db / .tns_opto true
# clock gating settings
set_db / .library_sets.libraries.lib_cells.dont_use false
set_db / .lp_insert_clock_gating false
set_db / .lp_power_analysis_effort high
set_db / .lp_power_unit mW
#set_db / .lp_insert_discrete_clock_gating_logic true
####################################################################
## Load Design
####################################################################
set_db / .hdl_error_on_latch true
set_db / .hdl_report_case_info true
set_db / .hdl_array_naming_style %s_%d
set_db / .hdl_create_label_for_unlabeled_generate false

read_hdl -sv $rtl_list
elaborate $DESIGN
puts "Runtime & Memory after 'read_hdl'"

edit_netlist uniquify $DESIGN -verbose

time_info Elaboration

check_design -unresolved

####################################################################
## Constraints Setup
####################################################################
read_sdc -stop_on_errors basic_constraints.sdc

#check_design -unresolved
#set_db / .lp_clock_gating_style latch
#set_db / .lp_clock_gating_cell [find / -libcell $CG_INTEGRATED] [find -design *] 

puts "The number of exceptions is [llength [vfind "design:$DESIGN" -exception *]]"

#set_db "design:$DESIGN" .force_wireload <wireload name> 

if {![file exists ${_LOG_PATH}]} {
  file mkdir ${_LOG_PATH}
  puts "Creating directory ${_LOG_PATH}"
}

if {![file exists ${_OUTPUTS_PATH}]} {
  file mkdir ${_OUTPUTS_PATH}
  puts "Creating directory ${_OUTPUTS_PATH}"
}

if {![file exists ${_REPORTS_PATH}]} {
  file mkdir ${_REPORTS_PATH}
  puts "Creating directory ${_REPORTS_PATH}"
}
report_timing -lint

###################################################################################
## Define cost groups (clock-clock, clock-output, input-clock, input-output)
###################################################################################

## Uncomment to remove already existing costgroups before creating new ones.
## delete_obj [vfind /designs/* -cost_group *]

if {[llength [all::all_seqs]] > 0} { 
  define_cost_group -name I2C -design $DESIGN
  define_cost_group -name C2O -design $DESIGN
  define_cost_group -name C2C -design $DESIGN
  path_group -from [all::all_seqs] -to [all::all_seqs] -group C2C -name C2C
  path_group -from [all::all_seqs] -to [all::all_outs] -group C2O -name C2O
  path_group -from [all::all_inps]  -to [all::all_seqs] -group I2C -name I2C
}

define_cost_group -name I2O -design $DESIGN
path_group -from [all::all_inps]  -to [all::all_outs] -group I2O -name I2O
foreach cg [vfind / -cost_group *] {
  report_timing -cost_group [list $cg] >> $_REPORTS_PATH/${DESIGN}_pretim.rpt
}

#### To turn off sequential merging on the design 
#### uncomment & use the following attributes.
##set_db / .optimize_merge_flops false # Esta sendo feito na otimizacao
##set_db / .optimize_merge_latches false 
#### For a particular instance use attribute 'optimize_merge_seqs' to turn off sequential merging. 

####################################################################################################
## Synthesizing to generic 
####################################################################################################
#To prevent automatic ungrouping
set_db / .auto_ungroup none

set_db / .syn_generic_effort $GEN_EFF
syn_generic
puts "Runtime & Memory after 'syn_generic'"
time_info GENERIC
report_dp > $_REPORTS_PATH/generic/${DESIGN}_datapath.rpt
write_snapshot -outdir $_REPORTS_PATH -tag generic
report_summary -directory $_REPORTS_PATH

####################################################################################################
## Synthesizing to gates
####################################################################################################
set_db / .syn_map_effort $MAP_OPT_EFF
syn_map
puts "Runtime & Memory after 'syn_map'"
time_info MAPPED
write_snapshot -outdir $_REPORTS_PATH -tag map
report_summary -directory $_REPORTS_PATH
report_dp > $_REPORTS_PATH/map/${DESIGN}_datapath.rpt


foreach cg [vfind / -cost_group *] {
  report_timing -cost_group [list $cg] > $_REPORTS_PATH/${DESIGN}_[vbasename $cg]_post_map.rpt
}

write_do_lec -revised_design fv_map -logfile ${_LOG_PATH}/rtl2intermediate.lec.log > ${_OUTPUTS_PATH}/rtl2intermediate.lec.do

## ungroup -threshold <value>

#######################################################################################################
## Optimize Netlist
#######################################################################################################
#set_db / .dp_perform_sharing_operations true
#set_db / .dp_area_mode true
#set_db / .dp_postmap_downsize true
#set_db / .lp_insert_operand_isolation true
set_db / .optimize_merge_flops true

## Uncomment to remove assigns & insert tiehilo cells during Incremental synthesis
set_db / .remove_assigns true 
##set_remove_assign_options -buffer_or_inverter <libcell> -design <design|subdesign> 
set_db / .use_tiehilo_for_const duplicate

set_db / .syn_opt_effort $MAP_OPT_EFF
syn_opt
write_snapshot -outdir $_REPORTS_PATH -tag syn_opt
report_summary -directory $_REPORTS_PATH

puts "Runtime & Memory after 'syn_opt'"
time_info OPT

foreach cg [vfind / -cost_group *] {
  report_timing -cost_group [list $cg] > $_REPORTS_PATH/${DESIGN}_[vbasename $cg]_post_opt.rpt
}

######################################################################################################
## write backend file set (verilog, SDC, config, etc.)
######################################################################################################

report_dp > $_REPORTS_PATH/${DESIGN}_datapath_incr.rpt
report_messages > $_REPORTS_PATH/${DESIGN}_messages.rpt
write_snapshot -outdir $_REPORTS_PATH -tag final
report_summary -directory $_REPORTS_PATH
report_power -verbose > $_REPORTS_PATH/${DESIGN}_power_final.rpt
report_clock_gating -detail > $_REPORTS_PATH/${DESIGN}_cg_final.rpt
report_clock_gating -gated_ff > $_REPORTS_PATH/${DESIGN}_cg_gated_final.rpt
report_clock_gating -ungated_ff > $_REPORTS_PATH/${DESIGN}_cg_ungated_final.rpt

# remove_cdn_loop_breaker must be before write_hdl and after sdf write
#remove_cdn_loop_breaker

write_hdl  > ${_OUTPUTS_PATH}/${DESIGN}_map.v
## write_script > ${_OUTPUTS_PATH}/${DESIGN}_m.script
write_sdc > ${_OUTPUTS_PATH}/${DESIGN}_map.sdc
## SDF file - timming
write_sdf -edges check_edge > ${_OUTPUTS_PATH}/${DESIGN}_map.sdf

#################################
### write_do_lec
#################################

write_do_lec -golden_design fv_map -revised_design ${_OUTPUTS_PATH}/${DESIGN}_m.v -logfile  ${_LOG_PATH}/intermediate2final.lec.log > ${_OUTPUTS_PATH}/intermediate2final.lec.do
##Uncomment if the RTL is to be compared with the final netlist..
write_do_lec -revised_design ${_OUTPUTS_PATH}/${DESIGN}_m.v -logfile ${_LOG_PATH}/rtl2final.lec.log > ${_OUTPUTS_PATH}/rtl2final.lec.do

puts "Final Runtime & Memory."
time_info FINAL
puts "============================"
puts "Synthesis Finished ........."
puts "============================"

file copy [get_db / .stdout_log] ${_LOG_PATH}/.

set stop_time [clock seconds]
    
puts "<PEM> =============================================="
puts "<PEM>         Elapsed runtime : [clock format [expr $stop_time - $start_time] -format %H:%M:%S -gmt true]"
puts "<PEM> =============================================="

quit
