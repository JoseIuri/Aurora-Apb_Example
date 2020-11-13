package arith_pkg;
    `include "uvm_macros.svh"
    import uvm_pkg::*;
    

	`include "../../tb/apb_transaction.sv"
    `include "../../tb/apb_coverage.sv"
	`include "../../tb/apb_driver.sv"
	`include "../../tb/arithRefmod_refmod.sv"
	`include "../../tb/arith_scoreboard.sv"
	`include "../../tb/apb_monitor.sv"
	`include "../../tb/apb_agent.sv"
	`include "../../tb/arith_env.sv"
	`include "../../tb/apbSequence_sequence.sv"
	`include "../../tb/apbTest_test.sv"
	
endpackage