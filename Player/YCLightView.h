//
//  YCLightView.h
//  YCPlayer
//
//  Created by zhYch on 2018/7/6.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCLightView : UIView

/** 亮度条的底部背景视图  */
@property (strong, nonatomic)  UIView *lightBackView;

/** 亮度显示图片  */
@property (strong, nonatomic)  UIImageView *centerLightIV;

//亮度数据数组
@property (strong, nonatomic) NSMutableArray * lightViewArr;


@end
