//
//  YCPlayerView.m
//  Player
//
//  Created by zhYch on 2018/8/13.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import "YCPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "YCPlayerMaskView.h"
#import "YCTimeManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "YCScreenshotsView.h"


@interface YCPlayerView() <YCPlayerMaskViewDelegate, UIGestureRecognizerDelegate>

/** 播放器的Item  */
@property (nonatomic, strong) AVPlayerItem *playerItem;

/** 播放器  */
@property (nonatomic, strong) AVPlayer *player;

/** 播放器的layer层  */
@property (nonatomic, strong) AVPlayerLayer *playerLayer;


/** 播放器视图的父视图  */
@property (nonatomic, strong) UIView *fatherView;

/**控件原始Farme*/
@property (nonatomic, assign) CGRect   customFarme;

/** 播放器遮罩层  */
@property (nonatomic, strong) YCPlayerMaskView *maskView;

/*进度条定时器*/
@property (nonatomic, strong) YCTimer  *sliderTimer;
/*点击定时器*/
@property (nonatomic, strong) YCTimer   *tapTimer;

//格式化时间（懒加载防止多次重复初始化）
@property (nonatomic,strong) NSDateFormatter *dateFormatter;

/** 播放总长时间  */
@property (nonatomic, assign) CGFloat totalTime;

/** controllView 隐藏*/
@property (nonatomic, assign) BOOL  isDisappear;

/** 更改数据的大小 */
@property (nonatomic, assign) CGFloat  changeTime;

/** 调节的类型 ： YES 调节的是声音 NO 调节的是亮度*/
@property (nonatomic, assign) BOOL  isVolume;

/** 音量滑竿  */
@property (nonatomic, strong) UISlider *volumeSlider;

@property (nonatomic, assign) YCFullScreeenStatusBarShowType  isStatusBarShowType;


@end

@implementation YCPlayerView

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    }
    return _dateFormatter;
}

//进度条定时器
- (YCTimer *)sliderTimer{
    if (_sliderTimer == nil){
        __weak __typeof(self) weakSelf = self;
        _sliderTimer = [[YCTimer alloc] initTimerWithTimeInterval:1.0f delayTime:0 queue:dispatch_get_main_queue() repeats:YES action:^{
            __typeof(&*weakSelf) strongSelf = weakSelf;
            [strongSelf timeStack];
        }];
    }
    return _sliderTimer;
}

//手势定时器
- (YCTimer *)tapTimer{
    if (_tapTimer == nil){
        __weak __typeof(self) weakSelf = self;
        _tapTimer = [[YCTimer alloc] initTimerWithTimeInterval:5 delayTime:5 queue:dispatch_get_main_queue() repeats:YES action:^{
            __typeof(&*weakSelf) strongSelf = weakSelf;
            [strongSelf disappear];
        }];
        
    }
    return _tapTimer;
}

//控制进度条
- (void)timeStack {
    if (_playerItem.duration.timescale != 0) {
        self.maskView.playSlider.maximumValue = 1;
        self.maskView.playSlider.value = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);
        if (self.playerItem.isPlaybackLikelyToKeepUp && self.maskView.playSlider.value > 0) {
            self.playerState = YCPlayerStatePlaying;
        }
        
        //当前时长
        long long nowTime = _playerItem.currentTime.value / _playerItem.currentTime.timescale;
        self.maskView.leftTimeLabel.text = [self converTimeSecond:nowTime];
        self.maskView.rightTimeLabel.text = [self converTimeSecond:self.totalTime];
    }
}

- (NSString *)converTimeSecond:(NSInteger)second {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [[self dateFormatter] setDateFormat:@"HH:mm:ss"];
    } else {
        [[self dateFormatter] setDateFormat:@"mm:ss"];
    }
    return [[self dateFormatter] stringFromDate:date];
}

