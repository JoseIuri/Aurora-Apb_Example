/**
  ******************************************************************************
  * File automatic generated by XGeneratorTB software
  ******************************************************************************
**/
class apb_coverage extends uvm_component;

  `uvm_component_utils(apb_coverage)

  apb_transaction tr;

  uvm_analysis_imp#(apb_transaction, apb_coverage) collected_port;

  function new(string name = "apb_coverage", uvm_component parent= null);
    super.new(name, parent);
    collected_port = new("collected_port", this);
    tr=new;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase (phase);
  endfunction

  protected uvm_phase running_phase;
  task run_phase(uvm_phase phase);
    running_phase = phase;
    running_phase.raise_objection(this);
    running_phase.raise_objection(this);
  endtask: run_phase


  function void write(apb_transaction t);
    tr.copy(t);
  endfunction: write
endclass : apb_coverage
