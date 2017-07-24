//
//  BAGiftUserCell.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/7/24.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BATableViewCell.h"

@class BAUserModel;

@interface BAGiftUserCell : BATableViewCell

/**
 传入用户数据
 */
@property (nonatomic, strong) BAUserModel *userModel;

@end
