//
//  BAReportModel.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/7.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BAReportModel : NSObject

/**
 自增ID
 */
@property (nonatomic, copy) NSString *ID;

/**
 主播姓名
 */
@property (nonatomic, copy) NSString *name;

/**
 主播头像
 */
@property (nonatomic, copy) NSString *icon;

/**
 直播间标题
 */
@property (nonatomic, copy) NSString *title;

/**
 直播间截图
 */
@property (nonatomic, copy) NSString *photo;

/**
 开始分析时间
 */
@property (nonatomic, strong) NSDate *begin;

/**
 结束分析时间
 */
@property (nonatomic, strong) NSDate *end;

/**
 分析时长
 */
@property (nonatomic, copy) NSString *duration;

/**
 弹幕数量
 */
@property (nonatomic, copy) NSString *bulletCount;

/**
 粉丝数量
 */
@property (nonatomic, copy) NSString *fansCount;

@end
