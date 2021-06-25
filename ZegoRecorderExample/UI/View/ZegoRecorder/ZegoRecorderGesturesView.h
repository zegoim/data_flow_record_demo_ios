//
//  ZegoRecorderGesturesView.h
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/20.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSUInteger, ZegoRecorderGesturesType) {
    ZegoRecorderGesturesNone,          //无操作
    ZegoRecorderGesturesVoice,         //音量
    ZegoRecorderGesturesBrightness,    //亮度
    ZegoRecorderGesturesProgress,      //进度
};

NS_ASSUME_NONNULL_BEGIN

//手势监听视图
@protocol ZegoRecorderGesturesViewDelegate <NSObject>

//开始
-(void)touchesBeganWith:(CGPoint)point;

//移动
-(void)touchesMovedWith:(CGPoint)point;

//结束
-(void)touchesEndWith:(CGPoint)point;

//点击事件。包含单击，双击事件
-(void)tapGesture:(UITapGestureRecognizer*)recognizer;

@end

@interface ZegoRecorderGesturesView : UIView

@property (nonatomic,weak) id<ZegoRecorderGesturesViewDelegate>delegate;

@property (nonatomic, assign) CGPoint startPoint;//手势触摸起始位置
@property (nonatomic, assign) ZegoRecorderGesturesType gestureType;//手势类型
@property (nonatomic, assign) CGFloat startVolume;//记录当前音量
@property (nonatomic, assign) CGFloat startBrightness;//记录当前亮度
@property (nonatomic, assign) CGFloat startProgress;//开始进度
@property (nonatomic, assign) CGFloat progress;//计算出当前的进度
@property (nonatomic, assign) CGFloat volume;//计算出的音量
@property (nonatomic, assign) CGFloat brightness;//计算出的亮度

@end

NS_ASSUME_NONNULL_END
