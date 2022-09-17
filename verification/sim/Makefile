RTL_FILES   =   $(wildcard $(PROJECT_ROOT)/rtl/*.v)
SV_FILES    =   $(wildcard $(PROJECT_ROOT)/verification/env/*.sv)
SV_FILES    +=  $(wildcard $(PROJECT_ROOT)/verification/harness/*.sv)

USER_MODE   = $(strip $(mode))
ifneq ($(USER_MODE),pre_sim)
	MODE = $(USER_MODE) 
else
	MODE = pre_sim
endif

TC 			=   $(strip $(tc))
SEED        =   $(strip $(seed))



OUTPUT_PATH = ./$(MODE)
LOG_DIR     = $(OUTPUT_PATH)/log


#--------------------------------------------------------------------------------------------
.PHONY: all run compile sim verdi clean regone 
#--------------------------------------------------------------------------------------------
all: run
#--------------------------------------------------------------------------------------------
compile: run
#--------------------------------------------------------------------------------------------
regone: sim
#--------------------------------------------------------------------------------------------

run:
	mkdir -p ./$(MODE)
	vcs  \
		+incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm.sv\
		$(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS \
		+incdir+$(PROJECT_ROOT)/rtl\
		+incdir+$(PROJECT_ROOT)/rtl/uart16550/rtl\
		+incdir+$(PROJECT_ROOT)/verification/harness\
		+incdir+$(PROJECT_ROOT)/compile_test_case/build/arm_test\
        -f file_list.f\
        -timescale=1ns/1ns\
        -fsdb  -full64  -R  +vc  +v2k  -sverilog\
		+UVM_TESTNAME=$(TC)\
		+UVM_VWRBOSITY=UVM_MEDIUM\
		+plusarg_save\
		-LDFLAGS -Wl,--no-as-needed\
        -P ${LD_LIBRARY_PATH}/novas.tab  ${LD_LIBRARY_PATH}/pli.a\
        |tee vcs.log  
	./simv  -l sim.log 
#--------------------------------------------------------------------------------------------
sim	:
	./simv -l sim.log

#--------------------------------------------------------------------------------------------

verdi  :
	verdi -sv -f file_list.f -ssf tb.fsdb &
#--------------------------------------------------------------------------------------------
clean  :
	rm  -rf  *~  core  csrc  simv*  vc_hdrs.h  ucli.key  urg* *.log  novas.* *.fsdb* verdiLog  64* DVEfiles *.vpd
#--------------------------------------------------------------------------------------------




