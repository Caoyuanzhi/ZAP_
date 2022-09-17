`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;

`ifndef MAX_CLOCK_CYCLES
	`define MAX_CLOCK_CYCLES 20000
`endif
`ifndef SEED 
	`define SEED 1234
`endif
`ifndef REG_HIER
	`define REG_HIER u_chip_top.u_zap_top.u_zap_core.u_zap_writeback.u_zap_register_file
`endif


module top_tb;
    reg         o_sim_ok = 1'd0;
    reg         o_sim_err = 1'd0;

	reg	  		i_clk	;
	reg	  		i_reset	;

	reg         o_wb_stb;
    reg         o_wb_cyc;
    reg [31:0]  o_wb_adr;
    reg [3:0]   o_wb_sel;
    reg         o_wb_we	;
    reg [31:0]  o_wb_dat;
    reg [2:0]   o_wb_cti;
    
	reg         i_wb_ack;
    reg [31:0]  i_wb_dat;
    reg [7:0]   i_mem [65536-1:0]	;
    
	reg         UART_SR_DAV_0		;
    reg         UART_SR_DAV_1		;
    reg [7:0]   UART_SR_0			;
    reg [7:0]   UART_SR_1			;	

	parameter SIMULATION_TIME = 200000;	

	//CPU config
  	parameter RAM_SIZE                      = 32768;
  	parameter DATA_SECTION_TLB_ENTRIES      = 4;
  	parameter DATA_LPAGE_TLB_ENTRIES        = 8;
  	parameter DATA_SPAGE_TLB_ENTRIES        = 16; 
  	parameter DATA_FPAGE_TLB_ENTRIES        = 32; 
  	parameter DATA_CACHE_SIZE               = 256; //1024;
  	parameter CODE_SECTION_TLB_ENTRIES      = 4;
  	parameter CODE_LPAGE_TLB_ENTRIES        = 8;
  	parameter CODE_SPAGE_TLB_ENTRIES        = 16; 
  	parameter CODE_FPAGE_TLB_ENTRIES        = 32; 
  	parameter CODE_CACHE_SIZE               = 256; //1024
  	parameter FIFO_DEPTH                    = 4;
  	parameter BP_ENTRIES                    = 1024;
  	parameter STORE_BUFFER_DEPTH            = 32; 

	localparam STRING_LENGTH                = 12; 

	localparam UART_LO      				= 32'hFFFFFFE0;
	localparam UART_HI      				= 32'hFFFFFFFF;
	localparam TIMER_LO     				= 32'hFFFFFFC0;
	localparam TIMER_HI     				= 32'hFFFFFFDF;
	localparam VIC_LO       				= 32'hFFFFFFA0;
	localparam VIC_HI       				= 32'hFFFFFFBF;


	///////////////////////////////////////////////////////////////////////////////
	reg             i_clk;
	reg             i_reset;
	
	wire            data_wb_cyc; 
	reg             data_wb_cyc_ram, data_wb_cyc_uart, data_wb_cyc_timer, data_wb_cyc_vic;
	wire            data_wb_stb;
   	reg             data_wb_stb_ram, data_wb_stb_uart, data_wb_stb_timer, data_wb_stb_vic;
	reg  [31:0]     data_wb_din; 
	wire [31:0]     data_wb_din_ram, data_wb_din_uart, data_wb_din_timer, data_wb_din_vic;
	reg             data_wb_ack; 
	wire            data_wb_ack_ram, data_wb_ack_uart, data_wb_ack_timer, data_wb_ack_vic;
	
	wire [3:0]      data_wb_sel;
	wire            data_wb_we;
	wire [31:0]     data_wb_dout;
	wire [31:0]     data_wb_adr;
	wire [2:0]      data_wb_cti; // Cycle Type Indicator.
	
	wire            global_irq;

	reg [7:0]       mem [65536-1:0];
	///////////////////////////////////////////////////////////////////////////////
	//initial begin
	//	i_clk = 0;
	//	forever begin
	//		#100 i_clk = ~i_clk;
	//	end 
	//end 
	//
	//initial begin
	//	i_reset = 1'b0;
	//	#1000;
	//	i_reset = 1'b1;
	//	#5050;
	//	i_reset = 1'b0;
	//end 

	initial begin
      $fsdbDumpfile("tb.fsdb");
      $fsdbDumpvars;
  	end
  
  	initial begin
      $display("---------------SIMULATION START-----------------");
      #SIMULATION_TIME
      $display("---------------SIMULATION FINISH----------------");
      $finish;
  	end
	
	//`include "rtl_force.sv"
	reg [255:0] testname;
	final begin
		if($value$plusargs("TEST_NAME=%s",testname))begin
			$display("-----Run on TEST:%s",testname);	
		end
		//uvm_top.print_topology();
	end

	// Wishbone selector.
	always @*
	begin
	        data_wb_cyc_uart = 0;
	        data_wb_stb_uart = 0;
	        data_wb_cyc_ram  = 0;
	        data_wb_stb_ram  = 0;
	        data_wb_cyc_timer = 0;
	        data_wb_stb_timer = 0;
	        data_wb_cyc_vic = 0;
	        data_wb_stb_vic = 0;
	        if ( data_wb_adr >= UART_LO && data_wb_adr <= UART_HI ) // UART access
	        begin
	                data_wb_cyc_uart = data_wb_cyc;
	                data_wb_stb_uart = data_wb_stb;
	                data_wb_ack      = data_wb_ack_uart;
	                data_wb_din      = data_wb_din_uart; 
	        end
	        else if ( data_wb_adr >= TIMER_LO && data_wb_adr <= TIMER_HI )  // Timer access
	        begin
	                data_wb_cyc_timer = data_wb_cyc;
	                data_wb_stb_timer = data_wb_stb;
	                data_wb_ack       = data_wb_ack_timer;
	                data_wb_din       = data_wb_din_timer; 
	        end
	        else if ( data_wb_adr >= VIC_LO && data_wb_adr <= VIC_HI ) // VIC access.
	        begin
	                data_wb_cyc_vic   = data_wb_cyc;
	                data_wb_stb_vic   = data_wb_stb;
	                data_wb_ack       = data_wb_ack_vic;
	                data_wb_din       = data_wb_din_vic;                
	        end
	        else // RAM access
	        begin
	                data_wb_cyc_ram  = data_wb_cyc;
	                data_wb_stb_ram  = data_wb_stb;
	                data_wb_ack      = data_wb_ack_ram;
	                data_wb_din      = data_wb_din_ram; 
	        end
	end
