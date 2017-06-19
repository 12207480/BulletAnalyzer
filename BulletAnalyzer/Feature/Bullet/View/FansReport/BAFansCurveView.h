//
//  BAFansCurveView.h
//  BulletAnalyzer
//
//  Created by Zj on 17/6/19.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^completeBlock)(CAShapeLayer *borderShapeLayer, CAShapeLayer *shapeLayer, CAGradientLayer *gradientLayer);

@class BAReportModel;

@interface BAFansCurveView : UIView
@property (nonatomic, strong) UIImageView *icon; 
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UILabel *beginTimeLabel;
@property (nonatomic, strong) UILabel *endTimeLabel;
@property (nonatomic, strong) UILabel *minValueLabel;
@property (nonatomic, strong) UILabel *maxValueLabel;

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

/**
 绘制图形
 */
- (void)drawLayerWithPointArray:(NSMutableArray *)pointArray color:(UIColor *)color;

@end
