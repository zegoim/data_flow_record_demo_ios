//
//  ZegoRecorderView.m
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/20.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZegoRecorderView.h"

@interface ZegoRecorderView ()<ZegoWhiteboardManagerDelegate>

//视频流视图  id : view
@property (nonatomic, strong) NSMutableDictionary <NSString *, ZegoPlaybackStreamInfoView *>*mediaViewDictionary;

// innerView,用于展示布局
@property (nonatomic, strong) UIView *innerView;

//布局模型数组
@property (nonatomic, strong) NSArray <ZegoPlaybackStreamInfo *>*mediaInfoList;

//当前显示的白板
@property (nonatomic, strong) ZegoMediaBoardView *boardView;

@end

@implementation ZegoRecorderView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[ZegoWhiteboardManager sharedInstance] setDelegate:self];
    }
    return self;
}

- (void)layoutSubviews
{
    DLog(@"recorderview width %f height %f",self.width,self.height);
    [self layoutChange:self.mediaInfoList];
}

- (void)dealloc {
    DLog(@" %@ dealloc",self.class);
}


#pragma mark - Public Method
//切换白板
- (void)whiteboardSwitch:(unsigned long long)whiteboard_id
{
    ZegoMediaBoardView * view = (ZegoMediaBoardView *)[self.mediaViewDictionary objectForKey:@(whiteboard_id).stringValue];
    [view bringSubviewToFront:self.innerView];
    for (ZegoPlaybackStreamInfoView * view in self.mediaViewDictionary.allValues) {
        view.hidden = YES;
    }
    view.hidden = NO;
    self.boardView = view;
    
    DLog(@"切换白板 %@ 信息 %@",@(whiteboard_id).stringValue,view.mediaInfo);
}

//新增流
- (void)mediaStreamStart:(ZegoPlaybackStreamInfo*)info
{
    DLog(@"新增流 %@",info);
    ZegoMediaStreamView * view = [ZegoMediaStreamView new];
    view.mediaInfo = info;
    [self.innerView addSubview:view];
    [info.mediaInfo.play setMediaView:view];
    [self.mediaViewDictionary setObject:view forKey:info.playback_id];
    [self layoutChange:self.mediaInfoList];
}

//删除流
- (void)mediaStreamStop:(ZegoPlaybackStreamInfo*)info
{
    DLog(@"删除流 %@",info);
    ZegoPlaybackStreamInfoView *view = [self.mediaViewDictionary objectForKey:info.playback_id];
    [self.mediaViewDictionary removeObjectForKey:info.playback_id];
    [view removeFromSuperview];
}

//重新布局
- (void)layoutChange:(NSArray<ZegoPlaybackStreamInfo *> *)mediaInfoList
{
    DLog(@"布局通知 %@",mediaInfoList);

    self.mediaInfoList = mediaInfoList;
    
    self.innerView.size = [self getSafeAreaSize];

    self.innerView.center = self.center;
    
    for (ZegoPlaybackStreamInfo * info in mediaInfoList) {
        ZegoPlaybackStreamInfoView * view = [self.mediaViewDictionary objectForKey:info.playback_id];
        
        CGFloat scale = self.innerView.width / kSafeAreaWidth;
        view.frame = CGRectMake(info.x * scale, info.y * scale, info.width * scale, info.height * scale);
        
        view.mediaInfo = info;
        view.hidden = !info.display;
        view.layer.zPosition = info.zorder;
    }
}
#pragma mark - Action event
#pragma mark - Delegate
#pragma mark - ZegoWhiteboardManagerDelegate
- (void)onWhiteboardAdd:(ZegoWhiteboardView *)whiteboardView {
    DLog(@"增加白板 %@",whiteboardView.whiteboardModel);
    ZegoMediaBoardView  * view = [ZegoMediaBoardView new];
    view.hidden = YES;
    [self.innerView addSubview:view];
    [self.mediaViewDictionary setObject:view forKey:@(whiteboardView.whiteboardModel.whiteboardID).stringValue];
    [view setWhiteboardView:whiteboardView];
}

- (void)onWhiteboardRemoved:(ZegoWhiteboardID)whiteboardID {
    DLog(@"删除白板 %@",@(whiteboardID).stringValue);
    ZegoPlaybackStreamInfoView * view = [self.mediaViewDictionary objectForKey:@(whiteboardID).stringValue];
    [self.mediaViewDictionary removeObjectForKey:@(whiteboardID).stringValue];
    [view removeFromSuperview];
}

- (void)onPlayAnimation:(NSString *)animationInfo {
    DLog(@"onPlayAnimation %@",animationInfo);
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        DLog(@"-[ZegoDocsView stopPlayAnimation] app在后台, 不播放音视频");
        [self.boardView.docsView stopPlay:0];
        return;
    }
    DLog(@"-[ZegoDocsView playAnimation] app在前台, 继续播放音视频");
    [self.boardView.docsView playAnimation:animationInfo];
}

- (void)onError:(ZegoWhiteboardViewError)error whiteboardView:(nonnull ZegoWhiteboardView *)whiboardView
{}

- (void)onWhiteboardAuthChanged:(NSDictionary *)authInfo
{}

- (void)onWhiteboardGraphicAuthChanged:(NSDictionary *)authInfo
{}

#pragma mark - Private

#pragma mark – Config method

#pragma mark - Set Get method
- (NSMutableDictionary *)mediaViewDictionary
{
    if (!_mediaViewDictionary) {
        _mediaViewDictionary = [NSMutableDictionary new];
    }
    return _mediaViewDictionary;
    
}

- (UIView *)innerView
{
    if (!_innerView) {
        _innerView = [UIView new];
        [self addSubview:_innerView];
    }
    return _innerView;
}

- (CGSize)getSafeAreaSize
{
    CGSize size = self.size;
    CGFloat rate = self.width / self.height;
    if (rate > kSafeAreaWidth / kSafeAreaHeight) {
        size = CGSizeMake(self.height * kSafeAreaWidth / kSafeAreaHeight, self.height);
    }else{
        size = CGSizeMake(self.width, self.width / kSafeAreaWidth * kSafeAreaHeight);
    }
    return size;
}

@end
