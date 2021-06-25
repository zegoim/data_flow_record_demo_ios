//
//  ZegoRecorderProgressView.m
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/22.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZegoRecorderProgressView.h"

@implementation ZegoRecorderProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.progressLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-20);
            make.top.equalTo(self).offset(18);
            make.bottom.equalTo(self).offset(-18);
            make.left.equalTo(self).offset(20);
        }];
    }
    return self;
}

- (UILabel *)progressLabel
{
    if (!_progressLabel) {
        _progressLabel = [UILabel new];
        _progressLabel.numberOfLines = 0;
        _progressLabel.adjustsFontSizeToFitWidth = YES;
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        [self setCurrentTime:0 totalTime:0];
        [self addSubview:_progressLabel];
    }
    return _progressLabel;
}

- (void)setCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;
{
    NSString * c  = [NSString stringFromTimeInterval:currentTime];
    NSString * t = [NSString stringFromTimeInterval:totalTime];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@/%@",c,t] attributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size: 25.5],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]}];
    [string addAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:10/255.0 green:132/255.0 blue:254/255.0 alpha:1.0]} range:NSMakeRange(0, c.length)];
    _progressLabel.attributedText = string;
}


@end
