//
//  BATransModelTool.h
//  BulletAnalyzer
//
//  Created by Zj on 17/6/3.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BAModelType) {
    BAModelTypeBullet = 0, //模型数据类型为弹幕
    BAModelTypeReply = 1, //模型数据类型为服务器回复
    BAModelTypeGift = 2 //模型数据类型为礼物
};

typedef void(^transCompleteBlock)(NSMutableArray *array, BAModelType modelType);

@interface BATransModelTool : NSObject

/**
 服务器传回的数据解析

 @param data 服务器返回的数据
 @param complete 解析回调
 */
+ (void)transModelWithData:(NSData *)data complete:(transCompleteBlock)complete;

@end
