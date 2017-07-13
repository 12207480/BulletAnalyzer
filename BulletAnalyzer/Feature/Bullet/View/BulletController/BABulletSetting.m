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

@property (nonatomic, strong) UIView *filterView;

@property (nonatomic, strong) UIView *speedView;
@property (nonatomic, strong) BASlider *silder;
@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) UIView *quitDisabledView;

@end

@implementation BABulletSetting
#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = BADark2BackgroundColor;
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - userInteraction
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint point = [[touches anyObject] locationInView:self];
    
    if (![_quitDisabledView.layer containsPoint:point]) {
        [self swichTo:_firstView];
    }
    
    if (_settingTouched) {
        _settingTouched();
    }
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_settingTouched) {
        _settingTouched();
    }
}


- (void)btnClicked:(UIButton *)sender{
    switch (sender.tag) {
        case 0:
            [self swichTo:_filterView];
            break;
            
        case 1:
            [self swichTo:_speedView];
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
    
    _filterBtn = [UIButton buttonWithFrame:CGRectMake(BAScreenWidth / 4, self.height / 5, BAScreenWidth / 2, self.height / 4) title:@"    弹幕筛选" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:BAThemeColor] target:self action:@selector(btnClicked:)];
    _filterBtn.layer.cornerRadius = _filterBtn.height / 2;
    _filterBtn.clipsToBounds = YES;
    _filterBtn.tag = 0;
    [_filterBtn setImage:[UIImage imageNamed:@"filterImg"] forState:UIControlStateNormal];
    
    [_firstView addSubview:_filterBtn];
    
    _speedBtn = [UIButton buttonWithFrame:CGRectMake(BAScreenWidth / 4, self.height * 3 / 5, BAScreenWidth / 2, self.height / 4) title:@"    弹幕速度" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:BAThemeColor] target:self action:@selector(btnClicked:)];
    _speedBtn.layer.cornerRadius = _speedBtn.height / 2;
    _speedBtn.clipsToBounds = YES;
    _speedBtn.tag = 1;
    [_speedBtn setImage:[UIImage imageNamed:@"speedImg"] forState:UIControlStateNormal];
    
    [_firstView addSubview:_speedBtn];

    
    _filterView = [[UIView alloc] initWithFrame:self.bounds];
    _filterView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    _filterView.alpha = 0;
    
    [self addSubview:_filterView];
    
    
    
    _speedView = [[UIView alloc] initWithFrame:self.bounds];
    _speedView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    _speedView.alpha = 0;
    
    [self addSubview:_speedView];
    
    _silder = [[BASlider alloc] initWithFrame:CGRectMake(2 * BAPadding, self.height / 2 - 6, BAScreenWidth - 4 * BAPadding , 12)];
    _silder.maximumValue = 1.0;
    _silder.minimumValue = 0.0;
    _silder.value = 0.5;
    _silder.maximumTrackTintColor = BALightTextColor;
    [_silder setThumbImage:[UIImage imageNamed:@"silderItem"] forState:UIControlStateNormal];
    _silder.tintColor = BAThemeColor;
    [_silder addTarget:self action:@selector(valueChanged) forControlEvents:UIControlEventTouchUpInside];
    
    [_speedView addSubview:_silder];
    
    _tipsLabel = [UILabel labelWithFrame:CGRectMake(_silder.x + BAPadding, _silder.bottom + BAPadding, _silder.width, 30) text:@"tip:调整弹幕速度不影响分析报告" color:BALightTextColor font:BAThinFont(BASmallTextFontSize) textAlignment:NSTextAlignmentLeft];
    
    [_speedView addSubview:_tipsLabel];
    
    _quitDisabledView = [[UIView alloc] initWithFrame:CGRectMake(BAPadding, 25, BAScreenWidth - 2 * BAPadding, 100)];
    _quitDisabledView.userInteractionEnabled = NO;
    
    [_speedView addSubview:_quitDisabledView];
}

@end
