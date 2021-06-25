//
//  ZegoProgessHUD.h
//  ZegoWhiteboardExample
//
//  Created by MartinNie on 2020/12/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoProgessHUD : NSObject

- (instancetype)initWithTitle:(NSString *)title onView:(UIView *)view cancelBlock:(void(^_Nullable)(void))cancelBlock;

- (void)updateProgress:(CGFloat)progress onView:(UIView *)view;
+ (void)showIndicatorHUDText:(NSString *)text onView:(UIView *)view;
+ (void)showTipMessage:(NSString *)message onView:(UIView *)view;
+ (void)showTipMessageWithErrorCode:(NSInteger)error onView:(UIView *)view; //根据错误码弹提示
+ (void)dismissOnView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
