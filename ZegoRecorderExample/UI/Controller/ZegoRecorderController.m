//
//  ZegoRecorderController.m
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/22.
//  Copyright © 2021 Zego. All rights reserved.
//

#import "ZegoRecorderController.h"
#import "ZegoRecorderView.h"
#import "ZegoRecorderControl.h"

@interface ZegoRecorderController ()<ZegoRecorderControlDelegate,ZegoPlaybackPlayerEventDelegate,ZegoPlaybackCustomCommandDelegate>

@property (nonatomic, strong) ZegoRecorderView *recorderView;/// 视频视图
@property (nonatomic, strong) ZegoRecorderControl * recorderControl;/// 操作面板
@property (nonatomic, strong) ZegoRecorderPlayback *recorderService;/// SDK

@end

@implementation ZegoRecorderController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    
    //初始化视图
    [self configUI];
    [self.recorderControl.HUDView showAnimated:YES];
    
    @weakify(self)
    [self getToken:^(NSString *token) {     //获取token
        @strongify(self)
        [self loadRemoteDataWithToken:token];     //获取任务ID的对应的录制信息
    }];
}
- (void)dealloc {
    [_recorderService uninitSDK];
    DLog(@" %@ dealloc",self.class);
}
#pragma mark - Public Method
#pragma mark - Action event
#pragma mark - Delegate
#pragma mark - ZegoRecorderControlDelegate

- (void)recorderControlAction:(ZegoRecorderControlAction)action
{
    switch (action) {
        case ZegoRecorderControlPlay: //播放
        {
            if (self.recorderControl.isPlayEnd) {
                [self.recorderService start];
            }else{
                [self.recorderService resume];
            }
        }
            break;
        case ZegoRecorderControlPause: //暂停
        {
            [self.recorderService pause];
            
        }
            break;
        case ZegoRecorderControlProgress: //进度
        {
            DLog(@"seekTo %ld",(long)self.recorderControl.seekTime);
            if(self.recorderControl.isPlayEnd == NO){
                [self.recorderControl.HUDView showAnimated:YES];
                [self.recorderService seekTo:self.recorderControl.seekTime];
            }
        }
            break;
        case ZegoRecorderControlVolume://音量
        {}
            break;
        case ZegoRecorderControlExit: //退出
        {
            [self.recorderService stop];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - ZegoPlaybackPlayerEventDelegate

/**
 播放状态更新
 
 @param state 状态码
 */
- (void)onPlayStateUpdate:(enum ZegoPlaybackState)state
{
    DLog(@"state %ld",(long)state);
    [self.recorderControl playStateUpdate:state];
}

/**
 播放出错
 
 @param errCode 错误码
 */
- (void)onPlayError:(int)errCode
{
    [ZegoProgessHUD showTipMessage:[NSString stringWithFormat:@"播放错误%d",errCode] onView:self.view];
}

/**
 快进到指定时刻
 */
- (void)onSeekComplete:(int)state timestamp:(long)timestamp
{
    [self.recorderControl setCurrentTime:timestamp];
    [self.recorderControl.HUDView hideAnimated:YES];
}

/**
 播放进度回调
 */
- (void)onPlayingProgress:(long)timestamp
{
    [self.recorderControl setCurrentTime:timestamp];
}

/**
 初始化完成的回调（包含整个回放过程中所有出现过的流信息）
 */
- (void)onLoadComplete:(int)error duration:(long)duration
{
    [self.recorderControl.HUDView hideAnimated:YES];
    
    if (error == 0) {
        
        [self.recorderControl setTotalDuration:duration];
        //开始播放
        [self.recorderService start];
        
    }else{
        [ZegoProgessHUD showTipMessage:[NSString stringWithFormat:@"加载失败，错误码为 %d",error] onView:self.view];
    }
}

/**
 白板流的切换
 
 */
- (void)onWhiteboardSwitch:(unsigned long long)whiteboard_id;
{
    [self.recorderView whiteboardSwitch:whiteboard_id];
}

/**
 音视频流的开始
 
 @param info 流指针
 */
- (void)onMediaStreamStart:(ZegoPlaybackStreamInfo*)info
{
    [self.recorderView mediaStreamStart:info];
}

/**
 音视频流的结束
 
 @param info 流指针
 */
- (void)onMediaStreamStop:(ZegoPlaybackStreamInfo*)info
{
    [self.recorderView mediaStreamStop:info];
}

/**
 布局的变化，返回每个流的布局
 */
- (void)onLayoutChange:(NSArray<ZegoPlaybackStreamInfo *> *)mediaInfoList
{
    DLog(@"onLayoutChange: %@",mediaInfoList);
    [self.recorderView layoutChange:mediaInfoList];
}

/**
 下载缓存进度回调
 */
- (void)onDownloadCacheProgress:(int)error bFinsh:(bool)bFinsh progress:(float)progress
{
    
}

#pragma mark - ZegoPlaybackCustomCommandDelegate
- (void)OnCustomCommand:(ZegoCustomCommand*)cmd
{
    DLog(@"OnCustomCommand: %@",cmd.data);
    [ZegoProgessHUD showTipMessage:cmd.data onView:self.view];
    
}

#pragma mark - Private
//获取任务ID的对应的录制信息
- (void)loadRemoteDataWithToken:(NSString *)token {
    NSDictionary *params = @{
        @"app_id":@([KeyCenter appID]),
        @"access_token":token,
        @"task_id":self.taskID,
    };
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/javascript",@"text/html",@"text/plain",nil];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [securityPolicy setValidatesDomainName:NO];
    securityPolicy.allowInvalidCertificates = YES; //还是必须设成YES
    manager.securityPolicy = securityPolicy;
    
    @weakify(self)
    [[manager POST:kZegoGetPlayInfoAPI parameters:params headers:@{@"Content-Type":@"application/json; charset=utf-8"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self)
        NSDictionary * dic = (NSDictionary *)responseObject;
        if ([dic[@"code"] intValue] == 0) {
            NSString * play_info = dic[@"play_info"];
            [self.recorderService load:play_info];
            DLog(@"play_info %@",play_info);
        }else{
            [ZegoProgessHUD showTipMessage:[NSString stringWithFormat:@"加载错误%d :%@",[dic[@"code"] intValue],dic[@"message"]] onView:self.view];
            DLog(@"error %@",dic);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.recorderControl.HUDView hideAnimated:YES];
        [ZegoProgessHUD showTipMessage:[NSString stringWithFormat:@"加载错误:%@",error] onView:self.view];
        DLog(@"error %@",error);
    }] resume];
}

#pragma mark - 获取token
- (void)getToken:(nullable void (^)(NSString *token))success
{
    long long current_time = (long long)[[NSDate date] timeIntervalSince1970]; //获取当前时间戳
    long long expired_time = current_time + 7200; //过期unix时间戳，单位：秒
    
    NSString *appid = @([KeyCenter appID]).stringValue;  // 这里填写各自分配的appid
    NSString *serverSecret = @"eb2280544902dc1b7ab1fde3985bd083";  // 这里填写对应的ServerSecret
    NSString *nonce = @"aabbcceeddaabbcc";//自定义的随机数
    
    NSString *originString = [NSString stringWithFormat:@"%@%@%@%@",appid,serverSecret,nonce,@(expired_time).stringValue];
    NSString *hashString = originString.md5String;
    DLog(@"--hashString--:%@ length %ld",hashString,hashString.length);
    
    NSDictionary *tokenInfo = @{
        @"ver":@(1),
        @"hash":hashString,
        @"nonce":nonce,
        @"expired":@(expired_time),
    };
    
    NSString * token = tokenInfo.jsonStringEncoded.base64EncodedString;
    
    NSDictionary *params = @{
        @"version":@(1),
        @"seq":@(1),
        @"app_id":@(appid.integerValue),
        @"token":token,
    };
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/javascript",@"text/html",@"text/plain",nil];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [securityPolicy setValidatesDomainName:NO];
    securityPolicy.allowInvalidCertificates = YES; //还是必须设成YES
    manager.securityPolicy = securityPolicy;
    
    @weakify(self)
    [[manager POST:kZegoGetTokenAPI parameters:params headers:@{@"Content-Type":@"application/json; charset=utf-8"} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self)
        NSDictionary * dic = (NSDictionary *)responseObject;
        
        if ([dic[@"code"] intValue] == 0) {
            NSDictionary * data = dic[@"data"];
            NSString * accesstoken = data[@"access_token"];
            if (success) {
                success(accesstoken);
            }
        }else{
            [ZegoProgessHUD showTipMessage:[NSString stringWithFormat:@"获取token失败%d :%@",[dic[@"code"] intValue],dic[@"message"]] onView:self.view];
            DLog(@"error %@",dic);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.recorderControl.HUDView hideAnimated:YES];
        [ZegoProgessHUD showTipMessage:[NSString stringWithFormat:@"获取token失败:%@",error] onView:self.view];
        DLog(@"error %@",error);
    }] resume];
    
}

