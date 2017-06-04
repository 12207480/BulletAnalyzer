
//
//  BATool.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/4.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BATool.h"
#import "MBProgressHUD.h"
#import "GiFHUD.h"

@implementation BATool

+ (void)showHUDWithText:(NSString *)text ToView:(UIView *)view{
    MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    progressHUD.mode = MBProgressHUDModeText;
    progressHUD.label.text = text;
    progressHUD.removeFromSuperViewOnHide = YES;
    progressHUD.alpha = 0.9;
    [progressHUD hideAnimated:YES afterDelay:1.0f];
}


+ (void)showGIFHud{
    [GiFHUD setGifWithImageName:@"house.gif"];
    [GiFHUD showWithOverlay];
}


+ (void)hideGIFHud{
    [GiFHUD dismiss];
}

@end