//	initial begin
//    	$readmemh("/home/rlk/UVM_Practice/ZAP_test/compile_test_case/build/arm_test/arm_test.verilog", mem);
//		for (n=0; n<8; n=n+1)begin
//			$display("%h",mem[n]);
//		end 
//	end 

	initial
	begin
	        $display("################################################################################");
	        $display("SEED in decimal = %d", `SEED);
	        $display("parameter RAM_SIZE              %d", RAM_SIZE           ); 
	        //$display("parameter START                 %d", START              ); 
	        //$display("parameter COUNT                 %d", COUNT              ); 
	        $display("parameter FIFO_DEPTH            %d", u_zap_top.FIFO_DEPTH);
	        `ifdef STALL
	                $display("STALL defined!");
	        `endif
	        `ifdef TLB_DEBUG
	                $display("TLB_DEBUG defined!");
	        `endif
	        $display("parameter DATA_SECTION_TLB_ENTRIES      = %d", DATA_SECTION_TLB_ENTRIES    ) ;
	        $display("parameter DATA_LPAGE_TLB_ENTRIES        = %d", DATA_LPAGE_TLB_ENTRIES      ) ;
	        $display("parameter DATA_SPAGE_TLB_ENTRIES        = %d", DATA_SPAGE_TLB_ENTRIES      ) ;
	        $display("parameter DATA_CACHE_SIZE               = %d", DATA_CACHE_SIZE             ) ;
	        $display("parameter CODE_SECTION_TLB_ENTRIES      = %d", CODE_SECTION_TLB_ENTRIES    ) ;
	        $display("parameter CODE_LPAGE_TLB_ENTRIES        = %d", CODE_LPAGE_TLB_ENTRIES      ) ;
	        $display("parameter CODE_SPAGE_TLB_ENTRIES        = %d", CODE_SPAGE_TLB_ENTRIES      ) ;
	        $display("parameter CODE_CACHE_SIZE               = %d", CODE_CACHE_SIZE             ) ;
	        $display("parameter STORE_BUFFER_DEPTH            = %d", STORE_BUFFER_DEPTH          ) ;
	        $display("################################################################################");
	end
	

	//////////////////////////////////////////////////////////////////////////////////
	// =========================
	// Processor core.
	// =========================
	zap_top #(
	        // Configure FIFO depth and BP entries.
	        .FIFO_DEPTH(FIFO_DEPTH),
	        .BP_ENTRIES(BP_ENTRIES),
	        .STORE_BUFFER_DEPTH(STORE_BUFFER_DEPTH),
	        // data config.
	        .DATA_SECTION_TLB_ENTRIES(DATA_SECTION_TLB_ENTRIES),
	        .DATA_LPAGE_TLB_ENTRIES(DATA_LPAGE_TLB_ENTRIES),
	        .DATA_SPAGE_TLB_ENTRIES(DATA_SPAGE_TLB_ENTRIES),
	        .DATA_CACHE_SIZE(DATA_CACHE_SIZE),
	        // code config.
	        .CODE_SECTION_TLB_ENTRIES(CODE_SECTION_TLB_ENTRIES),
	        .CODE_LPAGE_TLB_ENTRIES(CODE_LPAGE_TLB_ENTRIES),
	        .CODE_SPAGE_TLB_ENTRIES(CODE_SPAGE_TLB_ENTRIES),
	        .CODE_CACHE_SIZE(CODE_CACHE_SIZE)
	) 
	u_zap_top 
	(
	        .i_clk(i_clk),
	        .i_reset(i_reset),
	        .i_irq(global_irq),
	        .i_fiq(1'd0),
	        .o_wb_cyc(data_wb_cyc),
	        .o_wb_stb(data_wb_stb),
	        .o_wb_adr(data_wb_adr),
	        .o_wb_we (data_wb_we),
	        .o_wb_cti(data_wb_cti),
	        .i_wb_dat(data_wb_din),
	        .o_wb_dat(data_wb_dout),
	        .i_wb_ack(data_wb_ack),
	        .o_wb_sel(data_wb_sel),
	        .o_wb_bte()             // Always zero.
	);

	// ===============================
	// UART
	// ===============================
	
	wire uart_in = 1'd0;
	wire uart_out;
	wire uart_irq;
	
	uart_top u_uart_top (
	
	        // WISHBONE interface
	        .wb_clk_i(i_clk),
	        .wb_rst_i(i_reset),
	        .wb_adr_i(data_wb_adr),
	        .wb_dat_i(data_wb_dout),
	        .wb_dat_o(data_wb_din_uart),
	        .wb_we_i (data_wb_we),
	        .wb_stb_i(data_wb_stb_uart),
	        .wb_cyc_i(data_wb_cyc_uart),
	        .wb_sel_i(data_wb_sel),
	        .wb_ack_o(data_wb_ack_uart),
	        .int_o   (uart_irq), // Interrupt.
	        
	        // UART signals.
	        .srx_pad_i(uart_in),
	        .stx_pad_o(uart_out),
	        .rts_pad_o(),
	        .cts_pad_i(1'd0),
	        .dtr_pad_o(),
	        .dsr_pad_i(1'd0),
	        .ri_pad_i (1'd0),
	        .dcd_pad_i(1'd0)
	);

	// ===============================
	// Timer
	// ===============================
	
	wire timer_irq;
	timer u_timer (
	        .i_clk(i_clk),
	        .i_rst(i_reset),
	        .i_wb_adr(data_wb_adr),
	        .i_wb_dat(data_wb_dout),
	        .i_wb_stb(data_wb_stb_timer),
	        .i_wb_cyc(data_wb_cyc_timer),   // From core
	        .i_wb_wen(data_wb_we),
	        .i_wb_sel(data_wb_sel),
	        .o_wb_dat(data_wb_din_timer),   // To core.
	        .o_wb_ack(data_wb_ack_timer),
	        .o_irq(timer_irq)               // Interrupt
	);

	// ===============================
	// VIC
	// ===============================
	vic #(.SOURCES(2)) u_vic (
	        .i_clk(i_clk),
	        .i_rst(i_reset),
	        .i_wb_adr(data_wb_adr),
	        .i_wb_dat(data_wb_dout),
	        .i_wb_stb(data_wb_stb_vic),
	        .i_wb_cyc(data_wb_cyc_vic), // From core
	        .i_wb_wen(data_wb_we),
	        .i_wb_sel(data_wb_sel),
	        .o_wb_dat(data_wb_din_vic), // To core.
	        .o_wb_ack(data_wb_ack_vic),
	
	        .i_irq({timer_irq, uart_irq}), // Concatenate interrupt sources.
	        .o_irq(global_irq)             // Interrupt out
	);
	///////////////////////////////////////////////////////////////////////////////
	reg [3:0] clk_ctr = 4'd0;
	// Logic to read from UART - Assumes no parity, 8 bits per character and
	// 1 stop bit. TB logic.
	localparam UART_WAIT_FOR_START = 0;
	localparam UART_RX             = 1;
	localparam UART_STOP_BIT       = 2;
	
	integer uart_state = UART_WAIT_FOR_START;
	reg uart_sof = 1'd0;
	reg uart_eof = 1'd0;
	integer uart_ctr = 0;
	integer uart_bit_ctr = 1'dx;
	reg [7:0] uart_sr = 0;
	reg [7:0] UART_SR;
	reg       UART_SR_DAV;
	
	always @ (posedge i_clk)
	begin
	        UART_SR_DAV = 1'd0;
	        uart_sof = 1'd0;
	        uart_eof = 1'd0;
	        case ( uart_state ) 
	                UART_WAIT_FOR_START:
	                begin
	                        if ( !uart_out ) 
	                        begin
	                                uart_ctr = uart_ctr + 1;
	                                uart_sof = 1'd1;
	                        end
	                        if ( !uart_out && uart_ctr == 16  ) 
	                        begin
	                                uart_sof     = 1'd0;
	                                uart_state   = UART_RX;
	                                uart_ctr     = 0;
	                                uart_bit_ctr = 0;
	                        end                        
	                end
	                UART_RX:
	                begin
	                        uart_ctr++;
	
	                        if ( uart_ctr == 2 ) 
	                                uart_sr = uart_sr >> 1 | uart_out << 7;                                
	
	                        if ( uart_ctr == 16 ) 
	                        begin
	                                uart_bit_ctr++;
	                                uart_ctr = 0;
	                                if ( uart_bit_ctr == 8 ) 
	                                begin
	                                        uart_state  = UART_STOP_BIT;                               
	                                        UART_SR     = uart_sr;
	                                        UART_SR_DAV = 1'd1;
	                                        uart_ctr    = 0;
	                                        uart_bit_ctr = 0;
	                                end
	                        end                        
	                end
	
	                UART_STOP_BIT:
	                begin
	                        uart_ctr++;
	                        if ( uart_out && uart_ctr == 16 ) // Stop bit.
	                        begin
	                                uart_state = UART_WAIT_FOR_START;                                
	                                uart_bit_ctr = 0;
	                                uart_ctr = 0;
	                        end
	                end
	        endcase
	end
	
	//// Write ASCII characters on UART TX to a file.
	//integer signed fh;
	//initial
	//begin
	//        fh = $fopen(`UART_FILE_PATH, "w");
	//        if ( fh == -1 ) 
	//        begin
	//                $display($time, " - Error: Failed to open UART output log.");
	//                $finish;
	//        end
	//        else    
	//        begin
	//                $display($time, " - File opened %s!", `UART_FILE_PATH);
	//        end
	//end
	//
	//always @ (negedge i_clk)
	//begin
	//        if ( UART_SR_DAV )
	//        begin
	//                $display("UART Wrote %c", UART_SR);
	//                $fwrite(fh, "%c", UART_SR);
	//                $fflush(fh);
	//        end
	//end

	model_ram_dual
	#(
	        .SIZE_IN_BYTES  (RAM_SIZE)
	)
	U_MODEL_RAM_DATA
	(
	        .i_clk(i_clk),
	
	        .i_wb_cyc(data_wb_cyc_ram),
	        .i_wb_stb(data_wb_stb_ram),
	        .i_wb_adr(data_wb_adr),
	        .i_wb_we(data_wb_we),
	        .o_wb_dat(data_wb_din_ram),
	        .i_wb_dat(data_wb_dout),
	        .o_wb_ack(data_wb_ack_ram),
	        .i_wb_sel(data_wb_sel),
	
	        // Port 2 is unused.
	        .i_wb_cyc2(0),
	        .i_wb_stb2(0),
	        .i_wb_adr2(0),
	        .i_wb_we2 (0),
	        .o_wb_dat2(),
	        .o_wb_ack2(),
	        .i_wb_sel2(0),
	        .i_wb_dat2(0)
	);