//定时自动消失
- (void)disappear {
    [UIView animateWithDuration:0.5 animations:^{
        self.maskView.topView.alpha    = 0;
        self.maskView.bottomView.alpha = 0;
        self.maskView.lockScreenBtn.alpha = 0;
        self.maskView.screenshotsBtn.alpha = 0;
        self.statusBarHidden = YES;
    }];
    _isDisappear = YES;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[YCPlayerMaskView alloc] init];
        _maskView.delegate = self;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapplayerControlView)];
        [_maskView addGestureRecognizer:tap];
        
        //平移手势控制声音、亮度、快进、快退
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureAction:)];
        panGesture.delegate = self;
        [panGesture setMaximumNumberOfTouches:1];
        [panGesture setDelaysTouchesBegan:YES];
        [panGesture setDelaysTouchesEnded:YES];
        [panGesture setCancelsTouchesInView:YES];
        [_maskView addGestureRecognizer:panGesture];
        [self.sliderTimer startTimer];
        [self configureVolume];
    }
    return _maskView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.isFullScreen = NO;
        _isLandscape = NO;
        _isReplay = NO;
        _isDisappear = NO;
        _isLockScreen = NO;
        self.statusBarShowType = FullScreenShowAlways;
        [self.tapTimer startTimer];
                
        //开启
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        //注册屏幕旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:[UIDevice currentDevice]];
        

        
        //app已经进入到后台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        //app将要从后台返回到前台
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}


- (void)appDidEnterBackground:(NSNotification *)notification {
    [self pausePlayer];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    [self playPlayer];
}

- (void)tapplayerControlView {
    //取消定时消失定时器
    [self deallocTapTimer];
    if (_isLockScreen) {
        self.maskView.lockScreenBtn.hidden = !self.maskView.lockScreenBtn.hidden;
        self.maskView.screenshotsBtn.hidden = !self.maskView.screenshotsBtn.hidden;
    }else {
        _isDisappear = !_isDisappear;
        if (_isDisappear) {
            [UIView animateWithDuration:0.5 animations:^{
                self.maskView.topView.alpha = 0;
                self.maskView.bottomView.alpha = 0;
                self.maskView.lockScreenBtn.alpha = 0;
                self.maskView.screenshotsBtn.alpha = 0;
                self.isStatusBarShowType = self.statusBarShowType;
            }];
        }else {
            //重新添加定时器
            [self resetTapTimer];
            [UIView animateWithDuration:0.5 animations:^{
                self.maskView.topView.alpha = 1;
                self.maskView.bottomView.alpha = 1;
                self.maskView.lockScreenBtn.alpha = 1;
                self.maskView.screenshotsBtn.alpha = 1;
                self.isStatusBarShowType = self.statusBarShowType;
            }];
        }
    }
}


- (void)panGestureAction:(UIPanGestureRecognizer *)pan {
    
    if (_isLockScreen) {
        return;
    }
    
    //根据两者x方向和y方向的移动速度判断是水平移动还是竖直移动区分是快退还是快进或者是声音还是屏幕亮度
    CGPoint locationPoint = [pan locationInView:self];
    CGPoint veloctyPoint  = [pan velocityInView:self];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
             //水平移动
            if (x > y) {
                [self playerBeganchangeProgress:nil];
                [UIView animateWithDuration:0.5 animations:^{
                    self.maskView.topView.alpha    = 1.0;
                    self.maskView.bottomView.alpha = 1.0;
                }];
   
                self.panDirection = YCHorizontalPanMove;
                CMTime time = self.player.currentTime;
                self.changeTime = time.value / time.timescale;
            }else if (x < y) { //垂直移动
                self.panDirection = YCVerticalPanMoved;
                //判断改变的状态
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume= YES;
                }else {
                    self.isVolume = NO;
                }
            }
            break;
        }
        case UIGestureRecognizerStateChanged:{
            if (self.panDirection == YCHorizontalPanMove) { //水平移动 快进快退
                [self panHorizontalMoved:veloctyPoint.x];
            }else { //垂直移动 声音和亮度
                [self panVerticalMoved:veloctyPoint.y];
            }
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (self.panDirection == YCHorizontalPanMove) { //水平移动 快进快退
                self.changeTime = 0;
                [self playerEndChangeProgress:nil];
            }else { //垂直移动 声音和亮度
                self.isVolume = NO;
            }
            break;
        }
        default:
            break;
    }
}

- (void)panHorizontalMoved:(CGFloat)value {
    
    self.changeTime += value / 200;
    //限定更改的时间
    CMTime totalTime = self.playerItem.duration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value/totalTime.timescale;
    if (self.changeTime > totalMovieDuration) {
        self.changeTime = totalMovieDuration;
    }
    
    if (self.changeTime < 0) {
        self.changeTime = 0;
    }
    
    if (value == 0) {
        return;
    }
    
    //计算滑竿的进度
    self.maskView.playSlider.value = self.changeTime / totalMovieDuration;
    //转换成CMTime
    CMTime drageCMTime = CMTimeMake(self.changeTime, 1);
    [_player seekToTime:drageCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    long long nowTime = _playerItem.currentTime.value / _playerItem.currentTime.timescale;
    self.maskView.leftTimeLabel.text = [self converTimeSecond:nowTime];
}

- (void)panVerticalMoved:(CGFloat)value {
    if (self.isVolume) {
        self.volumeSlider.value -= value / 10000;
    }else {
        [UIScreen mainScreen].brightness -= value / 10000;
    }
}


- (void)configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc]init];
    for (UIControl *view in volumeView.subviews) {
        if ([view.superclass isSubclassOfClass:[UISlider class]]) {
            self.volumeSlider = (UISlider *)view;
        }
    }
}

