//
//  BACountInfoView.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/7/21.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BACountInfoView.h"
#import "BAReportModel.h"

@interface BACountInfoView()
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *tip1Label;
@property (nonatomic, strong) UIImageView *durationImgView;
@property (nonatomic, strong) UIView *line1;
@property (nonatomic, strong) UILabel *activeLabel;
@property (nonatomic, strong) UILabel *tip2Label;
@property (nonatomic, strong) UIImageView *activeImgView;
@property (nonatomic, strong) UIView *line2;
@property (nonatomic, strong) UILabel *bulletModeLabel;
@property (nonatomic, strong) UILabel *tip3Label;
@property (nonatomic, strong) UIImageView *bulletModeImgView;

@end

@implementation BACountInfoView

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - private
- (void)setupSubViews{
    
}

@end
