// language: Objective-C, file: Tweak.xm, target: iOS, Theos
#import <Foundation/Foundation.h>

%hook PlaytimeMonetize_PlaytimeOptionsBuilder

- (id)setUserProfile:(id)arg1 {
    NSLog(@"[N] PlaytimeOptionsBuilder setUserProfile intercepted: %@", arg1);
    return %orig(arg1);
}

- (id)initWithSdkHash:(id)arg1 userId:(id)arg2 userProfile:(id)arg3 params:(id)arg4 extensions:(id)arg5 wrapper:(id)arg6 {
    NSLog(@"[N] PlaytimeOptions initialized - userId: %@", arg2);
    return %orig(arg1, arg2, arg3, arg4, arg5, arg6);
}

%end
