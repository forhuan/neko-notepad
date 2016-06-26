.PHONY: all clean

ifeq ($(TARGET),)
    $(info Inspecting compiler to use...)
    ifneq ($(shell which arm-elf-gcc),)
        TARGET=arm-elf
    else
        ifneq ($(shell which arm-linux-gcc),)
            TARGET=arm-linux
        else
            $(error No compiler found. Check $$PATH or provide a $$TARGET)
        endif
    endif
endif

CC := $(TARGET)-gcc
LD := $(TARGET)-ld

ELF2HP ?= elf2hp
HP2APT ?= hp2aplet

SRC ?= $(wildcard *.c)
OBJ ?= $(SRC:%.c=%.o)
INC ?= "$(HPGCC)\include"
LIB ?= "$(HPGCC)\lib"


CFLAGS ?= -std=c99 -Wall -Os -I$(INC) -L$(LIB) \
	-mtune=arm920t -mcpu=arm920t -mlittle-endian -fomit-frame-pointer

crt0.o: CFLAGS += -msingle-pic-base -fpic -mpic-register=r10 -msoft-float

LDFLAGS := -L$(LIB) -T MMUld.script \
	-lwin -lggl -lhpg -lhplib -lgcc


all: sys_probe.apt

clean:
	rm *.o *.elf *.hp

%.apt: %.hp
	$(HP2APT) $< $@

%.hp: %.elf
	$(ELF2HP) $< $@

%.elf: $(OBJ)
	$(LD) $(OBJ) $(LDFLAGS) -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
