//
//  BAFansReport.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/16.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAFansReport.h"
#import "BAReportModel.h"
#import "NSDate+Category.h"
#import "BAFansCurveView.h"

@interface BAFansReport()
@property (nonatomic, strong) BAFansCurveView *onlineCurveView;
@property (nonatomic, strong) BAFansCurveView *fansCountCurveView;
@property (nonatomic, strong) BAFansCurveView *levelCountCurveView;

@end

@implementation BAFansReport

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = BADark3BackgroundColor;
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - public
- (void)setReportModel:(BAReportModel *)reportModel{
    _reportModel = reportModel;
    
    if (_reportModel.countTimePointArray.count < 6) return;
    
    [self setupStatus];
    
    [self animation];
}


- (void)animation{
    [_onlineCurveView performSelector:@selector(animation) withObject:nil afterDelay:0];
    [_fansCountCurveView performSelector:@selector(animation) withObject:nil afterDelay:0];
    [_levelCountCurveView performSelector:@selector(animation) withObject:nil afterDelay:0];
}


- (void)hide{
    [_onlineCurveView hide];
    [_fansCountCurveView hide];
    [_levelCountCurveView hide];
}


#pragma mark - private
- (void)setupSubViews{
    _onlineCurveView = [[BAFansCurveView alloc] initWithFrame:CGRectMake(0, 0, BAScreenWidth, 130)];
    _fansCountCurveView = [[BAFansCurveView alloc] initWithFrame:CGRectMake(0, 131, BAScreenWidth, 130)];
    _levelCountCurveView = [[BAFansCurveView alloc] initWithFrame:CGRectMake(0, 262, BAScreenWidth, 130)];
    
    [self addSubview:_onlineCurveView];
    [self addSubview:_fansCountCurveView];
    [self addSubview:_levelCountCurveView];
}


- (void)setupStatus{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    
    [_onlineCurveView drawLayerWithPointArray:_reportModel.onlineTimePointArray color:BALineColor5];
    _onlineCurveView.countLabel.text = BAStringWithInteger(_reportModel.maxOnlineCount);
    _onlineCurveView.typeLabel.text = @"最大在线";
    _onlineCurveView.beginTimeLabel.text = [formatter stringFromDate:_reportModel.begin];
    _onlineCurveView.endTimeLabel.text = _reportModel.end ? [formatter stringFromDate:_reportModel.end] : [formatter stringFromDate:[NSDate date]];
    _onlineCurveView.maxValueLabel.text = [NSString stringWithFormat:@"%.1fK", (CGFloat)_reportModel.maxOnlineCount / 1000];
    _onlineCurveView.minValueLabel.text = [NSString stringWithFormat:@"%.1fK", (CGFloat)_reportModel.minOnlineCount / 1000];
    
    [_fansCountCurveView drawLayerWithPointArray:_reportModel.fansTimePointArray color:BALineColor6];
    _fansCountCurveView.countLabel.text = BAStringWithInteger(_reportModel.fansIncrese);
    _fansCountCurveView.typeLabel.text = @"关注增长";
    _fansCountCurveView.beginTimeLabel.text = [formatter stringFromDate:_reportModel.begin];
    _fansCountCurveView.endTimeLabel.text = _reportModel.end ? [formatter stringFromDate:_reportModel.end] : [formatter stringFromDate:[NSDate date]];
    _fansCountCurveView.maxValueLabel.text = [NSString stringWithFormat:@"%.1fK", (CGFloat)_reportModel.maxFansCount / 1000];
    _fansCountCurveView.minValueLabel.text = [NSString stringWithFormat:@"%.1fK", (CGFloat)_reportModel.minFansCount / 1000];
    
    NSInteger maxLevelCount = [[_reportModel.levelCountArray valueForKeyPath:@"@max.integerValue"] integerValue];
    [_levelCountCurveView drawLayerWithPointArray:_reportModel.levelCountPointArray color:BALineColor7];
    _levelCountCurveView.countLabel.text = [NSString stringWithFormat:@"%zd", _reportModel.levelSum / _reportModel.levelCount];
    _levelCountCurveView.typeLabel.text = @"平均等级";
    _levelCountCurveView.beginTimeLabel.text = @"0";
    _levelCountCurveView.endTimeLabel.text = @"70+";
    _levelCountCurveView.maxValueLabel.text = [NSString stringWithFormat:@"%zd", maxLevelCount];
    _levelCountCurveView.minValueLabel.text = [NSString stringWithFormat:@"%zd", 0];
    UILabel *middleValue = [UILabel lableWithFrame:CGRectMake(_levelCountCurveView.beginTimeLabel.x + BAFansReportDrawViewWidth / 2 - 25, _levelCountCurveView.beginTimeLabel.y, 50, BACommonTextFontSize) text:@"35" color:BALightTextColor font:BACommonFont(BASmallTextFontSize) textAlignment:NSTextAlignmentCenter];
    
    [_levelCountCurveView addSubview:middleValue];
}


@end
