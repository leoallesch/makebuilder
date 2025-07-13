TOOLCHAIN_PREFIX ?=

# Default flags

CPPFLAGS := \
  -Wall \
  -Wextra \
  -Werror \
  -Wfatal-errors \
  -Wcast-qual \
  -Wpedantic \
  -Os \
  -g2

CFLAGS := \
  -std=c11

CXXFLAGS := \
  -std=c++17

ASFLAGS :=

LDFLAGS := \
#   -Wl,Map=$(BUILD_DIR)/$(TARGET).map
