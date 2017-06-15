//
//  BABulletController.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/13.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^returnBlock)();

@interface BABulletController : UIView

/**
 关注名单按钮被点击
 */
@property (nonatomic, copy) returnBlock whiteBtnClicked;

/**
 忽略名单被点击
 */
@property (nonatomic, copy) returnBlock blackBtnClicked;

/**
 结束按钮被点击
 */
@property (nonatomic, copy) returnBlock endBtnClicked;

@end
