//
//  BAActiveCell.h
//  BulletAnalyzer
//
//  Created by Zj on 17/6/18.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BATableViewCell.h"

@class BAUserModel;

@interface BAActiveCell : BATableViewCell

/**
 传入用户模型
 */
@property (nonatomic, strong) BAUserModel *userModel;

@end
