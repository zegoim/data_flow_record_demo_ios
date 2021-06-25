//
//  ZegoPlaybackStreamInfo+ZegoExtension.h
//  ZegoRecorderExample
//
//  Created by liquan on 2021/5/24.
//  Copyright © 2021 Zego. All rights reserved.
//
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZegoPlaybackStreamInfo (ZegoExtension)

//白板或者流的ID。具有唯一性
@property (strong) NSString* playback_id;

@end

NS_ASSUME_NONNULL_END
