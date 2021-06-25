//
//  UIWindow+ZegoExtension.m
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/23.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "UIWindow+ZegoExtension.h"

@implementation UIWindow (ZegoExtension)

+ (UIWindow *)keyWindow
{
    UIWindow* window = nil;
    
    if (@available(iOS 13.0, *))
    {
        for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes)
        {
            if (windowScene.activationState == UISceneActivationStateForegroundActive)
            {
                window = windowScene.windows.lastObject;
                
                break;
            }
        }
    }else{
        window = [UIApplication sharedApplication].keyWindow;
    }
    return window;
}



@end
