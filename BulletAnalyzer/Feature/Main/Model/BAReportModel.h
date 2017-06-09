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
 粉丝数量
 */
@property (nonatomic, copy) NSString *fansCount;

/**
 正在分析的弹幕数组
 */
@property (nonatomic, strong) NSMutableArray *analzingBulletsArray;

/**
 正在分析的词语数组
 */
@property (nonatomic, strong) NSMutableArray *analzingWordsArray;

/**
 新增报告
 */
@property (nonatomic, assign, getter=isAddNewReport) BOOL addNewReport;

/**
 是否被异常中断分析
 */
@property (nonatomic, assign, getter=isInterruptAnalyzing) BOOL interruptAnalyzing;

@end
