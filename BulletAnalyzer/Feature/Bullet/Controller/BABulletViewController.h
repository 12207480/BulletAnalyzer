//
//  BABulletViewController.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/13.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAViewController.h"

@class BAReportModel;

@interface BABulletViewController : BAViewController

/**
 传入分析数据模型
 */
@property (nonatomic, strong) BAReportModel *reportModel;

@end
