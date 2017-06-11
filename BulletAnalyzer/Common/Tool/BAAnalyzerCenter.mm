//
//  BAAnalyzerCenter.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/8.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAAnalyzerCenter.h"
#import "BAReportModel.h"
#import "BABulletModel.h"
#import "BAWordsModel.h"
#import "BAUserModel.h"
#import "BACountTimeModel.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "Segmentor.h"

static NSString *const BACompletedReport = @"completedReport"; //完成表
static NSString *const BAAnalyzingReport = @"AnalyzingReport"; //进行表
static NSString *const BAReportID = @"ID";  //ID
static NSString *const BAReportData = @"reportData"; //数据

@interface BAAnalyzerCenter()
@property (nonatomic, strong) BAReportModel *analyzingReportModel; //正在分析的报告
@property (nonatomic, strong) FMDatabaseQueue *queue;   //子线程中操作数据库
@property (nonatomic, assign) dispatch_queue_t analyzingQueue; //用于计算的子线程


@property (nonatomic, strong) NSMutableArray *bulletsArray; //弹幕数组 只保留前100个
@property (nonatomic, strong) NSMutableArray *wordsArray;   //单词数组 保留500个 频次低的不保留
@property (nonatomic, strong) NSMutableArray *userArraySortedByCount;   //根据发言次数排序的用户数组 保留100个
@property (nonatomic, strong) NSMutableArray *userArraySortedByLevel;   //用户等级与数量关系的数组
@property (nonatomic, strong) NSMutableArray *countTimeArray;   //弹幕数量与时间关系的数组


@property (nonatomic, assign) NSInteger timeRepeatCount; //时钟重复次数
@property (nonatomic, assign) NSInteger bulletsCount;   //弹幕次数/在采样时间内

@end

@implementation BAAnalyzerCenter

#pragma mark - public
- (void)beginAnalyzing{
    _analyzing = YES;
    
    //传入报告则接着分析
    if (!_proceedReportModel) {
        _bulletsArray = [NSMutableArray array];
        _wordsArray = [NSMutableArray array];
        _userArraySortedByCount = [NSMutableArray array];
        _userArraySortedByLevel = [NSMutableArray array];
        _countTimeArray = [NSMutableArray array];
        
        _analyzingReportModel.bulletsArray = _bulletsArray;
        _analyzingReportModel.wordsArray = _wordsArray;
        _analyzingReportModel.userArraySortedByCount = _userArraySortedByCount;
        _analyzingReportModel.userArraySortedByLevel = _userArraySortedByLevel;
        
        _analyzingReportModel = [BAReportModel new];
        _analyzingReportModel.begin = [NSDate date];
        
        
    } else {
        _analyzingReportModel = _proceedReportModel;
        _analyzingReportModel.interruptAnalyzing = NO;
        _analyzingReportModel.proceed = [NSDate date];
        _proceedReportModel = nil;
       
        //接着分析
        _bulletsArray = _analyzingReportModel.bulletsArray;
        _wordsArray = _analyzingReportModel.wordsArray;
        _userArraySortedByCount = _analyzingReportModel.userArraySortedByCount;
        _userArraySortedByLevel = _analyzingReportModel.userArraySortedByLevel;
        _countTimeArray = _analyzingReportModel.countTimeArray;
    }
    
    [self beginObserving];
}


- (void)interruptAnalyzing{
    _analyzing = NO;
    [self endObserving];
    
    if (_analyzingReportModel) {
        _analyzingReportModel.interruptAnalyzing = YES;
        _analyzingReportModel.interrupt = [NSDate date];
        [_reportModelArray addObject:_analyzingReportModel];
        
        //存入本地
        [self saveReportLocolized];
    }
}


- (void)endAnalyzing{
    _analyzing = NO;
    [self endObserving];

    if (_analyzingReportModel) {
        _analyzingReportModel.interruptAnalyzing = NO;
        _analyzingReportModel.end = [NSDate date];
        [_reportModelArray addObject:_analyzingReportModel];
        
        //存入本地
        [self saveReportLocolized];
    }
}


