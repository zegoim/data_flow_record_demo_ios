//
//  NSString+FormatValidator.m
//  ZegoWhiteboardViewDemo
//
//  Created by Vic on 2020/12/24.
//  Copyright © 2020 zego. All rights reserved.
//

#import "NSString+FormatValidator.h"
#import "ZGFormatValidator.h"

@implementation NSString (FormatValidator)

- (BOOL)isURL {
    return [ZGFormatValidator validateString:self withRegex:ZG_URL_REGEX];
}

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval
{
    if(interval < 0) interval = 0;
    NSInteger ti = interval / 1000;
    
    NSInteger second = ti;
    NSInteger minutes = 0;
    NSInteger hour = 0;
    
    if(ti >= 60){
        minutes = second / 60;
        second = second % 60;
        if (minutes >= 60) {
            hour = minutes / 60;
            minutes = minutes % 60;
        }
    }
    if (hour  > 0) {
        return [NSString stringWithFormat:@"%0.2ld:%0.2ld:%0.2ld",hour,minutes,second];;
    }
    return [NSString stringWithFormat:@"%0.2ld:%0.2ld",minutes,second];
}
@end