// ===========================
// Variables.
// ===========================
integer i;

// ===========================
// Clocks.
// ===========================
initial         i_clk    = 0;
always #10      i_clk = !i_clk;

integer seed = `SEED;
integer seed_new = `SEED + 1;

// ===========================
// Interrupts
// ===========================

initial i_reset = 1'd0;

initial
begin
        //for(i=START;i<START+COUNT;i=i+4)
        //begin
        //        $display("DATA INITIAL :: mem[%d] = %x", i, {U_MODEL_RAM_DATA.ram[(i/4)]});
        //end

        //$dumpvars;
        //$display($time," - Applying reset...");

        @(posedge i_clk);
        i_reset <= 1;
        @(posedge i_clk);
        i_reset <= 0;
        //$display($time, " - Running for %d clock cycles...", `MAX_CLOCK_CYCLES);
        //repeat(`MAX_CLOCK_CYCLES) 
        //        @(negedge i_clk);
        //$display($time, " - Clock cycles elapsed. Generating memory data.");

        //$display(">>>>>>>>>>>>>>>>>>>>>>> MEMORY DUMP START <<<<<<<<<<<<<<<<<<<<<<<");

        //for(i=START;i<START+COUNT;i=i+4)
        //begin
        //        $display("DATA mem[%d] = %x", i, {U_MODEL_RAM_DATA.ram[(i/4)]});
        //end
        //$display("<<<<<<<<<<<<<<<<<<<<<<< MEMORY DUMP END >>>>>>>>>>>>>>>>>>>>>>>>>>");
        //$fclose(fh);
        //`include "zap_check.vh"                
