//
//  ZegoRecorderGesturesView.m
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/20.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZegoRecorderGesturesView.h"

@implementation ZegoRecorderGesturesView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *doubleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        doubleRecognizer.numberOfTapsRequired = 2;// 双击
        [self addGestureRecognizer:doubleRecognizer];
        
        UITapGestureRecognizer *oneRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        oneRecognizer.numberOfTapsRequired = 1;// 单击
        [self addGestureRecognizer:oneRecognizer];
        
        [oneRecognizer requireGestureRecognizerToFail:doubleRecognizer];
    }
    return self;
}

- (void)tap:(UITapGestureRecognizer*)recognizer
{
    [self.delegate tapGesture:recognizer];
}

- (void)dealloc {
    DLog(@" %@ dealloc",self.class);
}

//触摸开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    DLog(@"获取触摸坐标%@",NSStringFromCGPoint(currentP));
    [self touchesBeganWith:currentP];
    [self.delegate touchesBeganWith:currentP];
}

//触摸移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    DLog(@"获取移动坐标%@",NSStringFromCGPoint(currentP));
    [self touchesMoveWithPoint:currentP];
    [self.delegate touchesMovedWith:currentP];
    
}

//触摸结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    DLog(@"获取触摸结束坐标%@",NSStringFromCGPoint(currentP));
    [self touchesMoveWithPoint:currentP];
    [self.delegate touchesEndWith:currentP];
    
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint currentP = [touch locationInView:self];
    DLog(@"获取触摸结束cancel坐标%@",NSStringFromCGPoint(currentP));
    [self touchesMoveWithPoint:currentP];
    [self.delegate touchesEndWith:currentP];
}

#pragma -mark 事件处理
// 开始
- (void)touchesBeganWith:(CGPoint)point{
    //记录首次触摸坐标
    self.startPoint = point;
    //方向置为无
    self.gestureType = ZegoRecorderGesturesNone;
}

- (void)touchesMoveWithPoint:(CGPoint)point {
   
    //得出手指移动的距离
    CGPoint panPoint = CGPointMake(point.x - self.startPoint.x, point.y - self.startPoint.y);
    [self caclulateGestureType:panPoint];

    if (self.gestureType == ZegoRecorderGesturesNone) return;
    
    switch (self.gestureType) {
        case ZegoRecorderGesturesProgress:
        {
            //进度调节
            CGFloat progress = self.startProgress + (panPoint.x / self.width / 0.5);
            self.progress = [ZegoRecorderGesturesView isInvalid:progress];
            DLog(@" 进度 %f",self.progress);
        }
            break;
        case ZegoRecorderGesturesVoice:
        {
            //音量或者亮度调节
            self.volume  = [ZegoRecorderGesturesView isInvalid:self.startVolume - panPoint.y / self.height / 0.5];;
            DLog(@" 音量 %f",self.volume);
        }
            break;
        case ZegoRecorderGesturesBrightness:
        {
            //音量或者亮度调节
            self.brightness = [ZegoRecorderGesturesView isInvalid:self.startBrightness - panPoint.y / self.height / 0.5];
            DLog(@" 亮度 %f",self.brightness);
        }
            break;
            
        default:
            break;
    }
}

+ (CGFloat)isInvalid:(CGFloat)rate
{
    CGFloat progress = rate;
    if (progress > 1) {
        progress = 1;
    } else if (progress < 0) {
        progress = 0;
    }
    return progress;
}

- (void)caclulateGestureType:(CGPoint)panPoint
{
    if (self.gestureType != ZegoRecorderGesturesNone) return;
    
    if (panPoint.x >= 30 || panPoint.x <= -30) {
        
        self.gestureType = ZegoRecorderGesturesProgress;
        
    }else if (panPoint.y >= 30 || panPoint.y <= -30){
        
        if (self.startPoint.x >= self.width / 2.0) {
             //音量
             self.gestureType = ZegoRecorderGesturesVoice;
         } else {
             //亮度
             self.gestureType = ZegoRecorderGesturesBrightness;
         }
    }
}


@end
