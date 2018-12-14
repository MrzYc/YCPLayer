//
//  YCVideoSource.h
//  YCVideoPlayer
//
//  Created by zhYch on 2018/7/27.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@class YCVideoModel;
@class YCVideoSourceModel;


typedef void(^VideoSourceBlock) (NSArray *sources);

@interface YCVideoSource : NSObject


/** 下一页数据  */
@property (nonatomic, copy) NSString *nextPageUrl;

/** 播放数据源  */
@property (nonatomic, copy) NSArray <YCVideoModel *> *itemList;

+ (void)getVideSourceArr:(VideoSourceBlock)videoSourceBlock;

@end


@interface YCVideoModel : NSObject

/** 视频标题  */
@property (nonatomic, copy) NSString *title;

/** 封面图  */
@property (nonatomic, copy) NSString *coverImage;

/** 视频播放资源数组  */
@property (nonatomic, copy) NSArray <YCVideoSourceModel *>*videoSourceArr;

@end

@interface YCVideoSourceModel : NSObject

/** 播放视频样式名字  */
@property (nonatomic, copy) NSString *name;

/** 播放视频的URL  */
@property (nonatomic, copy) NSString *url;

/** 视频的大小  */
@property (nonatomic, copy) NSString *size;


@end

@interface YCPlayModel : NSObject

/** 视频标题 */
@property (nonatomic, copy) NSString   *title;

/** 视频的URL，本地路径or网络路径http */
@property (nonatomic, strong) NSURL    *videoURL;

/** videoURL和playerItem二选一 */
@property (nonatomic, strong) AVPlayerItem   *playerItem;

/** 跳到seekTime处播放 */
@property (nonatomic, assign) double   seekTime;

@property (nonatomic, strong) NSIndexPath  *indexPath;

/** 视频尺寸 */
@property (nonatomic,assign) CGSize presentationSize;

/** 是否是适合竖屏播放的资源，w：h<1的资源，一般是手机竖屏（人像模式）拍摄的视频资源 */
@property (nonatomic,assign) BOOL verticalVideo;

@end



