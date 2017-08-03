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
@property (nonatomic, strong) UIImageView *levelBgView;
@property (nonatomic, strong) UILabel *levelLabel;
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


#pragma mark - userInteraction
- (void)btnClicked:(UIButton *)sender{
    _btnClicked();
}


#pragma mark - public
- (void)setBulletModel:(BABulletModel *)bulletModel{
    _bulletModel = bulletModel;
    
    _contentLabel.attributedText = bulletModel.bulletContent;
    _contentLabel.height = bulletModel.bulletContentHeight;
}


#pragma mark - private
- (void)setupSubViews{
    
    _levelBgView = [UIImageView imageViewWithFrame:CGRectMake(BAPadding * 1.5, 13.5, 30, 13) image:nil];
    
    [self.contentView addSubview:_levelBgView];
    
    _levelLabel = [UILabel labelWithFrame:CGRectMake(BAPadding * 1.5, 13.5, 28, 13) text:nil color:BAWhiteColor font:BABlodFont(BASmallTextFontSize) textAlignment:NSTextAlignmentRight];
    
    [self.contentView addSubview:_levelLabel];
    
    _contentLabel = [UILabel labelWithFrame:CGRectMake(_levelBgView.right + BAPadding / 2, 11, BAScreenWidth - 70, 40) text:nil color:nil font:nil textAlignment:NSTextAlignmentLeft];
    _contentLabel.numberOfLines = 2;
    
    [self.contentView addSubview:_contentLabel];
}


@end
