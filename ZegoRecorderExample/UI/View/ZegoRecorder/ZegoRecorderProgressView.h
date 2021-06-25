//
//  ZegoRecorderProgressView.h
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/22.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoRecorderProgressView : UIView

@property (nonatomic, strong) UILabel * progressLabel;

- (void)setCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

@end

NS_ASSUME_NONNULL_END
