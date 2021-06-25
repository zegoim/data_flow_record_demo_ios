//
//  UIViewController+ZegoExtension.m
//  ZegoTalklineRoom
//
//  Created by zego on 2020/5/28.
//  Copyright © 2020 zego. All rights reserved.
//

#import "UIViewController+ZegoExtension.h"
#import "UIWindow+ZegoExtension.h"

@implementation UIViewController (ZegoExtension)

+ (UIViewController *)zego_findCurrentShowingViewController
{
    UIViewController *vc = [UIWindow keyWindow].rootViewController;
    // 从根视图往上找
    UIViewController *currentShowingVC = [self findCurrentShowingViewControllerFrom:vc];
    return currentShowingVC;
}

+ (UIViewController *)findCurrentShowingViewControllerFrom:(UIViewController *)vc
{
    UIViewController *currentShowingVC;
    if ([vc presentedViewController]) {  // 优先判断vc是否有弹出其他视图，如有则当前显示的视图肯定是在那上面
        // 当前视图是被presented出来的
        UIViewController *nextRootVC = [vc presentedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        UIViewController *nextRootVC = [(UITabBarController *) vc selectedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];

    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // 根视图为UINavigationController
        UIViewController *nextRootVC = [(UINavigationController *) vc visibleViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
    } else {
        // 根视图为非导航类
        currentShowingVC = vc;
    }

    return currentShowingVC;
}
@end
