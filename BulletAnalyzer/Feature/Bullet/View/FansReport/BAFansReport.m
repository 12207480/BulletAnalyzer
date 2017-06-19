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
@property (nonatomic, strong) BAFansCurveView *fansCurveView;

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


- (void)layoutSubviews{
    [super layoutSubviews];
    
    //[self animation];
}


#pragma mark - public
- (void)setReportModel:(BAReportModel *)reportModel{
    _reportModel = reportModel;
    
    if (_reportModel.countTimePointArray.count < 6) return;
    
    [self setupStatus];
}


- (void)animation{


}


- (void)hide{
    
}


#pragma mark - private
- (void)setupSubViews{
    _fansCurveView = [[BAFansCurveView alloc] initWithFrame:CGRectMake(0, 0, BAScreenWidth, 130)];
    
    [self addSubview:_fansCurveView];
}


- (void)setupStatus{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    
    [_fansCurveView drawLayerWithPointArray:_reportModel.onlineTimePointArray color:BALineColor5];
    _fansCurveView.countLabel.text = BAStringWithInteger(_reportModel.maxOnlineCount);
    _fansCurveView.typeLabel.text = @"online";
    _fansCurveView.beginTimeLabel.text = [formatter stringFromDate:_reportModel.begin];
    _fansCurveView.endTimeLabel.text = _reportModel.end ? [formatter stringFromDate:_reportModel.end] : [formatter stringFromDate:[NSDate date]];
    _fansCurveView.maxValueLabel.text = [NSString stringWithFormat:@"%.1fK", (CGFloat)_reportModel.maxOnlineCount / 1000];
    _fansCurveView.minValueLabel.text = [NSString stringWithFormat:@"%.1fK", (CGFloat)_reportModel.minOnlineCount / 1000];
}


@end
