//
//  BACountReport.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/16.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BACountReport.h"
#import "BAReportModel.h"
#import "NSDate+Category.h"

@interface BACountReport()
@property (nonatomic, strong) NSMutableArray *XValues;
@property (nonatomic, strong) NSMutableArray *YValues;

@end

@implementation BACountReport

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = BADarkBackgroundColor;
        
        [self setupBg];
    }
    return self;
}


#pragma mark - public
- (void)setReportModel:(BAReportModel *)reportModel{
    _reportModel = reportModel;
    
    [self setupXY];
    
    [self draw];
}


#pragma mark - private
- (void)setupXY{
    
    if (_reportModel.countTimePointArray.count < 6) {
        
        return;
    } else if (_reportModel.countTimePointArray.count < 18) {
    
        
    }

    [_YValues enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL * _Nonnull stop) {

        obj.text = [NSString stringWithFormat:@"%zd", _reportModel.maxBulletCount / 6 * (5 - idx)];
    }];
    
    NSInteger duration = _reportModel.duration ? _reportModel.duration : [[NSDate date] minutesAfterDate:_reportModel.begin];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    
    [_XValues enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDate *date = [_reportModel.begin dateByAddingMinutes:idx * duration / 7];
        obj.text = [formatter stringFromDate:date];
    }];
}


- (void)draw{
    
}


- (void)setupBg{
    
    _XValues = [NSMutableArray array];
    _YValues = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 7; i++) {
        
        if (i < 6) {
            UIView *line = [self createLine];
            line.y = self.height / 7 * (i + 1);
            if (i == 5) {
                line.x = 0;
                line.width = BAScreenWidth;
            }
            
            UILabel *YValue = [self createYValue];
            YValue.y = self.height / 7 * i;
        }
        
        UILabel *XValue = [self createXValue];
        XValue.x = self.width / 7 * i;
    }
}


- (UIView *)createLine{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(2 * BAPadding, 0, BAScreenWidth - 4 * BAPadding, 0.5)];
    view.backgroundColor = BALightTextColor;
    
    [self addSubview:view];
    return view;
}


- (UILabel *)createXValue{
    UILabel *label = [UILabel lableWithFrame:CGRectMake(0, self.height * 6 / 7, self.width / 7, self.height / 7) text:@"" color:BAWhiteColor font:BAThinFont(BACommonTextFontSize) textAlignment:NSTextAlignmentCenter];
    label.hidden = !(_XValues.count == 0 || _XValues.count == 3 || _XValues.count == 6);
    [_XValues addObject:label];
    
    [self addSubview:label];
    return label;
}


- (UILabel *)createYValue{
    UILabel *label = [UILabel lableWithFrame:CGRectMake(0, 0, 4 * BAPadding, self.height / 7) text:@"" color:BAWhiteColor font:BAThinFont(BACommonTextFontSize) textAlignment:NSTextAlignmentCenter];
    [_YValues addObject:label];
    
    [self addSubview:label];
    return label;
}

@end
