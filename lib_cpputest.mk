# lib/makebuilder/lib_cpputest.mk
# CppUTest library configuration using the generic library builder

TOOLS_PATH := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

# Define CppUTest library parameters
LIB_NAME := cpputest
LIB_HOME := $(TOOLS_PATH)lib/cpputest
LIB_BUILD := $(BUILD_DIR)/$(LIB_NAME)

# CppUTest produces two libraries
LIB_BUILD_LIBS := $(LIB_BUILD)/lib/libCppUTest.a $(LIB_BUILD)/lib/libCppUTestExt.a

# Build command for CppUTest
LIB_BUILD_CMD := cd $(LIB_BUILD) && $(LIB_HOME)/configure && $(MAKE)

# CppUTest include directory
LIB_INC_DIRS := $(LIB_HOME)/include

# CppUTest linker flags
LIB_LDFLAGS := -L$(LIB_BUILD)/lib -lCppUTest -lCppUTestExt

# Include the generic library builder
include $(TOOLS_PATH)lib_builder.mk

# CppUTest-specific compiler flags for memory leak detection
CXXFLAGS += -include $(LIB_HOME)/include/CppUTest/MemoryLeakDetectorNewMacros.h
CFLAGS += -include $(LIB_HOME)/include/CppUTest/MemoryLeakDetectorMallocMacros.h