#pragma mark - private
- (void)beginObserving{
    [BANotificationCenter addObserver:self selector:@selector(bullet:) name:BANotificationBullet object:nil];
    
    [_cleanTimer invalidate];
    _cleanTimer = nil;
    if (!_repeatTime) {
        _repeatTime = 5.f; //默认5秒释放一次弹幕
    }

    _cleanTimer = [NSTimer scheduledTimerWithTimeInterval:_repeatTime repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self cleanMemory];
        _timeRepeatCount += 1;
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:_cleanTimer forMode:NSRunLoopCommonModes];
}


- (void)endObserving{
    [BANotificationCenter removeObserver:self];
    
    [_cleanTimer invalidate];
    _cleanTimer = nil;
}


- (void)bullet:(NSNotification *)sender{
    NSArray *bulletModelArray = sender.userInfo[BAUserInfoKeyBullet];
    
    [self caculate:bulletModelArray];
    [_bulletsArray addObjectsFromArray:bulletModelArray];
    _bulletsCount += 1;
}


- (void)cleanMemory{
    
    dispatch_async(self.analyzingQueue, ^{
      
        //只保留最新100个弹幕
        if (_bulletsArray.count > 100) {
            [_bulletsArray removeObjectsInRange:NSMakeRange(0, _bulletsArray.count - 100)];
        }
        
        //根据词出现的频次排序
        [_wordsArray sortUsingComparator:^NSComparisonResult(BAWordsModel *wordsModel1, BAWordsModel *wordsModel2) {
            return [wordsModel2.count compare:wordsModel1.count];
        }];
        //去掉排序500之后的词
        if (_wordsArray.count > 500) {
            [_wordsArray removeObjectsInRange:NSMakeRange(500, _wordsArray.count - 500)];
        }
        
        //根据用户发言的次数排序
        NSInteger params = 4;
        if ((double)_timeRepeatCount/params - _timeRepeatCount/params == 0) { //10秒处理一次用户/用户等级
            [_userArraySortedByCount sortUsingComparator:^NSComparisonResult(BAUserModel *userModel1, BAUserModel *userModel2) {
                return [userModel2.count compare:userModel1.count];
            }];
            
            //去掉发言数排名100名之后的人
            if (_userArraySortedByCount.count > 100) {
                [_userArraySortedByCount removeObjectsInRange:NSMakeRange(100, _userArraySortedByCount.count - 100)];
            }
            
            [_userArraySortedByCount sortUsingComparator:^NSComparisonResult(BAUserModel *userModel1, BAUserModel *userModel2) {
                return [userModel2.count compare:userModel1.count];
            }];
            
            //去掉发言数排名100名之后的人
            if (_userArraySortedByCount.count > 100) {
                [_userArraySortedByCount removeObjectsInRange:NSMakeRange(100, _userArraySortedByCount.count - 100)];
            }
            
            //根据等级排序, 次数组仅记录等级与数量之间的关系
            [_userArraySortedByLevel sortUsingComparator:^NSComparisonResult(BAUserModel *userModel1, BAUserModel *userModel2) {
                return [userModel2.level compare:userModel1.level];
            }];
        }
        
        params = 6;
        if ((double)_timeRepeatCount/params - _timeRepeatCount/params == 0) { //30秒处理弹幕数量
            
            BACountTimeModel *countTimeModel = [BACountTimeModel new];
            countTimeModel.count = BAStringWithInteger(_bulletsCount);
            countTimeModel.time = [NSDate date];
            
            [_countTimeArray addObject:countTimeModel];
            _bulletsCount = 0;
        }
    });
}


- (void)caculate:(NSArray *)bulletsArray{
    
    dispatch_async(self.analyzingQueue, ^{
        [bulletsArray enumerateObjectsUsingBlock:^(BABulletModel *bulletModel, NSUInteger idx, BOOL * _Nonnull stop1) {
            
            //分析单词
            [self analyzingWords:bulletModel];
            
            //分析发送人
            [self analyzingUser:bulletModel];
        }];
    });
}