//销毁定时消失定时器
- (void)deallocTapTimer {
    [self.tapTimer cancelTimer];
    self.tapTimer = nil;
}

- (void)resetTapTimer {
    [self deallocTapTimer];
    [self.tapTimer startTimer];
}

- (void)setPlayURL:(NSURL *)playURL {
    
    _playURL = playURL;
    self.playerItem  = [AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:playURL]];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer  = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.videoGravity = AVLayerVideoGravityResize;
    
    //设置静音模式播放声音
    AVAudioSession * session  = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    [self.layer insertSublayer:_playerLayer above:0];
    
    [self addSubview:self.maskView];

    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    //播放器播放
    [_player play];
    
}


//是否能够循环播放
- (void)setIsReplay:(BOOL)isReplay {
    _isReplay = isReplay;
}


- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem == playerItem) {
        return;
    }
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:AVPlayerItemDidPlayToEndTimeNotification
                                                      object:_playerItem];
        
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"duration"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        
    }
    _playerItem = playerItem;
    if (playerItem) {
        //播放器播放结束的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayDidEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:playerItem];
        //监控播放器的播放状态
        [playerItem addObserver:self
                     forKeyPath:@"status"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
        
        //监听播放器的播放时长
        [playerItem addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:nil];

        //监控网络加载情况属性
        [playerItem addObserver:self
                     forKeyPath:@"loadedTimeRanges"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
        
        // 监控缓冲区状态,需要等待数据
        [playerItem addObserver:self
                     forKeyPath:@"playbackBufferEmpty"
                        options:NSKeyValueObservingOptionNew
                        context:nil];
        
        //监听缓冲区有足够数据可以播放
//        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options: NSKeyValueObservingOptionNew context:nil];
    }
}

//通知监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            //加载完毕准备播放
            
        }else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
            self.playerState = YCPlayerStateFailed;
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self calculateDuration];
        CMTime duration  = self.playerItem.duration;
        CGFloat totalDuration       = CMTimeGetSeconds(duration);
        [self.maskView.loadingProgress setProgress:timeInterval / totalDuration animated:NO];
    }else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        //当视频缓冲为空的时候
        if (self.playerItem.playbackBufferEmpty) {
            [self bufferingLoading];
        }
    }else if ([keyPath isEqualToString:@"duration"]) {
        if (!isnan((CGFloat) CMTimeGetSeconds(_playerItem.asset.duration))) {
            self.totalTime = (NSInteger)CMTimeGetSeconds(_playerItem.asset.duration);
        }
    }
}

- (void)moviePlayDidEnd:(id)sender {
    if (_isReplay) {
        [self resetPlay];
    }else {
        NSLog(@"播放完成");
    }
}

