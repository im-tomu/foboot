PACKAGE    := foboot
FOMU_SDK  ?= .
ADD_CFLAGS := -I$(FOMU_SDK)/include -D__vexriscv__ -march=rv32im  -mabi=ilp32
ADD_LFLAGS := 
SRC_DIR    := src

GIT_VERSION := $(shell git describe --tags)
TRGT      ?= riscv64-unknown-elf-
CC         := $(TRGT)gcc
CXX        := $(TRGT)g++
OBJCOPY    := $(TRGT)objcopy

RM         := rm -rf
COPY       := cp -a
PATH_SEP   := /

ifeq ($(OS),Windows_NT)
COPY       := copy
RM         := del
PATH_SEP   := \\
endif

LDSCRIPT   := $(FOMU_SDK)/ld/linker.ld
LDSCRIPTS  := $(LDSCRIPT) $(FOMU_SDK)/ld/output_format.ld $(FOMU_SDK)/ld/regions.ld
DBG_CFLAGS := -ggdb -g -DDEBUG -Wall
DBG_LFLAGS := -ggdb -g -Wall
CFLAGS     := $(ADD_CFLAGS) \
			  -Wall -Wextra \
			  -ffunction-sections -fdata-sections -fno-common \
			  -fomit-frame-pointer -Os \
			  -march=rv32i \
			  -DGIT_VERSION=u\"$(GIT_VERSION)\" -std=gnu11
CXXFLAGS   := $(CFLAGS) -std=c++11 -fno-rtti -fno-exceptions
LFLAGS     := $(CFLAGS) $(ADD_LFLAGS) \
			  -nostartfiles \
			  -nostdlib \
			  -Wl,--gc-sections \
			  -Wl,--no-warn-mismatch \
			  -Wl,--script=$(LDSCRIPT) \
			  -Wl,--build-id=none

OBJ_DIR    := .obj

CSOURCES   := $(wildcard $(SRC_DIR)/*.c) $(wildcard third_party/libbase/*.c) $(wildcard third_party/*.c)
CPPSOURCES := $(wildcard $(SRC_DIR)/*.cpp) $(wildcard third_party/libbase/*.cpp) $(wildcard third_party/*.cpp)
ASOURCES   := $(wildcard $(SRC_DIR)/*.S) $(wildcard third_party/libbase/*.S) $(wildcard third_party/*.S)
COBJS      := $(addprefix $(OBJ_DIR)/, $(notdir $(CSOURCES:.c=.o)))
CXXOBJS    := $(addprefix $(OBJ_DIR)/, $(notdir $(CPPSOURCES:.cpp=.o)))
AOBJS      := $(addprefix $(OBJ_DIR)/, $(notdir $(ASOURCES:.S=.o)))
OBJECTS    := $(COBJS) $(CXXOBJS) $(AOBJS)
VPATH      := $(SRC_DIR) third_party/libbase third_party

QUIET      := @

ALL        := all
TARGET     := $(PACKAGE).elf
CLEAN      := clean

$(ALL): $(TARGET) $(PACKAGE).bin $(PACKAGE).ihex

$(OBJECTS): | $(OBJ_DIR)

$(TARGET): $(OBJECTS) $(LDSCRIPTS)
	$(QUIET) echo "  LD       $@"
	$(QUIET) $(CC) $(OBJECTS) $(LFLAGS) -o $@

$(PACKAGE).bin: $(TARGET)
	$(QUIET) echo "  OBJCOPY  $@"
	$(QUIET) $(OBJCOPY) -O binary $(TARGET) $@

$(PACKAGE).dfu: $(TARGET)
	$(QUIET) echo "  DFU      $@"
	$(QUIET) $(COPY) $(PACKAGE).bin $@
	$(QUIET) dfu-suffix -v 1209 -p 70b1 -a $@

#$(PACKAGE).bit: $(TARGET)
#	$(QUIET) echo "  BIT      $@"
#	# $(QUIET) ice40-repack input/top.bin input/mem_1.init ./foboot.bin ./foboot.bit

$(PACKAGE).ihex: $(TARGET)
	$(QUIET) echo "  IHEX     $(PACKAGE).ihex"
	$(QUIET) $(OBJCOPY) -O ihex $(TARGET) $@

$(DEBUG): CFLAGS += $(DBG_CFLAGS)
$(DEBUG): LFLAGS += $(DBG_LFLAGS)
CFLAGS += $(DBG_CFLAGS)
LFLAGS += $(DBG_LFLAGS)
$(DEBUG): $(TARGET)

$(OBJ_DIR):
	$(QUIET) mkdir $(OBJ_DIR)

$(COBJS) : $(OBJ_DIR)/%.o : %.c Makefile
	$(QUIET) echo "  CC       $<	$(notdir $@)"
	$(QUIET) $(CC) -c $< $(CFLAGS) -o $@ -MMD

$(OBJ_DIR)/%.o: %.cpp
	$(QUIET) echo "  CXX      $<	$(notdir $@)"
	$(QUIET) $(CXX) -c $< $(CXXFLAGS) -o $@ -MMD

$(OBJ_DIR)/%.o: %.S
	$(QUIET) echo "  AS       $<	$(notdir $@)"
	$(QUIET) $(CC) -x assembler-with-cpp -c $< $(CFLAGS) -o $@ -MMD

.PHONY: clean

clean:
	$(QUIET) echo "  RM      $(subst /,$(PATH_SEP),$(wildcard $(OBJ_DIR)/*.d))"
	-$(QUIET) $(RM) $(subst /,$(PATH_SEP),$(wildcard $(OBJ_DIR)/*.d))
	$(QUIET) echo "  RM      $(subst /,$(PATH_SEP),$(wildcard $(OBJ_DIR)/*.d))"
	-$(QUIET) $(RM) $(subst /,$(PATH_SEP),$(wildcard $(OBJ_DIR)/*.o))
	$(QUIET) echo "  RM      $(TARGET) $(PACKAGE).bin $(PACKAGE).symbol $(PACKAGE).ihex $(PACKAGE).dfu"
	-$(QUIET) $(RM) $(TARGET) $(PACKAGE).bin $(PACKAGE).symbol $(PACKAGE).ihex $(PACKAGE).dfu

include $(wildcard $(OBJ_DIR)/*.d)
