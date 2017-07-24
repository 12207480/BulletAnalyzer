//
//  BASentenceCell.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/7/24.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BATableViewCell.h"

@class BASentenceModel;

@interface BASentenceCell : BATableViewCell

@property (nonatomic, strong) BASentenceModel *sentenceModel;

@end
