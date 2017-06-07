//
//  BAReportCell.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/7.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAReportCell.h"

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


#pragma mark - private
- (void)setupHeaderView{
    _headerView = [UIView new];
    
    [self.contentView addSubview:_headerView];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = BABlodFont(BALargeTextFontSize);
    _nameLabel.textColor = BABlackColor;
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    _nameLabel.text = @"陈一发儿";
    
    [_headerView addSubview:_nameLabel];
    
    _titleLabel = [UILabel new];
    _titleLabel.font = BACommonFont(BALargeTextFontSize);
    _titleLabel.textColor = BABlackColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"久违的心灵鸡汤";
    
    [_headerView addSubview:_titleLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.font = BAThinFont(BASmallTextFontSize);
    _timeLabel.textColor = BALightTextColor;
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = @"6.6 17:00 - 19:00 2小时";
    
    [_headerView addSubview:_timeLabel];
    
    [_headerView.subviews mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
    }];
    [_headerView.subviews mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:0 leadSpacing:0 tailSpacing:0];
    
    [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(_headerView.superview.height * 2 / 7);
    }];
}


- (void)setupRoomImg{
    _roomImgView = [[UIImageView alloc] init];
    _roomImgView.contentMode = UIViewContentModeScaleAspectFill;
    _roomImgView.image = [UIImage imageNamed:@"陈一发儿"];
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
    
    [self.contentView addSubview:_openBtn];
    
    [_openBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(_roomImgView.superview.height * 1 / 7);
    }];
}




@end
