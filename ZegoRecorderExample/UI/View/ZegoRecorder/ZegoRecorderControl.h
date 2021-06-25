//
//  ZegoRecorderControl.h
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/20.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoRecorderGesturesView.h"

typedef NS_ENUM(NSUInteger, ZegoRecorderControlAction) {
    ZegoRecorderControlPlay,
    ZegoRecorderControlPause,
    ZegoRecorderControlProgress,
    ZegoRecorderControlVolume,
    ZegoRecorderControlExit,
    ZegoRecorderControlNone,
};

@protocol ZegoRecorderControlDelegate <NSObject>

@optional

- (void)recorderControlAction:(ZegoRecorderControlAction)action;

@end

NS_ASSUME_NONNULL_BEGIN

@interface ZegoRecorderControl : UIView

@property (nonatomic, weak) id <ZegoRecorderControlDelegate> delegate;

@property (nonatomic, strong) UIView *topBar;///顶部栏
@property (nonatomic, strong) UIView *bottomBar;///底部栏
@property (nonatomic, strong) UIButton *closeButton;/// 关闭按钮
@property (nonatomic, strong) UILabel *titleLabel;/// 标题
@property (nonatomic, strong) UIButton *playButton;/// 播放按钮
@property (nonatomic, strong) UISlider *progressSlider;/// 进度条
@property (nonatomic, strong) UILabel *currentTimeLabel;/// 当前时间
@property (nonatomic, strong) UILabel *totalDurationLabel;/// 总时长
@property (nonatomic, strong) MBProgressHUD *HUDView;/// 提示菊花
@property (nonatomic, strong) ZegoRecorderGesturesView *gesturesView;/// 接受手势的视图

@property (nonatomic, assign) NSTimeInterval totalDuration;///总时长
@property (nonatomic, assign) NSTimeInterval currentTime;///当前进度
@property (nonatomic, assign) NSTimeInterval seekTime;///跳转到指定时间
@property (nonatomic, assign) int volume;///音量，最大100，最小0
@property (nonatomic, assign) BOOL isPlayEnd;///是否播放结束。

//根据状态改变UI
- (void)playStateUpdate:(enum ZegoPlaybackState)state;


@end

NS_ASSUME_NONNULL_END
