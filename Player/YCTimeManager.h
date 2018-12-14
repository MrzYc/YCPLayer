//
//  YCTimeManager.h
//  Player
//
//  Created by zhYch on 2018/8/17.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YCTimer : NSObject

//初始话定时器
- (instancetype)initTimerWithTimeInterval:(double)interval delayTime:(float)time queue:(dispatch_queue_t)queue repeats:(BOOL)repeats action:(dispatch_block_t)aciton;

/** 定时器执行次数  */
@property (nonatomic, assign, readonly) NSInteger actionTimes;

/**开始定时器*/
- (void)startTimer;

/**执行一次定时器响应*/
- (void)responseOnceTimer;

/**取消定时器*/
- (void)cancelTimer;

/**暂停定时器*/
- (void)suspendTimer;

/**恢复定时器*/
- (void)resumeTimer;

/**替换旧的响应*/
- (void)replaceOldAction:(dispatch_block_t)action;

@end

@interface YCTimeManager : NSObject

+ (instancetype)shareManager;



@end
