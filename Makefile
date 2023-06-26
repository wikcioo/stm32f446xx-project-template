TARGET := __project_name__

TOOLCHAIN := arm-none-eabi-
CC        := $(TOOLCHAIN)gcc
CPU       := cortex-m4
FPU       := fpv4-sp-d16
FLOAT_ABI := soft

DEBUG := 1

BUILD_DIR    := build
ARTEFACT_DIR := $(BUILD_DIR)/artefact
CMSIS_DIR    := thirdparty/CMSIS
HAL_DIR      := thirdparty/STM32F4xx_HAL_Driver
LINKER_DIR   := linker
STARTUP_DIR  := startup
SYSCALLS_DIR := syscalls
USR_INC_DIR  := core/include
USR_SRC_DIR  := core/src

C_INCLUDES := \
-I$(CMSIS_DIR)/Include \
-I$(CMSIS_DIR)/Device/ST/STM32F4xx/Include \
-I$(HAL_DIR)/Inc \
-I$(HAL_DIR)/Inc/Legacy \
-I$(USR_INC_DIR) \

C_DEFINES := \
-DUSE_HAL_DRIVER \
-DSTM32F446xx

WARNINGS := \
-Wall \
-Wformat \
-Wpedantic \
-Wshadow

OPTS :=

ifeq ($(DEBUG), 1)
	OPTS += -Og -ggdb
	C_DEFINES += -D_DEBUG
else
	OPTS += -O2
endif

LD_SCRIPT := $(LINKER_DIR)/stm32f446xx_flash_ram.ld

C_FLAGS := \
-mcpu=$(CPU) \
-mthumb \
-mfloat-abi=$(FLOAT_ABI) \
-std=gnu11 \
$(C_INCLUDES) \
$(C_DEFINES) \
$(WARNINGS) \
$(OPTS)

LD_FLAGS := \
-mcpu=$(CPU) \
-mthumb \
-mfloat-abi=$(FLOAT_ABI) \
-T$(LD_SCRIPT) \
-Wl,-Map=$(BUILD_DIR)/$(TARGET).map \
-u_printf_float \
--specs=nano.specs

HARD_STR := hard
ifeq ($(FLOAT_ABI), $(HARD_STR))
	C_FLAGS += -mfpu=$(FPU)
	LD_FLAGS += -mfpu=$(FPU)
endif

SOURCES := $(wildcard $(USR_SRC_DIR)/*.c)
SOURCES += $(STARTUP_DIR)/stm32f446xx_startup.s
SOURCES += $(SYSCALLS_DIR)/syscalls.c
SOURCES += $(SYSCALLS_DIR)/sysmem.c
SOURCES += \
$(HAL_DIR)/Src/stm32f4xx_hal_tim.c \
$(HAL_DIR)/Src/stm32f4xx_hal_tim_ex.c \
$(HAL_DIR)/Src/stm32f4xx_hal_rcc.c \
$(HAL_DIR)/Src/stm32f4xx_hal_rcc_ex.c \
$(HAL_DIR)/Src/stm32f4xx_hal_flash.c \
$(HAL_DIR)/Src/stm32f4xx_hal_flash_ex.c \
$(HAL_DIR)/Src/stm32f4xx_hal_flash_ramfunc.c \
$(HAL_DIR)/Src/stm32f4xx_hal_gpio.c \
$(HAL_DIR)/Src/stm32f4xx_hal_uart.c \
$(HAL_DIR)/Src/stm32f4xx_hal_dma_ex.c \
$(HAL_DIR)/Src/stm32f4xx_hal_dma.c \
$(HAL_DIR)/Src/stm32f4xx_hal_pwr.c \
$(HAL_DIR)/Src/stm32f4xx_hal_pwr_ex.c \
$(HAL_DIR)/Src/stm32f4xx_hal_cortex.c \
$(HAL_DIR)/Src/stm32f4xx_hal.c \
$(HAL_DIR)/Src/stm32f4xx_hal_exti.c

OBJECTS := $(addprefix $(BUILD_DIR)/, $(addsuffix .c.o, $(basename $(notdir $(SOURCES)))))

.PHONY = all flash clean

all:
	@mkdir -p $(ARTEFACT_DIR)
	@make --no-print-directory $(ARTEFACT_DIR)/$(TARGET).elf
	@$(TOOLCHAIN)objcopy -O binary $(ARTEFACT_DIR)/$(TARGET).elf $(ARTEFACT_DIR)/$(TARGET).bin
	@$(TOOLCHAIN)size $(ARTEFACT_DIR)/$(TARGET).elf

$(ARTEFACT_DIR)/$(TARGET).elf: $(OBJECTS) | $(ARTEFACT_DIR)
	$(CC) $(LD_FLAGS) $^ -o $@

$(BUILD_DIR)/%.c.o: $(HAL_DIR)/Src/%.c | $(BUILD_DIR)
	$(CC) -c $(C_FLAGS) $^ -o $@

$(BUILD_DIR)/%.c.o: $(USR_SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) -c $(C_FLAGS) $^ -o $@

$(BUILD_DIR)/%.c.o: $(STARTUP_DIR)/%.s | $(BUILD_DIR)
	$(CC) -c $(C_FLAGS) $^ -o $@

$(BUILD_DIR)/%.c.o: $(SYSCALLS_DIR)/%.c | $(BUILD_DIR)
	$(CC) -c $(C_FLAGS) $^ -o $@

flash: $(ARTEFACT_DIR)
	st-flash --reset write $(ARTEFACT_DIR)/$(TARGET).bin 0x08000000

clean:
	rm -rf $(BUILD_DIR)
