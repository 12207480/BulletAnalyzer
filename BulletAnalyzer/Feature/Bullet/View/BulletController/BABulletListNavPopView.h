//
//  BABulletListNavPopView.h
//  BulletAnalyzer
//
//  Created by Zj on 17/8/5.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^btnClicked)(NSInteger tag);

@interface BABulletListNavPopView : UIView

/**
 按钮点击回调
 */
@property (nonatomic, copy) btnClicked btnClicked;

/**
 快速创建
 */
+ (instancetype)popViewWithFrame:(CGRect)frame titles:(NSArray *)titles;

@end
