//
//  BAReportModel.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/7.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BAReportModel : NSObject <NSCoding>

/**
 主播姓名
 */
@property (nonatomic, copy) NSString *name;

/**
 主播头像
 */
@property (nonatomic, copy) NSString *avatar;

/**
 直播间标题
 */
@property (nonatomic, copy) NSString *roomName;

/**
 直播间id
 */
@property (nonatomic, copy) NSString *roomId;

/**
 直播间截图
 */
@property (nonatomic, copy) NSString *photo;

/**
 粉丝数量
 */
@property (nonatomic, copy) NSString *fansCount;

/**
 主播体重
 */
@property (nonatomic, copy) NSString *weight;

/**
 开始分析时间
 */
@property (nonatomic, strong) NSDate *begin;

/**
 结束分析时间
 */
@property (nonatomic, strong) NSDate *end;

/**
 继续进行时间
 */
@property (nonatomic, strong) NSDate *proceed;

/**
 打断分析时间
 */
@property (nonatomic, strong) NSDate *interrupt;

/**
 分析时长
 */
@property (nonatomic, copy) NSString *duration;

/**
 弹幕数组
 */
@property (nonatomic, strong) NSMutableArray *bulletsArray;

/**
 词语数组
 */
@property (nonatomic, strong) NSMutableArray *wordsArray;

/**
 用户数组/弹幕数量排序
 */
@property (nonatomic, strong) NSMutableArray *userArraySortedByCount;

/**
 用户数据/等级排序
 */
@property (nonatomic, strong) NSMutableArray *userArraySortedByLevel;

/**
 弹幕数量与时间的排序
 */
@property (nonatomic, strong) NSMutableArray *countTimeArray;

/**
 新增报告
 */
@property (nonatomic, assign, getter=isAddNewReport) BOOL addNewReport;

/**
 是否被异常中断分析
 */
@property (nonatomic, assign, getter=isInterruptAnalyzing) BOOL interruptAnalyzing;

@end
