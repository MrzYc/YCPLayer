//
//  UIView+Category.h
//  Leting
//
//  Created by zhYch on 2018/5/29.
//  Copyright © 2018年 LeTing. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS (NSInteger, UIBorderSideType) {
    UIBorderSideTypeAll  = 0,
    UIBorderSideTypeTop = 1 << 0,
    UIBorderSideTypeBottom = 1 << 1,
    UIBorderSideTypeLeft = 1 << 2,
    UIBorderSideTypeRight = 1 << 3,
};


@interface UIView (Category)

/** 大小 */
@property (nonatomic, assign) CGSize size;
/** 宽 */
@property (nonatomic, assign) CGFloat width;
/** 高 */
@property (nonatomic, assign) CGFloat height;
/** x */
@property (nonatomic, assign) CGFloat x;
/** y */
@property (nonatomic, assign) CGFloat y;
/** centerX */
@property (nonatomic, assign) CGFloat centerX;
/** centerY */
@property (nonatomic, assign) CGFloat centerY;

/** bottomY  */
@property (nonatomic, assign) CGFloat bottomY;


/**给视图切圆角  */
- (void)cutViewWithRadian:(CGFloat)radian;

//给View 添加边框
- (UIView *)borderForColor:(UIColor *)color borderWidth:(CGFloat)borderWidth borderType:(UIBorderSideType)borderType;

@end
