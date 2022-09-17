`ifndef __MY_MONITOR__
`define __MY_MONITOR__
class my_monitor extends uvm_monitor;
	//factory:
	`uvm_component_utils(my_monitor)
	
	virtual my_if vif;

	function new(string name = "my_monitor", uvm_component parent = null);
		super.new(name, parent);
		`uvm_info("my_monitor","new_function is called",UVM_HIGH)
	endfunction
		
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("my_monitor","build_phase is called",UVM_HIGH)
		if(!uvm_config_db#(virtual my_if)::get(this,"","vif",vif))
			`uvm_fatal("my_monitor","virtual interface is not set for vif !")
	endfunction

	extern virtual task main_phase(uvm_phase phase);
	extern task collect_one_pkt(my_transcation tr);

endclass



task my_monitor::main_phase(uvm_phase phase);	
	my_transcation tr;
	//phase.raise_objection(this);
	`uvm_info("my_monitor","main_phase is called",UVM_HIGH)
	while(1) begin
		tr = new("tr");
		collect_one_pkt(tr);
	end 
	//phase.drop_objection(this);
endtask

task my_monitor::collect_one_pkt(my_transcation tr);
   bit[7:0] data_q[$]; 
   int psize;
   while(1) begin
      @(posedge vif.clk);
      if(vif.valid) break;
   end

   `uvm_info("my_monitor", "begin to collect one pkt", UVM_LOW);
   while(vif.valid) begin
      data_q.push_back(vif.data);
      @(posedge vif.clk);
   end
   //pop dmac
   for(int i = 0; i < 6; i++) begin
      tr.dest_mac = {tr.dest_mac[39:0], data_q.pop_front()};
   end
   //pop smac
   for(int i = 0; i < 6; i++) begin
      tr.src_mac = {tr.src_mac[39:0], data_q.pop_front()};
   end
   //pop ether_type
   for(int i = 0; i < 2; i++) begin
      tr.ether_type = {tr.ether_type[7:0], data_q.pop_front()};
   end

   psize = data_q.size() - 4;
   tr.payload = new[psize];
   //pop payload
   for(int i = 0; i < psize; i++) begin
      tr.payload[i] = data_q.pop_front();
   end
   //pop crc
   for(int i = 0; i < 4; i++) begin
      tr.crc = {tr.crc[23:0], data_q.pop_front()};
   end
   `uvm_info("my_monitor", "end collect one pkt, print it:", UVM_LOW);
    tr.my_print();

endtask 
`endif
