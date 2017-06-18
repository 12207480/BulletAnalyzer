//
//  BAUserModel.h
//  BulletAnalyzer
//
//  Created by Zj on 17/6/11.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BABulletModel;

@interface BAUserModel : NSObject <NSCoding>

/**
 发送者昵称
 */
@property (nonatomic, copy) NSString *nn;

/**
 发送者 id
 */
@property (nonatomic, copy) NSString *uid;

/**
 用户头像(猜想)
 */
@property (nonatomic, copy) NSString *ic;

/**
 用户头像小
 */
@property (nonatomic, copy) NSString *iconSmall;

/**
 用户头像中
 */
@property (nonatomic, copy) NSString *iconMiddle;

/**
 用户头像大
 */
@property (nonatomic, copy) NSString *iconBig;

/**
 客户端类型:默认值 0(表示 web 用户)
 */
@property (nonatomic, copy) NSString *ct;

/**
 该用户发送弹幕数量/该等级用户的数量
 */
@property (nonatomic, copy) NSString *count;

/**
 最大发言数
 */
@property (nonatomic, assign) NSInteger maxActiveCount;

/**
 用户等级
 */
@property (nonatomic, copy) NSString *level;

/**
 发言活跃度cell是否被选中
 */
@property (nonatomic, assign, getter=isActiveCellSelect) BOOL activeCellSelect;

/**
 快速创建用户模型
 */
+ (instancetype)userModelWithBullet:(BABulletModel *)bulletModel;

@end
