//
//  BASentenceLabel.h
//  BulletAnalyzer
//
//  Created by Zj on 17/7/22.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BASentenceLabel : UIView
@property (nonatomic, strong) UILabel *descripLabel;
@property (nonatomic, strong) UILabel *infoLabel;

/**
 快速创建
 */
+ (instancetype)blockWithDescription:(NSString *)description info:(NSString *)info frame:(CGRect)frame;

@end
