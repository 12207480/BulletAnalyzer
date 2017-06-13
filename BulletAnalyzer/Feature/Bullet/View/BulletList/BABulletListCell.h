//
//  BABulletListCell.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/13.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BATableViewCell.h"

@class BABulletModel;

@interface BABulletListCell : BATableViewCell

/**
 传入弹幕
 */
@property (nonatomic, strong) BABulletModel *bulletModel;

@end
