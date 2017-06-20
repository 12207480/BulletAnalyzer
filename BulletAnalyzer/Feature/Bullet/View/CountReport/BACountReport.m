//
//  BACountReport.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/16.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BACountReport.h"
#import "BAReportModel.h"
#import "NSDate+Category.h"

typedef void(^completeBlock)(CAShapeLayer *borderShapeLayer, CAShapeLayer *shapeLayer, CAGradientLayer *gradientLayer);

@interface BACountReport()
@property (nonatomic, strong) NSMutableArray *XValues;
@property (nonatomic, strong) NSMutableArray *YValues;
@property (nonatomic, strong) CAShapeLayer *bulletBorderLayer;
@property (nonatomic, strong) CAShapeLayer *bulletLayer;
@property (nonatomic, strong) CAGradientLayer *bulletGradientLayer;

@end

@implementation BACountReport

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = BADark1BackgroundColor;
        
        [self setupBg];
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self animation];
}


#pragma mark - public
- (void)setReportModel:(BAReportModel *)reportModel{
    _reportModel = reportModel;
    
    if (_reportModel.countTimePointArray.count < 6 || (!_bulletLayer.isHidden && _bulletLayer)) return;
    
    [self setupXYZ];
    
    [self drawBulletLayer];
}


- (void)animation{

    if (!_bulletLayer.isHidden) return;
    
    _bulletLayer.hidden = NO;
    _bulletBorderLayer.hidden = NO;
    
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    animation1.fromValue = @(0.0);
    animation1.toValue = @(1.0);
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation2.fromValue = @(self.height);
    animation2.toValue = @(0.0);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 1.0;
    animationGroup.animations = @[animation1, animation2];
    
    [_bulletLayer addAnimation:animationGroup forKey:nil];
    [_bulletBorderLayer addAnimation:animationGroup forKey:nil];
}


- (void)hide{
    _bulletLayer.hidden = YES;
    _bulletBorderLayer.hidden =  YES;
}


#pragma mark - private
- (void)setupXYZ{

    [_YValues enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL * _Nonnull stop) {

        obj.text = [NSString stringWithFormat:@"%zd", _reportModel.maxBulletCount / 6 * (5 - idx)];
    }];
    
    NSInteger duration = _reportModel.duration ? _reportModel.duration : [[NSDate date] minutesAfterDate:_reportModel.begin];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    
    [_XValues enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDate *date = [_reportModel.begin dateByAddingMinutes:idx * duration / 7];
        obj.text = [formatter stringFromDate:date];
    }];
}


- (void)drawBulletLayer{
    
    if (_bulletLayer) {
        [_bulletBorderLayer removeFromSuperlayer];
        [_bulletLayer removeFromSuperlayer];
        [_bulletGradientLayer removeFromSuperlayer];
    }
    
    WeakObj(self);
    [self drawLayerWithPointArray:_reportModel.countTimePointArray color:BALineColor1 compete:^(CAShapeLayer *borderShapeLayer, CAShapeLayer *shapeLayer, CAGradientLayer *gradientLayer) {
        selfWeak.bulletBorderLayer = borderShapeLayer;
        selfWeak.bulletLayer = shapeLayer;
        selfWeak.bulletGradientLayer = gradientLayer;
        selfWeak.bulletLayer.hidden = YES;
        selfWeak.bulletBorderLayer.hidden = YES;
    }];
}


