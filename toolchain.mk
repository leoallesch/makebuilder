ifeq ($(TOOLCHAIN), arm-none-eabi)
  include $(TOOLS_PATH)/toolchains/arm-none-eabi.mk
else ifeq ($(TOOLCHAIN), gcc)
  include $(TOOLS_PATH)/toolchains/gcc.mk
else
  include $(TOOLS_PATH)/toolchains/gcc.mk
endif