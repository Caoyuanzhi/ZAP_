.PHONY: test clean elf 

PWD          := $(shell pwd)
TC 		     := arm_test
TAG          := archlinux/zap
SHELL        := /bin/bash -o pipefail
ARCH         := armv5te
C_FILES      := $(wildcard $(TC)/*.c)
S_FILES      := $(wildcard $(TC)/*.s)
H_FILES      := $(wildcard $(TC)/*.h)
LD_FILE      := $(wildcard $(TC)/*.ld)
CFLAGS       := -c -msoft-float -mfloat-abi=soft -march=$(ARCH) -g 
SFLAGS       := -march=$(ARCH) -g
LFLAGS       := -T
OFLAGS       := -O binary
CC           := arm-none-eabi-gcc
AS           := arm-none-eabi-as
LD           := arm-none-eabi-ld
OB           := arm-none-eabi-objcopy
DP           := arm-none-eabi-objdump
CPU_FILES    := $(wildcard rtl/*)
#SYN_SCRIPTS  := $(wildcard src/syn/*)
#TB_FILES     := $(wildcard src/testbench/*)
#SCRIPT_FILES := $(wildcard scripts/*)
#TEST         := $(shell find * -type d -exec basename {} \; | xargs echo)
#DLOAD        := "FROM archlinux:latest\nRUN  pacman -Syyu --noconfirm arm-none-eabi-gcc arm-none-eabi-binutils gcc \
                 make perl verilator"

clean:
	rm -rf build
	mkdir -p build/$(TC)
########################### User Accessible Targets #########################################
# Thanks to Erez Binyamin for Docker support patches.
.DEFAULT_GOAL = test
# Compile S files to OBJ.A
build/$(TC)/a.o: $(S_FILES)
	$(AS) $(SFLAGS) $(S_FILES) -o build/$(TC)/a.o
# Compile C files to OBJ.C
build/$(TC)/c.o: $(C_FILES) $(H_FILES)
	$(CC) $(CFLAGS) $(C_FILES) -o build/$(TC)/c.o
# Rule to convert the object files to an ELF file.
build/$(TC)/$(TC).elf: $(LD_FILE) build/$(TC)/a.o build/$(TC)/c.o
	$(LD) $(LFLAGS) $(LD_FILE) build/$(TC)/a.o build/$(TC)/c.o -o build/$(TC)/$(TC).elf
	$(DP) -d build/$(TC)/$(TC).elf > build/$(TC)/$(TC).dump

# Rule to generate a BIN file.
build/$(TC)/$(TC).bin: build/$(TC)/$(TC).elf
	$(OB) $(OFLAGS) build/$(TC)/$(TC).elf build/$(TC)/$(TC).bin
	$(OB) $(OFLAGS) -O verilog build/$(TC)/$(TC).elf build/$(TC)/$(TC).verilog

elf: build/$(TC)/$(TC).bin



