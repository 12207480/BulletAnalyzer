
//
//  BABulletViewController.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/13.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BABulletViewController.h"
#import "BABulletListView.h"
#import "BAReportViewController.h"
#import "BABulletMenu.h"
#import "BABulletSetting.h"
#import "BABulletSliderView.h"
#import "BABulletListNavPopView.h"
#import "BASentenceView.h"
#import "BAReportModel.h"
#import "BAAnalyzerCenter.h"
#import "BASocketTool.h"
#import "UIImage+ZJExtension.h"
#import "UIBarButtonItem+ZJExtension.h"
#import "NSDate+Category.h"

@interface BABulletViewController () <UIScrollViewDelegate>
//弹幕列表
@property (nonatomic, strong) BABulletListView *bulletListView; //弹幕列表
@property (nonatomic, strong) BABulletMenu *bulletMenu;    //底部按钮
@property (nonatomic, strong) BABulletSetting *bulletSetting;  //弹出的三个按钮
@property (nonatomic, strong) BABulletSliderView *bulletSliderView; //弹幕速度滑块
@property (nonatomic, strong) BASentenceView *sentenceView; //相似弹幕
@property (nonatomic, strong) BABulletListNavPopView *popView; //筛选弹框
@property (nonatomic, strong) UIView *settingMask; //遮盖
@property (nonatomic, strong) NSTimer *hideTimer; //隐藏倒计时
@property (nonatomic, assign) CGFloat repeatDuration; //倒计时时间
@property (nonatomic, assign, getter=isMidBtnClose) BOOL midBtnClose; //中间按钮 NO表示回证 YES保持不回正

//控制速度
@property (nonatomic, strong) NSTimer *timer; //抓取弹幕
@property (nonatomic, assign) CGFloat getSpeed; //0-1之间 频率
@property (nonatomic, assign) CGFloat getDuration; //抓取间隔
@property (nonatomic, assign) NSInteger getCount; //抓取数量
@property (nonatomic, assign) NSInteger filterTag; //0只显示弹幕, 1只显示礼物, 2弹幕礼物同时显示

/*以下功能未实现*/
////等级筛选
//@property (nonatomic, assign) NSInteger level;
//
////移动端/web端 0都看, 1只看移动端, 2只看web端
//@property (nonatomic, assign) NSInteger source;

@end

@implementation BABulletViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBulletListView];
    
    [self setupBulletMenu];
    
    [self setupBulletSetting];
    
    [self setupBulletSlider];
    
    [self setupSentenceView];
    
    [self setupNavigationBar];
    
    [self setupPopView];
    
    [self addNotificationObserver];
    
    self.getSpeed = 0.5;
    self.filterTag = 2;
    
    [self larger];
}


- (void)dealloc{
    [BANotificationCenter removeObserver:self];
}


#pragma mark - animation
- (void)smaller{
    
    //底部按钮旋转正
    if (!_midBtnClose) {
        [_bulletMenu close];
        
        //弹幕列表尺寸变化
        [UIView animateWithDuration:0.3 animations:^{
            _bulletListView.frame = CGRectMake(0, 20, BAScreenWidth, BAScreenHeight - 69);
        } completion:nil];
    }
  
    //收回三个圆形按钮
    if (self.bulletSetting.isAlreadyShow) {
        [self.bulletSetting hide];
        self.settingMask.hidden = YES;
    }

    //收起导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //关闭定时器
    [_hideTimer invalidate];
    _hideTimer = nil;
}


- (void)larger{
    [self beginTimer];
    [UIView animateWithDuration:0.3 animations:^{
        _bulletListView.frame = CGRectMake(0, 64, BAScreenWidth, BAScreenHeight - 113);
    } completion:nil];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)sliderShow{
    _bulletSliderView.transform = CGAffineTransformMakeTranslation(0, _bulletSliderView.height + _bulletMenu.height);
    _bulletSliderView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _bulletSliderView.transform = CGAffineTransformIdentity;
        _bulletListView.frame = CGRectMake(0, 20, BAScreenWidth, BAScreenHeight - 69 - _bulletSliderView.height);
    } completion:^(BOOL finished) {
        [_bulletMenu shadowHide];
    }];
}


- (void)sliderHide{
    _bulletSliderView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.3 animations:^{
        _bulletSliderView.transform = CGAffineTransformMakeTranslation(0, _bulletSliderView.height + _bulletMenu.height);
        _bulletListView.frame = CGRectMake(0, 20, BAScreenWidth, BAScreenHeight - 69);
    } completion:^(BOOL finished) {
        [_bulletMenu shadowShow];
        _bulletSliderView.hidden = YES;
    }];
}


- (void)sentenceShow{
    _sentenceView.transform = CGAffineTransformMakeTranslation(0, _sentenceView.height + _bulletMenu.height);
    _sentenceView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        _sentenceView.transform = CGAffineTransformIdentity;
        _bulletListView.frame = CGRectMake(0, 20, BAScreenWidth, BAScreenHeight - 69 - _sentenceView.height);
    } completion:^(BOOL finished) {
        [_bulletMenu shadowHide];
    }];
}


