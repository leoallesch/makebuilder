TOOLS_PATH := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

include $(TOOLS_PATH)/toolchain.mk

CC = $(TOOLCHAIN_PREFIX)gcc
CXX = $(TOOLCHAIN_PREFIX)g++
AS = $(TOOLCHAIN_PREFIX)as
LD = $(TOOLCHAIN_PREFIX)gcc
AR = $(TOOLCHAIN_PREFIX)gcc-ar
GBD = $(TOOLCHAIN_PREFIX)gdb
OBJCOPY = $(TOOLCHAIN_PREFIX)objcopy
SIZE = $(TOOLCHAIN_PREFIX)size

SRCS := $(SRC_FILES)
SRCS += $(shell find $(SRC_DIRS) -maxdepth 1 -name '*.cpp' -or -name '*.c' -or -name '*.s')

OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(SRCS:%=$(BUILD_DIR)/%.d)

INC_DIRS+=$(SRC_DIRS)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

COMPILE_DB := $(BUILD_DIR)/compile_commands.json

CPPFLAGS := \
  $(INC_FLAGS) \
  $(CPPFLAGS) \
  $(addprefix -D,$(DEFINES))

# Default target
.PHONY: all
all: $(BUILD_DIR)/$(TARGET) $(COMPILE_DB)

# Link object files to create executable using gcc
$(BUILD_DIR)/$(TARGET): $(OBJS)
	@mkdir -p $(dir $@)
	@echo Linking $(notdir $@)
	@$(LD) $(OBJS) -o $@ $(LDFLAGS)

# Build step for C source
$(BUILD_DIR)/%.c.o: %.c
	@mkdir -p $(dir $@)
	@echo Compiling $(notdir $@)
	@$(CC) $(CPPFLAGS) -MMD -MP $(CFLAGS) -c $< -o $@

# Build step for C++ source
$(BUILD_DIR)/%.cpp.o: %.cpp
	@mkdir -p $(dir $@)
	@echo Compiling $(notdir $@)
	@$(CXX) $(CPPFLAGS) -MMD -MP $(CXXFLAGS) -c $< -o $@

# Build step for assembly source
$(BUILD_DIR)/%.s.o: %.s
	@mkdir -p $(dir $@)
	@echo Compiling $(notdir $@)
	@$(CC) $(CPPFLAGS) -c $< -o $@

# Generate compile_commands.json
$(COMPILE_DB): $(SRCS)
	@mkdir -p $(dir $@)
	@echo "[" > $@
	@first=1; \
	for src in $(SRCS); do \
		case "$$src" in \
			*.c) compiler="$(CC)"; flags="$(CFLAGS)";; \
			*.cpp) compiler="$(CXX)"; flags="$(CXXFLAGS)";; \
			*.s) compiler="$(AS)"; flags="";; \
			*) continue;; \
		esac; \
		obj="$$(echo "$$src" | sed 's|\.[a-z]*$$|.o|' | sed 's|^$(SRC_DIRS)/|$(BUILD_DIR)/|')"; \
		[ $$first -eq 1 ] && first=0 || echo "," >> $@; \
		printf '    {\n' >> $@; \
		printf '        "directory": "%s",\n' "$$(pwd)" >> $@; \
		printf '        "command": "%s %s %s -c %s -o %s",\n' "$$compiler" "$(CPPFLAGS)" "$$flags" "$$src" "$$obj" >> $@; \
		printf '        "file": "%s"\n' "$$src" >> $@; \
		printf '    }' >> $@; \
	done
	@echo "]" >> $@

# Clean up
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

-include $(DEPS)