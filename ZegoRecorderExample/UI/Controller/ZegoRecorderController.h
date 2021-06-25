//
//  ZegoRecorderController.h
//  ZegoRecorderExample
//
//  Created by liquan on 2021/4/22.
//  Copyright © 2021 Zego. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZegoRecorderController : UIViewController

//任务ID，获取本次回放的标识
@property (nonatomic, strong) NSString *taskID;

@end

NS_ASSUME_NONNULL_END