#pragma mark – Config method

- (void)configUI
{
    [self.recorderView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.view).offset(self.view.safeAreaInsets.left);
            make.top.equalTo(self.view).offset(self.view.safeAreaInsets.top);
            make.bottom.equalTo(self.view).offset(self.view.safeAreaInsets.bottom);
            make.right.equalTo(self.view).offset(self.view.safeAreaInsets.right);
        } else {
            make.left.right.top.bottom.equalTo(self.view);
        }
    }];
    
    [self.recorderControl mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(self.view.safeAreaInsets.left);
        make.top.equalTo(self.view).offset(self.view.safeAreaInsets.top);
        make.bottom.equalTo(self.view).offset(self.view.safeAreaInsets.bottom);
        make.right.equalTo(self.view).offset(self.view.safeAreaInsets.right);
    }];
}

#pragma mark - Set Get method

- (ZegoRecorderControl *)recorderControl
{
    if (!_recorderControl) {
        _recorderControl = [ZegoRecorderControl new];
        _recorderControl.delegate = self;
        [self.view addSubview:_recorderControl];
    }
    return _recorderControl;
}

- (ZegoRecorderView *)recorderView
{
    if (!_recorderView) {
        _recorderView = [[ZegoRecorderView alloc] init];
        [self.view addSubview:_recorderView];
    }
    return _recorderView;
}

- (ZegoRecorderPlayback *)recorderService
{
    if (!_recorderService) {
        _recorderService = [[ZegoRecorderPlayback alloc] init];
        [_recorderService initSDK];
        [_recorderService setCacheFolderPath:kZegoRecorderPath];
        [_recorderService setLogFolderPath:kZegoLogPath];
        [_recorderService setDeviceSize:kSafeAreaWidth height:kSafeAreaHeight];
        [_recorderService setPlaybackPlayerEventDelegate:self];
        [_recorderService setPlaybackCustomCommandDelegate:self];
    }
    return _recorderService;
}

@end
