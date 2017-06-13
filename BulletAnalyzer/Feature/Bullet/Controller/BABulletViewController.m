
//
//  BABulletViewController.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/13.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BABulletViewController.h"
#import "BABulletListView.h"
#import "BABulletController.h"
#import "BAReportModel.h"
#import "BAAnalyzerCenter.h"

@interface BABulletViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) BABulletListView *bulletListView;
@property (nonatomic, strong) BABulletController *bulletController;

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
    
    self.getSpeed = 0.3;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
}


#pragma mark - private
- (void)setupScrollView{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.contentSize = CGSizeMake(BAScreenWidth, BAScreenHeight * 5);
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollEnabled = NO;
    
    [self.view addSubview:_scrollView];
}


- (void)setupBulletListView{
    _bulletListView = [[BABulletListView alloc] initWithFrame:CGRectMake(0, 0, BAScreenWidth, BAScreenHeight)];
    
    
    [_scrollView addSubview:_bulletListView];
}


- (void)setupBulletConroller{
    _bulletController = [[BABulletController alloc] initWithFrame:CGRectMake(0, BAScreenHeight, BAScreenWidth, BABulletContollerHeight)];
    _bulletController.hidden = YES;
    
    [_scrollView addSubview:_bulletController];
}


- (void)setupTimer{
    [_timer invalidate];
    _timer = nil;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_getDuration repeats:YES block:^(NSTimer * _Nonnull timer) {
        
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




@end
