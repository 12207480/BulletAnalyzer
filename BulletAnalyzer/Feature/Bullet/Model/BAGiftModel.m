//
//  BAGiftModel.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/3.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAGiftModel.h"

@interface BAGiftModel()
@property (nonatomic, assign, getter=isStatusReady) BOOL statusReady;

@end

@implementation BAGiftModel

- (void)setIc:(NSString *)ic{
    _ic = ic;
    
    if (_ic.length) {
        NSString *urlStr = [ic stringByReplacingOccurrencesOfString:@"@S" withString:@"/"];
        urlStr = [BADouyuImgBaicUrl stringByAppendingString:urlStr];
        _iconSmall = [urlStr stringByAppendingString:BADouyuImgSmallSuffix];
        _iconMiddle = [urlStr stringByAppendingString:BADouyuImgMiddleSuffix];
        _iconBig = [urlStr stringByAppendingString:BADouyuImgBigSuffix];
    }
}


- (void)setBnn:(NSString *)bnn{
    _bnn = bnn;
    
    _giveTo = bnn;
    self.statusReady = (BOOL)_gs && (BOOL)_bl;
}


- (void)setDn:(NSString *)dn{
    _dn = dn;
    
    _giveTo = dn;
}


- (void)setSn:(NSString *)sn{
    _sn = sn;
    
    _nn = sn;
}


- (void)setGs:(NSString *)gs{
    _gs = gs;
    
    switch (gs.integerValue) {
        case 1: //鱼丸礼物
            _giftType = BAGiftTypeFishBall;
            break;
            
        case 2: //怂 稳 呵呵 点赞 粉丝荧光棒 辣眼睛
            self.statusReady = (BOOL)_bnn && (BOOL)_bl;
            break;
            
        case 3: //弱鸡
            self.statusReady = (BOOL)_bnn && (BOOL)_bl;
            break;
            
        case 5: //飞机
            _giftType = BAGiftTypePlane;
            break;
            
        case 6: //火箭
            _giftType = BAGiftTypeRocket;
            break;
            
        default:
            break;
    }
}


- (void)setBl:(NSString *)bl{
    _bl = bl;
    
    self.statusReady = (BOOL)_gs && (BOOL)_bnn;
}


- (void)setStatusReady:(BOOL)statusReady{
    _statusReady = statusReady;
    
    //道具礼物须通过 类型gs 是否有赠送者bnn 等级bl共同判断
    if (statusReady) {
        
    }
}


- (void)setLev:(NSString *)lev{
    _lev = lev;
    
    switch (lev.integerValue) {
        case 1: //低级酬勤
            _giftType = BAGiftTypeDeserveLevel1;
            break;
            
        case 2: //中级酬勤
            _giftType = BAGiftTypeDeserveLevel2;
            break;
            
        case 3: //高级酬勤
            _giftType = BAGiftTypeDeserveLevel3;
            break;
            
        default:
            break;
    }
}


@end
