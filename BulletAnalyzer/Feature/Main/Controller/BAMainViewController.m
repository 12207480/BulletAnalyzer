//
//  BAMainViewController.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/4.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAMainViewController.h"
#import "BABulletViewController.h"
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
@property (nonatomic, strong) UILabel *timeLabel;
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
    
    [self setupLaunchMask];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    _reportView.reportModelArray = [BAAnalyzerCenter defaultCenter].reportModelArray;
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (_launchMask && _launchAnimation) {
        [_launchAnimation playWithCompletion:^(BOOL animationFinished) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
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
- (void)roomBtnClicked{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


- (void)openBtnClicked:(NSNotification *)sender{
    BAReportModel *reportModel = sender.userInfo[BAUserInfoKeyMainCellClicked];

    BABulletViewController *bulletVC = [[BABulletViewController alloc] init];
    bulletVC.reportModel = reportModel;

    BANavigationViewController *navigationVc = [[BANavigationViewController alloc] initWithRootViewController:bulletVC];
    [self presentViewController:navigationVc animated:YES completion:nil];
    
    
    //[[BAAnalyzerCenter defaultCenter] delReport:sender.userInfo[BAUserInfoKeyReportModel]];
    
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


- (void)reportModelArrayUpdated:(NSNotification *)sender{
    NSMutableArray *array = sender.userInfo[BAUserInfoKeyReportModelArray];
    
    _reportView.reportModelArray = array;
}


#pragma mark - private
- (void)setupLaunchMask{
    _launchMask = [[UIView alloc] initWithFrame:self.view.bounds];
    _launchMask.backgroundColor = BAWhiteColor;
    
    [self.view addSubview:_launchMask];
    
    _launchAnimation = [LOTAnimationView animationNamed:@"servishero_loading"];
    _launchAnimation.frame = CGRectMake(0, 0, BAScreenWidth, 300);
    _launchAnimation.center = self.view.center;
    _launchAnimation.contentMode = UIViewContentModeScaleAspectFit;
    //_launchAnimation.loopAnimation = YES;
    
    [_launchMask addSubview:_launchAnimation];
}


- (void)setupTitleView{
    _titleLabel = [UILabel labelWithFrame:CGRectMake(0, 60, BAScreenWidth, BASuperLargeTextFontSize) text:@"ANALYZER" color:[UIColor whiteColor] font:BABlodFont(BASuperLargeTextFontSize) textAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:_titleLabel];
        
    _timeLabel = [UILabel labelWithFrame:CGRectMake(0, _titleLabel.bottom + BAPadding, BAScreenWidth, BALargeTextFontSize) text:nil color:BALightTextColor font:BACommonFont(BACommonTextFontSize) textAlignment:NSTextAlignmentCenter];
    
    NSTextAttachment *calenderImg = [[NSTextAttachment alloc] init];
    calenderImg.image = [UIImage imageNamed:@"Calender"];
    calenderImg.bounds = CGRectMake(0, 0, 15, 15);
    NSAttributedString *calenderAttr = [NSAttributedString attributedStringWithAttachment:calenderImg];
    NSAttributedString *timeStr = [[NSAttributedString alloc] initWithString:[self getNowTimeWithFomatterEng]];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    [string appendAttributedString:calenderAttr];
    [string appendAttributedString:timeStr];
    [string addAttribute:NSBaselineOffsetAttributeName value:@(1.5) range:NSMakeRange(1, string.length - 1)];
    
    _timeLabel.attributedText = string;
    
    [self.view addSubview:_timeLabel];
}


- (void)setupReportView{
    _reportView = [[BAReportView alloc] initWithFrame:CGRectMake(0, _timeLabel.bottom + 4 * BAPadding, BAScreenWidth, BAScreenHeight * 4 / 5)];
    
    [self.view addSubview:_reportView];
}


- (void)setupNavigation{
    //self.navigationItem.leftBarButtonItem = [UIBarButtonItem BarButtonItemWithTitle:@"房间" target:self action:@selector(roomBtnClicked)];
    
    
}


- (void)addNotificationObserver{
    [BANotificationCenter addObserver:self selector:@selector(roomSelected:) name:BANotificationRoomListCellClicked object:nil];
    [BANotificationCenter addObserver:self selector:@selector(openBtnClicked:) name:BANotificationMainCellClicked object:nil];
    [BANotificationCenter addObserver:self selector:@selector(beginAnalyzing:) name:BANotificationBeginAnalyzing object:nil];
    [BANotificationCenter addObserver:self selector:@selector(reportModelArrayUpdated:) name:BANotificationUpdateReporsComplete object:nil];
}


- (NSString *)getNowTimeWithFomatterEng{
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSLocale *EngLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter.locale = EngLocale;
    formatter.dateFormat = @" d MMMM - EEEE";
    
    return [formatter stringFromDate:[NSDate date]];
}

@end
