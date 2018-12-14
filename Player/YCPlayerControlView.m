//
//  YCPlayerControlView.m
//  Player
//
//  Created by zhYch on 2018/9/6.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import "YCPlayerControlView.h"
#import <Masonry.h>
#import "YCLightView.h"
#import "YCScreenshotsView.h"
#import <AVFoundation/AVFoundation.h>


@interface  YCPlayerControlView()


/** 播放器  */
@property (nonatomic, strong) AVPlayer *player;

/** 播放器的Item  */
@property (nonatomic, strong) AVPlayerItem *currentItem;

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

/** 播放倍率按钮  */
@property (nonatomic, strong) UIButton *rateBtn;

/** 截屏按钮  */
@property (nonatomic, strong) UIButton *screenshotsBtn;

//格式化时间（懒加载防止多次重复初始化）
@property (nonatomic,strong) NSDateFormatter *dateFormatter;

@end

@implementation YCPlayerControlView

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    }
    return _dateFormatter;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews {
    //顶部视图
    self.topView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"top_shadow"]];
    self.topView.userInteractionEnabled = YES;
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.height.mas_equalTo(60);
    }];
    
    //底部工具栏视图
    self.bottomView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bottom_shadow"]];
    self.bottomView.userInteractionEnabled = YES;
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.mas_equalTo(self);
        make.height.mas_equalTo(60);
    }];
    
    //锁屏按钮
    UIButton *lockScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lockScreenBtn setImage:[UIImage imageNamed:@"player_icon_unlock"] forState:UIControlStateNormal];
    [lockScreenBtn setImage:[UIImage imageNamed:@"player_icon_lock"] forState:UIControlStateSelected];
    [lockScreenBtn addTarget:self action:@selector(lockScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    lockScreenBtn.showsTouchWhenHighlighted = YES;
    self.lockScreenBtn = lockScreenBtn;
    lockScreenBtn.hidden = YES;
    [self addSubview:lockScreenBtn];
    [lockScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
    
    //截屏按钮
    UIButton *screenshotsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [screenshotsBtn setImage:[UIImage imageNamed:@"screenshots"] forState:UIControlStateNormal];
    [screenshotsBtn setImage:[UIImage imageNamed:@"screenshots"] forState:UIControlStateSelected];
    [screenshotsBtn addTarget:self action:@selector(screenshotsAction) forControlEvents:UIControlEventTouchUpInside];
    screenshotsBtn.showsTouchWhenHighlighted = YES;
    self.screenshotsBtn = screenshotsBtn;
    screenshotsBtn.hidden = YES;
    [self addSubview:screenshotsBtn];
    [screenshotsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(25, 25));
    }];
    
    //暂停/播放按钮
    UIButton *playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playOrPauseBtn setImage:[UIImage imageNamed:@"player_ctrl_icon_pause"] forState:UIControlStateNormal];
    [playOrPauseBtn setImage:[UIImage imageNamed:@"player_ctrl_icon_play"] forState:UIControlStateSelected];
    [playOrPauseBtn addTarget:self action:@selector(playOrPauseAction:) forControlEvents:UIControlEventTouchUpInside];
    playOrPauseBtn.showsTouchWhenHighlighted = YES;
    self.playOrPauseBtn = playOrPauseBtn;
    [self.bottomView addSubview:playOrPauseBtn];
    [playOrPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(10);
        make.centerY.mas_equalTo(self.bottomView).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
    
    UILabel *leftTimeLabel = [[UILabel alloc] init];
    leftTimeLabel.textColor = [UIColor whiteColor];
    self.leftTimeLabel = leftTimeLabel;
    leftTimeLabel.text = @"00:00";
    leftTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomView addSubview:leftTimeLabel];
    leftTimeLabel.font = [UIFont systemFontOfSize:12.0];
    [leftTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(playOrPauseBtn.mas_right).mas_offset(5).priority(500);
        make.centerY.mas_equalTo(self.bottomView).mas_offset(10);
    }];
    
    UIButton *fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenBtn = fullScreenBtn;
    fullScreenBtn.showsTouchWhenHighlighted = YES;
    [fullScreenBtn setImage:[UIImage imageNamed:@"player_icon_fullscreen"] forState:UIControlStateNormal];
    [fullScreenBtn setImage:[UIImage imageNamed:@"icon_narrow"] forState:UIControlStateSelected];
    [fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:fullScreenBtn];
    [fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bottomView).mas_offset(-10).priority(500);
        make.centerY.mas_equalTo(self.bottomView).mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
    
    
    UILabel *rightTimeLabel = [[UILabel alloc] init];
    rightTimeLabel.textColor = [UIColor whiteColor];
    rightTimeLabel.font = [UIFont systemFontOfSize:12.0];
    self.rightTimeLabel = rightTimeLabel;
    rightTimeLabel.text = @"00:00";
    rightTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomView addSubview:rightTimeLabel];
    [rightTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(fullScreenBtn.mas_left).mas_offset(-10).priority(450);
        make.centerY.mas_equalTo(self.bottomView).mas_offset(10);
    }];
    
    UIProgressView *loadingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    loadingProgress.progressTintColor = [UIColor lightGrayColor];
    loadingProgress.trackTintColor    = [UIColor clearColor];
    self.loadingProgress = loadingProgress;
    loadingProgress.hidden  = YES;
    [self.bottomView addSubview:loadingProgress];
    [loadingProgress setProgress:0.0 animated:NO];
    [self.bottomView addSubview:loadingProgress];
    [loadingProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftTimeLabel.mas_right).mas_offset(5);
        make.right.mas_equalTo(rightTimeLabel.mas_left).mas_equalTo(-5);
        make.centerY.mas_equalTo(self.bottomView).mas_offset(10).priority(400);
    }];
    
    UISlider  *playSlider = [UISlider new];
    playSlider.minimumValue = 0.0;
    playSlider.maximumValue = 1.0;
    self.playSlider = playSlider;
    [playSlider setThumbImage:[UIImage imageNamed:@"dot"]  forState:UIControlStateNormal];
    playSlider.minimumTrackTintColor = [UIColor greenColor];
    playSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    [playSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [playSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [playSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    playSlider.backgroundColor = [UIColor clearColor];
    playSlider.value = 0.0;//指定初始值
    [self.bottomView addSubview:playSlider];
    [playSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.centerY.mas_equalTo(loadingProgress);
        make.height.mas_equalTo(30);
    }];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.showsTouchWhenHighlighted = YES;
    self.backBtn = backBtn;
    backBtn.hidden = YES;
    [backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self.topView).mas_offset(-10);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
    
    UIButton *rateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rateBtn setTitle:@"1X" forState:UIControlStateNormal];
    rateBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [rateBtn addTarget:self action:@selector(rateBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:rateBtn];
    [rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-10);
        make.centerY.mas_equalTo(self.topView).mas_offset(-10);
        make.size.mas_equalTo(CGSizeMake(40, 15));
    }];
    
    YCLightView *lightView =  [[YCLightView alloc] init];
    [self addSubview:lightView];
    [lightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(155, 155));
    }];
}

