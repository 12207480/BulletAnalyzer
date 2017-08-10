//
//  BAMainViewController.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/4.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAMainViewController.h"
#import "BABulletViewController.h"
#import "BAReportViewController.h"
#import "BAReportView.h"
#import "UIViewController+MMDrawerController.h"
#import "BASocketTool.h"
#import "BAAnalyzerCenter.h"
#import "BARoomModel.h"
#import "BABulletModel.h"
#import "BAReportModel.h"
#import "Lottie.h"

@interface BAMainViewController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *weekLabel;
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UIView *timeLine;
@property (nonatomic, strong) BAReportView *reportView;
@property (nonatomic, strong) UIView *launchMask;
@property (nonatomic, strong) LOTAnimationView *launchAnimation;

@end

@implementation BAMainViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTitleView];
    
    [self setupReportView];
    
    [self setupNavigation];
    
    [self addNotificationObserver];
    
    //[self setupLaunchMask];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    _reportView.searchHistoryArray = [BAAnalyzerCenter defaultCenter].searchHistoryArray.mutableCopy;
    _reportView.reportModelArray = [BAAnalyzerCenter defaultCenter].reportModelArray.mutableCopy;
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (_launchMask && _launchAnimation) {
        [_launchAnimation playWithCompletion:^(BOOL animationFinished) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:1 animations:^{
                    _launchMask.alpha = 0;
                } completion:^(BOOL finished) {
                    [_launchAnimation removeFromSuperview];
                    _launchAnimation = nil;
                    [_launchMask removeFromSuperview];
                    _launchMask = nil;
                }];
            });
        }];
    }
}


- (void)dealloc{
    [BANotificationCenter removeObserver:self];
}


#pragma mark - userInteraction
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}


- (void)roomBtnClicked{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
    UIButton *btn = (UIButton *)self.navigationItem.leftBarButtonItem.customView;
    btn.selected = !btn.isSelected;
}


- (void)openBtnClicked:(NSNotification *)sender{
    BAReportModel *reportModel = sender.userInfo[BAUserInfoKeyMainCellOpenBtnClicked];
    reportModel.newReport = NO;
    CGRect rect = [sender.userInfo[BAUserInfoKeyMainCellOpenBtnFrame] CGRectValue];
    
    BAReportViewController *bulletVC = [[BAReportViewController alloc] init];
    bulletVC.reportModel = reportModel;

    BANavigationViewController *navigationVc = [[BANavigationViewController alloc] initWithRootViewController:bulletVC];
    navigationVc.cycleRect = rect;
    [self presentViewController:navigationVc animated:YES completion:nil];
}


- (void)reportDelBtnClicked:(NSNotification *)sender{
    BAReportModel *reportModel = sender.userInfo[BAUserInfoKeyMainCellReportDelBtnClicked];
    
    [[BAAnalyzerCenter defaultCenter] delReport:reportModel];
}


- (void)roomSelected:(NSNotification *)sender{
    BARoomModel *roomModel = sender.userInfo[BAUserInfoKeyRoomListCellClicked];
    
    [[BASocketTool defaultSocket] connectSocketWithRoomId:roomModel.room_id];
}


- (void)beginAnalyzing:(NSNotification *)sender{
    BAReportModel *reportModel = sender.userInfo[BAUserInfoKeyReportModel];
    
    BABulletViewController *bulletVC = [[BABulletViewController alloc] init];
    bulletVC.reportModel = reportModel;
    
    BANavigationViewController *navigationVc = [[BANavigationViewController alloc] initWithRootViewController:bulletVC];
    [self presentViewController:navigationVc animated:YES completion:nil];
}


- (void)dataUpdated:(NSNotification *)sender{
    NSMutableArray *searchHistoryArray = sender.userInfo[BAUserInfoKeySearchHistoryArray];
    NSMutableArray *reportModelArray = sender.userInfo[BAUserInfoKeyReportModelArray];
    
    _reportView.searchHistoryArray = searchHistoryArray.mutableCopy;
    _reportView.reportModelArray = reportModelArray.mutableCopy;
}


#pragma mark - private
- (void)setupLaunchMask{
    _launchMask = [[UIView alloc] initWithFrame:self.view.bounds];
    _launchMask.backgroundColor = BAWhiteColor;
    
    [self.view addSubview:_launchMask];
    
    _launchAnimation = [LOTAnimationView animationNamed:@"empty_status"];
    _launchAnimation.cacheEnable = NO;
    _launchAnimation.frame = self.view.bounds;
    _launchAnimation.contentMode = UIViewContentModeScaleAspectFill;
    
    [_launchMask addSubview:_launchAnimation];
}


- (void)setupTitleView{
    
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"d";
    
    _dayLabel = [UILabel labelWithFrame:CGRectMake(2 * BAPadding, 64 + BAPadding, BAScreenWidth, 40) text:[formatter stringFromDate:nowDate] color:BAWhiteColor font:BABlodFont(44) textAlignment:NSTextAlignmentLeft];
    [_dayLabel sizeToFit];
    
    [self.view addSubview:_dayLabel];
    
    _timeLine = [[UIView alloc] initWithFrame:CGRectMake(_dayLabel.right + BAPadding, _dayLabel.y + 8, 1.5, _dayLabel.height - 16)];
    _timeLine.backgroundColor = [BAWhiteColor colorWithAlphaComponent:0.5];
    
    [self.view addSubview:_timeLine];
    
    formatter.dateFormat = @"EEEE\nMMMM";
    _weekLabel = [UILabel labelWithFrame:CGRectMake(_timeLine.right + BAPadding, _dayLabel.y, BAScreenWidth / 3, _dayLabel.height) text:[formatter stringFromDate:nowDate] color:BAWhiteColor font:BACommonFont(15) textAlignment:NSTextAlignmentLeft];
    _weekLabel.numberOfLines = 2;
    
    [self.view addSubview:_weekLabel];
    
    _titleLabel = [UILabel labelWithFrame:CGRectMake(BAScreenWidth * 2 / 3 - 2 * BAPadding, _dayLabel.y, BAScreenWidth / 3, _dayLabel.height) text:@"ANALYZER" color:BAWhiteColor font:BABlodFont(20) textAlignment:NSTextAlignmentRight];
    
    [self.view addSubview:_titleLabel];
}


- (void)setupReportView{
    _reportView = [[BAReportView alloc] initWithFrame:CGRectMake(0, _dayLabel.bottom + 5 * BAPadding, BAScreenWidth, BAScreenHeight * 4 / 5)];
    
    [self.view addSubview:_reportView];
}


- (void)setupNavigation{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem BarButtonItemWithImg:@"roomList" highlightedImg:nil target:self action:@selector(roomBtnClicked)];
    
}


- (void)addNotificationObserver{
    [BANotificationCenter addObserver:self selector:@selector(roomSelected:) name:BANotificationRoomListCellClicked object:nil];
    [BANotificationCenter addObserver:self selector:@selector(openBtnClicked:) name:BANotificationMainCellOpenBtnClicked object:nil];
    [BANotificationCenter addObserver:self selector:@selector(reportDelBtnClicked:) name:BANotificationMainCellReportDelBtnClicked object:nil];
    [BANotificationCenter addObserver:self selector:@selector(beginAnalyzing:) name:BANotificationBeginAnalyzing object:nil];
    [BANotificationCenter addObserver:self selector:@selector(dataUpdated:) name:BANotificationDataUpdateComplete object:nil];
}


@end
