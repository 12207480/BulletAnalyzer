//
//  BABulletListCell.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/13.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BABulletListCell.h"
#import "BABulletModel.h"

@interface BABulletListCell()
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIView *labelBgView;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation BABulletListCell

#pragma mark - lifeCycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - public
- (void)setBulletModel:(BABulletModel *)bulletModel{
    _bulletModel = bulletModel;
    
    [_icon sd_setImageWithURL:[NSURL URLWithString:bulletModel.iconMiddle] placeholderImage:BAPlaceHolderImg];
    _contentLabel.text = [NSString stringWithFormat:@"%@:\n%@", bulletModel.nn, bulletModel.txt];
}


#pragma mark - private
- (void)setupSubViews{
    
    _icon = [[UIImageView alloc] initWithFrame:CGRectMake(BAPadding, BAPadding / 2, BABulletListCellHeight - BAPadding, BABulletListCellHeight - BAPadding)];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.cornerRadius = (BABulletListCellHeight - BAPadding) / 2;
    _icon.layer.borderColor = [UIColor whiteColor].CGColor;
    _icon.layer.borderWidth = 2;
    _icon.layer.masksToBounds =  YES;

    [self.contentView addSubview:_icon];
    
    _labelBgView = [[UIView alloc] initWithFrame:CGRectMake(_icon.centerX, BAPadding / 2, BAScreenWidth - _icon.centerX - BAPadding, _icon.height)];
    _labelBgView.backgroundColor = [BABlackColor colorWithAlphaComponent:0.7];
    _labelBgView.layer.cornerRadius = BARadius;
    _labelBgView.layer.masksToBounds = YES;
    
    [self.contentView insertSubview:_labelBgView belowSubview:_icon];
    
    _contentLabel = [UILabel lableWithFrame:CGRectMake(_icon.right + BAPadding / 2, BAPadding / 2, _labelBgView.width - _icon.right - BAPadding, _icon.height) text:nil color:BAWhiteColor font:BACommonFont(BASmallTextFontSize) textAlignment:NSTextAlignmentLeft];
    _contentLabel.numberOfLines = 0;
    
    [self.contentView insertSubview:_contentLabel aboveSubview:_labelBgView];
}



@end