- (void)resetPlay {
    [_player seekToTime:CMTimeMake(0, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [_player play];
}

//重新设置播放器
- (void)resetPlayer {
    self.playerState = YCPlayerStateStopped;
}

//缓冲时期处理
- (void)bufferingLoading {
    self.playerState = YCPlayerStateBuffering;
    [self pausePlayer];
    [self performSelector:@selector(bufferingEnded) withObject:@"Buffering" afterDelay:5];
}

- (void)bufferingEnded {
    [self playPlayer];
    if (!self.playerItem.isPlaybackLikelyToKeepUp) {
        [self bufferingLoading];
    }
}

- (void)pausePlayer {
    self.maskView.playOrPauseBtn.selected = YES;
    [_player pause];
    [self.sliderTimer suspendTimer];
}

- (void)playPlayer {
    self.maskView.playOrPauseBtn.selected = NO;
    if (self.maskView.playSlider.value == 1) {
        [self resetPlayer];
    }else {
        [_player play];
        [self.sliderTimer resumeTimer];
    }
}

//计算缓冲事件
- (NSTimeInterval)calculateDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    self.maskView.frame = self.bounds;
}

//视频方向改变
- (void)orientChange:(NSNotification *)notification {
    if (_isLockScreen) {
        return;
    }
    
    if (_isDisappear) {
        [self deallocTapTimer];
        //重新添加定时器
        [self resetTapTimer];
        [UIView animateWithDuration:0.5 animations:^{
            self.maskView.topView.alpha = 1;
            self.maskView.bottomView.alpha = 1;
            self.maskView.lockScreenBtn.alpha = 1;
            self.maskView.screenshotsBtn.alpha = 1;
        }];
        _isDisappear = NO;
        self.isStatusBarShowType = self.statusBarShowType;
    }
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft) {
        if (!_isFullScreen) {
            if (_isLandscape) {
                //播放器所在控制器页面支持旋转情况下，和正常情况是相反的
                [self fullScreenWithDirection:UIInterfaceOrientationLandscapeRight];
            }else {
                [self fullScreenWithDirection:UIInterfaceOrientationLandscapeLeft];
            }
            self.maskView.fullScreenBtn.selected = YES;
            self.maskView.lockScreenBtn.hidden = NO;
            self.maskView.screenshotsBtn.hidden = NO;
            self.maskView.backBtn.hidden = NO;
        }
    }else if (orientation == UIDeviceOrientationLandscapeRight) {
        if (!_isFullScreen) {
            if (_isLandscape) {
                [self fullScreenWithDirection:UIInterfaceOrientationLandscapeLeft];
            }else {
                [self fullScreenWithDirection:UIInterfaceOrientationLandscapeRight];
            }
            self.maskView.fullScreenBtn.selected = YES;
            self.maskView.lockScreenBtn.hidden = NO;
            self.maskView.screenshotsBtn.hidden = NO;
            self.maskView.backBtn.hidden = NO;
        }
    }else if (orientation == UIDeviceOrientationPortrait) {
        if (_isFullScreen) {
            [self originalscreen];
            self.maskView.fullScreenBtn.selected = NO;
            self.maskView.lockScreenBtn.hidden = YES;
            self.maskView.screenshotsBtn.hidden = YES;
            self.maskView.backBtn.hidden = YES;
        }
    }
}


- (void)fullScreenWithDirection:(UIInterfaceOrientation)direction {
    self.maskView.lockScreenBtn.hidden = NO;
    self.maskView.screenshotsBtn.hidden = NO;
    self.maskView.backBtn.hidden =  NO;
    //记录播放器父类
    _fatherView  = self.superview;
    //记录原始大小
    _customFarme              = self.frame;
    self.isFullScreen             = YES;
    //添加到Window上
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    if (_isLandscape) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
    }else {
        //播放器所在控制器不支持旋转，采用旋转view的方式实现
        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        if (direction == UIInterfaceOrientationLandscapeLeft){
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            [UIView animateWithDuration:duration animations:^{
                self.transform = CGAffineTransformMakeRotation(M_PI / 2);
            } completion:^(BOOL finished) {
                
            }];
        }else if (direction == UIInterfaceOrientationLandscapeRight) {
            [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
            [UIView animateWithDuration:duration animations:^{
                self.transform = CGAffineTransformMakeRotation( - M_PI / 2);
            }completion:^(BOOL finished) {
                
            }];
        }
    }
    
    self.frame  = keyWindow.bounds;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


- (void)originalscreen {
    self.maskView.lockScreenBtn.hidden = YES;
    self.maskView.screenshotsBtn.hidden = YES;
    self.maskView.backBtn.hidden =  YES;
    self.isFullScreen = NO;
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
    if (_isLandscape) {
        //还原为竖屏
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    }else {
        CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        [UIView animateWithDuration:duration animations:^{
            self.transform = CGAffineTransformMakeRotation(0);
        }completion:^(BOOL finished) {

        }];
    }
    self.frame = _customFarme;
    [_fatherView addSubview:self];
}


- (void)dealloc {
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"duration"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
//    [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:[UIDevice currentDevice]];
    //回到竖屏
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    //重置状态条
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:YES];
}


#pragma mark -- YCPlayerMaskViewDelegate
- (void)playerPlayOrPauseisPause:(BOOL)isPause {
    if (isPause) {
        [_player pause];
    }else {
        [_player play];
    }
}

- (void)playerChangeRate:(CGFloat)rate {
    _player.rate = rate;
}


