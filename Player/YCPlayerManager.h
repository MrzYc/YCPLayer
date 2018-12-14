//
//  YCPlayerManager.h
//  Player
//
//  Created by zhYch on 2018/9/5.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface YCPlayerManager : NSObject

/** 缓存条的颜色  */
@property (nonatomic, strong) UIColor *progressTintColor;

/** 进度条已播放颜色  */
@property (nonatomic, strong) UIColor *sliderMinColor;

/** 进度条未播放颜色  */
@property (nonatomic, strong) UIColor *sliderMaxColor;

/** 是否隐藏锁屏按钮  */
@property (nonatomic, assign) BOOL hiddenLock;

/** 是否隐藏截屏按钮  */
@property (nonatomic, assign) BOOL  hiddenSceenShot;

/** 是否隐藏缓存条 */
@property (nonatomic, assign) BOOL  hiddenProgress;

/** 是否隐藏播放速率按钮  */
@property (nonatomic, assign) BOOL  hiddenRate;

/** 播放器静音  */
@property (nonatomic, assign) BOOL  muted;

/** 初始化播放器音量  */
@property (nonatomic, assign) float  volume;

/** 播放器的速率  */
@property (nonatomic, assign) float  rate;

/** 播放器  */
@property (nonatomic, strong) AVPlayer *player;

/** 播放器锁屏状态  */
@property (nonatomic, assign) BOOL  lockScreenState;


/** 播放器全屏事件  */
@property (nonatomic, copy) void(^playerFullScreen)(BOOL isFullScreen);

/** 开始手势播放器的滑竿 */
@property (nonatomic, copy) void(^playerBeganchangeProgress)(void);

/** 滑动结束  */
@property (nonatomic, copy) void(^playerEndChangeProgress)(void);

/** 截屏事件  */
@property (nonatomic, copy) void(^playerScreenshots)(void);


//暂停
- (void)pausePlayer;

//开始播放
- (void)beginPlay;



@end
