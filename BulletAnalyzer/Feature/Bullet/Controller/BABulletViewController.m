
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
#import "BASocketTool.h"
#import "UIImage+ZJExtension.h"

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
    
    self.getSpeed = 0.5;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //[UIApplication sharedApplication].statusBarHidden = YES;
}


#pragma mark - animation
- (void)smaller{
    [_hideTimer invalidate];
    _hideTimer = nil;
    _bulletSetting.hidden = YES;
    _bulletListView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        _bulletMenu.frame = CGRectMake(0, BAScreenHeight - BABulletMenuHeight + 20, BAScreenWidth, BABulletMenuHeight - 20);
        _bulletMenu.moreBtn.centerY = _bulletMenu.height / 2;
        _bulletMenu.endBtn.centerY = _bulletMenu.height / 2;
        _bulletMenu.reportBtn.centerY = _bulletMenu.height / 2;
        
    }];
}


- (void)larger{
    [self beginTimer];
    _bulletListView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        _bulletMenu.frame = CGRectMake(0, BAScreenHeight - BABulletMenuHeight, BAScreenWidth, BABulletMenuHeight);
        _bulletMenu.moreBtn.centerY = _bulletMenu.height / 2;
        _bulletMenu.endBtn.centerY = _bulletMenu.height / 2;
        _bulletMenu.reportBtn.centerY = _bulletMenu.height / 2;    } completion:^(BOOL finished) {
        _bulletSetting.hidden = !(BOOL)_bulletSetting.tag;
    }];
}


#pragma mark - userInteraction
- (void)roomCollect{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - private
- (void)beginTimer{
    [_hideTimer invalidate];
    _hideTimer = nil;
    
    _repeatDuration = 5.f;
    _hideTimer = [NSTimer scheduledTimerWithTimeInterval:_repeatDuration target:self selector:@selector(smaller) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_hideTimer forMode:NSRunLoopCommonModes];
}


- (void)setupBulletListView{
    _bulletListView = [[BABulletListView alloc] initWithFrame:CGRectMake(0, 0, BAScreenWidth, BAScreenHeight - 50)];

    [self.view addSubview:_bulletListView];
}


- (void)setupBulletConroller{
    WeakObj(self);
    _bulletMenu = [[BABulletMenu alloc] initWithFrame:CGRectMake(0, BAScreenHeight - BABulletMenuHeight + 20, BAScreenWidth, BABulletMenuHeight - 20)];
    _bulletMenu.menuTouched = ^{
        if (selfWeak.bulletMenu.height == BABulletMenuHeight) {
            [selfWeak smaller];
        } else {
            [selfWeak larger];
        }
    };
    _bulletMenu.moreBtnClicked = ^{
        if (selfWeak.bulletMenu.height == BABulletMenuHeight) {
            selfWeak.bulletSetting.hidden = !selfWeak.bulletSetting.isHidden;
            selfWeak.bulletSetting.tag = selfWeak.bulletSetting.isHidden ? 0 : 1;
        } else {
            [selfWeak larger];
            selfWeak.bulletSetting.tag = 1;
        }
    };
    _bulletMenu.endBtnClicked = ^{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否结束分析?" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"结束" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            


            [[BASocketTool defaultSocket] cutOff];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:action1];
        [alert addAction:action2];
        
        [selfWeak presentViewController:alert animated:YES completion:nil];
    };
    _bulletMenu.reportBtnClicked = ^{
        
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
           
            
            
        } completion:nil];
    };
    
    [self.view addSubview:_bulletMenu];

    _bulletSetting = [[BABulletSetting alloc] initWithFrame:CGRectMake(0, BAScreenHeight - BABulletMenuHeight - BABulletSettingHeight, BAScreenWidth, BABulletSettingHeight)];
    _bulletSetting.hidden = YES;
    _bulletSetting.settingTouched = ^{
        [selfWeak larger];
    };
    _bulletSetting.speedChanged = ^(CGFloat speed){
        selfWeak.getSpeed = speed;
    };
    
    [self.view addSubview:_bulletSetting];
}


- (void)setupNavigationBar{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:[BAWhiteColor colorWithAlphaComponent:0.2]] forBarMetrics:UIBarMetricsDefault];
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
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem BarButtonItemWithImg:@"star" highlightedImg:nil target:self action:@selector(roomCollect)];
        [self larger];
    }
    
    NSArray *subArray;
    if (_reportModel.bulletsArray.count > _getCount) {
        subArray = [_reportModel.bulletsArray subarrayWithRange:NSMakeRange(_reportModel.bulletsArray.count - _getCount, _getCount)];
    } else {
        subArray = _reportModel.bulletsArray;
    }
    [_bulletListView addBullets:subArray];
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


@end
