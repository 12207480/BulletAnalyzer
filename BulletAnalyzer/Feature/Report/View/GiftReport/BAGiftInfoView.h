//
//  BAGiftInfoView.h
//  BulletAnalyzer
//
//  Created by Zj on 17/7/22.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BAGiftModel.h"

@class BAReportModel;

@interface BAGiftInfoView : UIView

/**
 传入分析数据模型
 */
@property (nonatomic, strong) BAReportModel *reportModel;

/**
 选中礼物类型
 */
@property (nonatomic, assign) BAGiftType selectedGiftType;

@end
