
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
#import "BACountReport.h"
#import "BAWordsReport.h"
#import "BAActiveReport.h"
#import "BAFansReport.h"
#import "BAReportModel.h"
#import "BAAnalyzerCenter.h"

@interface BABulletViewController () <UIScrollViewDelegate>
//弹幕列表
@property (nonatomic, strong) BABulletListView *bulletListView;
@property (nonatomic, strong) BABulletMenu *bulletMenu;
@property (nonatomic, strong) BABulletSetting *bulletSetting;
@property (nonatomic, strong) NSTimer *hideTimer;
@property (nonatomic, assign) CGFloat repeatDuration;

//分析报告
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) BACountReport *countReport;
@property (nonatomic, strong) BAWordsReport *wordsReport;
@property (nonatomic, strong) BAActiveReport *activeReport;
@property (nonatomic, strong) BAFansReport *fansReport;

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
    
    [self setupScrollView];
    
    [self setupCountReport];
    
    [self setupWordsReport];
    
    [self setupActiceReport];
    
    [self setupFansReport];
    
    self.getSpeed = 0.5;
    
    if (_reportModel.end) {
        self.page = 1;
        self.scrollView.y = 0;
        self.tipsLabel.hidden = YES;
    }
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
}


#pragma mark - animation
- (void)smaller{
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
    NSLog(@"%s", __func__);
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
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, BAScreenHeight, BAScreenWidth, BAScreenHeight)];
    _scrollView.contentSize = CGSizeMake(BAScreenWidth, BAScreenHeight * 4);
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.layer.contents = (id)[UIImage imageNamed:@"backgroundView"].CGImage;
    
    _tipsLabel = [UILabel labelWithFrame:CGRectMake(0, -20, BAScreenWidth, 20) text:@"下拉回到弹幕列表" color:BALightTextColor font:BAThinFont(BASmallTextFontSize) textAlignment:NSTextAlignmentCenter];
    
    [_scrollView addSubview:_tipsLabel];
    [self.view addSubview:_scrollView];
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
            
            [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
               
                selfWeak.scrollView.y = 0;
                
            } completion:nil];
    
            [[BAAnalyzerCenter defaultCenter] endAnalyzing];
            selfWeak.tipsLabel.hidden = YES;
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:action1];
        [alert addAction:action2];
        
        [selfWeak presentViewController:alert animated:YES completion:nil];
    };
    _bulletMenu.reportBtnClicked = ^{
        
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
           
            selfWeak.scrollView.y = 0;
            
        } completion:nil];
        selfWeak.page = 1;
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
    
}


- (void)setupTimer{
    [_timer invalidate];
    _timer = nil;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_getDuration repeats:YES block:^(NSTimer * _Nonnull timer) {
        
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
    }];
    [_timer fire];
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


- (void)setupCountReport{
    _countReport = [[BACountReport alloc] initWithFrame:CGRectMake(0, BAScreenHeight - BAScreenWidth, BAScreenWidth, BAScreenWidth)];
    
    [_scrollView addSubview:_countReport];
}


- (void)setupWordsReport{
    _wordsReport = [[BAWordsReport alloc] initWithFrame:CGRectMake(0, 2 * BAScreenHeight - 0.8 * BAScreenWidth, BAScreenWidth, 0.8 * BAScreenWidth)];
    
    [_scrollView addSubview:_wordsReport];
}


- (void)setupActiceReport{
    _activeReport = [[BAActiveReport alloc] initWithFrame:CGRectMake(0, 2 * BAScreenHeight, BAScreenWidth, BAScreenHeight)];

    [_scrollView addSubview:_activeReport];
}



- (void)setupFansReport{
    _fansReport = [[BAFansReport alloc] initWithFrame:CGRectMake(0, 4 * BAScreenHeight - BAScreenHeight * 0.75, BAScreenWidth, BAScreenHeight * 0.75)];
    
    [_scrollView addSubview:_fansReport];
}



- (void)setPage:(NSInteger)page{
  
    if (_page != page) {
        
        switch (page) {
            case 1:
                _countReport.reportModel = _reportModel;
                break;
                
            case 2:
                _wordsReport.reportModel = _reportModel;
                break;
                
            case 3:
                _activeReport.reportModel = _reportModel;
                break;
                
            case 4:
                _fansReport.reportModel = _reportModel;
                break;
                
            default:
                break;
        }
    }
    
    _page = page;
}


#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    //下拉隐藏
    if (offsetY < -50 && !_reportModel.end) {
        
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.9 options:UIViewAnimationOptionCurveEaseIn animations:^{
            
            scrollView.y = BAScreenHeight;
            
        } completion:^(BOOL finished) {
    
            _scrollView.contentOffset = CGPointMake(0, 0);
            self.page = 0;
        }];
    }
    
    if (offsetY >= BAScreenHeight) {
        [_countReport hide];
    }
    
    if (offsetY >= 2 * BAScreenHeight || offsetY <= 0) {
        [_wordsReport hide];
    }
    
    if (offsetY >= 3 * BAScreenHeight || offsetY <= BAScreenHeight) {
        [_activeReport hide];
    }
    
    if (offsetY >= 4 * BAScreenHeight || offsetY <= 2 * BAScreenHeight) {
        [_fansReport hide];
    }
    
    //划到每一页
    self.page = (NSInteger)(offsetY + BAScreenHeight / 2) / BAScreenHeight + 1;
}


@end
