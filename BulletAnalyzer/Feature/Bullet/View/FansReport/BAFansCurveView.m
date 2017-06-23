//
//  BAFansCurveView.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/19.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAFansCurveView.h"
#import "BAReportModel.h"

@interface BAFansCurveView()
@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIView *drawView;

@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAShapeLayer *borderShapeLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;


@end

@implementation BAFansCurveView

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - public
- (void)animation{
    if (!_shapeLayer.isHidden) return;
    
    _shapeLayer.hidden = NO;
    _borderShapeLayer.hidden = NO;
    
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    animation1.fromValue = @(0.0);
    animation1.toValue = @(1.0);
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation2.fromValue = @(_drawView.height);
    animation2.toValue = @(0.0);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 1.0;
    animationGroup.animations = @[animation1, animation2];
    
    [_shapeLayer addAnimation:animationGroup forKey:nil];
    [_borderShapeLayer addAnimation:animationGroup forKey:nil];
}


- (void)hide{
    _shapeLayer.hidden = YES;
    _borderShapeLayer.hidden = YES;
}


- (void)drawLayerWithPointArray:(NSMutableArray *)pointArray color:(UIColor *)color{
    
    if (_shapeLayer && !_shapeLayer.isHidden) return;
    
    if (_shapeLayer) {
        [_shapeLayer removeFromSuperlayer];
        [_borderShapeLayer removeFromSuperlayer];
        [_gradientLayer removeFromSuperlayer];
    }
    
    UIBezierPath *fillPath = [UIBezierPath new];
    UIBezierPath *borderPath = [UIBezierPath new];
    
    NSInteger ignoreSpace = pointArray.count / 15;
    
    __block CGPoint lastPoint;
    __block NSUInteger  lastIdx;
    [fillPath moveToPoint:CGPointMake(0, _drawView.height)];
    [pointArray enumerateObjectsUsingBlock:^(NSValue *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGPoint point = obj.CGPointValue;
        if (point.y != lastPoint.y) {
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
        }
    }];
    [fillPath addLineToPoint:CGPointMake(_drawView.width, _drawView.height)];
    [fillPath addLineToPoint:CGPointMake(0, _drawView.height)];
    
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.path = fillPath.CGPath;
    _shapeLayer.hidden = YES;
    [_drawView.layer addSublayer:_shapeLayer];
    
    _borderShapeLayer = [CAShapeLayer layer];
    _borderShapeLayer.path = borderPath.CGPath;
    _borderShapeLayer.lineWidth = 2.f;
    _borderShapeLayer.strokeColor = color.CGColor;
    _borderShapeLayer.fillColor = [UIColor clearColor].CGColor;
    _borderShapeLayer.hidden = YES;
    [_drawView.layer addSublayer:_borderShapeLayer];
    
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.frame = _drawView.bounds;
    [_gradientLayer setColors:[NSArray arrayWithObjects:(id)[[color colorWithAlphaComponent:0.8] CGColor], (id)[[UIColor clearColor] CGColor], nil]];
    [_gradientLayer setStartPoint:CGPointMake(0.5, 0)];
    [_gradientLayer setEndPoint:CGPointMake(0.5, 1)];
    [_gradientLayer setMask:_shapeLayer];
    [_drawView.layer addSublayer:_gradientLayer];
}


#pragma mark - private
- (void)setupSubViews{
    
    self.backgroundColor = BADark1BackgroundColor;
    
    _leftView = [[UIView alloc] initWithFrame:CGRectMake(BAScreenWidth - 100, 0, 100, self.height)];
    _leftView.backgroundColor = BADark2BackgroundColor;
    
    [self addSubview:_leftView];
    
    _icon = [[UIImageView alloc] initWithFrame:CGRectMake(40, self.height / 4 - 10, 20, 20)];
    _icon.backgroundColor = BARandomColor;
    
    [_leftView addSubview:_icon];
    
    _countLabel = [UILabel labelWithFrame:CGRectMake(0, _icon.bottom + BAPadding / 2, 100, 30) text:nil color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) textAlignment:NSTextAlignmentCenter];
    
    [_leftView addSubview:_countLabel];
    
    _typeLabel = [UILabel labelWithFrame:CGRectMake(0, _countLabel.bottom, 100, 30) text:nil color:BALightTextColor font:BACommonFont(BACommonTextFontSize) textAlignment:NSTextAlignmentCenter];
    
    [_leftView addSubview:_typeLabel];
    
    _drawView = [[UIView alloc] initWithFrame:CGRectMake(3.5 * BAPadding, 2 * BAPadding, _leftView.x - 5 * BAPadding, self.height - 4 * BAPadding)];

    [self addSubview:_drawView];
    
    _beginTimeLabel = [UILabel labelWithFrame:CGRectMake(_drawView.x, _drawView.bottom + BAPadding / 2, 40, BACommonTextFontSize) text:nil color:BALightTextColor font:BACommonFont(BASmallTextFontSize) textAlignment:NSTextAlignmentLeft];
    
    [self addSubview:_beginTimeLabel];
    
    _endTimeLabel = [UILabel labelWithFrame:CGRectMake(_drawView.right - 40, _drawView.bottom + BAPadding / 2, 40, BACommonTextFontSize) text:nil color:BALightTextColor font:BACommonFont(BASmallTextFontSize) textAlignment:NSTextAlignmentRight];
    
    [self addSubview:_endTimeLabel];
    
    _minValueLabel = [UILabel labelWithFrame:CGRectMake(BAPadding / 2, _drawView.bottom - BACommonTextFontSize, 50, BACommonTextFontSize) text:nil color:BALightTextColor font:BACommonFont(BASmallTextFontSize) textAlignment:NSTextAlignmentLeft];
    
    [self addSubview:_minValueLabel];
    
    _maxValueLabel = [UILabel labelWithFrame:CGRectMake(BAPadding / 2, _drawView.y, 50, BACommonTextFontSize) text:nil color:BALightTextColor font:BACommonFont(BASmallTextFontSize) textAlignment:NSTextAlignmentLeft];
    
    [self addSubview:_maxValueLabel];
}

@end
