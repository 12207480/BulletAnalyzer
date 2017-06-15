//
//  BABulletSetting.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/15.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^returnBlock)();

@interface BABulletSetting : UIView

/**
 菜单被触碰
 */
@property (nonatomic, copy) returnBlock settingTouched;

@end
