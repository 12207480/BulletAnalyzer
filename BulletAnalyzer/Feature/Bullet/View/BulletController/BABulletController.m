//
//  BABulletController.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/13.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BABulletController.h"

@interface BABulletController()
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIView *settingView;

@property (nonatomic, strong) UILabel *titleLabel1;
@property (nonatomic, strong) UIButton *blackBtn;
@property (nonatomic, strong) UIButton *whiheBtn;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UITextField *levelField;

@property (nonatomic, strong) UILabel *userSourceLabel;
@property (nonatomic, strong) UIButton *userSourceAllBtn;
@property (nonatomic, strong) UIButton *userSourceWebBtn;
@property (nonatomic, strong) UIButton *userSourceMobileBtn;

@property (nonatomic, strong) UILabel *titleLabel2;
@property (nonatomic, strong) UISlider *speedSilder;

@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIButton *endBtn;
@property (nonatomic, strong) UIButton *reportBtn;

@property (nonatomic, strong) NSTimer *hideTimer;
@property (nonatomic, assign) CGFloat repeatDuration;

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
- (void)btnClicked:(UIButton *)sender{
    
    switch (sender.tag) {
        case 0:

            break;
            
        case 1:
            if (_endBtnClicked) {
                _endBtnClicked();
            }
            break;
            
        case 2:

            break;
            
        case 3:
            
            break;
            
        case 4:
            
            break;
            
        default:
            
            break;
    }
}


- (void)valueChange{
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (_menuView.height > 50
        ) {
        [self beginTimer];
    } else {
        CGPoint point = [[touches anyObject] locationInView:self];
        if ([_menuView.layer containsPoint:point]) {
            [self larger];
        }
    }
}


#pragma mark - animation
- (void)smaller{
    _settingView.hidden = YES;
    [UIView animateWithDuration:0.8 animations:^{
        _menuView.frame = CGRectMake(0, 250, BAScreenWidth, 40);
    }];
}


- (void)larger{
    [self beginTimer];
    
    [UIView animateWithDuration:0.8 animations:^{
        _menuView.frame = CGRectMake(0, 220, BAScreenWidth, 70);
    }];
}


#pragma mark - private
- (void)beginTimer{
    [_hideTimer invalidate];
    _hideTimer = nil;
    
    _repeatDuration = 5.f;
    _hideTimer = [NSTimer scheduledTimerWithTimeInterval:_repeatDuration repeats:NO block:^(NSTimer * _Nonnull timer) {
       
        [self smaller];
        [_hideTimer invalidate];
        _hideTimer = nil;
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:_hideTimer forMode:NSRunLoopCommonModes];
}


- (void)setupSubViews{
    
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 250, BAScreenWidth, 40)];
    _menuView.backgroundColor = BADarkBackgroundColor;
    
    [self addSubview:_menuView];
    
    _settingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BAScreenWidth, 220)];
    _settingView.backgroundColor = BALightDarkBackgroundColor;
    _settingView.hidden = YES;
    
    [self addSubview:_settingView];
    
    
    _moreBtn = [UIButton buttonWithFrame:CGRectZero title:@"..." color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:nil target:self action:@selector(btnClicked:)];
    _moreBtn.tag = 0;
    
    [_menuView addSubview:_moreBtn];
    
    
    _endBtn = [UIButton buttonWithFrame:CGRectZero title:@"结" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:nil target:self action:@selector(btnClicked:)];
    _endBtn.tag = 1;
    
    [_menuView addSubview:_endBtn];
    
    _reportBtn = [UIButton buttonWithFrame:CGRectZero title:@"!!!" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:nil target:self action:@selector(btnClicked:)];
    _reportBtn.tag = 2;
    
    [_menuView addSubview:_reportBtn];
    
    
    [_moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(BAPadding);
        make.bottom.mas_equalTo(-BAPadding);
        make.width.mas_equalTo(_moreBtn.mas_height);
    }];
    
    [_endBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(BAPadding);
        make.bottom.mas_equalTo(-BAPadding);
        make.width.mas_equalTo(_moreBtn.mas_height);
        make.centerX.mas_equalTo(0);
    }];
    
    [_reportBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(BAPadding);
        make.bottom.right.mas_equalTo(-BAPadding);
        make.width.mas_equalTo(_moreBtn.mas_height);
    }];
    
    
