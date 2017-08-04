//
//  BABulletSetting.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/15.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^returnBlock)();
typedef void(^speedChangedBlock)(CGFloat speed);

@interface BABulletSetting : UIView

/**
 菜单被触碰
 */
@property (nonatomic, copy) returnBlock settingTouched;

/**
 速度改变回调
 */
@property (nonatomic, copy) speedChangedBlock speedChanged;

/**
 是否显示了
 */
@property (nonatomic, assign, getter=isAlreadyShow) BOOL alreadyShow;

/**
 显示
 */
- (void)show;

/**
 隐藏
 */
- (void)hide;

@end
