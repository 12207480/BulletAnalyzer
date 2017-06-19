
//
//  BALevelReport.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/17.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BALevelReport.h"
#import "BAReportModel.h"
#import "BAUserModel.h"

@interface BALevelReport()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) NSMutableArray *YValues;
@property (nonatomic, strong) NSMutableArray *barLayerArray;
@property (nonatomic, strong) NSMutableArray *gradientLayerArray;

@end

@implementation BALevelReport

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = BADark2BackgroundColor;
        
        [self setupBg];
        
        _barLayerArray = [NSMutableArray array];
        
        _gradientLayerArray = [NSMutableArray array];
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
    
    [self drawBarLayer];
}


- (void)animation{
    
    if (!_barLayerArray.count) return;
    
    for (NSInteger i = 0; i < 8; i++) {

        CAShapeLayer *layer = _barLayerArray[i];
        [self performSelector:@selector(animateLayer:) withObject:layer afterDelay:i * 0.5];
    }
}


- (void)hide{
    [_barLayerArray enumerateObjectsUsingBlock:^(CAShapeLayer *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
}


#pragma mark - private
- (void)animateLayer:(CAShapeLayer *)layer{
   
    layer.hidden = NO;
    
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    animation1.fromValue = @(0.0);
    animation1.toValue = @(1.0);
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation2.fromValue = @(6 * BAPadding);
    animation2.toValue = @(0.0);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 1.0;
    animationGroup.animations = @[animation1, animation2];
    
    [layer addAnimation:animationGroup forKey:nil];
}


- (void)drawBarLayer{
    
    [_barLayerArray makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_barLayerArray removeAllObjects];
    
    [_gradientLayerArray makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_gradientLayerArray removeAllObjects];
    
    CGFloat maxWidth = BAScreenWidth - 8 * BAPadding;
    NSInteger maxLevel = [[_reportModel.levelCountArray valueForKeyPath:@"@max.integerValue"] integerValue];
    CGFloat height = self.height / 16;
    [_reportModel.levelCountArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
   
        CGPoint orginPoint = CGPointMake(6 * BAPadding, height / 2 + idx * 2 * height);
        CGFloat width = maxWidth * obj.integerValue / maxLevel + 6 * BAPadding;
   
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:orginPoint];
        [path addLineToPoint:CGPointMake(width, orginPoint.y)];
        [path addLineToPoint:CGPointMake(width, orginPoint.y + height)];
        [path addLineToPoint:CGPointMake(6 * BAPadding, orginPoint.y + height)];
        [path addLineToPoint:orginPoint];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = path.CGPath;
        [self.layer addSublayer:shapeLayer];
        shapeLayer.hidden = YES;
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.bounds;
        [gradientLayer setColors:[NSArray arrayWithObjects:(id)[BALineColor3 CGColor], (id)[BALineColor4 CGColor], nil]];
        [gradientLayer setStartPoint:CGPointMake(0, 0.5)];
        [gradientLayer setEndPoint:CGPointMake(1, 0.5)];
        [self.layer addSublayer:gradientLayer];
        
        [gradientLayer setMask:shapeLayer];
        [_gradientLayerArray addObject:gradientLayer];
        [_barLayerArray addObject:shapeLayer];
    }];
}


- (void)setupBg{
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(BAPadding, 0, 5 * BAPadding, self.height)];
    _bgView.backgroundColor = BADark1BackgroundColor;
    _bgView.layer.shadowOffset = CGSizeMake(2, 2);
    _bgView.layer.shadowOpacity = 0.5;
    _bgView.layer.shadowColor = BABlackColor.CGColor;
    
    [self addSubview:_bgView];
    
    _YValues = [NSMutableArray array];
    for (NSInteger i = 0; i < 8; i ++ ) {
        
        UILabel *label = [self createYValue];
        label.y = i * self.height / 8;
        
        switch (i) {
            case 0:
                label.text = @"0-10";
                break;
                
            case 1:
                label.text = @"11-20";
                break;
                
            case 2:
                label.text = @"21-30";
                break;
                
            case 3:
                label.text = @"31-40";
                break;
                
            case 4:
                label.text = @"41-50";
                break;
                
            case 5:
                label.text = @"51-60";
                break;
                
            case 6:
                label.text = @"61-70";
                break;
                
            default:
                label.text = @"71+";
                break;
        }
    }
}


- (UILabel *)createYValue{
    UILabel *label = [UILabel lableWithFrame:CGRectMake(BAPadding, 0, 5 * BAPadding, self.height / 8) text:@"" color:BAWhiteColor font:BAThinFont(BACommonTextFontSize) textAlignment:NSTextAlignmentCenter];
    [_YValues addObject:label];
    
    [self addSubview:label];
    return label;
}

@end