- (void)sentenceHide{
    _sentenceView.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.3 animations:^{
        _sentenceView.transform = CGAffineTransformMakeTranslation(0, _sentenceView.height + _bulletMenu.height);
        _bulletListView.frame = CGRectMake(0, 20, BAScreenWidth, BAScreenHeight - 69);
    } completion:^(BOOL finished) {
        [_bulletMenu shadowShow];
        _sentenceView.hidden = YES;
    }];
}


#pragma mark - userInteraction
- (void)backBtnClicked{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


- (void)filterTypeBtnClicked{
    
    if (_bulletSetting.isAlreadyShow) return;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.navigationItem.rightBarButtonItem.enabled = YES;
    });
    
    if (_hideTimer) {
        [_hideTimer invalidate];
        _hideTimer = nil;
    
        _popView.hidden = NO;
        _settingMask.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _popView.alpha = 1;
        }];
    } else {
        [self beginTimer];
        
        _settingMask.hidden = YES;
        [UIView animateWithDuration:0.3 animations:^{
            _popView.alpha = 0;
        } completion:^(BOOL finished) {
            _popView.hidden = NO;
        }];
    }
}


- (void)maskTapped{
    if (!_popView.isHidden) {
        [self filterTypeBtnClicked];
    }
    
    if (_bulletSetting.isAlreadyShow) {
        [self smaller];
    }
}


#pragma mark - private
- (void)beginTimer{
    [_hideTimer invalidate];
    _hideTimer = nil;
    
    _repeatDuration = 3.f;
    _hideTimer = [NSTimer scheduledTimerWithTimeInterval:_repeatDuration target:self selector:@selector(smaller) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_hideTimer forMode:NSRunLoopCommonModes];
}


- (void)addNotificationObserver{
    [BANotificationCenter addObserver:self selector:@selector(gift:) name:BANotificationGift object:nil];
}


- (void)setupBulletListView{
    _bulletListView = [[BABulletListView alloc] init];

    [self.view addSubview:_bulletListView];
}


- (void)setupBulletMenu{
    WeakObj(self);
    _bulletMenu = [[BABulletMenu alloc] initWithFrame:CGRectMake(0, BAScreenHeight - BABulletMenuHeight, BAScreenWidth, BABulletMenuHeight)];
    _bulletMenu.menuTouched = ^{
       
        if (!selfWeak.midBtnClose) {
            [selfWeak larger];
        }
    };
    _bulletMenu.middleBtnClicked = ^{
        
        if (selfWeak.midBtnClose) {
            
            if (!selfWeak.bulletSliderView.isHidden) {
        
                [selfWeak sliderHide];
            } else {
                
                [selfWeak sentenceHide];
            }
            
            [selfWeak.bulletMenu close];
            selfWeak.midBtnClose = NO;
            return;
        }
        [selfWeak larger];
        if (selfWeak.bulletMenu.isOpened) {
            [selfWeak.bulletMenu close];
        } else {
            [selfWeak.bulletMenu open];
        }
        
        if (selfWeak.bulletSetting.isAlreadyShow) {
            [selfWeak.bulletSetting hide];
            selfWeak.settingMask.hidden = YES;
        } else {
            [selfWeak.bulletSetting show];
            selfWeak.settingMask.hidden = NO;
        }
    };
    _bulletMenu.leftBtnClicked = ^{
        
        if (!selfWeak.midBtnClose) {
            [selfWeak larger];
        }
        CGFloat duration = [[NSDate date] minutesAfterDate:selfWeak.reportModel.begin];
        
        NSString *message = @"断开后将自动保存分析报告";
        if (duration < 3) {
            message = @"连接不满三分钟, 将不会保存报告";
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否结束分析?" message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"结束" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [[BASocketTool defaultSocket] cutOff];
            [selfWeak backBtnClicked];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:action1];
        [alert addAction:action2];
        
        [selfWeak presentViewController:alert animated:YES completion:nil];
    };
    _bulletMenu.rightBtnClicked = ^{
        
        if (!selfWeak.midBtnClose) {
            [selfWeak larger];
        }
        CGFloat duration = [[NSDate date] minutesAfterDate:selfWeak.reportModel.begin];
        
        if (duration < 3) {
            [BATool showHUDWithText:@"查看报告需要连接三分钟以上!" ToView:BAKeyWindow];
            return;
        }
        
        BAReportViewController *bulletVC = [[BAReportViewController alloc] init];
        bulletVC.reportModel = selfWeak.reportModel;
        
        BANavigationViewController *navigationVc = [[BANavigationViewController alloc] initWithRootViewController:bulletVC];
        [selfWeak presentViewController:navigationVc animated:YES completion:nil];
    };

    [self.view addSubview:_bulletMenu];
}