end

endmodule


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module timer #(

        // Register addresses.
        parameter       [31:0]  TIMER_ENABLE_REGISTER = 32'h0,
        parameter       [31:0]  TIMER_LIMIT_REGISTER  = 32'h4,
        parameter       [31:0]  TIMER_INTACK_REGISTER = 32'h8,
        parameter       [31:0]  TIMER_START_REGISTER  = 32'hC

) (

// Clock and reset.
input wire                  i_clk,
input wire                  i_rst,

// Wishbone interface.
input wire  [31:0]          i_wb_dat,
input wire   [3:0]          i_wb_adr,
input wire                  i_wb_stb,
input wire                  i_wb_cyc,
input wire                  i_wb_wen,
input wire  [3:0]           i_wb_sel,
output reg [31:0]           o_wb_dat,
output reg                  o_wb_ack,


// Interrupt output. Level interrupt.
output  reg                 o_irq

);

// Timer registers.
reg [31:0] DEVEN;  
reg [31:0] DEVPR;  
reg [31:0] DEVAK;  
reg [31:0] DEVST;  

`define DEVEN TIMER_ENABLE_REGISTER
`define DEVPR TIMER_LIMIT_REGISTER
`define DEVAK TIMER_INTACK_REGISTER
`define DEVST TIMER_START_REGISTER

