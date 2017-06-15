//
//  BABulletMenu.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/15.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BABulletMenu.h"

@interface BABulletMenu()

@end

@implementation BABulletMenu

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = BADarkBackgroundColor;
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - userInteraction
- (void)btnClicked:(UIButton *)sender{
    
    switch (sender.tag) {
        case 0:
            if (_moreBtnClicked) {
                _moreBtnClicked();
            }
            if (_menuTouched) {
                _menuTouched();
            }
            break;
            
        case 1:
            if (_endBtnClicked) {
                _endBtnClicked();
            }
            if (_menuTouched) {
                _menuTouched();
            }
            break;
            
        case 2:
            if (_reportBtnClicked) {
                _reportBtnClicked();
            }
            if (_menuTouched) {
                _menuTouched();
            }
            break;
            
        default:
            
            break;
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_menuTouched) {
        _menuTouched();
    }
}


#pragma mark - private
- (void)setupSubViews{
    
    _moreBtn = [UIButton buttonWithFrame:CGRectMake(BAPadding, 0, 50, 50) title:@"..." color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:nil target:self action:@selector(btnClicked:)];
    _moreBtn.tag = 0;
    
    [self addSubview:_moreBtn];
    
    
    _endBtn = [UIButton buttonWithFrame:CGRectMake(BAScreenWidth / 2 - 30, 0, 50, 50) title:@"结" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:nil target:self action:@selector(btnClicked:)];
    _endBtn.tag = 1;
    
    [self addSubview:_endBtn];
    
    _reportBtn = [UIButton buttonWithFrame:CGRectMake(BAScreenWidth - BAPadding - 60, 0, 50, 50) title:@"!!!" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:nil target:self action:@selector(btnClicked:)];
    _reportBtn.tag = 2;
    
    [self addSubview:_reportBtn];
}

@end
