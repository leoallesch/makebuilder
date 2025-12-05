TOOLCHAIN_PREFIX ?=

# Default flags

CPPFLAGS := \
  -Wall \
  -Wextra \
  -Werror \
  -Os \
  -g2 \
  -MMD \
  -MP

CFLAGS := \
  -std=c11

CXXFLAGS := \
  -std=c++17

ASFLAGS :=

LDFLAGS := \
