//
//  ZegoRecorderControl.m
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/20.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZegoRecorderControl.h"
#import "ZegoRecorderVolumeView.h"
#import "ZegoRecorderProgressView.h"

static const CGFloat kZegoRecorderControlAnimationTimeInterval = 0.25;

@interface ZegoRecorderControl ()<ZegoRecorderGesturesViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) ZegoRecorderVolumeView *volumeView;
@property (nonatomic, strong) ZegoRecorderProgressView *progressView;

@property (nonatomic, assign) BOOL isBarShowing;///顶部栏底部栏是否显示

@end

@implementation ZegoRecorderControl

#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self configUI];
        
        self.isBarShowing = YES;
        self.isPlayEnd = YES;
 
    }
    return self;
}

- (void)dealloc {
    DLog(@" %@ dealloc",self.class);
}

#pragma mark - Public Method

- (void)setIsBarShowing:(BOOL)isBarShowing
{
    if (_isBarShowing == isBarShowing) return;
    
    _isBarShowing = isBarShowing;
    [UIView animateWithDuration:kZegoRecorderControlAnimationTimeInterval animations:^{
        self.topBar.hidden = !isBarShowing;
        self.bottomBar.hidden = !isBarShowing;
    } completion:^(BOOL finished) {
        self.topBar.hidden = !isBarShowing;
        self.bottomBar.hidden = !isBarShowing;
    }];
}

- (void)playStateUpdate:(enum ZegoPlaybackState)state
{
    switch (state) {
        case ZegoPlaybackStateNoPlay: //不在播放
            self.playButton.selected = NO;
            self.isPlayEnd = NO;
            break;
        case ZegoPlaybackStatePlaying: //播放中
            self.playButton.selected = YES;
            self.isPlayEnd = NO;
            break;
        case ZegoPlaybackStatePausing: //播放暂停
            self.playButton.selected = NO;
            self.isPlayEnd = NO;
            break;
        case ZegoPlaybackStatePlayEnded: //播放结束
            self.playButton.selected = NO;
            self.isPlayEnd = YES;
            break;
        default:
            break;
    }
}

#pragma mark - Action event
-(void)tapGesture:(UITapGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        if (recognizer.numberOfTapsRequired == 1) {
            //单击隐藏
            self.isBarShowing = !self.isBarShowing;
        }
        if (recognizer.numberOfTapsRequired == 2) {
            //双击类似播放按钮
            [self buttonClick:self.playButton];
        }
    }
}

- (void)progressSliderValueDidChanged:(UISlider *)slider
{
    self.currentTime = slider.value * self.totalDuration;
    
    if ([self.delegate respondsToSelector:@selector(recorderControlAction:)]) {
        [self.delegate recorderControlAction:ZegoRecorderControlProgress];
    }
}

- (void)buttonClick:(UIButton *)button
{
    ZegoRecorderControlAction action = ZegoRecorderControlPlay;
    if (button == self.playButton) {
        action = !button.selected ? ZegoRecorderControlPlay : ZegoRecorderControlPause;
        button.selected = !button.selected;
    }
    if (button == self.closeButton) {
        action = ZegoRecorderControlExit;
    }
    if ([self.delegate respondsToSelector:@selector(recorderControlAction:)]) {
        [self.delegate recorderControlAction:action];
    }
}
#pragma mark - Delegate
//开始
-(void)touchesBeganWith:(CGPoint)point
{
//    [self cancelAutoFadeOutControlBar];
//    self.isBarShowing = self.topBar.alpha = self.bottomBar.alpha = 1;
    self.gesturesView.startVolume = self.volumeView.volume;
    self.gesturesView.startBrightness = [UIScreen mainScreen].brightness;
    self.gesturesView.startProgress = self.progressSlider.value;
    self.volumeView.alpha = 0;
    self.progressView.alpha = 0;
}

