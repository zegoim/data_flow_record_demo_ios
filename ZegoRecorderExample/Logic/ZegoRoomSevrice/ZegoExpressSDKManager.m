//
//  ZegoExpressSDKManager.m
//  ZegoWhiteboardExample
//
//  Created by Xuyang Nie on 2020/11/24.
//
#import "ZegoExpressSDKManager.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

@interface ZegoExpressSDKManager()<ZegoEventHandler>

@property (nonatomic, strong) ZegoExpressEngine *api;

@end

@implementation ZegoExpressSDKManager

+ (instancetype)shareManager {
    static ZegoExpressSDKManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZegoExpressSDKManager alloc] init];
    });
    return manager;
}

//初始化expressSDK
- (void)initSDKComplementBlock:(void(^_Nullable)(NSInteger error))complementBlock{

    BOOL result = [ZegoLocalEnvManager shareManager].roomSeviceTestEnv;
    self.api = [ZegoExpressEngine createEngineWithAppID:[KeyCenter appID] appSign:[KeyCenter appSign] isTestEnv:result scenario:2 eventHandler:self];
    if (complementBlock) {
        complementBlock(0);
    }
}

- (void)uninit {
    [ZegoExpressEngine destroyEngine:nil];
}

@end
