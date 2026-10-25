# language: Makefile, file: Makefile, target: Theos build system
TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ExampleTweak

# Change ExampleTweak_FILES to Tweak.xm to match the file being created
ExampleTweak_FILES = Tweak.xm
ExampleTweak_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