//移动
-(void)touchesMovedWith:(CGPoint)point
{
    switch (self.gesturesView.gestureType) {
        case ZegoRecorderGesturesVoice:
            self.volumeView.alpha = 1;
            [self.volumeView setVolume:self.gesturesView.volume];
            break;
        case ZegoRecorderGesturesBrightness:
//            [[UIScreen mainScreen] setBrightness:self.gesturesView.brightness];
            break;
        case ZegoRecorderGesturesProgress:
            self.seekTime = self.gesturesView.progress * self.totalDuration;
            [self.progressView setCurrentTime:self.seekTime totalTime:self.totalDuration];
            self.progressView.alpha = 1;
//          self.progressSlider.value = self.gesturesView.progress;
//          self.currentTime = self.totalDuration * self.progressSlider.value;

            break;
        default:
            break;
    }
}

//结束
-(void)touchesEndWith:(CGPoint)point
{
    self.volumeView.alpha = 0;
    self.progressView.alpha = 0;
    ZegoRecorderControlAction action = ZegoRecorderControlNone;
    switch (self.gesturesView.gestureType) {
        case ZegoRecorderGesturesProgress:
            action = ZegoRecorderControlProgress;
            break;
        case ZegoRecorderGesturesVoice:{
            action = ZegoRecorderControlVolume;
            [self.volumeView setVolume:self.gesturesView.volume];
        }
        case ZegoRecorderGesturesBrightness:
            break;
        default:
            break;
    }
    if ([self.delegate respondsToSelector:@selector(recorderControlAction:)]) {
        [self.delegate recorderControlAction:action];
    }
}

#pragma mark - Private
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.hidden || self.alpha == 0 || self.userInteractionEnabled == NO) {
        return  nil;
    }
    CGPoint closePoint = [self convertPoint:point toView:self.closeButton];
    
    if ([self.closeButton pointInside:closePoint withEvent:event]) {  //关闭按钮永远响应事件
        return self.closeButton;
    }
    
    UIView * view = [super hitTest:point withEvent:event];
    
    if (self.HUDView.alpha > 0) { //如果有加载动画则不响应事件
        return nil;
    }
    if (view == self.playButton || view == self.closeButton ) { //只响应播放,关闭按钮，其他都交给gestureView响应
        return view;
        
    }else if(view == self.gesturesView || view == self.topBar || view == self.bottomBar){
        return self.gesturesView;
    }
    return  view;
}

#pragma mark – Config method
- (void)configUI
{
    [self.gesturesView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self);
    }];
    [self.topBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.mas_equalTo(18.5);
        make.height.mas_equalTo(44);
    }];
    [self.closeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(12);
        make.width.height.mas_equalTo(20);
    }];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(44.5);
        make.centerY.equalTo(self.topBar);
        make.right.lessThanOrEqualTo(self.topBar.mas_right).offset(-16 * 2);
    }];
    [self.bottomBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(44);
    }];
    [self.playButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.width.mas_equalTo(16);
        make.height.mas_equalTo(18);
        make.bottom.equalTo(self).offset(-23);
    }];
    [self.currentTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playButton);
        make.left.mas_equalTo(52);
        make.right.lessThanOrEqualTo(self.bottomBar.mas_right).offset(-16 * 2);
    }];
    [self.progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.currentTimeLabel.mas_right).offset(12);
        make.right.equalTo(self.totalDurationLabel.mas_left).offset(-12);
        make.height.mas_equalTo(3);
        make.centerY.equalTo(self.playButton);
    }];
    [self.totalDurationLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playButton);
        make.right.equalTo(self.bottomBar).offset(-16);
    }];

    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(182);
        make.height.mas_equalTo(60);
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
    }];
    [self.volumeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(153);
        make.height.mas_equalTo(32);
        make.centerX.equalTo(self);
        make.top.mas_equalTo(40);

    }];
    [self.HUDView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.equalTo(self);
    }];
}

#pragma mark - Set Get method
///Setter

- (void)setTotalDuration:(NSTimeInterval)totalDuration
{
    _totalDuration = totalDuration;
    self.totalDurationLabel.text = [NSString stringFromTimeInterval:totalDuration];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime
{
    _currentTime = currentTime;
    self.currentTimeLabel.text = [NSString stringFromTimeInterval:currentTime];
    self.progressSlider.value = currentTime / self.totalDuration * 1.0;
}

- (void)setVolume:(int)volume
{
    _volume = volume;
    self.volumeView.sliderView.value = volume * 1.0/ 100;
}

/// Getter

- (UIView *)topBar
{
    if (!_topBar) {
        _topBar = [UIView new];
        _topBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self addSubview:_topBar];
    }
    return _topBar;
}

