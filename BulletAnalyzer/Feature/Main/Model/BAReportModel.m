//
//  BAReportModel.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/7.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAReportModel.h"
#import "BAAnalyzerCenter.h"
#import "BABulletModel.h"
#import "BAWordsModel.h"
#import "MJExtension.h"

@interface BAReportModel()

@end

@implementation BAReportModel

MJExtensionCodingImplementation

#pragma mark - public
- (void)addBullets:(NSArray *)bulletsArray{
    [self.bulletsArray addObjectsFromArray:bulletsArray];
    
    if ([BAAnalyzerCenter defaultCenter].isAnalyzing) {
        [self caculate:bulletsArray];
    };
}


#pragma mark - private
- (void)caculate:(NSArray *)bulletsArray{

    [bulletsArray enumerateObjectsUsingBlock:^(BABulletModel *bulletsModel, NSUInteger idx, BOOL * _Nonnull stop1) {
        
        NSArray *wordsArray = [self stringTokenizerWithWord:bulletsModel.txt];
        [wordsArray enumerateObjectsUsingBlock:^(NSString *words, NSUInteger idx, BOOL * _Nonnull stop2) {
           
            __block BOOL contained = NO;
            [self.wordsArray enumerateObjectsUsingBlock:^(BAWordsModel *wordsModel, NSUInteger idx, BOOL * _Nonnull stop3) {
                
                contained = [wordsModel.words isEqualToString:words];
                if (contained) {
                    *stop3 = YES;
                    wordsModel.count = BAStringWithInteger(wordsModel.count.integerValue + 1);
                }
                NSLog(@"%@ : %@", wordsModel.words, wordsModel.count);
            }];
            if (!contained) {
                BAWordsModel *newWordsModel = [BAWordsModel new];
                newWordsModel.words = words;
                newWordsModel.count = BAStringWithInteger(1);
                [self.wordsArray addObject:newWordsModel];
            }
        }];
    }];
}


- (NSArray *)stringTokenizerWithWord:(NSString *)word{
   
    NSMutableArray *keyWords = [NSMutableArray new];
    CFStringTokenizerRef ref = CFStringTokenizerCreate(NULL,  (__bridge CFStringRef)word, CFRangeMake(0, word.length), kCFStringTokenizerUnitWord, NULL);
    CFRange range;
    CFStringTokenizerAdvanceToNextToken(ref);
    range = CFStringTokenizerGetCurrentTokenRange(ref);
   
    NSString *keyWord;
    while (range.length > 0)  {
        keyWord = [word substringWithRange:NSMakeRange(range.location, range.length)];
        if (keyWord.length > 1) { //一个字一下的词全部过滤
            [keyWords addObject:keyWord];
        }
        CFStringTokenizerAdvanceToNextToken(ref);
        range = CFStringTokenizerGetCurrentTokenRange(ref);
    }
    
    return keyWords;
}


- (NSMutableArray *)wordsArray{
    if (!_wordsArray) {
        _wordsArray = [NSMutableArray array];
    }
    return _wordsArray;
}

@end
