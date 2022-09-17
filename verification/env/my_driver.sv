`ifndef __MY_DRIVER__
`define __MY_DRIVER__
class my_driver extends uvm_driver;
	//factory:
	`uvm_component_utils(my_driver)
	
	virtual my_if vif;

	function new(string name = "my_driver", uvm_component parent = null);
		super.new(name, parent);
		`uvm_info("my_driver","new_function is called",UVM_HIGH)
	endfunction
		
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("my_driver","build_phase is called",UVM_HIGH)
		if(!uvm_config_db#(virtual my_if)::get(this,"","vif",vif))
			`uvm_fatal("my_driver","virtual interface is not set for vif !")
	endfunction

	extern virtual task main_phase(uvm_phase phase);
	extern task drive_one_pkt(my_transcation tr);

endclass



task my_driver::main_phase(uvm_phase phase);	
	my_transcation tr;
	phase.raise_objection(this);
	`uvm_info("my_driver","main_phase is called",UVM_HIGH)

	vif.data  <= 8'b0;
	vif.valid <= 1'b0;
	while(!vif.rst_n)
		@(posedge vif.clk);
	for(int i = 0; i < 5; i++)begin
		tr = new("tr");
		assert(tr.randomize() with {payload.size == 200 ;});
		drive_one_pkt(tr);
	end 	
		
	repeat(5) @(posedge vif.clk);
	phase.drop_objection(this);
endtask

task my_driver::drive_one_pkt(my_transcation tr);
	bit [47:0] 	tmp_data ;
	bit [7:0]	data_q[$];
	
	tmp_data = tr.dest_mac;
	for(int i = 0; i < 6; i++)begin
		data_q.push_back(tmp_data[7:0]);
		tmp_data = (tmp_data >> 8);
	end	
	
	tmp_data = tr.src_mac;
	for(int i = 0; i < 6; i++)begin
		data_q.push_back(tmp_data[7:0]);
		tmp_data = (tmp_data >> 8);
	end	

	tmp_data = tr.ether_type;
	for(int i = 0; i < 2; i++)begin
		data_q.push_back(tmp_data[7:0]);
		tmp_data = (tmp_data >> 8);
	end	

	for(int i = 0; i < tr.payload.size; i++)begin
		data_q.push_back(tr.payload[i]);
	end

	tmp_data = tr.crc;
	for(int i = 0; i < 4; i++)begin
		data_q.push_back(tmp_data[7:0]);
		tmp_data = (tmp_data >> 8);
	end	
	
	`uvm_info("my_driver", "--begin to drive one pkt", UVM_LOW)
	
	while(data_q.size() > 0)begin
		@(posedge vif.clk);
		vif.valid <= 1'b1;
		vif.data  <= data_q.pop_front();
		//`uvm_info("my_driver", $sformatf("rxd = %h",vif.data), UVM_HIGH)
	end 

	@(posedge vif.clk);
	vif.valid <= 1'b0;
	`uvm_info("my_driver", "--end drive one pkt", UVM_LOW)

endtask 
`endif