- (UIButton *)closeButton
{
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setEnlargeEdge:20];
        [self.topBar addSubview:_closeButton];
    }
    return _closeButton;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.text = @"名称";
        [self.topBar addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIView *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [UIView new];
        _bottomBar.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self addSubview:_bottomBar];
    }
    return _bottomBar;
}

- (UIButton *)playButton
{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"暂停"] forState:UIControlStateNormal];
        [_playButton setImage:[UIImage imageNamed:@"播放"] forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setEnlargeEdge:20];
        [self.bottomBar addSubview:_playButton];
    }
    return _playButton;
}

- (UILabel *)currentTimeLabel
{
    if (!_currentTimeLabel) {
        _currentTimeLabel = [UILabel new];
        _currentTimeLabel.numberOfLines = 0;
        _currentTimeLabel.textColor = UIColor.whiteColor;
        _currentTimeLabel.font = [UIFont systemFontOfSize:12];
        _currentTimeLabel.text = @"00:00";
        [self.bottomBar addSubview:_currentTimeLabel];
    }
    return _currentTimeLabel;
}

- (UISlider *)progressSlider
{
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        UIImage * image = [UIImage imageWithColor:[UIColor colorWithRed:10/255.0 green:132/255.0 blue:254/255.0 alpha:1.0] size:CGSizeMake(8, 8)];
        image = [image imageByRoundCornerRadius:4];
        [_progressSlider setThumbImage:image forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackTintColor:[UIColor colorWithRed:10/255.0 green:132/255.0 blue:254/255.0 alpha:1.0]];
        [_progressSlider setMaximumTrackTintColor: [UIColor colorWithRed:246/255.0 green:248/255.0 blue:250/255.0 alpha:1.0]];
        _progressSlider.value = 0.f;
        _progressSlider.maximumValue = 1;
        _progressSlider.minimumValue = 0;
        _progressSlider.enabled = NO;
        [_progressSlider addTarget:self action:@selector(progressSliderValueDidChanged:) forControlEvents:UIControlEventValueChanged];
        [self.bottomBar addSubview:_progressSlider];
    }
    return _progressSlider;
}

- (UILabel *)totalDurationLabel
{
    if (!_totalDurationLabel) {
        _totalDurationLabel = [UILabel new];
        _totalDurationLabel.numberOfLines = 0;
        _totalDurationLabel.textColor = UIColor.whiteColor;
        _totalDurationLabel.font = [UIFont systemFontOfSize:12];
        _totalDurationLabel.text = @"00:00";
        [self.bottomBar addSubview:_totalDurationLabel];
    }
    return _totalDurationLabel;
}

- (ZegoRecorderGesturesView *)gesturesView
{
    if (!_gesturesView) {
        _gesturesView = [[ZegoRecorderGesturesView alloc] init];
        _gesturesView.delegate = self;
        [self addSubview:_gesturesView];
    }
    return _gesturesView;
}

- (ZegoRecorderVolumeView *)volumeView
{
    if (!_volumeView) {
        _volumeView = [ZegoRecorderVolumeView new];
        _volumeView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
        _volumeView.layer.cornerRadius = 8;
        _volumeView.layer.maskedCorners = YES;
        _volumeView.alpha = 0;
        [self addSubview:_volumeView];
    }
    return _volumeView;
}

- (ZegoRecorderProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [ZegoRecorderProgressView new];
        _progressView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.4];
        _progressView.layer.cornerRadius = 8;
        _progressView.layer.maskedCorners = YES;
        _progressView.alpha = 0;
        [self addSubview:_progressView];
    }
    return _progressView;
}

- (MBProgressHUD *)HUDView
{
    if (!_HUDView) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        hud.removeFromSuperViewOnHide = NO;
        hud.bezelView.color = [UIColor colorWithWhite:0 alpha:0.8];
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.layer.masksToBounds = YES;
        hud.bezelView.layer.cornerRadius = 4;
        
        hud.contentColor = [UIColor whiteColor];
        
        hud.label.textColor = [UIColor whiteColor];
        hud.label.font = [UIFont systemFontOfSize:12];
        hud.label.text = @"加载中";
        _HUDView = hud;
    }
    return _HUDView;
}

@end
