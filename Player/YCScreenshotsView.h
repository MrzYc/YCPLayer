//
//  YCScreenshotsView.h
//  Player
//
//  Created by zhYch on 2018/9/4.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>


typedef void(^ScreenShotsDIdEndBlock)(void);

@interface YCScreenshotsView : UIView

/** 截屏结束事件  */
@property (nonatomic, copy) ScreenShotsDIdEndBlock screenShotsDIdEndBlock;

/** 播放器的Item  */
@property (nonatomic, strong) AVPlayerItem *playerItem;


@end
