//
//  BASentenceView.h
//  BulletAnalyzer
//
//  Created by Zj on 17/6/24.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BAReportModel;

@interface BASentenceView : UIView

/**
 传入报告
 */
@property (nonatomic, strong) BAReportModel *reportModel;

@end