- (void)drawLayerWithPointArray:(NSMutableArray *)pointArray color:(UIColor *)color compete:(completeBlock)compete{

    UIBezierPath *fillPath = [UIBezierPath new];
    UIBezierPath *borderPath = [UIBezierPath new];
    
    NSInteger ignoreSpace = pointArray.count / 15;
    
    __block CGPoint lastPoint;
    __block NSUInteger  lastIdx;
    [fillPath moveToPoint:CGPointMake(0, self.height)];
    [pointArray enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGPoint point = obj.CGPointValue;
        if (idx == 0) { //第一个点
            
            [fillPath addLineToPoint:point];
            [borderPath moveToPoint:point];
            lastPoint = point;
            lastIdx = idx;
        } else if (idx == pointArray.count - 1) { //最后一个点

            [fillPath addCurveToPoint:point controlPoint1:CGPointMake((lastPoint.x + point.x) / 2, lastPoint.y) controlPoint2:CGPointMake((lastPoint.x + point.x) / 2, point.y)]; //三次曲线
            [borderPath addCurveToPoint:point controlPoint1:CGPointMake((lastPoint.x + point.x) / 2, lastPoint.y) controlPoint2:CGPointMake((lastPoint.x + point.x) / 2, point.y)];
            lastPoint = point;
            lastIdx = idx;
        } else if (lastIdx + ignoreSpace + 1 == idx) { //当点数过多时 忽略部分点

            [fillPath addCurveToPoint:point controlPoint1:CGPointMake((lastPoint.x + point.x) / 2, lastPoint.y) controlPoint2:CGPointMake((lastPoint.x + point.x) / 2, point.y)]; //三次曲线
            [borderPath addCurveToPoint:point controlPoint1:CGPointMake((lastPoint.x + point.x) / 2, lastPoint.y) controlPoint2:CGPointMake((lastPoint.x + point.x) / 2, point.y)];
            lastPoint = point;
            lastIdx = idx;
        }
    }];
    [fillPath addLineToPoint:CGPointMake(self.width, self.height)];
    [fillPath addLineToPoint:CGPointMake(0, self.height)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = fillPath.CGPath;
    [self.layer addSublayer:shapeLayer];
    
    CAShapeLayer *borderShapeLayer = [CAShapeLayer layer];
    borderShapeLayer.path = borderPath.CGPath;
    borderShapeLayer.lineWidth = 2.f;
    borderShapeLayer.strokeColor = color.CGColor;
    borderShapeLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:borderShapeLayer];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    [gradientLayer setColors:[NSArray arrayWithObjects:(id)[[color colorWithAlphaComponent:0.8] CGColor], (id)[[color colorWithAlphaComponent:0.05] CGColor], nil]];
    [gradientLayer setStartPoint:CGPointMake(0.5, 0)];
    [gradientLayer setEndPoint:CGPointMake(0.5, 1)];
    [gradientLayer setMask:shapeLayer];
    [self.layer addSublayer:gradientLayer];
    
    compete(borderShapeLayer, shapeLayer, gradientLayer);
}


- (void)setupBg{
    
    _XValues = [NSMutableArray array];
    _YValues = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 7; i++) {
        
        if (i < 6) {
            UIView *line = [self createLine];
            line.y = self.height / 7 * (i + 1);
            if (i == 5) {
                line.x = 0;
                line.width = BAScreenWidth;
            }
            
            UILabel *YValue = [self createYValue];
            YValue.y = self.height / 7 * i;
        }
        
        UILabel *XValue = [self createXValue];
        XValue.x = self.width / 7 * i;
    }
}


- (UIView *)createLine{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(2 * BAPadding, 0, BAScreenWidth - 4 * BAPadding, 0.5)];
    view.backgroundColor = BALightTextColor;
    
    [self addSubview:view];
    return view;
}


- (UILabel *)createXValue{
    UILabel *label = [UILabel lableWithFrame:CGRectMake(0, self.height * 6 / 7, self.width / 7, self.height / 7) text:@"" color:BAWhiteColor font:BAThinFont(BACommonTextFontSize) textAlignment:NSTextAlignmentCenter];
    label.hidden = !(_XValues.count == 0 || _XValues.count == 3 || _XValues.count == 6);
    [_XValues addObject:label];
    
    [self addSubview:label];
    return label;
}


- (UILabel *)createYValue{
    UILabel *label = [UILabel lableWithFrame:CGRectMake(0, 0, 4 * BAPadding, self.height / 7) text:@"" color:BAWhiteColor font:BAThinFont(BACommonTextFontSize) textAlignment:NSTextAlignmentCenter];
    [_YValues addObject:label];
    
    [self addSubview:label];
    return label;
}

@end
