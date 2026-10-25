# Khai báo kiến trúc và target iOS
TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

# Tắt warning nếu cần
CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ExampleTweak

ExampleTweak_FILES = Tweak.x
ExampleTweak_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

# Dọn dẹp sau khi build
after-install::
	echo "Build completed."
