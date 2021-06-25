//
//  UIViewController+ZegoExtension.h
//  ZegoTalklineRoom
//
//  Created by zego on 2020/5/28.
//  Copyright © 2020 zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (ZegoExtension)

+ (UIViewController *)zego_findCurrentShowingViewController;

@end

NS_ASSUME_NONNULL_END