// Timer core.
reg [31:0] ctr;         // Core counter.
reg        start;       // Pulse to start the timer. Done signal is cleared.
reg        done;        // Asserted when timer is done.
reg        clr;         // Clears the done signal.
reg [31:0] state;       // State
reg        enable;      // 1 to enable the timer.
reg [31:0] finalval;    // Final value to count.
reg [31:0] wbstate;

localparam IDLE         = 0;
localparam COUNTING     = 1;
localparam DONE         = 2;

localparam WBIDLE       = 0;
localparam WBREAD       = 1;
localparam WBWRITE      = 2;
localparam WBACK        = 3;
localparam WBDONE       = 4;

always @ (*)
        o_irq    = done;

always @ (*)
begin
        start    = DEVST[0];
        enable   = DEVEN[0];
        finalval = DEVPR;
        clr      = DEVAK[0];
end

always @ ( posedge i_clk )
begin
        DEVST <= 0;

        if ( i_rst )
        begin
                DEVEN <= 0;
                DEVPR <= 0;
                DEVAK <= 0;
                DEVST <= 0;
                wbstate  <= WBIDLE;
                o_wb_dat <= 0;
                o_wb_ack <= 0;
        end
        else
        begin
                case(wbstate)
                        WBIDLE:
                        begin
                                o_wb_ack <= 1'd0;

                                if ( i_wb_stb && i_wb_cyc ) 
                                begin
                                        if ( i_wb_wen ) 
                                                wbstate <= WBWRITE;
                                        else
                                                wbstate <= WBREAD;
                                end
                        end

                        WBWRITE:
                        begin
                                case(i_wb_adr)
                                `DEVEN: // DEVEN
                                begin
                                        if ( i_wb_sel[0] ) DEVEN[7:0]   <= i_wb_dat >> 0; 
                                        if ( i_wb_sel[1] ) DEVEN[15:8]  <= i_wb_dat >> 8; 
                                        if ( i_wb_sel[2] ) DEVEN[23:16] <= i_wb_dat >> 16; 
                                        if ( i_wb_sel[3] ) DEVEN[31:24] <= i_wb_dat >> 24; 
                                end

                                `DEVPR: // DEVPR
                                begin
                                        if ( i_wb_sel[0] ) DEVPR[7:0]   <= i_wb_dat >> 0; 
                                        if ( i_wb_sel[1] ) DEVPR[15:8]  <= i_wb_dat >> 8; 
                                        if ( i_wb_sel[2] ) DEVPR[23:16] <= i_wb_dat >> 16; 
                                        if ( i_wb_sel[3] ) DEVPR[31:24] <= i_wb_dat >> 24;      
                                        
                                end 

                                `DEVAK: // DEVAK
                                begin
                                        if ( i_wb_sel[0] ) DEVPR[7:0]   <= i_wb_dat >> 0; 
                                        if ( i_wb_sel[1] ) DEVPR[15:8]  <= i_wb_dat >> 8; 
                                        if ( i_wb_sel[2] ) DEVPR[23:16] <= i_wb_dat >> 16; 
                                        if ( i_wb_sel[3] ) DEVPR[31:24] <= i_wb_dat >> 24;   
                                end

                                `DEVST: // DEVST
                                begin
                                        if ( i_wb_sel[0] ) DEVST[7:0]   <= i_wb_dat >> 0; 
                                        if ( i_wb_sel[1] ) DEVST[15:8]  <= i_wb_dat >> 8; 
                                        if ( i_wb_sel[2] ) DEVST[23:16] <= i_wb_dat >> 16; 
                                        if ( i_wb_sel[3] ) DEVST[31:24] <= i_wb_dat >> 24;    
                                end

                                default:
                                begin
                                        $display($time, " Error : Illegal register write in %m.");
                                        $finish;
                                end

                                endcase

                                wbstate <= WBACK;
                        end

                        WBREAD:
                        begin
                                case(i_wb_adr)
                                `DEVEN: o_wb_dat <= DEVEN;
                                `DEVPR: o_wb_dat <= DEVPR;
                                `DEVAK: o_wb_dat <= done;
                                `DEVST: o_wb_dat <= 32'd0;
                               default: 
                                        begin
                                                $display($time, " Error : Illegal register read in %m.");
                                                $finish;
                                        end
                                endcase

                                wbstate <= WBACK;
                        end

                        WBACK:
                        begin
                                o_wb_ack   <= 1'd1;
                                wbstate    <= WBDONE;
                        end

                        WBDONE:
                        begin
                                o_wb_ack  <= 1'd0;
                                wbstate   <= IDLE;
                        end
                endcase                
        end
