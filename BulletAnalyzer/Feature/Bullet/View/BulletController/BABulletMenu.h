//
//  BABulletMenu.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/15.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^returnBlock)();

@interface BABulletMenu : UIView

/**
 菜单被触碰
 */
@property (nonatomic, copy) returnBlock menuTouched;

/**
 结束按钮被点击
 */
@property (nonatomic, copy) returnBlock endBtnClicked;

/**
 详细设置被点击
 */
@property (nonatomic, copy) returnBlock moreBtnClicked;

/**
 报告按钮被点击
 */
@property (nonatomic, copy) returnBlock reportBtnClicked;

/**
 更多
 */
@property (nonatomic, strong) UIButton *moreBtn;

/**
 结束
 */
@property (nonatomic, strong) UIButton *endBtn;

/**
 报告
 */
@property (nonatomic, strong) UIButton *reportBtn;

@end
