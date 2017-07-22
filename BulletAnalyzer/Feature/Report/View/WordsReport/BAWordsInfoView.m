//
//  BAWordsInfoView.m
//  BulletAnalyzer
//
//  Created by Zj on 17/7/21.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAWordsInfoView.h"
#import "BAReportModel.h"
#import "BAWordsInfoBlock.h"
#import "BASentenceLabel.h"
#import "BAWordsModel.h"
#import "BASentenceModel.h"

@interface BAWordsInfoView()
@property (nonatomic, strong) BAWordsInfoBlock *popWordsBlock;
@property (nonatomic, strong) UIView *line1;
@property (nonatomic, strong) BAWordsInfoBlock *popSentenceBlock;
@property (nonatomic, strong) UIView *line2;
@property (nonatomic, strong) BASentenceLabel *sentence1;
@property (nonatomic, strong) UIView *line3;
@property (nonatomic, strong) BASentenceLabel *sentence2;
@property (nonatomic, strong) UIView *line4;
@property (nonatomic, strong) BASentenceLabel *sentence3;

@end

@implementation BAWordsInfoView

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupSubViews];
    }
    return self;
}


#pragma mark - public
- (void)setReportModel:(BAReportModel *)reportModel{
    _reportModel = reportModel;
    
    [self setupStatus];
}


#pragma mark - private
- (void)setupSubViews{
    
    CGFloat height = self.height;
    
    CGFloat blockHeight = (height - 4 - 2 * BAPadding) / 6 * 1.5;
    _popWordsBlock = [BAWordsInfoBlock blockWithDescription:nil info:nil iconName:@"words1" frame:CGRectMake(0, 0, BAScreenWidth, blockHeight)];
    
    [self addSubview:_popWordsBlock];
    
    _line1 = [[UIView alloc] initWithFrame:CGRectMake(2 * BAPadding, _popWordsBlock.bottom, BAScreenWidth - 4 * BAPadding, 1)];
    _line1.backgroundColor = BASpratorColor;
    
    [self addSubview:_line1];
    
    _popSentenceBlock = [BAWordsInfoBlock blockWithDescription:@"水友说得最多" info:nil iconName:@"words2" frame:CGRectMake(0, _line1.bottom, BAScreenWidth, blockHeight)];
    
    [self addSubview:_popSentenceBlock];
    
    _line2 = [[UIView alloc] initWithFrame:CGRectMake(2 * BAPadding, _popSentenceBlock.bottom, BAScreenWidth - 4 * BAPadding, 1)];
    _line2.backgroundColor = BASpratorColor;
    
    [self addSubview:_line2];
    
    CGFloat sentenceHeight = (height - 4) / 6;
    _sentence1 = [BASentenceLabel blockWithDescription:nil info:nil frame:CGRectMake(0, _line2.bottom, BAScreenWidth, sentenceHeight)];
    
    [self addSubview:_sentence1];
    
    _line3 = [[UIView alloc] initWithFrame:CGRectMake(2 * BAPadding, _sentence1.bottom, BAScreenWidth - 4 * BAPadding, 1)];
    _line3.backgroundColor = BASpratorColor;
    
    [self addSubview:_line3];
    
    _sentence2 = [BASentenceLabel blockWithDescription:nil info:nil frame:CGRectMake(0, _line3.bottom, BAScreenWidth, sentenceHeight)];
    
    [self addSubview:_sentence2];
    
    _line4 = [[UIView alloc] initWithFrame:CGRectMake(2 * BAPadding, _sentence2.bottom, BAScreenWidth - 4 * BAPadding, 1)];
    _line4.backgroundColor = BASpratorColor;
    
    [self addSubview:_line4];
    
    _sentence3 = [BASentenceLabel blockWithDescription:nil info:nil frame:CGRectMake(0, _line4.bottom, BAScreenWidth, sentenceHeight)];
    
    [self addSubview:_sentence3];
}


- (void)setupStatus{
    
    BAWordsModel *wordsModel = [_reportModel.wordsArray firstObject];
    _popWordsBlock.descripLabel.text = [NSString stringWithFormat:@"弹幕最多提到的关键词: %@", wordsModel.words];
    _popWordsBlock.infoLabel.text = [NSString stringWithFormat:@"%@次", wordsModel.count];
    
    
    BASentenceModel *sentence1Model = _reportModel.popSentenceArray[0];
    BASentenceModel *sentence2Model = _reportModel.popSentenceArray[1];
    BASentenceModel *sentence3Model = _reportModel.popSentenceArray[2];
    _sentence1.descripLabel.text = [NSString stringWithFormat:@"1、%@", sentence1Model.text];
    _sentence1.infoLabel.text = [NSString stringWithFormat:@"%zd次", sentence1Model.realCount];
    
    _sentence2.descripLabel.text = [NSString stringWithFormat:@"1、%@", sentence2Model.text];
    _sentence2.infoLabel.text = [NSString stringWithFormat:@"%zd次", sentence2Model.realCount];
    
    _sentence3.descripLabel.text = [NSString stringWithFormat:@"1、%@", sentence3Model.text];
    _sentence3.infoLabel.text = [NSString stringWithFormat:@"%zd次", sentence3Model.realCount];
}

@end
