//
//  BAReportViewController.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/7/20.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAReportViewController.h"
#import "BAGradientView.h"
#import "BAInfoView.h"
#import "BAMenuView.h"
#import "BAIndicator.h"
#import "BACountChart.h"
#import "BACountInfoView.h"
#import "BAWordsChart.h"
#import "BAWordsInfoView.h"
#import "BAFansChart.h"
#import "BAFansInfoView.h"
#import "BAGiftChart.h"
#import "BAGiftInfoView.h"

@interface BAReportViewController () <UIScrollViewDelegate>
//结构
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) BAGradientView *gradientView;
@property (nonatomic, strong) UIView *contentBgView;
@property (nonatomic, strong) BAIndicator *indicator;
@property (nonatomic, assign) NSInteger page;

//第一页(基本信息, 菜单)
@property (nonatomic, strong) BAInfoView *infoView;
@property (nonatomic, strong) BAMenuView *menuView;

//第二页(弹幕数量)
@property (nonatomic, strong) BACountChart *countChart;
@property (nonatomic, strong) BACountInfoView *countInfoView;

//第三页(关键词)
@property (nonatomic, strong) BAWordsChart *wordsChart;
@property (nonatomic, strong) BAWordsInfoView *wordsInfoView;

//第四页(粉丝)
@property (nonatomic, strong) BAFansChart *fansChart;
@property (nonatomic, strong) BAFansInfoView *fansInfoView;

//第五页(礼物)
@property (nonatomic, strong) BAGiftChart *giftChart;
@property (nonatomic, strong) BAGiftInfoView *giftInfoView;

@end

@implementation BAReportViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self prepare];
    
    [self setupGradientView];
    
    [self setupContentBgView];
    
    [self setupScrollView];
    
    [self setupInfoView];
    
    [self setupMenuView];
    
    [self setupIndicator];
    
    [self setupCountReport];
    
    [self setupWordsReport];
    
    [self setupFansReport];
    
    [self setupGiftReport];
}


#pragma mark - userInteraction
- (void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - private
- (void)prepare{
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.contents = (id)[UIImage new].CGImage;
    self.title = @"分析报告";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem BarButtonItemWithImg:@"back_white"  highlightedImg:nil target:self action:@selector(dismiss)];
}



- (void)setupGradientView{
    _gradientView = [[BAGradientView alloc] init];
    _gradientView.userInteractionEnabled = NO;
    
    [self.view addSubview:_gradientView];
}


- (void)setupContentBgView{
    _contentBgView = [[UIView alloc] initWithFrame:CGRectMake(0, BAScreenHeight / 2, BAScreenWidth, BAScreenHeight / 2)];
    _contentBgView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_contentBgView];
}


- (void)setupScrollView{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, BAScreenWidth, BAScreenHeight)];
    _scrollView.contentSize = CGSizeMake(BAScreenWidth * 5, 0);
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    
    [self.view addSubview:_scrollView];
}


- (void)setupInfoView{
    _infoView = [[BAInfoView alloc] initWithFrame:CGRectMake(0, 64 + 4 * BAPadding, BAScreenWidth, BAScreenWidth / 3)];
    _infoView.reportModel = _reportModel;
    
    [_scrollView addSubview:_infoView];
}


- (void)setupMenuView{
    CGFloat height = BAScreenWidth / 375 * 356;
    _menuView = [[BAMenuView alloc] initWithFrame:CGRectMake(0, BAScreenHeight - height - 2 * BAPadding, BAScreenWidth, height)];
    _menuView.reportModel = _reportModel;
    _menuView.menuClicked = ^(menuBtnType type){
        switch (type) {
            case menuBtnTypeCount:
                
                break;
                
            case menuBtnTypeWords:
                
                break;
                
            case menuBtnTypeFans:
                
                break;
                
            case menuBtnTypeGift:
                
                break;
                
            default:
                break;
        }
    };
    
    [_scrollView addSubview:_menuView];
}


- (void)setupIndicator{
    _indicator = [[BAIndicator alloc] initWithFrame:CGRectMake(0, BAScreenHeight / 2, BAScreenWidth, BAScreenHeight * 0.1)];
    _indicator.alpha = 0;
    
    [_scrollView addSubview:_indicator];
}


