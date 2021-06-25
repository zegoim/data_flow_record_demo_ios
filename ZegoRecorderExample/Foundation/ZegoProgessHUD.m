//
//  ZegoProgessHUD.m
//  ZegoWhiteboardExample
//
//  Created by MartinNie on 2020/12/5.
//

#import "ZegoProgessHUD.h"
@interface ZegoProgessHUD ()
@property (nonatomic, strong) MBProgressHUD  *hudView;
@property (nonatomic, strong) void(^cancleBlock)(void);
@end
@implementation ZegoProgessHUD

+ (void)showIndicatorHUDText:(NSString *)text onView:(UIView *)view{
    [MBProgressHUD hideHUDForView:view animated:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.bezelView.color = [UIColor colorWithWhite:0 alpha:0.8];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.layer.masksToBounds = YES;
    hud.bezelView.layer.cornerRadius = 4;
    
    hud.contentColor = [UIColor whiteColor];
    
    hud.label.textColor = [UIColor whiteColor];
    hud.label.font = [UIFont systemFontOfSize:12];
    hud.label.text = text;
    DLog(@"%@",text);
}

+ (void)showTipMessage:(NSString *)message onView:(UIView *)view{
    [MBProgressHUD hideHUDForView:view animated:NO];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.bezelView.color = [UIColor colorWithWhite:0 alpha:0.8];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.mode = MBProgressHUDModeText;
    hud.label.textColor = [UIColor whiteColor];
    hud.label.text = message;
    hud.label.font = [UIFont systemFontOfSize:12];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ZegoProgessHUD dismissOnView:view];
    });
    DLog(@"%@",message);
}

+ (void)showTipMessageWithErrorCode:(NSInteger)error onView:(UIView *)view{
    
    NSString *msg = nil;
//    switch (error) {
//        case 3030008:
//            msg = @"图片图元大小超出限制";
//            break;
//        case 3030009:
//            msg = @"不支持的图元类型";
//            break;
//        case 3030010:
//            msg = @"非法图片 url";
//            break;
//
//        default:
//            msg = [NSString stringWithFormat:@"error: %d", error];
//            break;
//    }
    msg = [NSString stringWithFormat:@"错误码: %ld", error];
    [ZegoProgessHUD showTipMessage:msg onView:view];
}

- (instancetype)initWithTitle:(NSString *)title onView:(UIView *)view cancelBlock:(void(^)(void))cancelBlock {
    if (self = [super init]) {
        [MBProgressHUD hideHUDForView:view animated:NO];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        self.hudView = hud;
        hud.bezelView.color = [UIColor colorWithWhite:0 alpha:0.8];
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.layer.masksToBounds = YES;
        hud.bezelView.layer.cornerRadius = 4;
        
        hud.contentColor = [UIColor whiteColor];
        hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        
        hud.label.textColor = [UIColor whiteColor];
        hud.label.font = [UIFont systemFontOfSize:12];
        hud.label.text = title;
        if (cancelBlock) {
            [hud.button addTarget:self action:@selector(didClickCancel:) forControlEvents:UIControlEventTouchUpInside];
            [hud.button setTitle:@"取消" forState:UIControlStateNormal];
            self.cancleBlock = cancelBlock;
        }
    }
    return self;
}

- (void)updateProgress:(CGFloat)progress {
    self.hudView.progress = progress;
    self.hudView.label.text = [NSString stringWithFormat:@"下载进度 %ld%%",(long)(progress * 100)];
}

- (void)didClickCancel:(UIButton *)sender {
    if (self.cancleBlock) {
        self.cancleBlock();
    }
}

+ (void)dismissOnView:(UIView *)view {
    [MBProgressHUD hideHUDForView:view animated:YES];
}
@end
