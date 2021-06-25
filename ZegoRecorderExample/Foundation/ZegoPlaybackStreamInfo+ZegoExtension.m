//
//  ZegoPlaybackStreamInfo+ZegoExtension.m
//  ZegoRecorderExample
//
//  Created by liquan on 2021/5/24.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZegoPlaybackStreamInfo+ZegoExtension.h"

@implementation ZegoPlaybackStreamInfo (ZegoExtension)

- (NSString *)playback_id
{
    if (self.type == ZegoPlaybackMediaStream ) {
        NSLog(@"Stream ID %@",self.mediaInfo.stream_id);
        return  self.mediaInfo.stream_id;
    }else if (self.type == ZegoPlaybackWhiteboardStream){
        NSLog(@"Whiteboard ID %@",@(self.whiteboardInfo.whiteboard_id).stringValue);
        return @(self.whiteboardInfo.whiteboard_id).stringValue;
        
    }
    NSLog(@"warning id Error");
    return @"";
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"type = %ld , whitboard id %llu, streamID %@ beginTime %ld ,endTime %ld, size %@,zorder%d,isdisplay%d",(long)self.type,self.whiteboardInfo.whiteboard_id,self.mediaInfo.stream_id,self.begin_time,self.end_time,NSStringFromCGRect(CGRectMake(self.x, self.y, self.width, self.height)),self.zorder,self.display];
}

@end
