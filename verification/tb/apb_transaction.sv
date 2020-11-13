/**
  ******************************************************************************
  * File automatic generated by XGeneratorTB software
  ******************************************************************************
**/
class apb_transaction extends uvm_sequence_item;

    rand logic[31:0] data;
	rand logic[31:0] addr;
	rand logic rw;
	logic slverr;

    constraint addr_1_range { addr >= 'd0; 
                              addr <= 'd23;}

    `uvm_object_utils_begin(apb_transaction)
        `uvm_field_int(data, UVM_ALL_ON|UVM_HEX)
		`uvm_field_int(addr, UVM_ALL_ON|UVM_HEX)
		`uvm_field_int(rw, UVM_ALL_ON|UVM_HEX)
		`uvm_field_int(slverr, UVM_ALL_ON|UVM_HEX)
		
    `uvm_object_utils_end

    function new(string name="apb_transaction");
        super.new(name);
    endfunction: new

    function string convert2string();
        return $sformatf("{ data: %h, addr %h, rw %h, slverr %h}", data, addr, rw, slverr);
    endfunction

endclass: apb_transaction
