//
//  ZegoExpressSDKManager.h
//  ZegoWhiteboardExample
//
//  Created by Xuyang Nie on 2020/11/24.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZegoExpressSDKManager : NSObject

+ (instancetype)shareManager;

//初始化SDK
- (void)initSDKComplementBlock:(void(^_Nullable)(NSInteger error))complementBlock;

//反初始化SDK
- (void)uninit;

@end

NS_ASSUME_NONNULL_END
