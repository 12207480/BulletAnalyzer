//
//  BAFansReport.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/16.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BAReportModel;

@interface BAFansReport : UIView

/**
 传入分析报告
 */
@property (nonatomic, strong) BAReportModel *reportModel;

/**
 动画
 */
- (void)animation;

/**
 隐藏
 */
- (void)hide;

@end
