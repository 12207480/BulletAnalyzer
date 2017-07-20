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

@interface BAReportViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) BAGradientView *gradientView;
@property (nonatomic, strong) UIView *contentBgView;

@property (nonatomic, strong) BAInfoView *infoView;

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
    _scrollView.bounces = NO;
    _scrollView.delegate = self;
    
    [self.view addSubview:_scrollView];
}


- (void)setupInfoView{
    _infoView = [[BAInfoView alloc] initWithFrame:CGRectMake(0, 64 + BAPadding, BAScreenWidth, BAScreenHeight / 4)];
    _infoView.reportModel = _reportModel;
    
    [_scrollView addSubview:_infoView];
}


#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x;
    
    _gradientView.offsetX = offsetX;
    if (offsetX < BAScreenWidth) {
        CGFloat percent = (BAScreenWidth - offsetX) / BAScreenWidth;
        CGFloat height = BAScreenHeight / 2 + BAScreenHeight * 0.1 * (1 - percent);
        _contentBgView.frame = CGRectMake(0, height, BAScreenWidth, BAScreenHeight - height);
    } else {
        _contentBgView.frame = CGRectMake(0, BAScreenHeight * 0.6, BAScreenWidth, BAScreenHeight * 0.4);
    }
}

@end
