//
//  BAGiftModel.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/3.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAGiftModel.h"

@implementation BAGiftModel

- (void)setIc:(NSString *)ic{
    _ic = ic;
    
    if (_ic.length) {
        NSString *urlStr = [ic stringByReplacingOccurrencesOfString:@"%@" withString:@"/"];
        urlStr = [BADouyuImgBaicUrl stringByAppendingString:urlStr];
        _iconSmall = [urlStr stringByAppendingString:BADouyuImgSmallSuffix];
        _iconMiddle = [urlStr stringByAppendingString:BADouyuImgMiddleSuffix];
        _iconBig = [urlStr stringByAppendingString:BADouyuImgBigSuffix];
    }
}

@end
