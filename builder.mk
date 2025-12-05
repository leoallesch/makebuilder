TOOLS_PATH := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

include $(TOOLS_PATH)/defaults.mk

CC = $(TOOLCHAIN_PREFIX)gcc
CXX = $(TOOLCHAIN_PREFIX)g++
AS = $(TOOLCHAIN_PREFIX)as
LD = $(TOOLCHAIN_PREFIX)g++
AR = $(TOOLCHAIN_PREFIX)gcc-ar
GDB = $(TOOLCHAIN_PREFIX)gdb
OBJCOPY = $(TOOLCHAIN_PREFIX)objcopy
SIZE = $(TOOLCHAIN_PREFIX)size

SRCS := $(SRC_FILES)
SRCS += $(shell find $(SRC_DIRS) -maxdepth 1 -name '*.cpp' -or -name '*.c' -or -name '*.s')

OUTPUT_PATH := $(BUILD_DIR)/$(TARGET)

OBJS := $(SRCS:%=$(OUTPUT_PATH)/%.o)
DEPS := $(SRCS:%=$(OUTPUT_PATH)/%.d)

INC_DIRS+=$(SRC_DIRS)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

COMPILE_DB := $(OUTPUT_PATH)/compile_commands.json

CPPFLAGS := \
  $(INC_FLAGS) \
  $(CPPFLAGS) \
  $(addprefix -D,$(DEFINES))

# Default target
.PHONY: all
.DEFAULT_GOAL := all
all: $(OUTPUT_PATH)/$(TARGET) $(COMPILE_DB)

# Run target: build and run the produced executable (available to all projects)
.PHONY: run
run: $(OUTPUT_PATH)/$(TARGET)
	@echo "Running $(OUTPUT_PATH)/$(TARGET)"
	@$(OUTPUT_PATH)/$(TARGET)

# Link object files to create executable
$(OUTPUT_PATH)/$(TARGET): $(OBJS) $(LIBS)
	@mkdir -p $(dir $@)
	@echo Linking $(notdir $@)
	@$(LD) $(OBJS) $(LIBS) -o $@ $(LDFLAGS) $(LDLIBS)

# Build step for C source
$(OUTPUT_PATH)/%.c.o: %.c
	@mkdir -p $(dir $@)
	@echo Compiling $(notdir $@)
	@$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

# Build step for C++ source
$(OUTPUT_PATH)/%.cpp.o: %.cpp
	@mkdir -p $(dir $@)
	@echo Compiling $(notdir $@)
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

# Build step for assembly source
$(OUTPUT_PATH)/%.s.o: %.s
	@mkdir -p $(dir $@)
	@echo Compiling $(notdir $@)
	@$(CC) $(CPPFLAGS) -c $< -o $@

$(COMPILE_DB): $(SRCS) $(OBJS)
	@echo "Generating $(notdir $(COMPILE_DB))"
	@mkdir -p $(dir $(COMPILE_DB))
	@printf '[\n' > $(COMPILE_DB)
	@set -e; \
	first=1; \
	for src in $(SRCS); do \
	    obj="$(OUTPUT_PATH)/$$src.o"; \
	    case "$$src" in \
	        *.c)   cmd="$(CC) $(CPPFLAGS) $(CFLAGS) -c $$src -o $$obj" ;; \
	        *.cpp) cmd="$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $$src -o $$obj" ;; \
	        *.cc)  cmd="$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $$src -o $$obj" ;; \
	        *.s)   cmd="$(CC) $(CPPFLAGS) -c $$src -o $$obj" ;; \
	        *)     echo "Unknown source type: $$src" >&2; exit 1 ;; \
	    esac; \
	    [ "$$first" = 1 ] && first=0 || printf ',\n' >> $(COMPILE_DB); \
	    printf '\t{\n'                                      >> $(COMPILE_DB); \
	    printf '\t\t"directory": "%s",\n' "$$(pwd)"         >> $(COMPILE_DB); \
	    printf '\t\t"command":   "%s",\n' "$$cmd"           >> $(COMPILE_DB); \
	    printf '\t\t"file":      "%s",\n' "$$(realpath $$src)" >> $(COMPILE_DB); \
	    printf '\t\t"output":    "%s"\n'  "$$(realpath $$obj)" >> $(COMPILE_DB); \
	    printf '\t}'                                      >> $(COMPILE_DB); \
	done; \
	printf '\n]\n' >> $(COMPILE_DB)

# Clean up
.PHONY: clean
clean:
	rm -rf $(OUTPUT_PATH)

.PHONY: clean_all
clean_all:
	rm -rf $(BUILD_DIR)

-include $(DEPS)