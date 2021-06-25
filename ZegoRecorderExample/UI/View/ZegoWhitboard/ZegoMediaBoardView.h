//
//  ZegoMediaBoardView.h
//  ZegoWhiteboardExample
//
//  Created by Xuyang Nie on 2020/11/27.
//

#import <UIKit/UIKit.h>
#import "ZegoPlaybackStreamInfoView.h"
NS_ASSUME_NONNULL_BEGIN

//文件白板播放视图
@interface ZegoMediaBoardView : ZegoPlaybackStreamInfoView

//白板视图
@property (nonatomic, strong) ZegoWhiteboardView *whiteboardView;
//文件视图，如果为纯白板则为空
@property (nonatomic, strong) ZegoDocsView *docsView;

- (void)removeFromSuperview;

@end

NS_ASSUME_NONNULL_END
