//
//  BABasicInfoModel
//  BulletAnalyzer
//
//  Created by Zj on 17/6/3.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const BAInfoTypeBullet = @"chatmsg"; //弹幕
static NSString *const BAInfoTypeLoginReplay = @"loginres"; //登录
static NSString *const BAInfoTypeSmallGift = @"dgb"; //鱼丸
static NSString *const BAInfoTypeDeserveGift = @"bc_buy_deserve"; //酬勤
static NSString *const BAInfoTypeSuperGift = @"spbc"; //火箭/飞机

@interface BABasicInfoModel : NSObject

/**
 弹幕模型 chatmsg
 */
@property (nonatomic, copy) NSString *type;

@end
