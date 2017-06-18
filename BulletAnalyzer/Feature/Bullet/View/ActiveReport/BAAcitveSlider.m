
//
//  BAAcitveSlider.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/18.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAAcitveSlider.h"

@interface BAAcitveSlider()
@property (nonatomic, strong) CAShapeLayer *bgLayer;
@property (nonatomic, strong) UIView *valueView;
@property (nonatomic, strong) CAShapeLayer *valueLayer;

@end

@implementation BAAcitveSlider

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupBg];
        
        [self setupValue];
    }
    return self;
}

#pragma mark - public
- (void)setValue:(CGFloat)value{
    _value = value;

    _valueView.frame = CGRectMake(0, 0, self.width * value, self.height);
}


#pragma mark - private
- (void)setupValue{
    _valueView = [UIView new];
    _valueView.frame = CGRectMake(0, 0, 0, self.height);
    _valueView.layer.masksToBounds = YES;
    
    [self addSubview:_valueView];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(self.height / 2, 0)];
    [path addLineToPoint:CGPointMake(self.width - self.height / 2, 0)];
    [path addArcWithCenter:CGPointMake(path.currentPoint.x, self.height / 2) radius:self.height / 2 startAngle:(CGFloat)M_PI * 1.5 endAngle:(CGFloat)M_PI / 2 clockwise:YES];
    [path addLineToPoint:CGPointMake(self.height / 2, path.currentPoint.y)];
    [path addArcWithCenter:CGPointMake(path.currentPoint.x, self.height / 2) radius:self.height / 2 startAngle:(CGFloat)M_PI / 2 endAngle:(CGFloat)M_PI * 1.5  clockwise:YES];
    
    _valueLayer = [CAShapeLayer layer];
    _valueLayer.path = path.CGPath;
    _valueLayer.fillColor = BAThemeColor.CGColor;
    
    [_valueView.layer addSublayer:_valueLayer];
}


- (void)setupBg{
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(self.height / 2, 0)];
    [path addLineToPoint:CGPointMake(self.width - self.height / 2, 0)];
    [path addArcWithCenter:CGPointMake(path.currentPoint.x, self.height / 2) radius:self.height / 2 startAngle:(CGFloat)M_PI * 1.5 endAngle:(CGFloat)M_PI / 2 clockwise:YES];
    [path addLineToPoint:CGPointMake(self.height / 2, path.currentPoint.y)];
    [path addArcWithCenter:CGPointMake(path.currentPoint.x, self.height / 2) radius:self.height / 2 startAngle:(CGFloat)M_PI / 2 endAngle:(CGFloat)M_PI * 1.5  clockwise:YES];
    
    _bgLayer = [CAShapeLayer layer];
    _bgLayer.path = path.CGPath;
    _bgLayer.fillColor = BALightTextColor.CGColor;

    [self.layer addSublayer:_bgLayer];
}

@end
