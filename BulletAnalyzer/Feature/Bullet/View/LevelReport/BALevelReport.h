//
//  BALevelReport.h
//  BulletAnalyzer
//
//  Created by Zj on 17/6/17.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BAReportModel;

@interface BALevelReport : UIView

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
