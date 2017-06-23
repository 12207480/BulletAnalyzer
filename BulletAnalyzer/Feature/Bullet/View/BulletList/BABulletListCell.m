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
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) UIImageView *notification;
@property (nonatomic, strong) UILabel *notificationCount;
@property (nonatomic, strong) UIView *labelBgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation BABulletListCell

#pragma mark - lifeCycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - public
- (void)setBulletModel:(BABulletModel *)bulletModel{
    _bulletModel = bulletModel;
    
    [_icon sd_setImageWithURL:[NSURL URLWithString:bulletModel.iconSmall] placeholderImage:BAPlaceHolderImg];
    _nameLabel.text = bulletModel.nn;
    _contentLabel.text = bulletModel.txt;
}


#pragma mark - private
- (void)setupSubViews{
    
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(2 * BAPadding, 0, BAScreenWidth - 4 * BAPadding, BABulletListCellHeight)];
    _bgView.backgroundColor = BACellColor1;
    _bgView.layer.cornerRadius = BARadius;
    _bgView.layer.shadowOpacity = 0.5;
    _bgView.layer.shadowColor = BABlackColor.CGColor;
    _bgView.layer.shadowOffset = CGSizeMake(0, 0.5);
    _bgView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_bgView.bounds].CGPath;
    
    [self.contentView addSubview:_bgView];
    
    CGFloat iconHeight = BABulletListCellHeight - 4 * BAPadding;
    _icon = [[UIImageView alloc] initWithFrame:CGRectMake(4 * BAPadding, 2 * BAPadding, iconHeight, iconHeight)];
    _icon.contentMode = UIViewContentModeScaleAspectFill;
    _icon.layer.cornerRadius = iconHeight / 2;
    _icon.layer.masksToBounds = YES;
    
    [self.contentView addSubview:_icon];
    
    _notification = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notification1"]];
    _notification.centerX = _icon.x + iconHeight / 6;
    _notification.centerY = _icon.y + iconHeight / 6;
    
    [self.contentView addSubview:_notification];
    
    _notificationCount = [UILabel labelWithFrame:_notification.bounds text:@"" color:BAWhiteColor font:[UIFont boldSystemFontOfSize:9] textAlignment:NSTextAlignmentCenter];
    
    [_notification addSubview:_notificationCount];
    
    CGFloat labelWidth = _bgView.width - _icon.right - 3 * BAPadding;
    _nameLabel = [UILabel labelWithFrame:CGRectMake(_icon.right + 2 * BAPadding, BAPadding, labelWidth, 15) text:@"" color:BALightTextColor font:BACommonFont(BALargeTextFontSize) textAlignment:NSTextAlignmentLeft];
    
    [self.contentView addSubview:_nameLabel];
    
    _contentLabel = [UILabel labelWithFrame:CGRectMake(_nameLabel.x, _nameLabel.bottom, labelWidth, BABulletListCellHeight -  2 * BAPadding - _nameLabel.height) text:nil color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) textAlignment:NSTextAlignmentLeft];
    _contentLabel.numberOfLines = 0;
    
    [self.contentView addSubview:_contentLabel];
}



@end
