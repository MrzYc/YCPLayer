//
//  YCScreenshotsView.m
//  Player
//
//  Created by zhYch on 2018/9/4.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import "YCScreenshotsView.h"
#import <Masonry.h>
#import <Photos/Photos.h>


@interface YCScreenshotsView()

/** 截图UI  */
@property (nonatomic, strong)  UIImageView*screenImageView;

@end

@implementation YCScreenshotsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews {
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:bgView];
    
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
    self.screenImageView = imageView;
    
    UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeBtn setImage:[UIImage imageNamed:@"screenX"] forState:UIControlStateNormal];
    [removeBtn addTarget:self action:@selector(removeScreenView) forControlEvents:UIControlEventTouchUpInside];
    removeBtn.frame = CGRectMake(20, 20, 25, 25);
    [self addSubview:removeBtn];
    
    UIControl *saveView = [[UIControl alloc] init];
    [self addSubview:saveView];
    [saveView addTarget:self action:@selector(saveSceenShotImage) forControlEvents:UIControlEventTouchUpInside];
    [saveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(-20);
        make.size.mas_equalTo(CGSizeMake(65, 50));
    }];
    
    UIImageView *saveImage = [[UIImageView alloc] init];
    saveImage.image = [UIImage imageNamed:@"saveScreen"];
    [saveView addSubview:saveImage];
    [saveImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.centerX.mas_equalTo(saveView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"保存到相册";
    [saveView addSubview:titleLabel];
    titleLabel.font = [UIFont systemFontOfSize:12.0];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(saveImage.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(0);
    }];

}


- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    _playerItem = playerItem;
    self.screenImageView.image = [self thumbnailImageAtCurrentTime];
}


-(UIImage *)thumbnailImageAtCurrentTime {
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:_playerItem.asset];
    CMTime expectedTime = _playerItem.currentTime;
    CGImageRef CGImage = NULL;
    
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imageGenerator.requestedTimeToleranceAfter= kCMTimeZero;
    CGImage = [imageGenerator copyCGImageAtTime:expectedTime actualTime:NULL error:NULL];
    
    if (!CGImage) {
        imageGenerator.requestedTimeToleranceBefore =  kCMTimePositiveInfinity;
        imageGenerator.requestedTimeToleranceAfter = kCMTimePositiveInfinity;
        CGImage = [imageGenerator copyCGImageAtTime:expectedTime actualTime:NULL error:NULL];
    }
    
    UIImage *image = [UIImage imageWithCGImage:CGImage];
    return image;
}


- (void)saveSceenShotImage {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted) { // 因为家长控制, 导致应用无法方法相册(跟用户的选择没有关系)
        NSLog(@"因为系统原因, 无法访问相册");
    } else if (status == PHAuthorizationStatusDenied) { // 用户拒绝当前应用访问相册(用户当初点击了"不允许")
        NSLog(@"提醒用户去[设置-隐私-照片-xxx]打开访问开关");
    } else if (status == PHAuthorizationStatusAuthorized) { // 用户允许当前应用访问相册(用户当初点击了"好")
        [self saveImage];
    } else if (status == PHAuthorizationStatusNotDetermined) { // 用户还没有做出选择
        // 弹框请求用户授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) { // 用户点击了好
                [self saveImage];
            }
        }];
    }
}

- (void)saveImage {
    UIImageWriteToSavedPhotosAlbum(self.screenImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error == nil) {
        NSLog(@"存入手机相册成功");
    }else{
        NSLog(@"存入手机相册失败");
    }
    [self removeScreenView];
}


- (void)removeScreenView {
    if (self.screenShotsDIdEndBlock) {
        self.screenShotsDIdEndBlock();
    }
    [self removeFromSuperview];
}






@end