//    _titleLabel1 = [UILabel lableWithFrame:CGRectMake(BAPadding, BAPadding, BAScreenWidth - 2 * BAPadding, 30) text:@"弹幕筛选" color:BAWhiteColor font:BABlodFont(BALargeTextFontSize) textAlignment:NSTextAlignmentLeft];
//    
//    [self addSubview:_titleLabel1];
//    
//    _blackBtn = [UIButton buttonWithFrame:CGRectMake(BAPadding, _titleLabel1.bottom + BAPadding, (BAScreenWidth - BAPadding) / 2 - BAPadding, 30) title:@"忽略名单" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:BAThemeColor] target:self action:@selector(btnClicked:)];
//    _blackBtn.tag = 0;
//    
//    [self addSubview:_blackBtn];
//    
//    _whiheBtn = [UIButton buttonWithFrame:CGRectMake(_blackBtn.right + BAPadding, _blackBtn.y, _blackBtn.width, _blackBtn.height) title:@"关注名单" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:BAThemeColor] target:self action:@selector(btnClicked:)];
//    _whiheBtn.tag = 1;
//    
//    [self addSubview:_whiheBtn];
//    

//    
//    _levelLabel = [UILabel lableWithFrame:CGRectMake(BAPadding, _blackBtn.bottom + BAPadding, 80, 30) text:@"等级筛选:" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) textAlignment:NSTextAlignmentLeft];
//    
//    [self addSubview:_levelLabel];
//    
//    _levelField = [UITextField textFieldWithFrame:CGRectMake(_levelLabel.right + BAPadding, _levelLabel.y, 100, 30) placeholder:@"用户等级过滤" color:BACommonTextColor font:BACommonFont(BACommonTextFontSize) secureTextEntry:NO delegate:self];
//    _levelField.layer.borderColor = BAWhiteColor.CGColor;
//    _levelField.backgroundColor = [BAWhiteColor colorWithAlphaComponent:0.2];
//    _levelField.layer.borderWidth = 1;
//    _levelField.keyboardType = UIKeyboardTypeDefault;
//    _levelField.returnKeyType = UIReturnKeyDone;
//    _levelField.textAlignment = NSTextAlignmentCenter;
//    
//    [self addSubview:_levelField];
//    
//    _userSourceLabel = [UILabel lableWithFrame:CGRectMake(_levelLabel.x, _levelLabel.bottom + BAPadding, 80, 30) text:@"用户来源:" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) textAlignment:NSTextAlignmentLeft];
//    
//    [self addSubview:_userSourceLabel];
//    
//    _userSourceAllBtn = [UIButton buttonWithFrame:CGRectMake(_userSourceLabel.right + BAPadding, _userSourceLabel.y, 80, 30) title:@"全部" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:BAThemeColor] target:self action:@selector(btnClicked:)];
//    _userSourceAllBtn.tag = 3;
//    
//    [self addSubview:_userSourceAllBtn];
//    
//    _userSourceWebBtn = [UIButton buttonWithFrame:CGRectMake(_userSourceAllBtn.right + BAPadding, _userSourceLabel.y, 80, 30) title:@"PC端" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:BAThemeColor] target:self action:@selector(btnClicked:)];
//    _userSourceWebBtn.tag = 4;
//    
//    [self addSubview:_userSourceWebBtn];
//    
//    _userSourceMobileBtn = [UIButton buttonWithFrame:CGRectMake(_userSourceWebBtn.right + BAPadding, _userSourceLabel.y, 80, 30) title:@"移动端" color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:BAThemeColor] target:self action:@selector(btnClicked:)];
//    _userSourceMobileBtn.tag = 5;
//    
//    [self addSubview:_userSourceMobileBtn];
//    
//    
//    _titleLabel2 = [UILabel lableWithFrame:CGRectMake(BAPadding, _userSourceLabel.bottom + BAPadding, BAScreenWidth - 2 * BAPadding, 30) text:@"弹幕速度" color:BAWhiteColor font:BABlodFont(BALargeTextFontSize) textAlignment:NSTextAlignmentLeft];
//    
//    [self addSubview:_titleLabel2];
//    
//    _speedSilder = [[UISlider alloc] initWithFrame:CGRectMake(BAPadding, _titleLabel2.bottom + BAPadding, BAScreenWidth - 2 * BAPadding, 30)];
//    _speedSilder.tintColor = BAWhiteColor;
//    _speedSilder.maximumValue = 1.0;
//    _speedSilder.minimumValue = 0.0;
//    _speedSilder.value = 0.2;
//    _speedSilder.maximumTrackTintColor = BAThemeColor;
//    _speedSilder.tintColor = BAHighlightThemeColor;
//    [_speedSilder setThumbImage:[UIImage imageNamed:@"sliderItem"] forState:UIControlStateNormal];
//    [_speedSilder addTarget:self action:@selector(valueChange) forControlEvents:UIControlEventValueChanged];
//    
//    [self addSubview:_speedSilder];
}

@end
