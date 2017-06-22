
//
//  BASentenceModel.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/22.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BASentenceModel.h"
#import "MJExtension.h"

@implementation BASentenceModel

MJExtensionCodingImplementation

- (void)decrease{
    self.count -= 1;
}


- (void)setCount:(NSInteger)count{
    _count = count;
    
    if (!count && _container) {
        [_container removeObject:self];
    }
}

@end
