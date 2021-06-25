//
//  ZegoRecorderView.h
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/20.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZegoMediaStreamView.h"
#import "ZegoMediaBoardView.h"

NS_ASSUME_NONNULL_BEGIN

/// 播放器视图
@interface ZegoRecorderView : UIView

//切换白板
- (void)whiteboardSwitch:(unsigned long long)whiteboard_id;

//新增流
- (void)mediaStreamStart:(ZegoPlaybackStreamInfo*)info;

//删除流
- (void)mediaStreamStop:(ZegoPlaybackStreamInfo*)info;

//重新布局
- (void)layoutChange:(NSArray<ZegoPlaybackStreamInfo *> *)mediaInfoList;

@end

NS_ASSUME_NONNULL_END
