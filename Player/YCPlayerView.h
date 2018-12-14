//
//  YCPlayerView.h
//  Player
//
//  Created by zhYch on 2018/8/13.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import <UIKit/UIKit.h>

//播放器状态
typedef NS_ENUM(NSInteger, YCPlayerState) {
    YCPlayerStateFailed,        // 播放失败
    YCPlayerStateBuffering,     // 缓冲中...
    YCPlayerStatePlaying,       // 正在播放中
    YCPlayerStateStopped,       //停止播放
    YCPlayerStateFinished,      //完成播放
};


//手势方向
typedef NS_ENUM(NSInteger, YCMoveDirection) {
    YCHorizontalPanMove = 0,
    YCVerticalPanMoved,
};

//状态栏全屏显示方式
typedef NS_ENUM(NSInteger, YCFullScreeenStatusBarShowType) {
    FullScreenShowAlways = 0,  //默认模式
    FullScreenShowNever,
    FullScreenShowFollowToolbar,
};

@interface YCPlayerView : UIView

/** 播放器的状态  */
@property (nonatomic, assign) YCPlayerState  playerState;

/** 播放链接  */
@property (nonatomic, strong) NSURL *playURL;

/**当前页面是否支持自动横屏,默认NO*/
@property (nonatomic, assign) BOOL     isLandscape;

/** 是否可以循环播放  */
@property (nonatomic, assign) BOOL  isReplay;

/**是否是全屏*/
@property (nonatomic, assign, readonly) BOOL   isFullScreen;

/** 锁屏  */
@property (nonatomic, assign) BOOL isLockScreen;

/** 状态栏隐藏  */
@property (nonatomic, assign) BOOL  statusBarHidden;

/** 手势方向  */
@property (nonatomic, assign) YCMoveDirection  panDirection;

/** 状态栏显示模式默认 不隐藏 */
@property (nonatomic, assign) YCFullScreeenStatusBarShowType  statusBarShowType;

@end
