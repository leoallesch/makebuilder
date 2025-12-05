# lib/makebuilder/lib_example.mk
# Example configuration for a source-based library
#
# This file demonstrates how to create a library configuration file
# for a library with standard C/C++ source files.
#
# To use this as a template:
# 1. Copy this file and rename it to match your library name
# 2. Update the variables below
# 3. Include it in your Makefile before including builder.mk

TOOLS_PATH := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

# ============================================================================
# Library Configuration Variables
# ============================================================================

# Unique name for your library (used in targets and messages)
LIB_NAME := example

# Path to the library's source directory
LIB_HOME := $(TOOLS_PATH)lib/example

# Directories containing source files (.c and .cpp files)
# Can include multiple directories separated by spaces
LIB_SRC_DIRS := $(LIB_HOME)/src $(LIB_HOME)/src/utils

# Output directory where the compiled .a file will be placed
LIB_BUILD := $(LIB_HOME)/build

# Output library file (the .a file that will be created)
LIB_BUILD_LIBS := $(LIB_BUILD)/libexample.a

# Include directories to be available to your project
LIB_INC_DIRS := $(LIB_HOME)/include

# Optional: Additional linker flags (usually not needed for source libraries)
# LIB_LDFLAGS := -L$(LIB_BUILD)

# ============================================================================
# Include the generic library builder
# ============================================================================

include $(TOOLS_PATH)lib_builder.mk

# ============================================================================
# Optional: Library-specific compiler flags
# ============================================================================

# Example: Add specific flags only when compiling this library's sources
# CFLAGS += -Wall -Wextra
# CXXFLAGS += -std=c++11
