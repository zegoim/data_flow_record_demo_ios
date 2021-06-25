//
//  ZegoWhiteboardServiceManager.m
//  ZegoWhiteboardExample
//
//  Created by Xuyang Nie on 2020/11/24.
//

#import "ZegoBoardServiceManager.h"
#import <ZegoWhiteboardView/ZegoWhiteboardManager.h>
#import "ZegoLocalEnvManager.h"
#import "ZGAppSignHelper.h"
@interface ZegoBoardServiceManager()

@property (nonatomic, strong) ZegoWhiteboardManager *wbManager;
@property (nonatomic, strong) ZegoDocsViewManager *docsManager;

@end
@implementation ZegoBoardServiceManager

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    static ZegoBoardServiceManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZegoBoardServiceManager alloc] init];
    });
    return manager;
}

- (void)initWithAppID:(unsigned int )appID
              appSign:(NSString *)appSign
      complementBlock:(void(^_Nullable)(NSInteger error))complementBlock
{
    self.wbManager = [ZegoWhiteboardManager sharedInstance];
    self.docsManager = [ZegoDocsViewManager sharedInstance];
    
    //初始化白板SDK
    ZegoWhiteboardConfig *wbConfig = [[ZegoWhiteboardConfig alloc] init];
    wbConfig.logPath = kZegoLogPath;
    wbConfig.cacheFolder = kZegoImagePath;
    __weak typeof(self) weakSelf = self;
    [self.wbManager initWithCompleteBlock:^(ZegoWhiteboardViewError errorCode) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        DLog(@"localWhiteboarManagerInitFinish,error:%ld",(long)errorCode);
        if (errorCode == 0) {
            [strongSelf.wbManager setConfig:wbConfig];
            
            //初始化文件SDK
            ZegoDocsViewConfig *docsConfig = [[ZegoDocsViewConfig alloc] init];
            docsConfig.dataFolder = kZegoDocsDataPath;
            docsConfig.logFolder = kZegoLogPath;
            docsConfig.cacheFolder = kZegoDocsDataPath;
            docsConfig.appID = [KeyCenter appID];
            docsConfig.appSign = [KeyCenter appSign];
            docsConfig.isTestEnv = [ZegoLocalEnvManager shareManager].docsSeviceTestEnv;
            
            [strongSelf.docsManager initWithConfig:docsConfig completionBlock:^(ZegoDocsViewError errorCode) {
                DLog(@"localDocsViewManagerInitFinish,error:%lu",(unsigned long)errorCode);
                if (complementBlock) {
                    complementBlock(errorCode);
                }
            }];
            
            if([ZegoLocalEnvManager shareManager].enableCutomFont){
                [strongSelf.wbManager setCustomFontWithName:@"SourceHanSansSC-Regular" boldFontName:@"SourceHanSansSC-Bold"];
            } else {
                [strongSelf.wbManager setCustomFontWithName:@"" boldFontName:@""];
            }
        } else {
            if (complementBlock) {
                complementBlock(errorCode);
            }
        }
    }];
}

- (BOOL)setupCustomConfig:(NSString *)value key:(NSString *)key {
    DLog(@"BoardSevice>>> getCustomizedConfigWithKey:%@",key);
    return [self.docsManager setCustomizedConfig:value key:key];
}

- (NSString *)getCustomizedConfigWithKey:(NSString *)key {
    DLog(@"BoardSevice>>> getCustomizedConfigWithKey:%@",key);
    return [self.docsManager getCustomizedConfigWithKey:key];
}

- (void)setupCustomFontName:(NSString *)fontName boldName:(NSString *)boldName {
    DLog(@"BoardSevice>>> setupCustomFontName:%@ boldName:%@",fontName,boldName);
    [self.wbManager setCustomFontWithName:fontName boldFontName:boldName];
}

- (void)clearCacheFolder {
    DLog(@"BoardSevice>>> clearCacheFolder");
    [self.docsManager clearCacheFolder];
}

- (void)clearRoomSrc {
    DLog(@"BoardSevice>>> clearRoomSrc");
    [self.wbManager clear];
}

- (void)uninit {
    [self clearRoomSrc];
    [self.wbManager uninit];
    [self.docsManager uninit];
    self.wbManager = nil;
    self.docsManager = nil;
    DLog(@"BoardSevice>>> uninit");
}

- (NSString *)getVersion {
    DLog(@"BoardSevice>>> getVersion");
    return [NSString stringWithFormat:@"Version:\ndocsView:%@\nwhiteboardView:%@",@"",self.wbManager.getVersion];
}

@end