end

always @ (posedge i_clk)
begin
        if ( i_rst || !enable ) 
        begin
                ctr     <= 0;
                done    <= 0;
                state   <= IDLE;
        end     
        else // if enabled
        begin
                case(state)
                IDLE:
                begin
                        if ( start ) 
                        begin
                                state <= COUNTING;
                        end
                end

                COUNTING:
                begin
                        ctr <= ctr + 1;

                        if ( ctr == finalval ) 
                        begin
                                state <= DONE;
                        end                                
                end

                DONE:
                begin
                        done <= 1;

                        if ( start ) 
                        begin
                                done  <= 0;
                                state <= COUNTING;
                                ctr   <= 0;
                        end
                        else if ( clr ) // Acknowledge. 
                        begin
                                done  <= 0;
                                state <= IDLE;
                                ctr   <= 0;
                        end
                end
                endcase
        end
end

endmodule


//                                                                            
// A simple interrupt controller.                                             
//                                                                            
// Registers:                                                                 
// 0x0 - INT_STATUS - Interrupt status as reported by peripherals (sticky).   
// 0x4 - INT_MASK   - Interrupt mask - setting a bit to 1 masks the interrupt 
// 0x8 - INT_CLEAR  - Write 1 to a particular bit to clear the interrupt      
//                    status.                                                 

