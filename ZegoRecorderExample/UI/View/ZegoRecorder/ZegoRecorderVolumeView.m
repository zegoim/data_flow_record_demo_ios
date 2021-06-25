//
//  ZegoRecorderVolumeView.m
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/22.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZegoRecorderVolumeView.h"

@implementation ZegoRecorderVolumeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.iconView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(12);
            make.width.height.mas_equalTo(20);
            make.centerY.equalTo(self);
        }];
        
        [self.sliderView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconView.mas_right).offset(16);
            make.height.mas_equalTo(3);
            make.centerY.equalTo(self);
            make.right.equalTo(self.mas_right).offset(-16);

        }];
        //监听系统的音量
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(systemVolumeDidChangeNoti:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];

    }
    return self;
}

- (UIButton *)iconView
{
    if (!_iconView) {
        _iconView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_iconView setImage:[UIImage imageNamed:_volume > 0 ? @"音量打开" : @"音量关闭"] forState:UIControlStateNormal];
        [self addSubview:_iconView];
    }
    return _iconView;
}

- (UISlider *)sliderView
{
    if (!_sliderView) {
        _sliderView = [[UISlider alloc] init];
        UIImage * image = [UIImage imageWithColor:[UIColor colorWithRed:10/255.0 green:132/255.0 blue:254/255.0 alpha:1.0] size:CGSizeMake(8, 8)];
        image = [image imageByRoundCornerRadius:4];
        [_sliderView setThumbImage:image forState:UIControlStateNormal];
        [_sliderView setMinimumTrackTintColor:[UIColor colorWithRed:10/255.0 green:132/255.0 blue:254/255.0 alpha:1.0]];
        [_sliderView setMaximumTrackTintColor: [UIColor colorWithRed:246/255.0 green:248/255.0 blue:250/255.0 alpha:1.0]];
        _sliderView.value = _volume = [self getVolume];
        _sliderView.maximumValue = 1;
        _sliderView.minimumValue = 0;
        [self addSubview:_sliderView];
    }
    return _sliderView;
}


- (void)setVolume:(CGFloat)volume
{
    DLog(@"设置音量为 %f",volume);
    
    _volume = volume;
    [self.iconView setImage:[UIImage imageNamed:volume > 0 ? @"音量打开" : @"音量关闭"] forState:UIControlStateNormal];
    self.sliderView.value = volume;
 
    // 需要设置 showsVolumeSlider 为 YES
    self.volumeView.showsVolumeSlider = YES;
    [self.volumeSlider setValue:volume animated:NO];
}


- (MPVolumeView *)volumeView
{
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-100, -100, 40, 40)];
        _volumeView.hidden = NO;
        _volumeView.alpha = 0.01;
        for (UIView *view in [_volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            self.volumeSlider = (UISlider*)view;
            break;
           }
        }
        [self addSubview:_volumeView];
    }
    return _volumeView;
}

- (float)getVolume
{
    return self.volumeSlider.value > 0 ? self.volumeSlider.value : [[AVAudioSession sharedInstance] outputVolume];
}

- (void)systemVolumeDidChangeNoti:(NSNotification* )noti
{
    // 当前手机音量
    float volume = [[noti.userInfo valueForKey:@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
    self.sliderView.value = volume;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
