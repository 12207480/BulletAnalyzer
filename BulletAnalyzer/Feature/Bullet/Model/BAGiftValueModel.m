//
//  BAGiftValueModel.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/22.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAGiftValueModel.h"
#import "BAUserModel.h"
#import "MJExtension.h"

@implementation BAGiftValueModel

MJCodingImplementation

- (void)setGiftType:(BAGiftType)giftType{
    _giftType = giftType;
    
    switch (giftType) {
        case BAGiftTypeFreeGift:
            _giftValue = 0;
            break;
            
        case BAGiftTypeCostGift:
            _giftValue = 0.15;
            break;
            
        case BAGiftTypeDeserveLevel1:
            _giftValue = 15;
            break;
            
        case BAGiftTypeDeserveLevel2:
            _giftValue = 30;
            break;
            
        case BAGiftTypeDeserveLevel3:
            _giftValue = 50;
            break;
            
        case BAGiftTypeCard:
            _giftValue = 6;
            break;
            
        case BAGiftTypePlane:
            _giftValue = 100;
            break;
            
            
        case BAGiftTypeRocket:
            _giftValue = 500;
            break;
            
        default:
            break;
    }
}


- (NSInteger)count{
    NSArray *countTotal = [_userModelArray valueForKeyPath:@"@unionOfObjects.giftCount"];
    NSNumber *sumCount = [countTotal valueForKeyPath:@"@sum.integerValue"];
    
    return sumCount.integerValue;
}


- (NSMutableArray *)userModelArray{
    if (!_userModelArray) {
        _userModelArray = [NSMutableArray array];
    }
    return _userModelArray;
}

@end