- (void)analyzingWords:(BABulletModel *)bulletModel{
    
    NSArray *wordsArray = [self stringCutByJieba:bulletModel.txt];
    [wordsArray enumerateObjectsUsingBlock:^(NSString *words, NSUInteger idx, BOOL * _Nonnull stop2) {
        
        if (words.length > 1) { //筛选1个字的词
            
            __block BOOL contained = NO;
            [_wordsArray enumerateObjectsUsingBlock:^(BAWordsModel *wordsModel, NSUInteger idx, BOOL * _Nonnull stop3) {
                
                contained = [wordsModel.words isEqualToString:words];
                if (contained) {
                    *stop3 = YES;
                    wordsModel.count = BAStringWithInteger(wordsModel.count.integerValue + 1);
                }
            }];
            if (!contained) {
                BAWordsModel *newWordsModel = [BAWordsModel new];
                newWordsModel.words = words;
                newWordsModel.count = BAStringWithInteger(1);
                
                [_wordsArray addObject:newWordsModel];
            }
        }
    }];
}


- (void)analyzingUser:(BABulletModel *)bulletModel{
    
    __block BOOL contained1 = NO;
    [_userArraySortedByCount enumerateObjectsUsingBlock:^(BAUserModel *userModel, NSUInteger idx, BOOL * _Nonnull stop) {
       
        contained1 = [bulletModel.uid isEqualToString:userModel.uid];
        if (contained1) {
            *stop = YES;
            userModel.count = BAStringWithInteger(userModel.count.integerValue + 1);
        }
    }];
    
    if (!contained1) {
        [_userArraySortedByCount addObject:[BAUserModel userModelWithBullet:bulletModel]];
    }
    
    __block BOOL contained2 = NO;
    [_userArraySortedByLevel enumerateObjectsUsingBlock:^(BAUserModel *userModel, NSUInteger idx, BOOL * _Nonnull stop) {
    
        contained2 = [bulletModel.level isEqualToString:userModel.level];
        if (contained2) {
            *stop = YES;
            userModel.count = BAStringWithInteger(userModel.count.integerValue + 1);
        }
    }];
    
    if (!contained2) {
        [_userArraySortedByLevel addObject:[BAUserModel userModelWithBullet:bulletModel]];
    }
}


- (NSArray *)stringCutByJieba:(NSString *)string{
    
    const char* sentence = [string UTF8String];
    std::vector<std::string> words;
    JiebaCut(sentence, words);
    std::string result;
    result << words;
    
    NSString *relustString = [NSString stringWithUTF8String:result.c_str()].copy;
    
    relustString = [relustString stringByReplacingOccurrencesOfString:@"[" withString:@""];
    relustString = [relustString stringByReplacingOccurrencesOfString:@"]" withString:@""];
    relustString = [relustString stringByReplacingOccurrencesOfString:@" " withString:@""];
    relustString = [relustString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSArray *wordsArray = [relustString componentsSeparatedByString:@","];
    
    return wordsArray;
}


//        系统分词, 不好用
//- (NSArray *)stringTokenizerWithWord:(NSString *)word{
//
//    NSMutableArray *keyWords = [NSMutableArray new];
//    CFStringTokenizerRef ref = CFStringTokenizerCreate(NULL,  (__bridge CFStringRef)word, CFRangeMake(0, word.length), kCFStringTokenizerUnitWord, NULL);
//    CFRange range;
//    CFStringTokenizerAdvanceToNextToken(ref);
//    range = CFStringTokenizerGetCurrentTokenRange(ref);
//    
//    NSString *keyWord;
//    while (range.length > 0)  {
//        keyWord = [word substringWithRange:NSMakeRange(range.location, range.length)];
//        if (keyWord.length > 1) { //一个字一下的词全部过滤
//            [keyWords addObject:keyWord];
//        }
//        CFStringTokenizerAdvanceToNextToken(ref);
//        range = CFStringTokenizerGetCurrentTokenRange(ref);
//    }
//    
//    return keyWords;
//}


- (dispatch_queue_t)analyzingQueue{
    if (!_analyzingQueue) {
        _analyzingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return _analyzingQueue;
}


#pragma mark - dataLocolize
- (void)updateReportLocolized{
    
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        NSMutableArray *tempArray = [NSMutableArray array];
        BOOL open = [db open];
        if (open) {
            //创表(若无) 1.完成分析表
            NSString *execute1 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ integer primary key autoincrement, %@ Blob)", BACompletedReport, BAReportID, BAReportData];
            BOOL createCompletedReportTable = [db executeUpdate:execute1];
            if (createCompletedReportTable) {
                NSLog(@"completedReport创表成功");
            } else {
                NSLog(@"completedReport创表失败");
            }
            
            //未完成分析表
            NSString *execute2 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@ integer primary key autoincrement, %@ Blob)", BAAnalyzingReport, BAReportID, BAReportData];
            BOOL createAnalyzingReportTable = [db executeUpdate:execute2];
            if (createAnalyzingReportTable) {
                NSLog(@"AnalyzingReportTable创表成功");
            } else {
                NSLog(@"AnalyzingReportTable创表失败");
            }
            
            //先取出完成表来里的数据解档
            NSString *select1 = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC", BACompletedReport, BAReportID];
            FMResultSet *result1 = [db executeQuery:select1];
            while (result1.next) {
                NSData *reportData = [result1 dataForColumn:BAReportData];
                BAReportModel *reportModel = [NSKeyedUnarchiver unarchiveObjectWithData:reportData];
                
                [tempArray addObject:reportModel];
            }
            
            //再取出未完成表来里的数据解档
            NSString *select2 = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY %@ DESC", BAAnalyzingReport, BAReportID];
            FMResultSet *result2 = [db executeQuery:select2];
            while (result2.next) {
                
                NSData *reportData = [result2 dataForColumn:BAReportData];
                BAReportModel *reportModel = [NSKeyedUnarchiver unarchiveObjectWithData:reportData];
                
                [tempArray addObject:reportModel];
            }
            [db close];
        }
        _reportModelArray = tempArray;
    }];
}