- (void)setupBulletSetting{
    
    WeakObj(self);
    _bulletSetting = [[BABulletSetting alloc] initWithFrame:CGRectMake(0, BAScreenHeight - BABulletMenuHeight - BABulletSettingHeight, BAScreenWidth, BABulletSettingHeight)];
    _bulletSetting.hidden = YES;
    _bulletSetting.leftBtnClicked = ^{
        
        selfWeak.settingMask.hidden = YES;
        selfWeak.midBtnClose = NO;
        [selfWeak smaller];
    };
    _bulletSetting.middleBtnClicked = ^{
        
        [selfWeak sentenceShow];
        selfWeak.settingMask.hidden = YES;
        selfWeak.midBtnClose = YES;
        [selfWeak smaller];
    };
    _bulletSetting.rightBtnClicked = ^{
        
        [selfWeak sliderShow];
        selfWeak.settingMask.hidden = YES;
        selfWeak.midBtnClose = YES;
        [selfWeak smaller];
    };
    
    [self.view insertSubview:_bulletSetting belowSubview:_bulletMenu];
    
    _settingMask = [[UIView alloc] initWithFrame:self.view.bounds];
    _settingMask.backgroundColor = [BABlackColor colorWithAlphaComponent:0.4];
    _settingMask.hidden = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskTapped)];
    [_settingMask addGestureRecognizer:tap];
    
    [self.view insertSubview:_settingMask aboveSubview:_bulletListView];
}


- (void)setupBulletSlider{
    
    WeakObj(self);
    _bulletSliderView = [[BABulletSliderView alloc] initWithFrame:_bulletSetting.frame];
    _bulletSliderView.speedChanged = ^(CGFloat speed){
        
        selfWeak.getSpeed = speed;
    };
    _bulletSliderView.hidden = YES;
    
    [self.view insertSubview:_bulletSliderView belowSubview:_bulletMenu];
}


- (void)setupSentenceView{
    
    _sentenceView = [[BASentenceView alloc] initWithFrame:CGRectMake(0, _bulletMenu.y - BASentenceViewHeight, BAScreenWidth, BASentenceViewHeight) style:UITableViewStylePlain];
    _sentenceView.statusArray = _reportModel.sentenceArray;
    _sentenceView.hidden = YES;
    
    [self.view insertSubview:_sentenceView belowSubview:_bulletMenu];
}


- (void)setupPopView{
    WeakObj(self);
    _popView = [[BABulletListNavPopView alloc] initWithFrame:CGRectMake(BAScreenWidth - 100, 64, 100, 105)];
    _popView.alpha = 0;
    _popView.hidden = YES;
    _popView.btnClicked = ^(NSInteger tag) {
        selfWeak.filterTag = tag;
        [selfWeak filterTypeBtnClicked];
    };
    
    [self.view addSubview:_popView];
}


- (void)setupNavigationBar{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:[BAWhiteColor colorWithAlphaComponent:0.3]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navShadowImg"]];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem BarButtonItemWithTitle:@"筛选" target:self action:@selector(filterTypeBtnClicked)];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}


- (void)setupTimer{
    [_timer invalidate];
    _timer = nil;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_getDuration target:self selector:@selector(getTimeUp) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}


- (void)getTimeUp{
    
    if (_filterTag == 1) return;
    
    if (!self.title.length) {
        self.title = _reportModel.name;
        [self larger];
    }
    
    NSArray *subArray;
    if (_reportModel.bulletsArray.count > _getCount) {
        subArray = [_reportModel.bulletsArray subarrayWithRange:NSMakeRange(_reportModel.bulletsArray.count - _getCount, _getCount)];
    } else {
        subArray = _reportModel.bulletsArray;
    }
    [_bulletListView addStatus:subArray];
}


- (void)setGetSpeed:(CGFloat)getSpeed{
    _getSpeed = getSpeed;
    
    if (getSpeed > 1) { //设为1为最快速度 预留
        
        self.getDuration = 0.05;
        self.getCount = 50;
        
    } else if (getSpeed > 0.8) {
        
        _getDuration = 0.05;
        _getCount = 30;
        
    } else if (getSpeed > 0.6) {
        
        _getDuration = 0.1;
        _getCount = 5;
        
    } else if (getSpeed > 0.4) {
        
        _getDuration = 0.1;
        _getCount = 2;
        
    } else if (getSpeed > 0.2) {
        
        _getDuration = 0.2;
        _getCount = 1;
        
    } else {
        
        _getDuration = 0.5;
        _getCount = 1;
    }
    
    [self setupTimer];
}


- (void)gift:(NSNotification *)sender{
    
    if (_filterTag == 0) return;
    
    NSArray *giftArray = sender.userInfo[BAUserInfoKeyGift];
    [_bulletListView addStatus:giftArray];
}

@end
