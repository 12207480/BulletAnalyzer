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
#import <UShareUI/UShareUI.h>

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

//二维码
@property (nonatomic, strong) UIImageView *CIFilterView;
@property (nonatomic, assign, getter=isScreenshot) BOOL screenshot;
@property (nonatomic, strong) UIImage *shareImg;

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
    
    [self setupCIFilterView];
}


#pragma mark - userInteraction
- (void)dismiss{
    if (self.scrollView.contentOffset.x) {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)share{
    
    if (!_shareImg) {
        
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        self.screenshot = YES;
        
        [_countChart animation];
        [_wordsChart animation];
        [_fansChart animation];
        [_giftChart animation];
        
        __block NSMutableArray *images = [NSMutableArray array];
        UIImage *menuPage = [BATool captureScreen:BAKeyWindow];
        [images addObject:menuPage];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            for (NSInteger i = 2; i < 6; i++) {
                [_scrollView setContentOffset:CGPointMake(BAScreenWidth * (i - 1) - 1, 0) animated:NO];
                [_scrollView setContentOffset:CGPointMake(BAScreenWidth * (i - 1), 0) animated:YES];
                switch (i) {
                    case 2:
                        self.title = @"弹幕数量波动";
                        break;
                        
                    case 3:
                        self.title = @"关键词分析";
                        break;
                        
                    case 4:
                        self.title = @"粉丝质量解析";
                        break;
                        
                    case 5:
                        self.title = @"礼物价值分布";
                        break;
                        
                    default:
                        break;
                }
                
                UIImage *currentPage = [BATool captureScreen:BAKeyWindow];
                [images addObject:currentPage];
            }
            _shareImg = [BATool combineImages:images];
            
            self.navigationItem.leftBarButtonItem = [UIBarButtonItem BarButtonItemWithImg:@"back_white"  highlightedImg:nil target:self action:@selector(dismiss)];
            self.navigationItem.rightBarButtonItem = [UIBarButtonItem BarButtonItemWithImg:@"back_white"  highlightedImg:nil target:self action:@selector(share)];
            self.screenshot = NO;
            self.title = @"分析报告";
            [_scrollView setContentOffset:CGPointMake(1, 0) animated:NO];
            [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
            
            [self shareBtnClicked];
        });
    } else {
        
        [self shareBtnClicked];
    }
}


#pragma mark - private
- (void)prepare{
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.layer.contents = (id)[UIImage new].CGImage;
    self.title = @"分析报告";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem BarButtonItemWithImg:@"back_white"  highlightedImg:nil target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem BarButtonItemWithImg:@"back_white"  highlightedImg:nil target:self action:@selector(share)];
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
    WeakObj(self);
    _menuView.menuClicked = ^(menuBtnType type){
        switch (type) {
            case menuBtnTypeCount:
                [selfWeak.scrollView setContentOffset:CGPointMake(BAScreenWidth, 0) animated:YES];
                break;
                
            case menuBtnTypeWords:
                [selfWeak.scrollView setContentOffset:CGPointMake(BAScreenWidth * 2, 0) animated:YES];
                break;
                
            case menuBtnTypeFans:
                [selfWeak.scrollView setContentOffset:CGPointMake(BAScreenWidth * 3, 0) animated:YES];
                break;
                
            case menuBtnTypeGift:
                [selfWeak.scrollView setContentOffset:CGPointMake(BAScreenWidth * 4, 0) animated:YES];
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
    WeakObj(self);
    _giftChart.giftPieClicked = ^(BAGiftType giftType) {
        selfWeak.giftInfoView.selectedGiftType = giftType;
    };
    
    [_scrollView addSubview:_giftChart];
    
    _giftInfoView = [[BAGiftInfoView alloc] initWithFrame:CGRectMake(BAScreenWidth * 4, _indicator.bottom, BAScreenWidth, BAScreenHeight * 0.4)];
    _giftInfoView.reportModel = _reportModel;
    
    [_scrollView addSubview:_giftInfoView];
}


- (void)setupCIFilterView{
    // 1. 创建一个二维码滤镜实例(CIFilter)
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 滤镜恢复默认设置
    [filter setDefaults];
    
    // 2. 给滤镜添加数据
    NSString *string = @"https://itunes.apple.com/app/id1194998642";
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    // 使用KVC的方式给filter赋值
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    // 3. 生成二维码
    CIImage *image = [filter outputImage];
    UIImage *result = [BATool createNonInterpolatedUIImageFormCIImage:image withSize:BAScreenWidth / 3];
    result = [BATool imageBlackToTransparent:result withRed:249 andGreen:118 andBlue:143];
    
    // 4. 显示二维码
    _CIFilterView = [[UIImageView alloc] initWithImage:result];
    _CIFilterView.center = self.view.center;
    _CIFilterView.hidden = YES;
    [self.view addSubview:_CIFilterView];
}


- (void)setPage:(NSInteger)page{
    if (self.isScreenshot) return;
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


#pragma mark - share
- (void)shareBtnClicked{
    
    NSData *imageData = UIImageJPEGRepresentation(_shareImg,1);
    
    NSLog(@"%f", (CGFloat)[imageData length]/1024);
    
//    NSArray *activityItems = @[_shareImg];
//    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
//    [self presentViewController:activityVC animated:YES completion:nil];
    
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone),@(UMSocialPlatformType_Sina)]];
    //显示分享面板
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        [self shareWebPageToPlatformType:platformType];
    }];
}


- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType{
    
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图
    //shareObject.thumbImage = [UIImage imageNamed:@"AppIcon"];
    [shareObject setShareImage:_shareImg];
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSLog(@"************Share fail with error %@*********",error);
        }else{
            NSLog(@"response data is %@",data);
        }
    }];
}

@end
