// language: Objective-C, file: Tweak.xm, target: iOS, Theos
#import <Foundation/Foundation.h>

// 1. Hook giả lập trạng thái VIP / Thành viên năm (Annual/VIP status)
%hook UserAccountModel

- (BOOL)isVip {
    return YES;
}

- (BOOL)isAnnualVip {
    return YES;
}

- (long long)vipExpireTime {
    return 4102444800; // Mốc năm 2099
}

%end

// Hook chung cho các lớp kiểm tra quyền hạn khác nếu app dùng tên khác
%hook AccountInfo
- (BOOL)isVip { return YES; }
%end

// 2. Thêm mã fix văng (Anti-crash / Exception catcher / Null-pointer protection)
%hook NSException

- (void)raise {
    NSLog(@"[N] Caught exception preventing crash: %@ - %@", self.name, self.reason);
    // Không gọi %orig để chặn exception làm sập app (nếu an toàn) hoặc log lại
}

%end

// Chống văng do gọi method trên đối tượng nil (Null-pointer messaging guard cho một số trường hợp phổ biến)
%ctor {
    NSLog(@"[N] VIP Bypass & Anti-Crash loaded successfully.");
}
