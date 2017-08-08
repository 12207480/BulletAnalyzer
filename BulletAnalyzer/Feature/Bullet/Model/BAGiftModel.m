//
//  BAGiftModel.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/3.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAGiftModel.h"
#import "BAUserModel.h"
#import "BABulletModel.h"
#import "MJExtension.h"

@interface BAGiftModel()
@property (nonatomic, assign, getter=isStatusReady) BOOL statusReady;

@end

@implementation BAGiftModel

MJCodingImplementation

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


- (void)setGs:(NSString *)gs{
    _gs = gs;
    
    switch (gs.integerValue) {
        case 1: //鱼丸礼物
            _giftType = BAGiftTypeFishBall;
            break;
            
        case 2: //怂 稳 呵呵 点赞 粉丝荧光棒 辣眼睛
            self.statusReady = (BOOL)_bl;
            break;
            
        case 3: //弱鸡
            self.statusReady = (BOOL)_bl;
            break;
            
        case 4: //办卡
            _giftType = BAGiftTypeCard;
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


- (void)setSn:(NSString *)sn{
    _sn = sn;
    
    if (sn.length) {
        self.nn = sn;
    }
}


- (void)setBl:(NSString *)bl{
    _bl = bl;
    
    self.statusReady = _gs.integerValue == 2 || _gs.integerValue == 3;
}


- (void)setStatusReady:(BOOL)statusReady{
    _statusReady = statusReady;
    
    //道具礼物须通过 类型gs 等级bl共同判断
    if (statusReady) {
        _giftType = _bl.integerValue ? BAGiftTypeCostGift : BAGiftTypeFreeGift;
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


- (void)setNn:(NSString *)nn{
    if (nn.length) {
        _nn = nn;
        
        CGRect nameRect = [[nn stringByAppendingString:@":"] boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : BACommonFont(16)} context:nil];
        
        _nameWidth = nameRect.size.width;
    }
}

@end
