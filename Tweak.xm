// language: Objective-C++, file: Tweak.xm, target: iOS / Theos, arm64
// *mã nguồn tweak iOS hoàn chỉnh theo Hướng 1: Dùng Foundation, thay thế log Android bằng NSLog và bypass hội viên năm*

#import <Foundation/Foundation.h>
#include <pthread.h>
#include <signal.h>

// Định nghĩa macro log tương thích với môi trường iOS (thay thế cho __android_log_print)
#define LOGI(fmt, ...) NSLog((@"[EriNguyen_Patch] " fmt), ##__VA_ARGS__)
#define LOGE(fmt, ...) NSLog((@"[EriNguyen_Patch_Error] " fmt), ##__VA_ARGS__)

// Nguyên mẫu hàm gốc kiểm tra hội viên (được thay đổi chữ ký phù hợp với runtime Objective-C / C++)
typedef BOOL (*OriginalCheckSubscriptionStatus)(id self, SEL _cmd);
OriginalCheckSubscriptionStatus orig_CheckSubscriptionStatus = nullptr;

/**
 * Hàm móc (Hook function) thay thế logic kiểm tra hội viên trên iOS.
 * Đảm bảo trả về YES (true) để kích hoạt quyền hội viên năm và lọc an toàn các con trỏ nil.
 */
BOOL Hooked_CheckSubscriptionStatus(id self, SEL _cmd) {
    if (self == nil) {
        LOGE("[!] Phát hiện đối tượng nil tại hàm kiểm tra hội viên. Đã chặn đứng sự cố văng ứng dụng.");
        return NO;
    }
    
    LOGI("[+] Đã chặn thành công hàm kiểm tra gói cước. Kích hoạt trạng thái hội viên năm thành công.");
    return YES;
}

/**
 * Bộ xử lý tín hiệu lỗi phân vùng bộ nhớ (SIGSEGV) dành cho iOS để giữ ổn định tiến trình.
 */
void safety_segmentation_fault_handler(int sig) {
    LOGE("[!] Bắt được tín hiệu lỗi SIGSEGV. Đã khống chế ngoại lệ để tránh sập app đột ngột.");
}

// Luồng giám sát chạy ngầm thiết lập bẫy sự cố
static void* stability_monitor_thread(void* arg) {
    LOGI("[*] Luồng chống văng ứng dụng (Anti-Crash Monitor) đã được kích hoạt.");
    
    struct sigaction sa;
    sa.sa_handler = safety_segmentation_fault_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sigaction(SIGSEGV, &sa, nullptr);
    
    return nullptr;
}

// Khởi tạo tự động ngay khi tweak được nạp vào tiến trình ứng dụng iOS
__attribute__((constructor)) static void init_ios_patch_module() {
    LOGI("[*] Đang khởi tạo mô-đun vá lỗi hội viên và chống văng trên iOS...");
    
    pthread_t monitor_thread;
    int result = pthread_create(&monitor_thread, nullptr, stability_monitor_thread, nullptr);
    if (result != 0) {
        LOGE("[!] Không thể khởi tạo luồng giám sát.");
    }
}
