
//
//  BAActiveCell.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/18.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAActiveCell.h"
#import "BAAcitveSlider.h"
#import "BAUserModel.h"

@interface BAActiveCell()
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) BAAcitveSlider *slider;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UIButton *recordBtn;

@end

@implementation BAActiveCell

#pragma mark - lifeCycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = BACellColor1;
        
        self.layer.masksToBounds = NO;
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - public
- (void)setUserModel:(BAUserModel *)userModel{
    _userModel = userModel;
    
    [self setupStatus];
}


#pragma mark - userInteraction
- (void)recordBtnClicked{
    NSLog(@"%s", __func__);
}


#pragma mark - private
- (void)setupSubViews{
    _countLabel = [UILabel labelWithFrame:CGRectMake(0, 0, BABulletActiveCellHeight / 2, BABulletActiveCellHeight) text:@"" color:BAWhiteColor font:BABlodFont(BACommonTextFontSize) textAlignment:NSTextAlignmentCenter];
    
    [self.contentView addSubview:_countLabel];
    
    _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(_countLabel.right, BAPadding, BABulletActiveCellHeight - 2 * BAPadding, BABulletActiveCellHeight - 2 * BAPadding)];
    _iconView.layer.cornerRadius = _iconView.width / 2;
    _iconView.clipsToBounds = YES;
    
    [self.contentView addSubview:_iconView];
    
    _slider = [[BAAcitveSlider alloc] initWithFrame:CGRectMake(_iconView.right + BAPadding, BABulletActiveCellHeight / 2 - 3, BAScreenWidth - 2 * BAPadding - BABulletActiveCellHeight * 2, 6)];
    
    [self.contentView addSubview:_slider];
    
    _nameLabel = [UILabel labelWithFrame:CGRectMake(_slider.x + BAPadding / 2, _slider.bottom + BAPadding / 2, _slider.width, BASmallTextFontSize) text:@"" color:BAWhiteColor font:BAThinFont(BASmallTextFontSize) textAlignment:NSTextAlignmentLeft];
    
    [self.contentView addSubview:_nameLabel];
    
    _levelLabel = [UILabel labelWithFrame:CGRectMake(BAScreenWidth - 2 * BAPadding - BABulletActiveCellHeight / 2, 0, BABulletActiveCellHeight / 2, BABulletActiveCellHeight) text:@"" color:BALightTextColor font:BAThinFont(BACommonTextFontSize) textAlignment:NSTextAlignmentLeft];
    _levelLabel.numberOfLines = 0;
    
    [self.contentView addSubview:_levelLabel];
    
    _recordBtn = [UIButton buttonWithFrame:CGRectMake(0, BABulletActiveCellHeight, BAScreenWidth - 2 * BAPadding, 30) title:@"查看TA的发言记录" color:BAThemeColor font:BACommonFont(BACommonTextFontSize) backgroundImage:[UIImage imageWithColor:BACellColor1] target:self action:@selector(recordBtnClicked)];
    _recordBtn.hidden = YES;
    
    [self.contentView addSubview:_recordBtn];
}


- (void)setupStatus{    

    _countLabel.text = _userModel.count;
    [_iconView sd_setImageWithURL:[NSURL URLWithString:_userModel.iconBig] placeholderImage:BAPlaceHolderImg];
    _slider.value = _userModel.count.floatValue / _userModel.maxActiveCount;
    _nameLabel.text = _userModel.nn;
    _levelLabel.text = [NSString stringWithFormat:@"%@\nLVL", _userModel.level];
    _recordBtn.hidden = !_userModel.isActiveCellSelect;
    self.backgroundColor = _userModel.isActiveCellSelect ? BACellColor1 : [UIColor clearColor];
}

@end
