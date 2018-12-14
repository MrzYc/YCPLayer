//
//  YCTimeManager.m
//  Player
//
//  Created by zhYch on 2018/8/17.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import "YCTimeManager.h"

@interface YCTimer ()

/**  执行时间  */
@property (nonatomic, assign) NSTimeInterval   timeInterval;

/**  延迟时间  */
@property (nonatomic, assign) float   delayTime;

/**  线程   */
@property (nonatomic, strong) dispatch_queue_t serialQueue;

/**  是否重复  */
@property (nonatomic, assign) BOOL    repeat;

/**  响应事件   */
@property (nonatomic, copy) dispatch_block_t   action;

/**  定时器名字  */
@property (nonatomic, strong) NSString   *timerName;

/** 是否正在运行  */
@property (nonatomic, assign) BOOL  isRuning;

/**  定时器 */
@property (nonatomic,strong) dispatch_source_t timer_t;

/*  事件响应次数   */
@property (nonatomic, assign) NSInteger actionTimes;

@end

@implementation YCTimer

- (instancetype)initTimerWithTimeInterval:(double)interval delayTime:(float)time queue:(dispatch_queue_t)queue repeats:(BOOL)repeats action:(dispatch_block_t)aciton {
    if (self = [super init]) {
        self.timeInterval = interval;
        self.delayTime = time;
        self.repeat = repeats;
        self.action = aciton;
        self.isRuning = NO;
        self.serialQueue = dispatch_queue_create([[NSString stringWithFormat:@"YCTimer.%p", self] cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        self.timer_t = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.serialQueue);
        dispatch_set_target_queue(self.serialQueue, queue);
    }
    return self;
}

- (instancetype)initDispatchTimerWithName:(NSString *)timerName timeInterval:(double)interval delayTime:(float)time queue:(dispatch_queue_t)queue repeats:(BOOL)repeats action:(dispatch_block_t)aciton {
    if (self = [super init]) {
        self.timerName = timerName;
        self.timeInterval = interval;
        self.delayTime = time;
        self.action = aciton;
        self.isRuning = NO;
        self.repeat = repeats;
        self.serialQueue           = dispatch_queue_create([[NSString stringWithFormat:@"YCTimer.%p", self] cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
        self.timer_t      = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.serialQueue);
        dispatch_set_target_queue(self.serialQueue, queue);
    }
    return self;
}



- (void)replaceOldAction:(dispatch_block_t)action {
    self.action = action;
}

- (void)startTimer {
    dispatch_async(self.serialQueue, ^{
        dispatch_source_set_timer(self.timer_t, dispatch_time(DISPATCH_TIME_NOW, (NSInteger)(self.delayTime * NSEC_PER_SEC)),(NSInteger)(self.timeInterval * NSEC_PER_SEC), 0 * NSEC_PER_SEC);
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(self.timer_t, ^{
            if (self.action) {
                self.action();
                self.actionTimes++;
            }
            if (!self.repeat) {
                [weakSelf cancelTimer];
            }
        });
        [self resumeTimer];
    });
}

- (void)responseOnceTimer {
    self.isRuning = YES;
    if (self.action) {
        self.action();
        self.actionTimes++;
    }
    self.isRuning = NO;
}

- (void)cancelTimer {
    dispatch_async(self.serialQueue, ^{
        if (!self.isRuning) {
            [self resumeTimer];
        }
        dispatch_source_cancel(self.timer_t);
    });
}

- (void)suspendTimer {
    dispatch_async(self.serialQueue, ^{
        if (self.isRuning) {
            dispatch_suspend(self.timer_t);
            self.isRuning = NO;
        }
    });
}

- (void)resumeTimer {
    dispatch_async(self.serialQueue, ^{
        if (!self.isRuning) {
            dispatch_resume(self.timer_t);
            self.isRuning = YES;
        }
    });
}

@end


@interface YCTimeManager() <NSCopying, NSMutableCopying>

/** timer 字典  */
@property (nonatomic, strong) NSMutableDictionary *timerObjectCache;

/** 信号  */
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

@end

    
@implementation YCTimeManager

static YCTimeManager *_manager = nil;
+(id)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

+ (instancetype)shareManager {
    return [[self alloc] init];
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super init];
        self.timerObjectCache = [NSMutableDictionary dictionary];
        self.semaphore = dispatch_semaphore_create(1);
    });
    return _manager;
}


