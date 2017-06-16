//
//  BABezierView.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/16.
//  Copyright © 2017年 Zj. All rights reserved.
//

#define BAChartWidth BAScreenHeight / 2
#define BAChartHeight BAScreenHeight / 2

#import "BABezierChart.h"

@implementation BABezierChart

+ (UIView *)drawLineChartWithXValues:(NSMutableArray *)XValues YValues:(NSMutableArray *)YValues lineType:(BALineType)lineType{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BAChartWidth, BAChartHeight)];

    

    return view;
}


@end
