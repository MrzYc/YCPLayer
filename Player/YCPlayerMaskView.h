//
//  YCPlayerMaskView.h
//  Player
//
//  Created by zhYch on 2018/8/14.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol YCPlayerMaskViewDelegate <NSObject>

@optional;

/**锁屏代理事件*/
- (void)playerLockScreenisLock:(BOOL)isLock;

/**返回按钮代理*/
- (void)playerBackAction;

/**播放暂停事件代理*/
- (void)playerPlayOrPauseisPause:(BOOL)isPause;

/**全屏按钮代理*/
- (void)playerisFullScreen:(BOOL)isFullScreen;

/**开始滑动*/
- (void)playerBeganchangeProgress:(UISlider *)slider;

/**滑动中*/
- (void)playerProgressValueChanged:(UISlider *)slider;

/**滑动结束*/
- (void)playerEndChangeProgress:(UISlider *)slider;

/** 切换播放速率事件 */
- (void)playerChangeRate:(CGFloat)rate;

/** 播放器截屏事件  */
- (void)playerScreenshots;


@end

@interface YCPlayerMaskView : UIView


/** 播放器的Item  */
@property (nonatomic, strong) AVPlayerItem *playerItem;

/** 播放器  */
@property (nonatomic, strong) AVPlayer *player;


/** 代理  */
@property (nonatomic, weak) id<YCPlayerMaskViewDelegate > delegate;

/** 全屏按钮  */
@property (nonatomic, strong) UIButton *fullScreenBtn;

/** 缓存加载UI  */
@property (nonatomic, strong) UIProgressView *loadingProgress;

/** 播放按钮  */
@property (nonatomic, strong) UIButton *playOrPauseBtn;

/** 播放滑竿进度条  */
@property (nonatomic, strong) UISlider *playSlider;

/** 左边时间显示视图  */
@property (nonatomic, strong) UILabel *leftTimeLabel;

/** 右边时间显示视图  */
@property (nonatomic, strong) UILabel *rightTimeLabel;

/** 顶部视图  */
@property (nonatomic, strong) UIImageView *topView;

/** 底部工具栏  */
@property (nonatomic, strong) UIImageView *bottomView;

/** 锁屏按钮  */
@property (nonatomic, strong) UIButton *lockScreenBtn;

/** 返回按钮  */
@property (nonatomic, strong) UIButton *backBtn;

/** 截屏按钮  */
@property (nonatomic, strong) UIButton *screenshotsBtn;


@end
