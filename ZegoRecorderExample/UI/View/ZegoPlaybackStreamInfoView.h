//
//  ZegoPlaybackStreamInfoView.h
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/23.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//基础播放视图
@interface ZegoPlaybackStreamInfoView : UIView

//回放的数据模型
@property (nonatomic ,strong) ZegoPlaybackStreamInfo *mediaInfo;

@end

NS_ASSUME_NONNULL_END
