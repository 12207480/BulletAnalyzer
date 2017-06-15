
//
//  BABulletViewController.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/13.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BABulletViewController.h"
#import "BABulletListView.h"
#import "BABulletMenu.h"
#import "BABulletSetting.h"
#import "BAReportModel.h"
#import "BAAnalyzerCenter.h"

@interface BABulletViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIView *navigationBar;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) BABulletListView *bulletListView;
@property (nonatomic, strong) BABulletMenu *bulletMenu;
@property (nonatomic, strong) BABulletSetting *bulletSetting;
@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) NSTimer *hideTimer;
@property (nonatomic, assign) CGFloat repeatDuration;

//控制速度
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGFloat getSpeed; //0-1之间 频率
@property (nonatomic, assign) CGFloat getDuration;
@property (nonatomic, assign) NSInteger getCount;

//等级筛选
@property (nonatomic, assign) NSInteger level;

//移动端/web端 0都看, 1只看移动端, 2只看web端
@property (nonatomic, assign) NSInteger source;

@end

@implementation BABulletViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupScrollView];
    
    [self setupBulletListView];
    
    [self setupBulletConroller];
    
    [self setupNavigationBar];
    
    self.getSpeed = 0.3;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
}


#pragma mark - animation
- (void)smaller{
    _bulletSetting.hidden = YES;
    [UIView animateWithDuration:0.4 animations:^{
        _bulletMenu.frame = CGRectMake(0, BAScreenHeight - BABulletMenuHeight + 20, BAScreenWidth, BABulletMenuHeight - 20);
        _bulletMenu.moreBtn.centerY = _bulletMenu.height / 2;
        _bulletMenu.endBtn.centerY = _bulletMenu.height / 2;
        _bulletMenu.reportBtn.centerY = _bulletMenu.height / 2;
        
        _navigationBar.y = -44;
    }];
}


- (void)larger{
    [self beginTimer];
    [UIView animateWithDuration:0.4 animations:^{
        _bulletMenu.frame = CGRectMake(0, BAScreenHeight - BABulletMenuHeight, BAScreenWidth, BABulletMenuHeight);
        _bulletMenu.moreBtn.centerY = _bulletMenu.height / 2;
        _bulletMenu.endBtn.centerY = _bulletMenu.height / 2;
        _bulletMenu.reportBtn.centerY = _bulletMenu.height / 2;
        
        _navigationBar.y = 0;
    } completion:^(BOOL finished) {
        _bulletSetting.hidden = !(BOOL)_bulletSetting.tag;
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


- (void)setupScrollView{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.contentSize = CGSizeMake(BAScreenWidth, BAScreenHeight * 5);
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollEnabled = NO;
    _scrollView.delegate = self;
    
    [self.view addSubview:_scrollView];
}


- (void)setupBulletListView{
    _bulletListView = [[BABulletListView alloc] initWithFrame:CGRectMake(0, 0, BAScreenWidth, BAScreenHeight - 50)];
    _bulletListView.scrollEnabled = NO;
    
    _bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _bgImgView.contentMode = UIViewContentModeScaleAspectFill;
    _bgImgView.image = [UIImage imageNamed:@"bgImg"];
    _bgImgView.userInteractionEnabled = NO;
    
    UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *beffectView = [[UIVisualEffectView alloc] initWithEffect:beffect];
    beffectView.frame = _bgImgView.bounds;
    [_bgImgView addSubview:beffectView];
    
    [_scrollView addSubview:_bgImgView];
    [_scrollView addSubview:_bulletListView];
}


- (void)setupBulletConroller{
    WeakObj(self);
    _bulletMenu = [[BABulletMenu alloc] initWithFrame:CGRectMake(0, BAScreenHeight - BABulletMenuHeight + 20, BAScreenWidth, BABulletMenuHeight - 20)];
    _bulletMenu.menuTouched = ^{
        [selfWeak larger];
    };
    _bulletMenu.moreBtnClicked = ^{
        if (selfWeak.bulletMenu.height == BABulletMenuHeight) {
            selfWeak.bulletSetting.hidden = !selfWeak.bulletSetting.isHidden;
            selfWeak.bulletSetting.tag = selfWeak.bulletSetting.isHidden ? 0 : 1;
        } else {
            selfWeak.bulletSetting.tag = 1;
        }
    };
    _bulletMenu.endBtnClicked = ^{
    
    };
    _bulletMenu.reportBtnClicked = ^{
    
    };
    
    [_scrollView addSubview:_bulletMenu];

    _bulletSetting = [[BABulletSetting alloc] initWithFrame:CGRectMake(0, BAScreenHeight - BABulletMenuHeight - BABulletSettingHeight, BAScreenWidth, BABulletSettingHeight)];
    _bulletSetting.hidden = YES;
    _bulletSetting.settingTouched = ^{
        [selfWeak larger];
    };
    
    [_scrollView addSubview:_bulletSetting];
}


- (void)setupNavigationBar{
    _navigationBar = [[UIView alloc] initWithFrame:CGRectMake(0, -44, BAScreenWidth, 44)];
    _navigationBar.backgroundColor = BAThemeColor;
    
    _titleLabel = [UILabel lableWithFrame:_navigationBar.bounds text:@"" color:BAWhiteColor font:BABlodFont(BALargeTextFontSize) textAlignment:NSTextAlignmentCenter];
    
    [_navigationBar addSubview:_titleLabel];
    [self.view addSubview:_navigationBar];
}


- (void)setupTimer{
    [_timer invalidate];
    _timer = nil;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_getDuration repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        if (_reportModel.avatar.length && !_bgImgView.tag) {
            [_bgImgView sd_setImageWithURL:[NSURL URLWithString:_reportModel.avatar] placeholderImage:BAPlaceHolderImg options:SDWebImageTransformAnimatedImage];
            _bgImgView.tag = 1; //标记已设置背景
            _titleLabel.text = _reportModel.name;
            [self larger];
        }
        
        NSArray *subArray;
        if (_reportModel.bulletsArray.count > _getCount) {
            subArray = [_reportModel.bulletsArray subarrayWithRange:NSMakeRange(_reportModel.bulletsArray.count - _getCount, _getCount)];
        } else {
            subArray = _reportModel.bulletsArray;
        }
        [_bulletListView addBullets:subArray];
    }];
    [_timer fire];
}


- (void)setGetSpeed:(CGFloat)getSpeed{
    _getSpeed = getSpeed;
    
    if (getSpeed > 1) {
        self.getDuration = 0.05;
        self.getCount = 50;
    } else {
        self.getDuration = 0.1 / getSpeed;
        self.getCount = 10 * getSpeed;
    }
    
    [self setupTimer];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _bgImgView.y = scrollView.contentOffset.y;
}

@end
