//
//  UIImageView+ZJRadius.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/7/13.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "UIImageView+ZJRadius.h"
#import <objc/runtime.h>

@implementation UIImageView (ZJRadius)
static bool _needClipsToBounds;


+ (void)load{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector1 = @selector(setClipsToBounds:);
        SEL swizzledSelector1 = @selector(ZJ_setClipsToBounds:);
        
        Method originalMethod1 = class_getInstanceMethod(class, originalSelector1);
        Method swizzledMethod1 = class_getInstanceMethod(class, swizzledSelector1);
        
        BOOL didAddMethod1 = class_addMethod(class, originalSelector1, method_getImplementation(swizzledMethod1), method_getTypeEncoding(swizzledMethod1));
        
        if (didAddMethod1) {
            class_replaceMethod(class, swizzledSelector1, method_getImplementation(originalMethod1), method_getTypeEncoding(originalMethod1));
        } else {
            method_exchangeImplementations(originalMethod1, swizzledMethod1);
        }
        
        
        SEL originalSelector2 = @selector(setImage:);
        SEL swizzledSelector2 = @selector(ZJ_setImage:);
        
        Method originalMethod2 = class_getInstanceMethod(class, originalSelector2);
        Method swizzledMethod2 = class_getInstanceMethod(class, swizzledSelector2);
        
        BOOL didAddMethod2 = class_addMethod(class, originalSelector2, method_getImplementation(swizzledMethod2), method_getTypeEncoding(swizzledMethod2));
        
        if (didAddMethod2) {
            class_replaceMethod(class, swizzledSelector2, method_getImplementation(originalMethod2), method_getTypeEncoding(originalMethod2));
        } else {
            method_exchangeImplementations(originalMethod2, swizzledMethod2);
        }
        
    });
}


- (void)ZJ_setClipsToBounds:(BOOL)clipsToBounds{
    _needClipsToBounds = clipsToBounds;
    
    if (self.layer.cornerRadius <= 0) { //若圆角为0 则允许maskToBounds
        [self ZJ_setClipsToBounds:clipsToBounds];
    }
}


- (void)ZJ_setImage:(UIImage *)image{
    
    if ([self.image isEqual:image]) return;
    
    if (self.layer.cornerRadius > 0 && _needClipsToBounds) {
        [self ZJ_clipsImage:image];
    } else {
        [self ZJ_setImage:image];
    }
}


- (void)ZJ_clipsImage:(UIImage *)image{
    
    [self ZJ_setImage:nil];
    
    //创建一个的layer显示
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        UIImageView *imageView;
        for (UIView *subView in self.subviews) {
            if (subView.tag == 10241024) {
                imageView = (UIImageView *)subView;
                break;
            }
        }
        
        if (!imageView) {
            imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            imageView.userInteractionEnabled = NO;
            imageView.tag = 10241024; //标记
            
            [self addSubview:imageView];
        }
        
        CGSize size = CGSizeMake(self.layer.cornerRadius * 2, self.layer.cornerRadius * 2);
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
        [path addClip];
        
        [image drawInRect:rect];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        [self ZJ_setImage:image];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
    });
}

@end
