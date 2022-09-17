`ifndef __MY_TRAN__
`define __MY_TRAN__

class my_transcation extends uvm_sequence_item;
	rand bit[47:0]	dest_mac	;
	rand bit[47:0]	src_mac		;
	rand bit[15:0]	ether_type	;
	rand byte		payload[]	;
	rand bit[31:0]	crc 		;

	constraint payload_cons{
			payload.size >= 46	;
			payload.size <= 1500;
	}

	function bit[31:0] cal_crc();
		return 32'h0;
	endfunction

	function void post_randomize();
		crc = cal_crc();
	endfunction 

	`uvm_object_utils(my_transcation)

	function new(string name = "my_transcation");
		super.new(name);
	endfunction 

	function void my_print();
        $display("dest_mac = %0h", dest_mac);
        $display("src_mac = %0h", src_mac);
        $display("ether_type = %0h", ether_type);
        for(int i = 0; i < payload.size; i++) begin
        	$display("payload[%0d] = %0h", i, payload[i]);
        end
        $display("crc = %0h", crc);
    endfunction

endclass 
`endif
