//
//  BABulletController.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/13.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BABulletController.h"

@interface BABulletController()
@property (nonatomic, strong) UIButton *blackBtn;
@property (nonatomic, strong) UIButton *whiheBtn;
@property (nonatomic, strong) UIButton *endBtn;

@end

@implementation BABulletController

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - userInteraction
- (void)blackBtnClicked{

}


- (void)whiteBtnClicked{

}


- (void)endBtnClicked{
    
}


#pragma mark - private
- (void)setupSubViews{
    _blackBtn = [UIButton buttonWithFrame:CGRectMake(BAPadding, BAPadding, (BAScreenWidth - BAPadding) / 2 - BAPadding, 30) title:@"黑名单" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:BAThemeColor] target:self action:@selector(blackBtnClicked)];
    
    [self addSubview:_blackBtn];
    
    _whiheBtn = [UIButton buttonWithFrame:CGRectMake(_blackBtn.right + BAPadding, BAPadding, _blackBtn.width, _blackBtn.height) title:@"白名单" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:BAThemeColor] target:self action:@selector(whiteBtnClicked)];
    
    [self addSubview:_whiheBtn];
    
    _endBtn = [UIButton buttonWithFrame:CGRectMake(BAPadding, BABulletContollerHeight - BAPadding - 30, BAScreenWidth - 2 * BAPadding, 30) title:@"结束分析" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:BAThemeColor] target:self action:@selector(endBtnClicked)];
    
    [self addSubview:_endBtn];
    
    
}

@end
