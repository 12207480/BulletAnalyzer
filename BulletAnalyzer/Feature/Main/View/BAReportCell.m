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
@property (nonatomic, strong) UIView *reportView;
@property (nonatomic, strong) UIButton *delBtn;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *bulletLabel;
@property (nonatomic, strong) UILabel *giftLabel;
@property (nonatomic, strong) UIButton *openBtn;
//@property (nonatomic, strong) UIView *newReportView;

@end

@implementation BAReportCell

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
    
        [self setupReportView];
        
        //[self setupRoomImg];
        
        //[self setupfooterView];
        
        //[self setupOpenBtn];
    }
    return self;
}


#pragma mark - userInteraction
- (void)openBtnClicked{
    [BANotificationCenter postNotificationName:BANotificationMainCellOpenBtnClicked object:nil userInfo:@{BAUserInfoKeyMainCellOpenBtnClicked : _reportModel}];
}


- (void)delBtnClicked{
    [BANotificationCenter postNotificationName:BANotificationMainCellReportDelBtnClicked object:nil userInfo:@{BAUserInfoKeyMainCellReportDelBtnClicked : _reportModel}];
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
        
        self.layer.contents = (id)[UIImage imageNamed:@"newReport"].CGImage;
        _reportView.hidden = YES;
        
        
    } else {
        
        self.layer.contents = (id)[UIImage imageNamed:@"report"].CGImage;
        _reportView.hidden = NO;
        
        _nameLabel.text = _reportModel.name;
        [_imgView sd_setImageWithURL:[NSURL URLWithString:_reportModel.avatar] placeholderImage:BAPlaceHolderImg];
        _titleLabel.text = _reportModel.roomName;
        _timeLabel.text = _reportModel.timeDescription;
        [self setInfoWithBulletCount:[NSString stringWithFormat:@" %zd", _reportModel.totalBulletCount] giftCount:[NSString stringWithFormat:@" %zd", _reportModel.giftsArray.count]];
    }
}


- (void)setInfoWithBulletCount:(NSString *)bulletCount giftCount:(NSString *)giftCount{
    
    NSTextAttachment *bulletImg = [[NSTextAttachment alloc] init];
    bulletImg.image = [UIImage imageNamed:@"bullet"];
    bulletImg.bounds = CGRectMake(0, 0, 20, 20);
    NSAttributedString *bulletAttr = [NSAttributedString attributedStringWithAttachment:bulletImg];
    NSAttributedString *bulletStr = [[NSAttributedString alloc] initWithString:bulletCount];
    
    NSMutableAttributedString *bulletString = [[NSMutableAttributedString alloc] init];
    [bulletString appendAttributedString:bulletAttr];
    [bulletString appendAttributedString:bulletStr];
    [bulletString addAttribute:NSBaselineOffsetAttributeName value:@(4) range:NSMakeRange(1, bulletString.length - 1)];
    
    _bulletLabel.attributedText = bulletString;
    
    NSTextAttachment *giftImg = [[NSTextAttachment alloc] init];
    giftImg.image = [UIImage imageNamed:@"gift"];
    giftImg.bounds = CGRectMake(0, 0, 20, 20);
    NSAttributedString *giftAttr = [NSAttributedString attributedStringWithAttachment:giftImg];
    NSAttributedString *giftStr = [[NSAttributedString alloc] initWithString:giftCount];
    
    NSMutableAttributedString *giftString = [[NSMutableAttributedString alloc] init];
    [giftString appendAttributedString:giftAttr];
    [giftString appendAttributedString:giftStr];
    [giftString addAttribute:NSBaselineOffsetAttributeName value:@(4) range:NSMakeRange(1, giftString.length - 1)];
    
    _giftLabel.attributedText = giftString;
}


- (void)setupReportView{
    _reportView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BAReportCellWidth, BAReportCellHeight)];
    
    [self.contentView addSubview:_reportView];
    
    _delBtn = [UIButton buttonWithFrame:CGRectMake(BAReportCellWidth - BAPadding - 21, BAPadding, 21, 21) title:nil color:nil font:nil backgroundImage:[UIImage imageNamed:@"reportDel"] target:self action:@selector(delBtnClicked)];
    
    [_reportView addSubview:_delBtn];
    
    _nameLabel = [UILabel labelWithFrame:CGRectMake(0, _delBtn.bottom + BAPadding, BAReportCellWidth, 30) text:nil color:BAWhiteColor font:BABlodFont(BALargeTextFontSize) textAlignment:NSTextAlignmentCenter];
    
    [_reportView addSubview:_nameLabel];
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(BAReportCellWidth / 2 - 60, _nameLabel.bottom + 2 * BAPadding, 120, 120)];
    _imgView.contentMode = UIViewContentModeScaleAspectFill;
    _imgView.layer.cornerRadius = 60;
    _imgView.layer.masksToBounds = YES;
    
    [_reportView addSubview:_imgView];
    
    _titleLabel = [UILabel labelWithFrame:CGRectMake(BAPadding, _imgView.bottom + 2 * BAPadding, BAReportCellWidth - 2 * BAPadding, 28) text:nil color:BARoomNameColor font:BACommonFont(BALargeTextFontSize) textAlignment:NSTextAlignmentCenter];

    [_reportView addSubview:_titleLabel];
    
    _timeLabel = [UILabel labelWithFrame:CGRectMake(0, _titleLabel.bottom, BAReportCellWidth, 28) text:nil color:BARoomInfoColor font:BACommonFont(BACommonTextFontSize) textAlignment:NSTextAlignmentCenter];
    
    [_reportView addSubview:_timeLabel];
    
    _bulletLabel = [UILabel labelWithFrame:CGRectMake(0, _timeLabel.bottom, BAReportCellWidth / 2 - BAPadding / 2, 28) text:nil color:BARoomInfoColor font:BACommonFont(BACommonTextFontSize) textAlignment:NSTextAlignmentRight];
    
    [_reportView addSubview:_bulletLabel];
    
    _giftLabel = [UILabel labelWithFrame:CGRectMake(BAReportCellWidth / 2 + BAPadding / 2, _timeLabel.bottom, BAReportCellWidth / 2, 28) text:nil color:BARoomInfoColor font:BACommonFont(BACommonTextFontSize) textAlignment:NSTextAlignmentLeft];

    [_reportView addSubview:_giftLabel];
    
    _openBtn = [UIButton buttonWithFrame:CGRectMake(2 * BAPadding, _giftLabel.bottom, BAReportCellWidth - 4 * BAPadding, 60) title:@"查看" color:BAWhiteColor font:BACommonFont(BALargeTextFontSize) backgroundImage:[UIImage imageNamed:@"openBtn"] target:self action:@selector(openBtnClicked)];
    
    [_reportView addSubview:_openBtn];
}


- (void)setupfooterView{

}


@end
