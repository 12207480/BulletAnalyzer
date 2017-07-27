//
//  UIView+ZJRadius.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/7/27.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "UIView+ZJRadius.h"
#import <objc/runtime.h>

@implementation UIView (ZJRadius)
static bool _needClipsToBounds;


+ (void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(setClipsToBounds:);
        SEL swizzledSelector = @selector(ZJ_setClipsToBounds:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}


- (void)ZJ_setClipsToBounds:(BOOL)clipsToBounds{
    _needClipsToBounds = clipsToBounds;
    
    if (self.layer.cornerRadius <= 0) { //若圆角为0 则允许maskToBounds
        [self ZJ_setClipsToBounds:clipsToBounds];
    } else {
        [self ZJ_maskCorner];
    }
}


- (void)ZJ_maskCorner{
    
    //创建一个圆角蒙版
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(self.layer.cornerRadius, self.layer.cornerRadius)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = maskPath.CGPath;
    maskLayer.frame = self.bounds;
    maskLayer.fillColor = [UIColor whiteColor].CGColor;
    
    [self.layer addSublayer:maskLayer];
    self.layer.mask = maskLayer;
}

@end
