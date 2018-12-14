//
//  YCPlayerMaskView.m
//  Player
//
//  Created by zhYch on 2018/8/14.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import "YCPlayerMaskView.h"
#import <Masonry.h>
#import "YCLightView.h"

@interface YCPlayerMaskView()


@end

@implementation YCPlayerMaskView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setSubviews];
    }
    return self;
}


- (void)setSubviews {
    
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
    loadingProgress.progressTintColor = [UIColor clearColor];
    loadingProgress.trackTintColor    = [UIColor clearColor];
    self.loadingProgress = loadingProgress;
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

#pragma mark  -- Button Aciton
//锁屏事件
- (void)lockScreenAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerLockScreenisLock:)]) {
        [self.delegate playerLockScreenisLock:sender.selected];
    }
}

//播放暂停事件
- (void)playOrPauseAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerPlayOrPauseisPause:)]) {
        [self.delegate playerPlayOrPauseisPause:sender.selected];
    }
}

//全屏事件
- (void)fullScreenAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerisFullScreen:)]) {
        [self.delegate playerisFullScreen:sender.isSelected];
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerChangeRate:)]) {
        [self.delegate playerChangeRate:rate];
    }
}


//开始滑动
- (void)progressSliderTouchBegan:(UISlider *)slider {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerBeganchangeProgress:)]) {
        [self.delegate playerBeganchangeProgress:slider];
    }
}

//正在滑动
- (void)progressSliderValueChanged:(UISlider *)slider {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerProgressValueChanged:)]) {
        [self.delegate playerProgressValueChanged:slider];
    }
}

//滑动结束
- (void)progressSliderTouchEnded:(UISlider *)slider {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerEndChangeProgress:)]) {
        [self.delegate playerEndChangeProgress:slider];
    }
}

//截屏事件
- (void)screenshotsAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerScreenshots)]) {
        [self.delegate playerScreenshots];
    }
}

@end