module vic #(
        parameter [31:0]        SOURCES                    = 32'd4,
        parameter [31:0]        INTERRUPT_PENDING_REGISTER = 32'h0,
        parameter [31:0]        INTERRUPT_MASK_REGISTER    = 32'h4,
        parameter [31:0]        INTERRUPT_CLEAR_REGISTER   = 32'h8
) (

// Clock and reset.
input  wire                 i_clk,
input  wire                 i_rst,

// Wishbone interface.
input  wire  [31:0]          i_wb_dat,
input  wire   [3:0]          i_wb_adr,
input  wire                  i_wb_stb,
input  wire                  i_wb_cyc,
input  wire                  i_wb_wen,
input  wire  [3:0]           i_wb_sel,
output reg  [31:0]           o_wb_dat,
output reg                   o_wb_ack,

// Interrupt sources in. Concatenate all
// sources together.
input wire   [SOURCES-1:0]       i_irq,

// Interrupt output. Level interrupt.
output  reg                  o_irq


);

`ifndef ZAP_SOC_VIC
`define ZAP_SOC_VIC
        `define INT_STATUS INTERRUPT_PENDING_REGISTER
        `define INT_MASK   INTERRUPT_MASK_REGISTER
        `define INT_CLEAR  INTERRUPT_CLEAR_REGISTER
`endif

