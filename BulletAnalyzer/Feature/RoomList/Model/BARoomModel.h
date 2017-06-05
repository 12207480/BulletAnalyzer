//
//  BARoomModel.h
//  BulletAnalyzer
//
//  Created by Zj on 17/6/4.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BARoomModel : NSObject

/**
 房间号
 */
@property (nonatomic, copy) NSString *room_id;

/**
 主播名称
 */
@property (nonatomic, copy) NSString *nickname;

/**
 在线人数
 */
@property (nonatomic, copy) NSString *online;

/**
 游戏名称
 */
@property (nonatomic, copy) NSString *game_name;

/**
 中头像
 */
@property (nonatomic, copy) NSString *avatar_mid;

/**
 标准头像
 */
@property (nonatomic, copy) NSString *avatar;

/**
 小头像
 */
@property (nonatomic, copy) NSString *avatar_small;

/**
 直播间截图 //垂直
 */
@property (nonatomic, copy) NSString *vertical_src;

/**
 直播间名称
 */
@property (nonatomic, copy) NSString *room_name;

/**
 直播间url
 */
@property (nonatomic, copy) NSString *url;

/**
 游戏分类url
 */
@property (nonatomic, copy) NSString *game_url;

/**
 房间所属用户的 UID
 */
@property (nonatomic, copy) NSString *owner_uid;

/**
 房间图片,大小 320*180
 */
@property (nonatomic, copy) NSString *room_src;

/**
 是否是垂直
 */
@property (nonatomic, copy) NSString *isVertical;

/**
 保存首页截图Y值
 */
@property (nonatomic, assign) CGFloat screenShotViewY;

@end
