//
//  BATransition.h
//  BulletAnalyzer
//
//  Created by 张骏 on 17/7/13.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BATransitionType) {
    BATransitionTypePresent = 0,//管理present动画
    BATransitionTypeDismiss = 1//管理dismiss动画
};

typedef NS_ENUM(NSUInteger, BATransitionAnimation) {
    BATransitionAnimationDamping = 0,//弹性动画
    BATransitionAnimationCycle = 1, //圆圈切割动画
    BATransitionAnimationGradient = 2, //渐变缩放动画
    BATransitionAnimationMove = 3 //视图移动动画
};

static NSString *const BATransitionAttributeCycleRect = @"BATransitionAttributeCycleRect";
static NSString *const BATransitionAttributeDampingHeight = @"BATransitionAttributeDampingHeight";

@interface BATransition : NSObject <UIViewControllerAnimatedTransitioning>

/**
 初始化方法
 */
+ (instancetype)transitionWithType:(BATransitionType)type animation:(BATransitionAnimation)animation attribute:(NSDictionary *)attribute;

@end