reg [31:0] INT_STATUS;
reg [31:0] INT_MASK;
reg [31:0] wbstate;

// Wishbone states.
localparam WBIDLE       = 0;
localparam WBREAD       = 1;
localparam WBWRITE      = 2;
localparam WBACK        = 3;
localparam WBDONE       = 4;

// Send out a global interrupt signal.
always @ (posedge i_clk)
begin
        o_irq <= | ( INT_STATUS & ~INT_MASK );
end

// Wishbone access FSM
always @ ( posedge i_clk )
begin
        if ( i_rst )
        begin
                wbstate         <= WBIDLE;
                o_wb_dat        <= 0;
                o_wb_ack        <= 0;
                INT_MASK        <= 32'hffffffff;
                INT_STATUS      <= 32'h0;
        end
        else
        begin:blk1
                integer i;

                // Normally record interrupts. These are sticky bits.
                for(i=0;i<SOURCES;i=i+1)
                        INT_STATUS[i] <= INT_STATUS[i] == 0 ? i_irq[i] : 1'd1;

                case(wbstate)
                        WBIDLE:
                        begin
                                o_wb_ack <= 1'd0;

                                if ( i_wb_stb && i_wb_cyc ) 
                                begin
                                        if ( i_wb_wen ) 
                                                wbstate <= WBWRITE;
                                        else
                                                wbstate <= WBREAD;
                                end
                        end

                        WBWRITE:
                        begin
                                case(i_wb_adr)

                                `INT_MASK: // INT_MASK
                                begin
                                        if ( i_wb_sel[0] ) INT_MASK[7:0]   <= i_wb_dat >> 0; 
                                        if ( i_wb_sel[1] ) INT_MASK[15:8]  <= i_wb_dat >> 8; 
                                        if ( i_wb_sel[2] ) INT_MASK[23:16] <= i_wb_dat >> 16; 
                                        if ( i_wb_sel[3] ) INT_MASK[31:24] <= i_wb_dat >> 24;      
                                        
                                end 

                                `INT_CLEAR: // INT_CLEAR
                                begin: blk22
                                        integer i;

                                        if ( i_wb_sel[0] ) for(i=0; i <=7;i=i+1) if ( i_wb_dat[i] ) INT_STATUS[i] <= 1'd0; 
                                        if ( i_wb_sel[1] ) for(i=8; i<=15;i=i+1) if ( i_wb_dat[i] ) INT_STATUS[i] <= 1'd0; 
                                        if ( i_wb_sel[2] ) for(i=16;i<=23;i=i+1) if ( i_wb_dat[i] ) INT_STATUS[i] <= 1'd0; 
                                        if ( i_wb_sel[3] ) for(i=24;i<=31;i=i+1) if ( i_wb_dat[i] ) INT_STATUS[i] <= 1'd0; 
                                end

                                default: 
                                begin
                                        $display($time, " Error : Attemting to write to illegal register in %m");
                                        $finish;
                                end

                                endcase

                                wbstate <= WBACK;
                        end

                        WBREAD:
                        begin
                                case(i_wb_adr)
                                `INT_STATUS:            o_wb_dat <= `INT_STATUS;
                                `INT_MASK:              o_wb_dat <= `INT_MASK;

                                default:                
                                begin
                                        $display($time, " Error : Attempting to read from illegal register in %m.");
                                        $finish;
                                end
                                endcase

                                wbstate <= WBACK;
                        end

                        WBACK:
                        begin
                                o_wb_ack   <= 1'd1;
                                wbstate    <= WBDONE;
                        end

                        WBDONE:
                        begin
                                o_wb_ack   <= 1'd0;
                                wbstate    <= WBIDLE;
                        end
                endcase                
        end
end

endmodule // vic










