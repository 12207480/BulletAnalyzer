
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
#import "BAReportModel.h"
#import "BAAnalyzerCenter.h"
#import "BASocketTool.h"
#import "UIImage+ZJExtension.h"
#import "UIBarButtonItem+ZJExtension.h"
#import "NSDate+Category.h"

@interface BABulletViewController () <UIScrollViewDelegate>
//弹幕列表
@property (nonatomic, strong) BABulletListView *bulletListView;
@property (nonatomic, strong) BABulletMenu *bulletMenu;
@property (nonatomic, strong) BABulletSetting *bulletSetting;
@property (nonatomic, strong) NSTimer *hideTimer;
@property (nonatomic, assign) CGFloat repeatDuration;

//控制速度
@property (nonatomic, strong) NSTimer *timer; //抓取弹幕
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
    
    [self setupBulletListView];
    
    [self setupBulletConroller];
    
    [self setupNavigationBar];
    
    [self addNotificationObserver];
    
    self.getSpeed = 0.5;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self larger];
}


- (void)dealloc{
    [BANotificationCenter removeObserver:self];
}


#pragma mark - animation
- (void)smaller{
    [_hideTimer invalidate];
    _hideTimer = nil;
    [_bulletMenu close];
    [UIView animateWithDuration:0.3 animations:^{
        _bulletListView.frame = CGRectMake(0, 20, BAScreenWidth, BAScreenHeight - 69);
    } completion:nil];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];

}


- (void)larger{
    [self beginTimer];
    [UIView animateWithDuration:0.3 animations:^{
        _bulletListView.frame = CGRectMake(0, 64, BAScreenWidth, BAScreenHeight - 113);
    } completion:nil];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - userInteraction
- (void)backBtnClicked{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - private
- (void)beginTimer{
    [_hideTimer invalidate];
    _hideTimer = nil;
    
    _repeatDuration = 8.f;
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


- (void)setupBulletConroller{
    WeakObj(self);
    _bulletMenu = [[BABulletMenu alloc] initWithFrame:CGRectMake(0, BAScreenHeight - BABulletMenuHeight, BAScreenWidth, BABulletMenuHeight)];
    _bulletMenu.menuTouched = ^{
       
        [selfWeak larger];
    };
    _bulletMenu.middleBtnClicked = ^{
        
        [selfWeak larger];
        
        if (selfWeak.bulletSetting.isAlreadyShow) {
            [selfWeak.bulletSetting hide];
        } else {
            [selfWeak.bulletSetting show];
        }
    };
    _bulletMenu.leftBtnClicked = ^{
        
        [selfWeak larger];
        
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
        
        [selfWeak larger];
        
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

    _bulletSetting = [[BABulletSetting alloc] initWithFrame:CGRectMake(0, BAScreenHeight - BABulletMenuHeight - BABulletSettingHeight, BAScreenWidth, BABulletSettingHeight)];
    _bulletSetting.hidden = YES;
    _bulletSetting.settingTouched = ^{
        
        [selfWeak larger];
    };
    _bulletSetting.speedChanged = ^(CGFloat speed){
        
        [selfWeak larger];
        selfWeak.getSpeed = speed;
    };
    
    [self.view insertSubview:_bulletSetting belowSubview:_bulletMenu];
}


- (void)setupNavigationBar{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:[BAWhiteColor colorWithAlphaComponent:0.3]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage imageNamed:@"navShadowImg"]];
//    self.navigationItem.leftBarButtonItem = [UIBarButtonItem BarButtonItemWithImg:@"back_white"  highlightedImg:nil target:self action:@selector(backBtnClicked)];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}


- (void)setupTimer{
    [_timer invalidate];
    _timer = nil;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_getDuration target:self selector:@selector(getTimeUp) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}


- (void)getTimeUp{
    
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
    NSArray *giftArray = sender.userInfo[BAUserInfoKeyGift];
    
    [_bulletListView addStatus:giftArray];
}

@end
