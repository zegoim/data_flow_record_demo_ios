//
//  ZegoRecorderVolumeView.h
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/22.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoRecorderVolumeView : UIView

//系统的音量控件
@property (nonatomic, strong) MPVolumeView * volumeView;
@property (nonatomic, strong) UISlider * volumeSlider;
//自定义的音量控件
@property (nonatomic, strong) UIButton * iconView;
@property (nonatomic, strong) UISlider * sliderView;
@property (nonatomic, assign) CGFloat volume; //音量 0 ~ 1 

@end

NS_ASSUME_NONNULL_END
