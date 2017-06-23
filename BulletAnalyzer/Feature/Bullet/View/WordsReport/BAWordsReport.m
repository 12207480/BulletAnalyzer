//
//  BAWordsReport.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/17.
//  Copyright © 2017年 Zj. All rights reserved.
//

#define BAMargin 1

#import "BAWordsReport.h"
#import "BAReportModel.h"
#import "BAWordsModel.h"

@interface BAWordsReport()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) NSMutableArray *XValues;
@property (nonatomic, strong) NSMutableArray *barLayerArray;
@property (nonatomic, strong) NSMutableArray *gradientLayerArray;

@end

@implementation BAWordsReport

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


#pragma mark - userInteraction
- (void)labelTapped:(UILabel *)sender{
    NSLog(@"%zd", sender.tag);
}


#pragma mark - public
- (void)setReportModel:(BAReportModel *)reportModel{
    _reportModel = reportModel;
    
    if (![[_barLayerArray firstObject] isHidden] && _barLayerArray.count) return;
    
    [self drawBarLayer];
}


- (void)animation{
    
    if (_barLayerArray.count < 10 || ![[_barLayerArray firstObject] isHidden]) return;
    
    for (NSInteger i = 0; i < 10; i++) {
        
        CAShapeLayer *layer = _barLayerArray[9 - i];
        [self performSelector:@selector(animateLayer:) withObject:layer afterDelay:i * 0.1];
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
    
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    animation1.fromValue = @(0.0);
    animation1.toValue = @(1.0);
    
    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation2.fromValue = @(self.height - BAPadding);
    animation2.toValue = @(0.0);
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 0.3;
    animationGroup.animations = @[animation1, animation2];
    
    [layer addAnimation:animationGroup forKey:nil];
}


- (void)drawBarLayer{
    
    [_barLayerArray makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_barLayerArray removeAllObjects];
    
    [_gradientLayerArray makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [_gradientLayerArray removeAllObjects];
    
    BAWordsModel *wordsModel = _reportModel.wordsArray.firstObject;
    
    CGFloat maxHeight = BAScreenWidth * 0.6 - BAPadding;
    CGFloat width = (BAScreenWidth - 2 * BAPadding - 9 * BAMargin) / 10;
    NSInteger maxCount = wordsModel.count.integerValue;
    [_reportModel.wordsArray enumerateObjectsUsingBlock:^(BAWordsModel *wordsModel, NSUInteger idx, BOOL * _Nonnull stop) {

        NSMutableString *words = [NSMutableString string];
        for(int i = 0; i < wordsModel.words.length; i++){
            [words appendString:[wordsModel.words substringWithRange:NSMakeRange(i, 1)]];
            if (i < wordsModel.words.length - 1) {
                [words appendString:@"\n"];
            }
        }
        
        UILabel *label = _XValues[idx];
        label.text = words;
        
        CGPoint orginPoint = CGPointMake(BAPadding + (width + BAMargin) * idx, self.height - BAPadding);
        CGFloat height = maxHeight * wordsModel.count.integerValue / maxCount;
        if (height > maxHeight) {
            height = maxHeight;
        }
        
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:orginPoint];
        [path addLineToPoint:CGPointMake(path.currentPoint.x, path.currentPoint.y - height)];
        [path addLineToPoint:CGPointMake(path.currentPoint.x + width, path.currentPoint.y)];
        [path addLineToPoint:CGPointMake(path.currentPoint.x, orginPoint.y)];
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
        
        *stop = idx == 9;
    }];
}


- (void)setupBg{
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(BAPadding, 0, BAScreenWidth - 2 * BAPadding, self.height - BAPadding)];
    _bgView.backgroundColor = BADark1BackgroundColor;
    _bgView.layer.shadowOffset = CGSizeMake(2, 2);
    _bgView.layer.shadowOpacity = 0.5;
    _bgView.layer.shadowColor = BABlackColor.CGColor;
    
    [self addSubview:_bgView];
    
    _XValues = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i ++ ) {
        
        UILabel *label = [self createXValue];
        label.tag = i;
        label.x = i * ((_bgView.width - 9 * BAMargin) / 10 + BAMargin) + BAPadding;
    }
}


- (UILabel *)createXValue{
    UILabel *label = [UILabel labelWithFrame:CGRectMake(0, 0, _bgView.width / 10, BAScreenWidth * 0.2) text:@"" color:BAWhiteColor font:BAThinFont(BACommonTextFontSize) textAlignment:NSTextAlignmentCenter];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [_XValues addObject:label];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped:)];
    [label addGestureRecognizer:tap];
    
    [self addSubview:label];
    return label;
}

@end
