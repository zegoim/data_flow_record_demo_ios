//
//  KeyCenter.h
//  ZegoRecorderExample
//
//  Created by liquan on 2021/6/24.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyCenter : NSObject

+ (unsigned int)appID;

+ (NSString *)appSign;

@end

NS_ASSUME_NONNULL_END