- (void)playerisFullScreen:(BOOL)isFullScreen {
    if (isFullScreen) {
        [self fullScreenWithDirection:UIInterfaceOrientationLandscapeLeft];
    }else {
        [self originalscreen];
    }
}

- (void)playerLockScreenisLock:(BOOL)isLock {
    _isLockScreen = isLock;
    if (isLock) {
        [self deallocTapTimer];
        [UIView animateWithDuration:0.5 animations:^{
            self.maskView.topView.alpha    = 0;
            self.maskView.bottomView.alpha = 0;
        }];
    }else {
        [self resetTapTimer];
        [UIView animateWithDuration:0.5 animations:^{
            self.maskView.topView.alpha = 1;
            self.maskView.bottomView.alpha = 1;
            self.maskView.lockScreenBtn.alpha = 1;
        }];
    }
}

//开始滑动
- (void)playerBeganchangeProgress:(UISlider *)slider {
    [self pausePlayer];
    [self deallocTapTimer];
}

//正在滑动
- (void)playerProgressValueChanged:(UISlider *)slider {
    CGFloat totalTime = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
    CGFloat dragedSeconds = totalTime * slider.value;
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    [_player seekToTime:dragedCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    long long nowTime = _playerItem.currentTime.value / _playerItem.currentTime.timescale;
    self.maskView.leftTimeLabel.text = [self converTimeSecond:nowTime];
}

//结束滑动
- (void)playerEndChangeProgress:(UISlider *)slider {
    if (!self.playerItem.isPlaybackLikelyToKeepUp) {
        [self bufferingLoading];
    }else {
        [self playPlayer];
    }
    [self resetTapTimer];
}


//截屏事件
- (void)playerScreenshots {
    __weak typeof(self) weakSelf = self;
    YCScreenshotsView *shotView = [[YCScreenshotsView alloc] initWithFrame:self.bounds];
    shotView.playerItem = _playerItem;
    shotView.screenShotsDIdEndBlock = ^{
        [weakSelf playPlayer];
        weakSelf.isLockScreen = NO;
        [weakSelf tapplayerControlView];
    };
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:shotView];
    
    [self pausePlayer];
    [self tapplayerControlView];
    self.isLockScreen = YES;
}

- (void)setPlayerState:(YCPlayerState)playerState {
    if (_playerState == playerState) {
        return;
    }
    _playerState = playerState;
    if (playerState == YCPlayerStateBuffering) {
        NSLog(@"缓冲中。。。");
    }else if (playerState == YCPlayerStateFailed) {
        self.maskView.playOrPauseBtn.selected = NO;
        NSLog(@"加载失败");
    }else if(playerState == YCPlayerStatePlaying) {
        NSLog(@"正在播放");
    }
}

//设置状态栏的样式
- (void)setIsFullScreen:(BOOL)isFullScreen {
    _isFullScreen = isFullScreen;
    [[self get_currentViewController] setNeedsStatusBarAppearanceUpdate];
}

- (UIViewController *)get_currentViewController {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    UIViewController *topViewController = [window rootViewController];
    while (true) {
        if (topViewController.presentedViewController) {
            topViewController = topViewController.presentedViewController;
        }else if ([topViewController isKindOfClass:[UINavigationController class]] &&  [(UINavigationController*)topViewController topViewController]) {
            topViewController = [(UINavigationController *)topViewController topViewController];
        }else if ([topViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tab = (UITabBarController *)topViewController;
            topViewController = tab.selectedViewController;
        }else {
            break;
        }
    }
    return topViewController;
}



//设置状态栏的隐藏模式
- (void)setStatusBarShowType:(YCFullScreeenStatusBarShowType)statusBarShowType {
    _statusBarShowType = statusBarShowType;
}

- (void)setIsStatusBarShowType:(YCFullScreeenStatusBarShowType)isStatusBarShowType {
    _isStatusBarShowType = isStatusBarShowType;
    if (_isFullScreen) {
        if (isStatusBarShowType == FullScreenShowAlways) { //全屏状态下一直显示
            self.statusBarHidden = NO;
        }else if (isStatusBarShowType == FullScreenShowNever) { //全屏状态下不显示
            self.statusBarHidden = YES;
        }else {
            if (_isDisappear) {
                self.statusBarHidden = YES;
            }else {
                self.statusBarHidden = NO;
            }
        }
    }
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    _statusBarHidden = statusBarHidden;
    [[self get_currentViewController] setNeedsStatusBarAppearanceUpdate];
}


@end
