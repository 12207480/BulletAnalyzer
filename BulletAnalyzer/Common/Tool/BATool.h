//
//  BATool.h
//  BulletAnalyzer
//
//  Created by Zj on 17/6/4.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BATool : NSObject

/**
 创建HUD
 */
+ (void)showHUDWithText:(NSString *)text ToView:(UIView *)view;

/**
 创建GIFHUd
 */
+ (void)showGIFHud;

/**
 取消GIFHUd
 */
+ (void)hideGIFHud;

@end
