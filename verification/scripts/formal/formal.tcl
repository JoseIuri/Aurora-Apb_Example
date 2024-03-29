# Analyze design under verification files
set ROOT_PATH ../../..
set RTL_PATH ${ROOT_PATH}/frontend/rtl/src/
set PROP_PATH ${ROOT_PATH}/verification/formal/properties

set rtl_list [glob ${RTL_PATH}/*.sv]

analyze -sv ${rtl_list}

# Analyze property files
analyze -sva \
  ${PROP_PATH}/bindings.sva \
  ${PROP_PATH}/v_arith.sva
  
# Elaborate design and properties
elaborate -top arith

# Set up Clocks and Resets
clock pclk


reset ~presetn


# Get design information to check general complexity
get_design_info

# Prove properties
# 1st pass: Quick validation of properties with default engines
set_max_trace_length 10
prove -all
#
# 2nd pass: Validation of remaining properties with different engine
set_max_trace_length 80
set_prove_per_property_time_limit 30s
set_engine_mode {K I N} 
prove -all

# Report proof results
report -task . -csv -file report.csv

