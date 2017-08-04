//
//  BABulletSetting.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/15.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BABulletSetting.h"
#import "BASlider.h"

@interface BABulletSetting()
@property (nonatomic, strong) UIView *firstView;
@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, strong) UIButton *speedBtn;
@property (nonatomic, strong) UIButton *sentenceBtn;

@property (nonatomic, strong) UIView *filterView;

@property (nonatomic, strong) UIView *speedView;
@property (nonatomic, strong) BASlider *silder;
@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) UIView *quitDisabledView;

@end

@implementation BABulletSetting {
    CGPoint _btnHidePosition;
    BOOL _isHideAnimation;
}


#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - public
- (void)show{
    self.hidden = NO;
    _filterBtn.hidden = YES;
    _sentenceBtn.hidden = YES;
    _speedBtn.hidden = YES;
    _isHideAnimation = NO;
    
    [self animate:_filterBtn withDuration:0.4 angle:M_PI * 2 position:_btnHidePosition toPosition:_filterBtn.center];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animate:_sentenceBtn withDuration:0.4 angle:M_PI * 2 position:_btnHidePosition toPosition:_sentenceBtn.center];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animate:_speedBtn withDuration:0.4 angle:M_PI * 2 position:_btnHidePosition toPosition:_speedBtn.center];
    });
}


- (void)hide{
    _isHideAnimation = YES;
    
    [self animate:_filterBtn withDuration:0.4 angle:M_PI * 2 position:_filterBtn.center toPosition:_btnHidePosition];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animate:_sentenceBtn withDuration:0.4 angle:M_PI * 2 position:_sentenceBtn.center toPosition:_btnHidePosition];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self animate:_speedBtn withDuration:0.4 angle:M_PI * 2 position:_speedBtn.center toPosition:_btnHidePosition];
    });
}


- (BOOL)isAlreadyShow{
    return !self.isHidden;
}


#pragma mark - animation
- (void)animate:(UIView *)view withDuration:(CFTimeInterval)duration angle:(CGFloat)angle position:(CGPoint)point toPosition:(CGPoint)toPoint{
    
    view.hidden = NO;
    
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.byValue = [NSNumber numberWithFloat:angle];

    CASpringAnimation *moveAnimation;
    moveAnimation = [CASpringAnimation animationWithKeyPath:@"position"];
    moveAnimation.fromValue = [NSValue valueWithCGPoint:point];
    moveAnimation.toValue = [NSValue valueWithCGPoint:toPoint];
    moveAnimation.damping = 7;
    moveAnimation.stiffness = 80;
    moveAnimation.mass = 0.6;

    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[moveAnimation, rotationAnimation];
    animationGroup.duration = duration;
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    
    [CATransaction setCompletionBlock:^{
        if ([view isEqual:_speedBtn] && _isHideAnimation) {
            self.hidden = YES;
        }
    }];
    
    [view.layer addAnimation:animationGroup forKey:nil];
}


#pragma mark - userInteraction
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    
//    if (![_quitDisabledView.layer containsPoint:point]) {
//        [self swichTo:_firstView];
//    }
//    
//    if (_settingTouched) {
//        _settingTouched();
//    }
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    if (_settingTouched) {
//        _settingTouched();
//    }
}


- (void)btnClicked:(UIButton *)sender{
    switch (sender.tag) {
        case 0:
            //[self swichTo:_filterView];
            break;
            
        case 1:
            //[self swichTo:_speedView];
            break;
            
        case 2:
            //[self swichTo:_speedView];
            break;
            
        default:
            break;
    }
}


- (void)valueChanged{
    if (_settingTouched) {
        _settingTouched();
    }
    if (_speedChanged) {
        _speedChanged(_silder.value);
    }
}


#pragma mark - animation
- (void)swichTo:(UIView *)view{
    
    [UIView animateWithDuration:0.4 animations:^{
       
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqual:view]) {
                obj.transform = CGAffineTransformIdentity;
                obj.alpha = 1;
            } else {
                obj.alpha = 0;
            }
        }];
        
    } completion:^(BOOL finished) {
        
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![obj isEqual:view]) {
                obj.transform = CGAffineTransformMakeScale(0.1, 0.1);
            }
        }];
        
    }];
}


#pragma mark - private
- (void)setupSubViews{
    
    
    _firstView = [[UIView alloc] initWithFrame:self.bounds];
    
    [self addSubview:_firstView];
    
    _sentenceBtn = [UIButton buttonWithFrame:CGRectMake(BAScreenWidth / 2 - 25, self.height - 90, 50, 50) title:nil color:nil font:nil backgroundImage:[UIImage imageNamed:@"sentenceImg"] target:self action:@selector(btnClicked:)];
    _sentenceBtn.tag = 1;
    
    [_firstView addSubview:_sentenceBtn];
    
    
    _filterBtn = [UIButton buttonWithFrame:CGRectMake(_sentenceBtn.centerX - 60 - 25, self.height  - 60, 50, 50) title:nil color:nil font:nil backgroundImage:[UIImage imageNamed:@"filterImg"] target:self action:@selector(btnClicked:)];
    _filterBtn.tag = 0;
    
    [_firstView addSubview:_filterBtn];
    
    
    _speedBtn = [UIButton buttonWithFrame:CGRectMake(_sentenceBtn.centerX + 60 - 25, _filterBtn.y, 50, 50) title:nil color:nil font:nil backgroundImage:[UIImage imageNamed:@"speedImg"] target:self action:@selector(btnClicked:)];
    _speedBtn.tag = 2;
    
    [_firstView addSubview:_speedBtn];

    _btnHidePosition = CGPointMake(BAScreenWidth / 2, self.height + 45);
    
//    _filterView = [[UIView alloc] initWithFrame:self.bounds];
//    _filterView.transform = CGAffineTransformMakeScale(0.1, 0.1);
//    _filterView.alpha = 0;
//    
//    [self addSubview:_filterView];
//    
//    
//    
//    _speedView = [[UIView alloc] initWithFrame:self.bounds];
//    _speedView.transform = CGAffineTransformMakeScale(0.1, 0.1);
//    _speedView.alpha = 0;
//    
//    [self addSubview:_speedView];
//    
//    _silder = [[BASlider alloc] initWithFrame:CGRectMake(2 * BAPadding, self.height / 2 - 6, BAScreenWidth - 4 * BAPadding , 12)];
//    _silder.maximumValue = 1.0;
//    _silder.minimumValue = 0.0;
//    _silder.value = 0.5;
//    _silder.maximumTrackTintColor = BALightTextColor;
//    [_silder setThumbImage:[UIImage imageNamed:@"silderItem"] forState:UIControlStateNormal];
//    _silder.tintColor = BAThemeColor;
//    [_silder addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventTouchUpInside];
//    
//    [_speedView addSubview:_silder];
//    
//    _tipsLabel = [UILabel labelWithFrame:CGRectMake(_silder.x + BAPadding, _silder.bottom + BAPadding, _silder.width, 30) text:@"tip:调整弹幕速度不影响分析报告" color:BALightTextColor font:BAThinFont(BASmallTextFontSize) textAlignment:NSTextAlignmentLeft];
//    
//    [_speedView addSubview:_tipsLabel];
//    
//    _quitDisabledView = [[UIView alloc] initWithFrame:CGRectMake(BAPadding, 25, BAScreenWidth - 2 * BAPadding, 100)];
//    _quitDisabledView.userInteractionEnabled = NO;
//    
//    [_speedView addSubview:_quitDisabledView];
}

@end
