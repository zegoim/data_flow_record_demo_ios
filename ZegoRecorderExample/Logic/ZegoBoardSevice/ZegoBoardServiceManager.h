//
//  ZegoWhiteboardServiceManager.h
//  ZegoWhiteboardExample
//
//  Created by Xuyang Nie on 2020/11/24.
//

#import <Foundation/Foundation.h>
#import <ZegoWhiteboardView/ZegoWhiteboardDefine.h>
#import <ZegoWhiteboardView/ZegoWhiteboardView.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZegoBoardServiceManager : NSObject

//SDK单例
+ (instancetype)shareManager;

//初始化白板和文件SDK
- (void)initWithAppID:(unsigned int )appID
              appSign:(NSString *)appSign
      complementBlock:(void(^_Nullable)(NSInteger error))complementBlock;

//设置自定义字体及粗体
- (void)setupCustomFontName:(NSString *)fontName boldName:(NSString *)boldName;

//反初始化SDK
- (void)uninit;

//获取SDK 版本号
- (NSString *)getVersion;

@end

NS_ASSUME_NONNULL_END
