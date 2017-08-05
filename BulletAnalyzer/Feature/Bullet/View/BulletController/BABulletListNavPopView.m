//
//  BABulletListNavPopView.m
//  BulletAnalyzer
//
//  Created by Zj on 17/8/5.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BABulletListNavPopView.h"

@interface BABulletListNavPopView()
@property (nonatomic, strong) UIButton *bulletBtn;
@property (nonatomic, strong) UIButton *giftBtn;
@property (nonatomic, strong) UIButton *bulletGiftBtn;

@end

@implementation BABulletListNavPopView

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - userInteraction
- (void)btnClicked:(UIButton *)sender{
    _bulletBtn.selected = NO;
    _giftBtn.selected = NO;
    _bulletGiftBtn.selected = NO;
    sender.selected = YES;
    
    _btnClicked(sender.tag);
}


#pragma mark - private
- (void)setupSubViews{
    
    CGFloat height = self.height / 3;
    CGFloat width = self.width;
    _bulletBtn = [UIButton buttonWithFrame:CGRectMake(0, 0, width, height) title:@"弹幕" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:[BAWhiteColor colorWithAlphaComponent:0.45]] target:self action:@selector(btnClicked:)];
    _bulletBtn.tag = 0;
    [_bulletBtn setBackgroundImage:[UIImage imageWithColor:[BAWhiteColor colorWithAlphaComponent:0.3]] forState:UIControlStateSelected];
    
    [self addSubview:_bulletBtn];
    
    _giftBtn = [UIButton buttonWithFrame:CGRectMake(0, _bulletBtn.bottom, width, height) title:@"礼物" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:[BAWhiteColor colorWithAlphaComponent:0.45]] target:self action:@selector(btnClicked:)];
    _giftBtn.tag = 1;
    [_giftBtn setBackgroundImage:[UIImage imageWithColor:[BAWhiteColor colorWithAlphaComponent:0.3]] forState:UIControlStateSelected];
    
    [self addSubview:_giftBtn];
    
    _bulletGiftBtn = [UIButton buttonWithFrame:CGRectMake(0, _giftBtn.bottom, width, height) title:@"弹幕&礼物" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:[BAWhiteColor colorWithAlphaComponent:0.45]] target:self action:@selector(btnClicked:)];
    _bulletGiftBtn.tag = 2;
    [_bulletGiftBtn setBackgroundImage:[UIImage imageWithColor:[BAWhiteColor colorWithAlphaComponent:0.3]] forState:UIControlStateSelected];
    _bulletGiftBtn.selected = YES;
    
    [self addSubview:_bulletGiftBtn];
}

@end
