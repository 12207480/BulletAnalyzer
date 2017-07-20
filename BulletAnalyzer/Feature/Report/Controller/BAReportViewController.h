//
//  BAReportViewController.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/7/20.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAViewController.h"

@class BAReportModel;

@interface BAReportViewController : BAViewController

/**
 传入分析数据模型
 */
@property (nonatomic, strong) BAReportModel *reportModel;

@end
