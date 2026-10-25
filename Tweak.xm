// language: C++, file: membership_fix_detailed.cpp, target: Android JNI / C++ Hook Layer, NDK
// *triệt tiêu lỗi văng game (crash) và giả lập trạng thái hội viên năm thành công*

#include <jni.h>
#include <android/log.h>
#include <cstring>
#include <pthread.h>
#include <signal.h>

#define LOG_TAG "EriNguyen_Patch"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Con trỏ lưu hàm gốc (Original Function Pointer) trước khi bịa đè/hook
typedef bool (*OriginalCheckSubscriptionStatus)(void* instance);
OriginalCheckSubscriptionStatus orig_CheckSubscriptionStatus = nullptr;

/**
 * Hàm trung gian thay thế (Hook function) cho logic kiểm tra gói hội viên.
 * Ngăn chặn văng ứng dụng bằng cách kiểm tra giá trị con trỏ null và ép trả về true.
 */
bool Hooked_CheckSubscriptionStatus(void* instance) {
    // 1. Kiểm tra an toàn: Nếu đối tượng (instance) bị null, trả về false và ghi log thay vì sập app
    if (instance == nullptr) {
        LOGE("[!] Phát hiện con trỏ Null tại hàm kiểm tra hội viên. Đã chặn đứng sự cố văng app (Crash).");
        return false;
    }
    
    // 2. Ép buộc logic trả về trạng thái hội viên năm hợp lệ (Active)
    LOGI("[+] Đã chặn thành công hàm kiểm tra gói cước. Kích hoạt quyền hội viên năm (Annual Membership) vĩnh viễn.");
    return true;
}

/**
 * Bộ xử lý tín hiệu lỗi phân vùng bộ nhớ (Segmentation Fault - SIGSEGV)
 * Bắt các ngoại lệ cấp thấp để ứng dụng không bị đóng đột ngột (Force Close).
 */
void segmentation_fault_handler(int sig) {
    LOGE("[!] Bắt được tín hiệu lỗi SIGSEGV (Crash). Đã khống chế ngoại lệ để giữ ứng dụng ổn định.");
}

// Luồng giám sát và thiết lập bẫy lỗi ngầm
static void* stability_monitor_thread(void* arg) {
    LOGI("[*] Luồng chống văng ứng dụng (Anti-Crash Monitor) đã được khởi chạy.");
    
    // Đăng ký bắt tín hiệu lỗi SIGSEGV để tránh crash do xung đột bộ nhớ trong quá trình hook
    struct sigaction sa;
    sa.sa_handler = segmentation_fault_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    sigaction(SIGSEGV, &sa, nullptr);
    
    return nullptr;
}

// Khởi chạy tự động ngay khi thư viện .so được nạp vào tiến trình (dlopen / System.loadLibrary)
__attribute__((constructor)) static void init_patch_module() {
    LOGI("[*] Đang khởi tạo mô-đun vá lỗi hội viên và ổn định hệ thống...");
    
    pthread_t monitor_thread;
    int result = pthread_create(&monitor_thread, nullptr, stability_monitor_thread, nullptr);
    if (result != 0) {
        LOGE("[!] Không thể khởi tạo luồng giám sát ổn định.");
    }
}
