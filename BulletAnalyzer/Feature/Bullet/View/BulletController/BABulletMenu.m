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
            break;
            
        case 1:
            if (_endBtnClicked) {
                _endBtnClicked();
            }
            break;
            
        case 2:
            if (_reportBtnClicked) {
                _reportBtnClicked();
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


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_menuTouched) {
        _menuTouched();
    }
}


#pragma mark - private
- (void)setupSubViews{
    
    _moreBtn = [UIButton buttonWithFrame:CGRectMake(BAPadding, 10, 30, 30) title:nil color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:nil target:self action:@selector(btnClicked:)];
    _moreBtn.tag = 0;
    [_moreBtn setImage:[UIImage imageNamed:@"moreImg"] forState:UIControlStateNormal];
    
    [self addSubview:_moreBtn];
    
    
    _endBtn = [UIButton buttonWithFrame:CGRectMake(BAScreenWidth / 2 - 20, 5, 40, 40) title:nil color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:nil target:self action:@selector(btnClicked:)];
    _endBtn.tag = 1;
    [_endBtn setImage:[UIImage imageNamed:@"endImg"] forState:UIControlStateNormal];
    
    [self addSubview:_endBtn];
    
    _reportBtn = [UIButton buttonWithFrame:CGRectMake(BAScreenWidth - BAPadding - 30, 10, 30, 30) title:nil color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:nil target:self action:@selector(btnClicked:)];
    _reportBtn.tag = 2;
    [_reportBtn setImage:[UIImage imageNamed:@"reportImg"] forState:UIControlStateNormal];
    
    [self addSubview:_reportBtn];
}

@end
