//
//  CALayer+ZJRadius.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/7/13.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "CALayer+ZJRadius.h"
#import <objc/runtime.h>

@implementation CALayer (ZJRadius)
static bool _needMaskToBounds;
/*
+ (void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector2 = @selector(setMasksToBounds:);
        SEL swizzledSelector2 = @selector(ZJ_setMasksToBounds:);
        
        Method originalMethod2 = class_getInstanceMethod(class, originalSelector2);
        Method swizzledMethod2 = class_getInstanceMethod(class, swizzledSelector2);
        
        BOOL didAddMethod2 = class_addMethod(class, originalSelector2, method_getImplementation(swizzledMethod2), method_getTypeEncoding(swizzledMethod2));
        
        if (didAddMethod2) {
            class_replaceMethod(class, swizzledSelector2, method_getImplementation(originalMethod2), method_getTypeEncoding(originalMethod2));
        } else {
            method_exchangeImplementations(originalMethod2, swizzledMethod2);
        }
        
        SEL originalSelector3 = @selector(drawLayer:inContext:);
        SEL swizzledSelector3 = @selector(ZJ_drawLayer:inContext:);
        
        Method originalMethod3 = class_getInstanceMethod(class, originalSelector3);
        Method swizzledMethod3 = class_getInstanceMethod(class, swizzledSelector3);
        
        BOOL didAddMethod3 = class_addMethod(class, originalSelector3, method_getImplementation(swizzledMethod3), method_getTypeEncoding(swizzledMethod3));
        
        if (didAddMethod3) {
            class_replaceMethod(class, swizzledSelector3, method_getImplementation(originalMethod3), method_getTypeEncoding(originalMethod3));
        } else {
            method_exchangeImplementations(originalMethod3, swizzledMethod3);
        }
    });
}


- (void)ZJ_setMasksToBounds:(BOOL)maskToBounds{
    _needMaskToBounds = maskToBounds;

    if (self.cornerRadius <= 0) { //若圆角为0 则允许maskToBounds
        [self ZJ_setMasksToBounds:maskToBounds];
    }
}


- (void)ZJ_drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 1. 开启图形上下文
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
        
        // 2. 设置填充颜色
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        [[UIColor clearColor] setFill];
        UIRectFill(rect);
        
        // 3.贝塞尔曲线
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
        [path addClip];
        
        // 4.绘制图像
        [image drawInRect:rect];
        
        // 5.绘制的图像
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        // 6.关闭图形上下文
        UIGraphicsEndImageContext();
        
        // 7.回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(image);
            }
        });
    });
}
 */


@end
