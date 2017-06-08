//
//  BAReportCell.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/7.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAReportCell.h"
#import "BAReportModel.h"

@interface BAReportCell()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *roomImgView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *openBtn;

@end

@implementation BAReportCell

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
    
        [self setupHeaderView];
        
        [self setupRoomImg];
        
        [self setupfooterView];
        
        [self setupOpenBtn];
    }
    return self;
}


#pragma mark - userInteraction
- (void)openBtnClicked{

    [BANotificationCenter postNotificationName:BANotificationMainCellClicked object:nil userInfo:@{BAUserInfoKeyMainCellClicked : _reportModel}];
}


#pragma mark - public
- (void)setReportModel:(BAReportModel *)reportModel{
    _reportModel = reportModel;
    
    if (reportModel) {
        [self setupStatus];
    }
}


#pragma mark - private
- (void)setupStatus{
    
    if (_reportModel.isAddNewReport) {
        
        _nameLabel.text = @"暂无分析";
        _titleLabel.text = @"点击按钮, 立即分析弹幕";
        _timeLabel.text = @"时间越长, 采样越多";
        [_openBtn setTitle:@"分析" forState:UIControlStateNormal];
        _roomImgView.image = [UIImage imageNamed:@"陈一发儿"];
    } else {
        _nameLabel.text = @"陈一发儿";
        _titleLabel.text = @"久违的心灵鸡汤";
        _timeLabel.text = @"6.6 17:00 - 19:00 2小时";
        [_openBtn setTitle:@"查看" forState:UIControlStateNormal];
        _roomImgView.image = [UIImage imageNamed:@"陈一发儿"];
    }
}


- (void)setupHeaderView{
    _headerView = [UIView new];
    
    [self.contentView addSubview:_headerView];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = BABlodFont(BALargeTextFontSize);
    _nameLabel.textColor = BABlackColor;
    _nameLabel.textAlignment = NSTextAlignmentCenter;

    
    [_headerView addSubview:_nameLabel];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = BACommonFont(BALargeTextFontSize);
    _titleLabel.textColor = BABlackColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;

    
    [_headerView addSubview:_titleLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = BAThinFont(BASmallTextFontSize);
    _timeLabel.textColor = BALightTextColor;
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    
    [_headerView addSubview:_timeLabel];
    
    [_headerView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
    }];
    [_headerView.subviews mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:0 leadSpacing:BAPadding tailSpacing:BAPadding];
    
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(_headerView.superview.height * 2 / 7);
    }];
}


- (void)setupRoomImg{
    _roomImgView = [[UIImageView alloc] init];
    _roomImgView.contentMode = UIViewContentModeScaleAspectFill;
    _roomImgView.clipsToBounds = YES;
    
    [self.contentView addSubview:_roomImgView];
    
    [_roomImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(_headerView.mas_bottom);
        make.height.mas_equalTo(_roomImgView.superview.height * 2.5 / 7);
    }];
}


- (void)setupfooterView{

}


- (void)setupOpenBtn{
    _openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _openBtn.titleLabel.font = BACommonFont(BALargeTextFontSize);
    [_openBtn setTitle:@"查看" forState:UIControlStateNormal];
    [_openBtn setTitleColor:BAWhiteColor forState:UIControlStateNormal];
    [_openBtn setBackgroundColor:BAThemeColor];
    [_openBtn addTarget:self action:@selector(openBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:_openBtn];
    
    [_openBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(1);
        make.height.mas_equalTo(_roomImgView.superview.height * 1 / 7);
    }];
}




@end
