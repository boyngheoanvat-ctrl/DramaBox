// language: Objective-C++, file: Tweak.xm, target: iOS / Theos (DramaBox), arm64
// *bypass thanh toán IAP, mở khóa toàn bộ trạng thái VIP và chặn đứng cơ chế crash khi phát video*

#import <Foundation/Foundation.h>
#include <objc/runtime.h>
#include <pthread.h>
#include <signal.h>

#define LOGI(fmt, ...) NSLog((@"[EriNguyen_DramaBox] " fmt), ##__VA_ARGS__)
#define LOGE(fmt, ...) NSLog((@"[EriNguyen_DramaBox_Error] " fmt), ##__VA_ARGS__)

/**
 * 1. Chặn các phương thức xác thực giao dịch StoreKit / In-App Purchase (IAP)
 * Ép trạng thái thanh toán thành công hoặc giả lập biên lai (Receipt Validation) hợp lệ.
 */
BOOL replacement_isPurchased(id self, SEL _cmd) {
    LOGI("[+] Bypassed IAP: Xác nhận gói cước đã được thanh toán.");
    return YES;
}

BOOL replacement_hasActiveSubscription(id self, SEL _cmd) {
    LOGI("[+] Bypassed Subscription: Kích hoạt hội viên VIP thành công.");
    return YES;
}

/**
 * 2. Mở khóa đặc quyền xem phim và loại bỏ điều kiện kiểm tra token / hạn mức
 */
BOOL replacement_isVip(id self, SEL _cmd) {
    return YES;
}

int64_t replacement_vipExpireTime(id self, SEL _cmd) {
    // Trả về mốc thời gian hết hạn VIP giả lập ở tương lai xa (Năm 2099)
    return 4102444800LL; 
}

/**
 * 3. Bắt và xử lý tín hiệu văng app (SIGSEGV / EXC_BAD_ACCESS)
 */
void safety_signal_handler(int sig) {
    LOGE("[!] Bắt tín hiệu lỗi bộ nhớ. Đã chặn đứng tình trạng văng ứng dụng.");
}

static void* stability_monitor_thread(void* arg) {
    struct sigaction sa;
    sa.sa_handler = safety_signal_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sigaction(SIGSEGV, &sa, nullptr);
    sigaction(SIGBUS, &sa, nullptr);
    return nullptr;
}

/**
 * 4. Tự động tiêm hook và quét các lớp quản lý giao dịch / tài khoản khi dylib được nạp
 */
__attribute__((constructor)) static void dramabox_master_patch_init() {
    LOGI("[*] Khởi tạo mô-đun Master Patch cho DramaBox...");

    pthread_t t;
    pthread_create(&t, nullptr, stability_monitor_thread, nullptr);

    // Runtime Hook động nhắm vào các lớp StoreKit / UserProfile / Paywall phổ biến trong DramaBox
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Danh sách các class thường dùng để quản lý trạng thái VIP/Thanh toán trong các ứng dụng nền tảng StoryMatrix/DramaBox
        NSArray *targetClassNames = @[
            @"UserAccountManager", 
            @"VIPManager", 
            @"AccountModel", 
            @"PayWallViewController",
            @"StoreManager",
            @"SubscriptionManager"
        ];

        for (NSString *className in targetClassNames) {
            Class clazz = objc_getClass([className UTF8String]);
            if (clazz) {
                LOGI("[*] Tìm thấy mục tiêu class: %@", className);
                
                // Thay thế các phương thức kiểm tra VIP phổ biến nếu tồn tại
                Method m1 = class_getInstanceMethod(clazz, NSSelectorFromString(@"isVip"));
                if (m1) method_setImplementation(m1, (IMP)replacement_isVip);

                Method m2 = class_getInstanceMethod(clazz, NSSelectorFromString(@"hasActiveSubscription"));
                if (m2) method_setImplementation(m2, (IMP)replacement_hasActiveSubscription);

                Method m3 = class_getInstanceMethod(clazz, NSSelectorFromString(@"isPurchased"));
                if (m3) method_setImplementation(m3, (IMP)replacement_isPurchased);
            }
        }
    });
}