- (void)saveReportLocolized{
    
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        BOOL open = [db open];
        if (open) {
            
            //判断是否为未完成分析表分别存入表单
            NSString *insert;
            if (_analyzingReportModel.isInterruptAnalyzing) {
                insert = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (?)", BAAnalyzingReport, BAReportData];
            } else {
                insert = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (?)", BACompletedReport, BAReportData];
            }
            NSData *reportData = [NSKeyedArchiver archivedDataWithRootObject:_analyzingReportModel];
            BOOL success = [db executeUpdate:insert, reportData];
            if (!success) {
                NSLog(@"储存失败");
            }
            [db close];
        }
    }];
}


#pragma mark - singleton
//单例类的静态实例对象，因对象需要唯一性，故只能是static类型
static BAAnalyzerCenter *defaultCenter = nil;

/**
 单例模式对外的唯一接口，用到的dispatch_once函数在一个应用程序内只会执行一次，且dispatch_once能确保线程安全
 */
+ (BAAnalyzerCenter *)defaultCenter{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (defaultCenter == nil) {
            defaultCenter = [[self alloc] init];
            
            //从本地取出报告
            NSString *filePath = [BAPathDocument stringByAppendingPathComponent:BAReportDatabase];
            defaultCenter.queue = [FMDatabaseQueue databaseQueueWithPath:filePath];
            [defaultCenter updateReportLocolized];
            
            NSString *dictPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/jieba.dict.small.utf8"];
            NSString *hmmPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/hmm_model.utf8"];
            NSString *userDictPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/user.dict.utf8"];
            
            NSLog(@"%@",dictPath);
            NSLog(@"%@",hmmPath);
            NSLog(@"%@",hmmPath);
            
            const char *cDictPath = [dictPath UTF8String];
            const char *cHmmPath = [hmmPath UTF8String];
            const char *cUserDictPath = [userDictPath UTF8String];
            
            JiebaInit(cDictPath, cHmmPath, cUserDictPath);
        }
    });
    return defaultCenter;
}

/**
 覆盖该方法主要确保当用户通过[[Singleton alloc] init]创建对象时对象的唯一性，alloc方法会调用该方法，只不过zone参数默认为nil，因该类覆盖了allocWithZone方法，所以只能通过其父类分配内存，即[super allocWithZone:zone]
 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (defaultCenter == nil) {
            defaultCenter = [super allocWithZone:zone];
        }
    });
    return defaultCenter;
}

//覆盖该方法主要确保当用户通过copy方法产生对象时对象的唯一性
- (id)copy{
    return self;
}

//覆盖该方法主要确保当用户通过mutableCopy方法产生对象时对象的唯一性
- (id)mutableCopy{
    return self;
}

@end
