//
//  ViewController.m
//  Player
//
//  Created by zhYch on 2018/8/10.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import "ViewController.h"
#import "YCVideoSource.h"
#import <YYModel.h>
#import <SDWebImage/UIButton+WebCache.h>
#import <Masonry.h>
#import "YCPlayerView.h"
#import "UIView+Category.h"

@interface ViewController ()

/** 播放模型  */
@property (nonatomic, strong) YCVideoModel *videoModel;

/** bgview  */
@property (nonatomic, strong) UIButton *bgview;

/** 播放网址  */
@property (nonatomic, strong) NSString *playUrl;

/** playerView  */
@property (nonatomic, strong) YCPlayerView *playerView;



@end

@implementation ViewController

- (BOOL)shouldAutorotate {
    return !self.playerView.isLockScreen;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.playerView.isFullScreen) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return self.playerView.statusBarHidden;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"videoSoure" ofType:@"plist"];
    NSArray  *dataArr =  [NSArray arrayWithContentsOfFile:filePath];
    NSArray *videos =  [NSArray yy_modelArrayWithClass:[YCVideoModel class] json:dataArr];
    self.videoModel = videos[8];
    YCVideoSourceModel *playModel =  self.videoModel.videoSourceArr.firstObject;
    self.playUrl = playModel.url;
    
    //播放器网站
    NSURL *mediaURL = [NSURL URLWithString:playModel.url];
    YCPlayerView *playerView =  [[YCPlayerView alloc] initWithFrame:CGRectMake(0, 90, self.view.width, 300)];
    playerView.isLandscape = YES;
    playerView.isReplay = YES;
    playerView.statusBarShowType = FullScreenShowFollowToolbar;
    [self.view addSubview:playerView];
    playerView.playURL = mediaURL;
    self.playerView = playerView;
}









@end