- (void)setManager:(YCPlayerManager *)manager {
    _manager = manager;
    self.player = manager.player;
    self.currentItem = manager.player.currentItem;
    self.loadingProgress.tintColor = manager.progressTintColor ? manager.progressTintColor : self.loadingProgress.tintColor;
    self.playSlider.minimumTrackTintColor = manager.sliderMinColor ? manager.sliderMinColor : self.playSlider.minimumTrackTintColor;
    self.playSlider.maximumTrackTintColor = manager.sliderMaxColor ? manager.sliderMaxColor : self.playSlider.maximumTrackTintColor;
    self.lockScreenBtn.hidden = manager.hiddenLock ? manager.hiddenLock : self.lockScreenBtn.hidden;
    self.screenshotsBtn.hidden = manager.hiddenSceenShot ? manager.hiddenSceenShot : self.screenshotsBtn.hidden;
    self.loadingProgress.hidden = manager.hiddenProgress ? manager.hiddenProgress : self.loadingProgress.hidden;
    self.rateBtn.hidden = manager.hiddenRate ? manager.hiddenRate : self.rateBtn.hidden;
    self.player.muted= manager.muted ? manager.muted : self.player.muted;
    self.player.volume = manager.volume ? manager.volume : self.player.volume;
    self.player.rate = manager.rate ? manager.rate : self.player.rate;
}


#pragma mark --- 播放器操作事件
//锁屏事件
- (void)lockScreenAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        _manager.lockScreenState = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.topView.alpha   = 0;
            self.bottomView.alpha = 0;
        }];
    }else {
        _manager.lockScreenState = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.topView.alpha   = 1;
            self.bottomView.alpha = 1;
        }];
    }
}

//播放暂停事件
- (void)playOrPauseAction:(UIButton *)sender  {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [_player pause];
    }else {
        [_player play];
    }
}

//全屏事件
- (void)fullScreenAction:(UIButton *)sender  {
    sender.selected = !sender.selected;
    if (sender.selected) {
        _manager.playerFullScreen(YES);
    }else {
        _manager.playerFullScreen(NO);
    }
}

//返回事件
- (void)backBtnAction {
    [self fullScreenAction:self.fullScreenBtn];
}

//播放速率改变事件
- (void)rateBtnAction:(UIButton *)sender {
    CGFloat rate = [sender.currentTitle floatValue];
    if(rate==0.5){
        rate +=0.5;
    }else if(rate ==1.0){
        rate += 0.25;
    }else if(rate==1.25){
        rate += 0.25;
    }else if(rate==1.5){
        rate += 0.5;
    }else if(rate==2){
        rate = 0.5;
    }
    
    if(rate == 1.25){
        [sender setTitle:[NSString stringWithFormat:@"%.2fX",rate] forState:UIControlStateNormal];
    }else{
        [sender setTitle:[NSString stringWithFormat:@"%.1fX",rate] forState:UIControlStateNormal];
        [sender setTitle:[NSString stringWithFormat:@"%.1fX",rate] forState:UIControlStateSelected];
    }
    _player.rate = rate;
}

//开始滑动
- (void)progressSliderTouchBegan:(UISlider *)slider {
    _manager.playerBeganchangeProgress();
}

//正在滑动
- (void)progressSliderValueChanged:(UISlider *)slider {
    CGFloat totalTime = (CGFloat)_currentItem.duration.value / _currentItem.duration.timescale;
    CGFloat dragedSeconds = totalTime * slider.value;
    CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
    [_player seekToTime:dragedCMTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    long long nowTime = _currentItem.currentTime.value / _currentItem.currentTime.timescale;
    self.leftTimeLabel.text = [self converTimeSecond:nowTime];
}

//结束滑动
- (void)progressSliderTouchEnded:(UISlider *)slider  {
    _manager.playerEndChangeProgress();
}

//截屏事件
- (void)screenshotsAction {
    _manager.playerScreenshots();
}


- (NSString *)converTimeSecond:(NSInteger)second {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    if (second/3600 >= 1) {
        [self.dateFormatter setDateFormat:@"HH:mm:ss"];
    } else {
        [self.dateFormatter setDateFormat:@"mm:ss"];
    }
    return [self.dateFormatter stringFromDate:date];
}

@end
