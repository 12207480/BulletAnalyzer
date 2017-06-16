//
//  BAReportModel.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/7.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAReportModel.h"
#import "BACountTimeModel.h"
#import "MJExtension.h"
#import "NSDate+Category.h"

@interface BAReportModel()

@end

@implementation BAReportModel

MJExtensionCodingImplementation

- (void)setPhoto:(NSString *)photo{
    if (photo.length && ![photo isEqualToString:_photo]) {
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(queue, ^{
            
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:photo]];
            UIImage *screenShot = [UIImage imageWithData:data];
            
            if (!_photoArray) {
                _photoArray = [NSMutableArray array];
            }
            [_photoArray addObject:screenShot];
        });
    }
    
    _photo = photo;
}


- (void)setEnd:(NSDate *)end{
    _end = end;
    
    _duration = [end minutesAfterDate:_begin];
}

@end
