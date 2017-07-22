//
//  BASentenceLabel.m
//  BulletAnalyzer
//
//  Created by Zj on 17/7/22.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BASentenceLabel.h"

@interface BASentenceLabel()

@end

@implementation BASentenceLabel

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupSubViews];
    }
    return self;
}


+ (instancetype)blockWithDescription:(NSString *)description info:(NSString *)info frame:(CGRect)frame{
    BASentenceLabel *sentenceLabel = [[BASentenceLabel alloc] initWithFrame:frame];
    sentenceLabel.descripLabel.text = description;
    sentenceLabel.infoLabel.text = info;
    
    return sentenceLabel;
}


#pragma mark - private
- (void)setupSubViews{
    CGFloat height = self.height;
    
    _infoLabel = [UILabel labelWithFrame:CGRectMake(BAScreenWidth - 2 * BAPadding - 60, height / 2 - 10, 60, 20) text:nil color:BALightTextColor font:BACommonFont(BASmallTextFontSize) textAlignment:NSTextAlignmentRight];
    
    [self addSubview:_infoLabel];
    
    _descripLabel = [UILabel labelWithFrame:CGRectMake(2 * BAPadding, _infoLabel.y, _infoLabel.x - 3 * BAPadding, 20) text:nil color:BALightTextColor font:BACommonFont(BASmallTextFontSize) textAlignment:NSTextAlignmentLeft];
    
    [self addSubview:_descripLabel];
}

@end
