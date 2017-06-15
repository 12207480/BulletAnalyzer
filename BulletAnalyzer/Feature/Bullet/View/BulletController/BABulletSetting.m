//
//  BABulletSetting.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/15.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BABulletSetting.h"

@interface BABulletSetting()
@property (nonatomic, strong) UIView *firstView;
@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, strong) UIButton *speedBtn;

@property (nonatomic, strong) UIView *filterView;

@property (nonatomic, strong) UIView *speedView;

@end

@implementation BABulletSetting
#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = BALightDarkBackgroundColor;
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - userInteraction
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_settingTouched) {
        _settingTouched();
    }
    [self swichTo:_firstView];
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
    
    _filterBtn = [UIButton buttonWithFrame:CGRectMake(BAScreenWidth / 4, self.height / 5, BAScreenWidth / 2, self.height / 5) title:@"弹幕筛选" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:BAThemeColor] target:self action:@selector(btnClicked:)];
    _filterBtn.tag = 0;
    
    [_firstView addSubview:_filterBtn];
    
    _speedBtn = [UIButton buttonWithFrame:CGRectMake(BAScreenWidth / 4, self.height * 3 / 5, BAScreenWidth / 2, self.height / 5) title:@"弹幕速度" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:BAThemeColor] target:self action:@selector(btnClicked:)];
    _speedBtn.tag = 1;
    
    [_firstView addSubview:_speedBtn];

    
    _filterView = [[UIView alloc] initWithFrame:self.bounds];
    _filterView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    _filterView.alpha = 0;
    
    [self addSubview:_filterView];
    
    
    
    _speedView = [[UIView alloc] initWithFrame:self.bounds];
    _speedView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    _speedView.alpha = 0;
    
    [self addSubview:_speedView];
    
    
    
}

@end
