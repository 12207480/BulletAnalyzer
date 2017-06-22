//
//  BAGiftValueModel.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/22.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BAGiftModel.h"

@interface BAGiftValueModel : NSObject <NSCoding>

/**
 礼物类型
 */
@property (nonatomic, assign) BAGiftType giftType;

/**
 礼物价值
 */
@property (nonatomic, assign) CGFloat giftValue;

/**
 赠送者数组
 */
@property (nonatomic, strong) NSMutableArray *userModelArray;

/**
 该类型礼物的数量
 */
@property (nonatomic, assign) NSInteger count;

@end
