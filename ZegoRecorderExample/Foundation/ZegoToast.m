//
//  ZegoToast.m
//  ZegoWhiteboardExample
//
//  Created by Vic on 2021/3/13.
//

#import "ZegoToast.h"
#import "Toast.h"

@implementation ZegoToast

+ (void)toastWithMessage:(NSString *)msg {
    UIWindow *window = [UIWindow keyWindow];
    [window makeToast:msg duration:2 position:[NSValue valueWithCGPoint:window.center] style:nil];
}

+ (void)toastWithError:(int)error {
    NSString *msg = [NSString stringWithFormat:@"错误码: %d", error];
    [self toastWithMessage:msg];
}

+ (UIWindow *)keyWindow
{
    UIWindow* window = nil;
    
    if (@available(iOS 13.0, *))
    {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
        {
            if (windowScene.activationState == UISceneActivationStateForegroundActive)
            {
                window = windowScene.windows.firstObject;
                
                break;
            }
        }
    }else{
        window = [UIApplication sharedApplication].keyWindow;
    }
    return window;
}

@end
