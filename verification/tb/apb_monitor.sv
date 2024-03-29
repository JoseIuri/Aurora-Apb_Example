/**
  ******************************************************************************
  * File automatic generated by XGeneratorTB software
  ******************************************************************************
**/
class apb_monitor extends uvm_monitor;

    // Attributes
    virtual apb_interface apb_if_vif;
    uvm_analysis_port #(apb_transaction) req;
    uvm_analysis_port #(apb_transaction) resp;
    string                              tID;

    protected apb_transaction transCollected;

    `uvm_component_utils_begin(apb_monitor)
    `uvm_component_utils_end

    ////////////////////////////////////////////////////////////////////////////////
    // Implementation
    //------------------------------------------------------------------------------
    function new(string name="apb_monitor", uvm_component parent=null);
        super.new(name, parent);
        this.transCollected = apb_transaction::type_id::create("transCollected");

        this.tID = get_type_name();
        this.req = new("req", this);
        this.resp = new("resp", this);
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(tID, $sformatf("build_phase begin ..."), UVM_HIGH)
        if (!(uvm_config_db#(virtual apb_interface)::get(this, "", "VIRTUAL_IF", apb_if_vif))) begin
            `uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".apb_if_vif"})
        end
    endfunction : build_phase

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        this.CollectTransactions(phase); // collector task
    endtask: run_phase

    task CollectTransactions(uvm_phase phase);
        @(posedge apb_if_vif.presetn);
        forever begin

            this.BusToTransaction();
            if (transCollected.rw) begin
                this.resp.write(transCollected);
                this.req.write(transCollected);
            end
            else
                this.req.write(transCollected);

        end
    endtask : CollectTransactions

    task BusToTransaction();
        @(posedge apb_if_vif.pclk);

        if (apb_if_vif.psel & apb_if_vif.penable & apb_if_vif.presetn) begin
            
            
            wait (apb_if_vif.pready == 1'b1);
            transCollected.addr = apb_if_vif.paddr;
            transCollected.slverr = apb_if_vif.pslverr;

            if (apb_if_vif.pwrite)
                transCollected.data = apb_if_vif.pwdata;
            else
                transCollected.data = apb_if_vif.prdata;

            transCollected.rw = ~apb_if_vif.pwrite;
        end 
        
    endtask : BusToTransaction

endclass: apb_monitor
