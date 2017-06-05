//
//  BARoomListCell.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/5.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BARoomListCell.h"
#import "BARoomModel.h"

@interface BARoomListCell()
@property (nonatomic, strong) UIImageView *screenShotImgView;
@property (nonatomic, strong) UILabel *anchorNameLabel;
@property (nonatomic, strong) UILabel *roomNameLabel;
@property (nonatomic, strong) UILabel *roomTypeLabel;
@property (nonatomic, strong) UIButton *connectBtn;
@property (nonatomic, strong) UIVisualEffectView *beffectView;
@property (nonatomic, assign, getter=isEffectHidden) BOOL effectHidden;

@end

@implementation BARoomListCell

#pragma mark - lifeCycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = BADarkBackgroundColor;
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - public
- (void)setRoomModel:(BARoomModel *)roomModel{
    _roomModel = roomModel;
    
    [_screenShotImgView sd_setImageWithURL:[NSURL URLWithString:roomModel.room_src] placeholderImage:BAPlaceHolderImg];
    _anchorNameLabel.text = roomModel.nickname;
    _roomNameLabel.text = roomModel.room_name;
    _roomTypeLabel.text = roomModel.game_name;
}


#pragma mark - userInteraction
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.effectHidden = YES;
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.effectHidden = NO;
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.effectHidden = NO;
}


- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.effectHidden = NO;
}


- (void)selectedBtnClicked{
    [BANotificationCenter postNotificationName:BANotificationRoomListCellClicked object:nil userInfo:@{@"roomModel" : _roomModel}];
}


#pragma mark - private
- (void)setupSubViews{
    _screenShotImgView = [[UIImageView alloc] initWithFrame:CGRectMake(BAPadding, 0, BARoomListScreenShotImgWidth, BARoomListScreenShotImgHeight)];
    _screenShotImgView.layer.cornerRadius = BARadius;
    _screenShotImgView.layer.masksToBounds = YES;

    [self.contentView addSubview:_screenShotImgView];
    
    UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _beffectView = [[UIVisualEffectView alloc] initWithEffect:beffect];
    _beffectView.frame = _screenShotImgView.frame;
    _beffectView.layer.cornerRadius = BARadius;
    _beffectView.layer.masksToBounds = YES;
    
    [self.contentView addSubview:_beffectView];
    
    _anchorNameLabel = [UILabel lableWithFrame:CGRectMake(BAPadding, _screenShotImgView.bottom - BACommonTextFontSize - BAPadding, BARoomListScreenShotImgWidth - 2 * BAPadding, BALargeTextFontSize) text:nil color:BAWhiteColor font:BACommonFont(BACommonTextFontSize) textAlignment:NSTextAlignmentRight];
   
    [_beffectView addSubview:_anchorNameLabel];
    
    _roomNameLabel = [UILabel lableWithFrame:CGRectMake(BAPadding, _screenShotImgView.centerY - BALargeTextFontSize / 2, BARoomListScreenShotImgWidth - 2 * BAPadding, BALargeTextFontSize) text:nil color:BAWhiteColor font:BAThinFont(BALargeTextFontSize) textAlignment:NSTextAlignmentCenter];
    
    [_beffectView addSubview:_roomNameLabel];
    
    _roomTypeLabel = [UILabel lableWithFrame:CGRectMake(BAPadding, BAPadding, BARoomListScreenShotImgWidth - 2 * BAPadding, BASmallTextFontSize) text:nil color:BALightTextColor font:BAThinFont(BASmallTextFontSize) textAlignment:NSTextAlignmentLeft];
    
    [_beffectView addSubview:_roomTypeLabel];
    
    _connectBtn = [UIButton buttonWithFrame:CGRectMake(BARoomListViewWidth - BAPadding - 10, 0, 30, BARoomListScreenShotImgHeight) title:@"选择" color:BABlackColor font:BAThinFont(BASmallTextFontSize) backgroundImage:[UIImage imageWithColor:BAThemeColor] target:self action:@selector(selectedBtnClicked)];
    _connectBtn.layer.cornerRadius = BARadius;
    _connectBtn.layer.masksToBounds = YES;
    
    [self.contentView addSubview:_connectBtn];
}


- (void)setEffectHidden:(BOOL)effectHidden{
    _effectHidden = effectHidden;
    
    CGFloat alpha = effectHidden ? 0 : 1;
    [UIView animateWithDuration:1.f delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _beffectView.alpha = alpha;
    } completion:nil];
}

@end
