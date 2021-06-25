//
//  ViewController.m
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/20.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ViewController.h"
#import "ZegoRecorderController.h"

@interface ViewController ()

@property (nonatomic ,assign) NSInteger errorCode;

@property (weak, nonatomic) IBOutlet UITextField *taskIDTextFiled;

@property (weak, nonatomic) IBOutlet UIView *envView;
@property (weak, nonatomic) IBOutlet UITextField *envTextFiled;

@end

@implementation ViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    //初始化SDK
    [self setupRoomSDK];
    
    self.envTextFiled.text = [ZegoLocalEnvManager shareManager].domain;
    self.envView.hidden = YES;

//    @weakify(self)
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
//        @strongify(self)
//        self.envView.hidden = NO;
//    }];
//    tap.numberOfTapsRequired = 3;
//    [self.view addGestureRecognizer:tap];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

#pragma mark - Public Method
#pragma mark - Action event
- (IBAction)start:(id)sender {
    
    if(self.errorCode == 0){
        
        if (self.taskIDTextFiled.text.length == 0) {
            [ZegoProgessHUD showTipMessage:@"任务ID 不能为空" onView:self.view];
            return;
        }
        
        ZegoRecorderController * vc = [[ZegoRecorderController alloc] init];
        vc.taskID = self.taskIDTextFiled.text;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
        
    }else{
        
        [ZegoProgessHUD showTipMessage:[NSString stringWithFormat:@"初始化SDK失败 %ld，请联系ZEGO技术支持",(long)self.errorCode] onView:self.view];
    }
    
}

//初始化音视频SDK
- (void)setupRoomSDK {
    
    [ZegoProgessHUD showIndicatorHUDText:@"开始初始化SDK" onView:self.view];
    __weak typeof(self) weakSelf = self;
    [[ZegoExpressSDKManager shareManager] initSDKComplementBlock:^(NSInteger error) {
        weakSelf.errorCode = error;
        if (error == 0) {
            [weakSelf setupWhiteboardSDK];
        }else{
            [ZegoProgessHUD dismissOnView:weakSelf.view];
            [ZegoProgessHUD showTipMessage:[NSString stringWithFormat:@"初始化音视频SDK失败，错误码 %ld",(long)error] onView:weakSelf.view];
        }
    }];
}

//初始化文件白板SDK
- (void)setupWhiteboardSDK
{
    __weak typeof(self) weakSelf = self;
    [[ZegoBoardServiceManager shareManager] initWithAppID:[KeyCenter appID] appSign:[KeyCenter appSign]  complementBlock:^(NSInteger error) {
        [ZegoProgessHUD dismissOnView:self.view];
        weakSelf.errorCode = error;
        if(error == 0){
//            [ZegoProgessHUD showTipMessage:@"初始化SDK成功" onView:weakSelf.view];
        }else{
            [ZegoProgessHUD showTipMessage:[NSString stringWithFormat:@"初始化白板文件SDK失败，错误码 %ld",error] onView:weakSelf.view];
        }
    }];
}

#pragma mark - Delegate
#pragma mark - Private

- (IBAction)saveEnv:(id)sender {
    
    [[ZegoLocalEnvManager shareManager] setupDomain:self.envTextFiled.text];
    exit(0);
}

#pragma mark – Config method

#pragma mark - Set Get method

@end
