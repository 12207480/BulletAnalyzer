//
//  BAMainViewController.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/4.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAMainViewController.h"
#import "BAReportView.h"
#import "UIViewController+MMDrawerController.h"
#import "BASocketTool.h"
#import "BARoomModel.h"
#import "BABulletModel.h"
#import "BAReportModel.h"

@interface BAMainViewController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) BAReportView *reportView;

@end

@implementation BAMainViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BADarkBackgroundColor;
    
    [self setupTitleView];
    
    [self setupReportView];
    
    [self setupNavigation];
    
    [self addNotificationObserver];
}


- (void)dealloc{
    [BANotificationCenter removeObserver:self];
}


#pragma mark - userInteraction
- (void)roomBtnClicked{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


#pragma mark - private
- (void)setupTitleView{
    _titleLabel = [UILabel lableWithFrame:CGRectMake(0, 60, BAScreenWidth, BASuperLargeTextFontSize) text:@"ANALYZER" color:[UIColor whiteColor] font:BABlodFont(BASuperLargeTextFontSize) textAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:_titleLabel];
        
    _timeLabel = [UILabel lableWithFrame:CGRectMake(0, _titleLabel.bottom + BAPadding, BAScreenWidth, BALargeTextFontSize) text:nil color:BALightTextColor font:BACommonFont(BACommonTextFontSize) textAlignment:NSTextAlignmentCenter];
    
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
    _reportView.reportModelArray = @[[BAReportModel new], [BAReportModel new], [BAReportModel new], [BAReportModel new], [BAReportModel new]].mutableCopy;
    
    [self.view addSubview:_reportView];
}


- (void)setupNavigation{
    //self.navigationItem.leftBarButtonItem = [UIBarButtonItem BarButtonItemWithTitle:@"房间" target:self action:@selector(roomBtnClicked)];
}


- (void)addNotificationObserver{
    [BANotificationCenter addObserver:self selector:@selector(roomSelected:) name:BANotificationRoomListCellClicked object:nil];
}


- (NSString *)getNowTimeWithFomatterEng{
    NSDateFormatter *formatter = [NSDateFormatter new];
    NSLocale *EngLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter.locale = EngLocale;
    formatter.dateFormat = @" d MMMM - EEEE";
    
    return [formatter stringFromDate:[NSDate date]];
}


#pragma mark - userInteraction
- (void)roomSelected:(NSNotification *)sender{
    BARoomModel *roomModel = sender.userInfo[@"roomModel"];
    
    [[BASocketTool defaultSocket] connectSocketWithRoomId:roomModel.room_id];
    [BASocketTool defaultSocket].bullet = ^(NSArray *array) {
        [array enumerateObjectsUsingBlock:^(BABulletModel *bulletModel, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%@:%@", bulletModel.nn, bulletModel.txt);
        }];
    };
}



@end