- (id)copyWithZone:(NSZone *)zone {
    return _manager;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _manager;
}


- (void)createDispatchTimerWithName:(NSString *)timerName timeInterval:(NSTimeInterval)interval delaytime:(float)delayTime queue:(dispatch_queue_t)queue repeats:(BOOL)repeats action:(dispatch_block_t)action {
    NSParameterAssert(timerName);
    __strong NSString *string = timerName;
    YCTimer *timer = [self timerWithName:string];
    if (timer) {
        return;
    }
    if (queue == nil) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    timer = [[YCTimer alloc] initDispatchTimerWithName:string timeInterval:interval delayTime:delayTime queue:queue repeats:repeats action:action];
    [self setTimerWithName:timer timerName:string];
}

//开启定时器
- (void)startTimer:(NSString *)timerName {
    YCTimer *timer = [self timerWithName:timerName];
    if (timer.isRuning && timer) {
        dispatch_async(timer.serialQueue, ^{
            NSParameterAssert(timerName);
            dispatch_source_t timer_t = timer.timer_t;
            dispatch_source_set_timer(timer_t, dispatch_time(DISPATCH_TIME_NOW, (NSInteger)(timer.delayTime * NSEC_PER_SEC)), (NSInteger)(timer.timeInterval * NSEC_PER_SEC), 0 * NSEC_PER_SEC);
            __weak typeof(self) weakSelf = self;
            dispatch_source_set_event_handler(timer_t, ^{
                if (timer.action) {
                    timer.action();
                    timer.actionTimes++;
                }
                if (timer.repeat) {
                    [weakSelf cancelTimerWithName:timerName];
                }
            });
            [self resumeTimer:timerName];          
        });
    }
}

//执行一次定时器
- (void)responseOnceTimer:(NSString *)timerName {
    YCTimer *timer = [self timerWithName:timerName];
    timer.isRuning = YES;
    if (timer.action) {
        timer.action();
        timer.actionTimes++;
    }
    timer.isRuning = NO;
}

//取消定时器
- (void)cancelTimerWithName:(NSString *)timerName {
    YCTimer *timer = [self timerWithName:timerName];
    if (timer.isRuning && timer) {
        [self resumeTimer:timerName];
    }
    if (timer) {
        dispatch_async(timer.serialQueue, ^{
            dispatch_source_cancel(timer.timer_t);
            [self.timerObjectCache removeObjectForKey:timerName];
        });
    }
}

//暂停定时器
- (void)suspendTimer:(NSString *)timerName {
    YCTimer *timer = [self timerWithName:timerName];
    if (timer.isRuning && timer) {
        //拿到当前线程线程
        dispatch_async(timer.serialQueue, ^{
            dispatch_suspend(timer.timer_t);
            timer.isRuning = NO;
        });
    }
}

//恢复定时器
- (void)resumeTimer:(NSString *)timerName {
    YCTimer *timer = [self timerWithName:timerName];
    if (!timer.isRuning && timer) {
        //拿到当前线程线程
        dispatch_async(timer.serialQueue, ^{
            dispatch_resume(timer.timer_t);
            timer.isRuning = YES;
        });
    }
}


//获取定时器
- (YCTimer *)timerWithName:(NSString *)timerName {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    __strong NSString *string = timerName;
    YCTimer *timer = [self.timerObjectCache objectForKey:string];
    dispatch_semaphore_signal(self.semaphore);
    return timer;
}

//存储定时器
- (void)setTimerWithName:(YCTimer *)timer timerName:(NSString *)timerName {
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    [self.timerObjectCache setObject:timer forKey:timerName];
    dispatch_semaphore_signal(self.semaphore);
}


@end
