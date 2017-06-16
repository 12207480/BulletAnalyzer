//
//  BABezierChart
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/16.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

// 线条类型
typedef NS_ENUM(NSInteger, BALineType) {
    BALineTypeStraight, // 折线
    BALineTypeCurve     // 曲线
};

@interface BABezierChart : NSObject

/**
 *  画折线图
 *  @param XValues      x轴所有值名称
 *  @param YValues      Y轴所有目标值
 *  @param lineType     直线类型
 */
+ (UIView *)drawLineChartWithXValues:(NSMutableArray *)XValues YValues:(NSMutableArray *)YValues lineType:(BALineType)lineType;


/**
 *  画柱状图
 *  @param XValues      x轴所有值名称
 *  @param YValues      Y轴所有目标值
 */
+ (UIView *)drawBarChartWithXValues:(NSMutableArray *)XValues YValues:(NSMutableArray *)YValues;


/**
 *  画饼状图
 *  @param XValues      x轴所有值名称
 *  @param YValues      Y轴所有目标值
 */
+ (UIView *)drawPieChartWithXValues:(NSMutableArray *)XValues YValues:(NSMutableArray *)YValues;

@end
