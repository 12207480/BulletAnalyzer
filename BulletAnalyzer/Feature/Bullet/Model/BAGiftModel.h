//
//  BAGiftModel.h
//  BulletAnalyzer
//
//  Created by Zj on 17/6/3.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BABasicInfoModel.h"

@interface BAGiftModel : BABasicInfoModel

/**
 房间id
 */
@property (nonatomic, copy) NSString *rid;

/**
 弹幕分组 ID
 */
@property (nonatomic, copy) NSString *gid;

/**
 客户端类型:默认值 0(表示 web 用户)
 */
@property (nonatomic, copy) NSString *ct;

/**
 主播体重
 */
@property (nonatomic, copy) NSString *dw;

/**
 特效id
 */
@property (nonatomic, copy) NSString *eid;

/**
 礼物id
 */
@property (nonatomic, copy) NSString *gfid;

/**
 礼物显示样式
 */
@property (nonatomic, copy) NSString *gs;

/**
 连击
 */
@property (nonatomic, copy) NSString *hits;

/**
 头像(猜想)
 */
@property (nonatomic, copy) NSString *ic;

/**
 用户等级
 */
@property (nonatomic, copy) NSString *level;

/**
 昵称
 */
@property (nonatomic, copy) NSString *nn;

/**
 用户id
 */
@property (nonatomic, copy) NSString *uid;

/**
 赠送火箭用户昵称
 */
@property (nonatomic, copy) NSString *sn;

/**
 受赠火箭者昵称
 */
@property (nonatomic, copy) NSString *dn;

/**
 礼物名称
 */
@property (nonatomic, copy) NSString *gn;

/**
 礼物数量
 */
@property (nonatomic, copy) NSString *gc;

/**
 1火箭 2飞机
 */
@property (nonatomic, copy) NSString *es;

@end