- (void)setupCountReport{
    _countChart = [[BACountChart alloc] initWithFrame:CGRectMake(BAScreenWidth, 0, BAScreenWidth, BAScreenHeight / 2)];
    _countChart.reportModel = _reportModel;
    
    [_scrollView addSubview:_countChart];
    
    _countInfoView = [[BACountInfoView alloc] initWithFrame:CGRectMake(BAScreenWidth, _indicator.bottom, BAScreenWidth, BAScreenHeight * 0.4)];
    _countInfoView.reportModel = _reportModel;
    
    [_scrollView addSubview:_countInfoView];
}


- (void)setupWordsReport{
    _wordsChart = [[BAWordsChart alloc] initWithFrame:CGRectMake(BAScreenWidth * 2, 0, BAScreenWidth, BAScreenHeight / 2)];
    _wordsChart.reportModel = _reportModel;
    
    [_scrollView addSubview:_wordsChart];
    
    _wordsInfoView = [[BAWordsInfoView alloc] initWithFrame:CGRectMake(BAScreenWidth * 2, _indicator.bottom, BAScreenWidth, BAScreenHeight * 0.4)];
    _wordsInfoView.reportModel = _reportModel;
    
    [_scrollView addSubview:_wordsInfoView];
}


- (void)setupFansReport{
    _fansChart = [[BAFansChart alloc] initWithFrame:CGRectMake(BAScreenWidth * 3, 0, BAScreenWidth, BAScreenHeight / 2)];
    _fansChart.reportModel = _reportModel;
    
    [_scrollView addSubview:_fansChart];
    
    _fansInfoView = [[BAFansInfoView alloc] initWithFrame:CGRectMake(BAScreenWidth * 3, _indicator.bottom, BAScreenWidth, BAScreenHeight * 0.4)];
    _fansInfoView.reportModel = _reportModel;
    
    [_scrollView addSubview:_fansInfoView];
}


- (void)setupGiftReport{
    _giftChart = [[BAGiftChart alloc] initWithFrame:CGRectMake(BAScreenWidth * 4, 0, BAScreenWidth, BAScreenHeight / 2)];
    _giftChart.reportModel = _reportModel;
    
    [_scrollView addSubview:_giftChart];
    
    _giftInfoView = [[BAGiftInfoView alloc] initWithFrame:CGRectMake(BAScreenWidth * 4, _indicator.bottom, BAScreenWidth, BAScreenHeight * 0.4)];
    _giftInfoView.reportModel = _reportModel;
    
    [_scrollView addSubview:_giftInfoView];
}


- (void)setPage:(NSInteger)page{
    if (_page != page) { //如果改变了页数
        
        switch (page) {
            case 1:
                [_countChart hide];
                [_wordsChart hide];
                [_fansChart hide];
                [_giftChart hide];
                break;
                
            case 2:
                [_wordsChart hide];
                [_fansChart hide];
                [_giftChart hide];
                [_countChart animation];
                break;
                
            case 3:
                [_countChart hide];
                [_fansChart hide];
                [_giftChart hide];
                [_wordsChart animation];
                break;
                
            case 4:
                [_countChart hide];
                [_wordsChart hide];
                [_giftChart hide];
                [_fansChart animation];
                break;
                
            case 5:
                [_wordsChart hide];
                [_countChart hide];
                [_fansChart hide];
                [_giftChart animation];
                break;
                
            default:
                break;
        }
        
    }
    
    _page = page;
}


#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x;
    
    if ((CGFloat)offsetX/BAScreenWidth - (NSInteger)(offsetX/BAScreenWidth) == 0) { //翻页为整数才会调用动画
        self.page = offsetX / BAScreenWidth + 1;
    }
    _indicator.x = offsetX; //保持指示器不动
    
    //根据移动距离动画
    _gradientView.offsetX = offsetX;
    _indicator.offsetX = offsetX;
    if (offsetX < BAScreenWidth) {
        CGFloat percent = (BAScreenWidth - offsetX) / BAScreenWidth;
        CGFloat height = BAScreenHeight / 2 + BAScreenHeight * 0.1 * (1 - percent);
        _contentBgView.frame = CGRectMake(0, height, BAScreenWidth, BAScreenHeight - height);
        _indicator.alpha = (1 - percent * 2);
    } else {
        _contentBgView.frame = CGRectMake(0, BAScreenHeight * 0.6, BAScreenWidth, BAScreenHeight * 0.4);
        _indicator.alpha = 1;
    }
    
    
}

@end
