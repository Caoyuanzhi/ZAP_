.PHONY: test clean reset lint runlint c2asm dirs runsim syn

PWD          := $(shell pwd)
TAG          := archlinux/zap
SHELL        := /bin/bash -o pipefail
ARCH         := armv5te
C_FILES      := $(wildcard compile_test_case/$(TC)/*.c)
S_FILES      := $(wildcard compile_test_case/$(TC)/*.s)
H_FILES      := $(wildcard compile_test_case/$(TC)/*.h)
LD_FILE      := $(wildcard compile_test_case/$(TC)/*.ld)
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
TEST         := $(shell find compile_test_case/* -type d -exec basename {} \; | xargs echo)
DLOAD        := "FROM archlinux:latest\nRUN  pacman -Syyu --noconfirm arm-none-eabi-gcc arm-none-eabi-binutils gcc \
                 make perl verilator"

########################### User Accessible Targets #########################################
# Thanks to Erez Binyamin for Docker support patches.
.DEFAULT_GOAL = test
# Run all tests. Default goal.
test:
	docker info
	$(MAKE) lint
	mkdir -p obj/syn
	docker image ls | grep $(TAG) || echo -e $(DLOAD) | docker build --no-cache --rm --tag $(TAG) -
ifndef TC
	for var in $(TEST); do $(MAKE) test TC=$$var HT=1 || exit 10 ; done; 
else
	docker run --interactive --tty --volume `pwd`:`pwd` --workdir `pwd` $(TAG) $(MAKE) runsim TC=$(TC) HT=1 || exit 10
endif

# Remove runsim objects
clean: 
	docker info
	docker image ls | grep $(TAG) && docker run --interactive --tty --volume `pwd`:`pwd` --workdir `pwd` $(TAG) \
        rm -rfv obj/

# Compile S files to OBJ.
obj/ts/$(TC)/a.o: $(S_FILES)
	$(AS) $(SFLAGS) $(S_FILES) -o obj/ts/$(TC)/a.o

# Compile C files to OBJ.
obj/ts/$(TC)/c.o: $(C_FILES) $(H_FILES)
	$(CC) $(CFLAGS) $(C_FILES) -o obj/ts/$(TC)/c.o

# Rule to convert the object files to an ELF file.
obj/ts/$(TC)/$(TC).elf: $(LD_FILE) obj/ts/$(TC)/a.o obj/ts/$(TC)/c.o
	$(LD) $(LFLAGS) $(LD_FILE) obj/ts/$(TC)/a.o obj/ts/$(TC)/c.o -o obj/ts/$(TC)/$(TC).elf
	$(DP) -d obj/ts/$(TC)/$(TC).elf > obj/ts/$(TC)/$(TC).dump

# Rule to generate a BIN file.
obj/ts/$(TC)/$(TC).bin: obj/ts/$(TC)/$(TC).elf
	$(OB) $(OFLAGS) obj/ts/$(TC)/$(TC).elf obj/ts/$(TC)/$(TC).bin

# Rule to verilate.
obj/ts/$(TC)/Vzap_test: $(CPU_FILES) $(TB_FILES) $(SCRIPT_FILES) src/ts/$(TC)/Config.cfg obj/ts/$(TC)/$(TC).bin
	$(info ********************************)
	$(info BUILDING SIMULATION ENV         )
	$(info ********************************)
	# perl verwrap.pl $(TC) $(HT)


