# lib/makebuilder/lib_builder.mk
# Generic library builder for external dependencies
#
# Usage:
#   Define these variables before including this file:
#   - LIB_NAME        : Name of the library (e.g., "cpputest", "mylib")
#   - LIB_HOME        : Path to library source (e.g., "$(TOOLS_PATH)lib/cpputest")
#   - LIB_INC_DIRS    : Include directories to add (required)
#   
#   For external libraries with custom build:
#   - LIB_BUILD       : Path to build directory (e.g., "$(LIB_HOME)/build")
#   - LIB_BUILD_LIBS  : List of output .a files (e.g., "$(LIB_BUILD)/lib/libCppUTest.a")
#   - LIB_BUILD_CMD   : Command to build (e.g., "cd $(LIB_BUILD) && ../configure && make")
#   - LIB_LDFLAGS     : Linker flags to add (optional, e.g., "-L$(LIB_BUILD)/lib -lcpputest")
#   
#   For source-based libraries:
#   - LIB_SRC_DIRS    : Source directories (e.g., "$(LIB_HOME)/src")
#   - LIB_BUILD_LIBS  : Output .a file (e.g., "$(LIB_BUILD)/libmylib.a")
#   - LIB_BUILD       : Output directory for .a file (e.g., "$(LIB_HOME)/build")

ifndef LIB_NAME
$(error LIB_NAME must be defined)
endif

ifndef LIB_HOME
$(error LIB_HOME must be defined)
endif

ifndef LIB_INC_DIRS
$(error LIB_INC_DIRS must be defined)
endif

ifndef LIB_BUILD_LIBS
$(error LIB_BUILD_LIBS must be defined)
endif

# Detect library type based on what's defined
LIB_TYPE ?= $(if $(LIB_BUILD_CMD),external,source)

# Add library includes and linker flags to global variables
INC_DIRS += $(LIB_INC_DIRS)
LDFLAGS += $(LIB_LDFLAGS)

# Add to global LIBS list
LIBS += $(LIB_BUILD_LIBS)

# ============================================================================
# External Library Type: Uses custom build command
# ============================================================================

ifeq ($(LIB_TYPE),external)

ifndef LIB_BUILD
$(error External library $(LIB_NAME): LIB_BUILD must be defined)
endif

ifndef LIB_BUILD_CMD
$(error External library $(LIB_NAME): LIB_BUILD_CMD must be defined)
endif

# Build the library using custom command
$(LIB_BUILD_LIBS): | $(LIB_HOME)
	@echo "Building $(LIB_NAME) (external)..."
	@mkdir -p $(LIB_BUILD)
	@$(LIB_BUILD_CMD)

endif

# ============================================================================
# Source Library Type: Compiles .c/.cpp files into .a
# ============================================================================

ifeq ($(LIB_TYPE),source)

ifndef LIB_SRC_DIRS
$(error Source library $(LIB_NAME): LIB_SRC_DIRS must be defined)
endif

ifndef LIB_BUILD
$(error Source library $(LIB_NAME): LIB_BUILD must be defined)
endif

# Find all source files in library source directories
LIB_SRCS := $(shell find $(LIB_SRC_DIRS) -maxdepth 1 -name '*.c' -o -name '*.cpp')
LIB_OBJS := $(LIB_SRCS:%=$(LIB_BUILD)/%.o)

# Build object files
$(LIB_BUILD)/%.c.o: %.c
	@mkdir -p $(dir $@)
	@echo "Compiling $(notdir $@) [$(LIB_NAME)]"
	@$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

$(LIB_BUILD)/%.cpp.o: %.cpp
	@mkdir -p $(dir $@)
	@echo "Compiling $(notdir $@) [$(LIB_NAME)]"
	@$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $< -o $@

# Create static library
$(LIB_BUILD_LIBS): $(LIB_OBJS)
	@mkdir -p $(dir $@)
	@echo "Creating library $(notdir $@)"
	@$(AR) rcs $@ $(LIB_OBJS)

endif

# ============================================================================
# Common rules for both library types
# ============================================================================

# Initialize submodule if missing
$(LIB_HOME):
	@echo "$(LIB_NAME) submodule not found. Initializing..."
	git submodule update --init --recursive $(LIB_HOME)

# Clean library build artifacts
clean-$(LIB_NAME):
	@echo "Cleaning $(LIB_NAME)..."
	rm -rf $(LIB_BUILD)

.PHONY: clean-$(LIB_NAME)
