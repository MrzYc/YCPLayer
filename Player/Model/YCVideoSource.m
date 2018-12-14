//
//  YCVideoSource.m
//  YCVideoPlayer
//
//  Created by zhYch on 2018/7/27.
//  Copyright © 2018年 zhaoyongchuang. All rights reserved.
//

#import "YCVideoSource.h"
#import <YYModel.h>
#import <AFNetworking.h>

@implementation YCVideoSource

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"videoSourceArr":[YCVideoSourceModel class]};
}


+ (void)getVideSourceArr:(VideoSourceBlock)videoSourceBlock {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:@"http://baobab.kaiyanapp.com/api/v4/tabs/selected?udid=11111&vc=168&vn=3.3.1&deviceModel=Huawei%36&first_channel=eyepetizer_baidu_market&last_channel=eyepetizer_baidu_market&system_version_code=20" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *dataArr = [NSMutableArray array];
        for (NSDictionary *dic in responseObject[@"itemList"]) {
            if (![dic[@"type"] isEqualToString:@"video"]) {
                continue;
            }
            NSDictionary *data = dic[@"data"];
            NSString *title = data[@"title"]; //视频标题
            NSString *coverImage = data[@"cover"][@"detail"]; //视频封面图
            NSMutableArray *videoSourceArr = [NSMutableArray array]; //视频资源数组
            NSArray *playInfo = data[@"playInfo"];
            for (NSDictionary *playDic in playInfo) {
                NSArray *urlList = playDic[@"urlList"];
                NSDictionary *videoDic = urlList.firstObject;
                NSDictionary *urlDic = @{@"name":playDic[@"name"],@"url":videoDic[@"url"],@"size":videoDic[@"size"]};
                [videoSourceArr addObject:urlDic];
            }
            NSDictionary *videoSourceDic = @{@"title":title,@"coverImage":coverImage,@"videoSourceArr":videoSourceArr};
            [dataArr addObject:videoSourceDic];
        }
//        [self creatPlistFileWithArr:dataArr];
        videoSourceBlock([NSArray yy_modelArrayWithClass:[YCVideoModel class] json:dataArr]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}


+ (void)creatPlistFileWithArr:(NSArray *)array{
    //将字典保存到document文件->获取appdocument路径
    NSString *docPath = @"/Users/tingle/Desktop/Model";
    //要创建的plist文件名 -> 路径
    NSString *filePath = [docPath stringByAppendingPathComponent:@"videoSoure.plist"];
    //将数组写入文件
    [array writeToFile:filePath atomically:YES];
}

@end


@implementation YCVideoModel

@end

@implementation YCVideoSourceModel

@end

@implementation YCPlayModel

- (void)setPresentationSize:(CGSize)presentationSize {
    _presentationSize = presentationSize;
    if (presentationSize.width / presentationSize.height < 1) {
        self.verticalVideo = YES;
    }
}

@end


