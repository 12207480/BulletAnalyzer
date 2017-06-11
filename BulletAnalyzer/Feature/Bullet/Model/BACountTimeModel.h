//
//  BACountTimeModel.h
//  BulletAnalyzer
//
//  Created by Zj on 17/6/11.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BACountTimeModel : NSObject

/**
 此刻弹幕数量
 */
@property (nonatomic, copy) NSString *count;

/**
 此刻时间
 */
@property (nonatomic, strong) NSDate *time;

@end
