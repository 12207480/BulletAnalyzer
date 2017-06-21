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
#import "BARoomModel.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "Segmentor.h"

static NSString *const BACompletedReport = @"completedReport"; //完成表
static NSString *const BAAnalyzingReport = @"AnalyzingReport"; //进行表
static NSString *const BAReportID = @"ID";  //ID
static NSString *const BAReportData = @"reportData"; //数据

@interface BAAnalyzerCenter()
@property (nonatomic, strong) FMDatabaseQueue *queue;   //子线程中操作数据库
@property (nonatomic, assign) dispatch_queue_t analyzingQueue; //用于计算的子线程

@property (nonatomic, strong) BAReportModel *analyzingReportModel; //正在分析的报告

@property (nonatomic, strong) NSMutableArray *bulletsArray; //弹幕数组 只保留前100个
@property (nonatomic, strong) NSMutableArray *wordsArray;   //单词数组 保留500个 频次低的不保留
@property (nonatomic, strong) NSMutableArray *userBulletCountArray;   //根据发言次数排序的用户数组 保留100个
@property (nonatomic, strong) NSMutableArray *levelCountArray;   //用户等级与数量关系的数组
@property (nonatomic, strong) NSMutableArray *countTimeArray;   //弹幕数量与时间关系的数组
@property (nonatomic, strong) BACountTimeModel *timeCountModel; //当前处理的时间有关模型
@property (nonatomic, strong) NSMutableArray *countTimePointArray; //弹幕数量与时间坐标数组
@property (nonatomic, strong) NSMutableArray *onlineTimePointArray; //在线数量与时间坐标数组
@property (nonatomic, strong) NSMutableArray *fansTimePointArray; //关注数量与时间坐标数组
@property (nonatomic, strong) NSMutableArray *levelCountPointArray; //等级与数量的坐标数组

@property (nonatomic, assign) NSInteger timeRepeatCount; //时钟重复次数
@property (nonatomic, assign) NSInteger bulletsCount;   //弹幕次数/在采样时间内

@end

@implementation BAAnalyzerCenter

#pragma mark - public
- (void)beginAnalyzing{
    _analyzing = YES;
    
    //传入报告则接着分析
    if (!_proceedReportModel) {
        //初始化各个数组
        _bulletsArray = [NSMutableArray array];
        _wordsArray = [NSMutableArray array];
        _userBulletCountArray = [NSMutableArray array];
        _countTimeArray = [NSMutableArray array];
        _countTimePointArray = [NSMutableArray array];
        _onlineTimePointArray = [NSMutableArray array];
        _fansTimePointArray = [NSMutableArray array];
        _levelCountPointArray = [NSMutableArray array];
        _levelCountArray = @[
                             @0, //0-10级
                             @0, //11-20级
                             @0, //21-30级
                             @0, //31-40级
                             @0, //41-50级
                             @0, //51-60级
                             @0, //61-70级
                             @0  //70级以上
                             ].mutableCopy;
        
        
        //初始化分析报告
        _analyzingReportModel = [BAReportModel new];
        _analyzingReportModel.bulletsArray = _bulletsArray;
        _analyzingReportModel.wordsArray = _wordsArray;
        _analyzingReportModel.userBulletCountArray = _userBulletCountArray;
        _analyzingReportModel.levelCountArray = _levelCountArray;
        _analyzingReportModel.countTimePointArray = _countTimePointArray;
        _analyzingReportModel.onlineTimePointArray = _onlineTimePointArray;
        _analyzingReportModel.fansTimePointArray = _fansTimePointArray;
        _analyzingReportModel.levelCountPointArray = _levelCountPointArray;
        _analyzingReportModel.maxActiveCount = 1;
        
        //传入开始分析时间
        _analyzingReportModel.begin = [NSDate date];
    } else {
        //获取继续分析模型
        _analyzingReportModel = _proceedReportModel;
        _analyzingReportModel.interruptAnalyzing = NO;
        _analyzingReportModel.proceed = [NSDate date];
        _proceedReportModel = nil;
       
        //接着分析
        _bulletsArray = _analyzingReportModel.bulletsArray;
        _wordsArray = _analyzingReportModel.wordsArray;
        _userBulletCountArray = _analyzingReportModel.userBulletCountArray;
        _levelCountArray = _analyzingReportModel.levelCountArray;
        _countTimeArray = _analyzingReportModel.countTimeArray;
        _countTimePointArray = _analyzingReportModel.countTimePointArray;
        _onlineTimePointArray = _analyzingReportModel.onlineTimePointArray;
        _fansTimePointArray = _analyzingReportModel.fansTimePointArray;
        _levelCountPointArray = _analyzingReportModel.levelCountPointArray;
    }
    
    [self beginObserving];

    //发出通知 开始分析
    [BANotificationCenter postNotificationName:BANotificationBeginAnalyzing object:nil userInfo:@{BAUserInfoKeyReportModel : _analyzingReportModel}];
}


- (void)interruptAnalyzing{
    _analyzing = NO;
    [self endObserving];
    
    //异常打断
    if (_analyzingReportModel) {
        _analyzingReportModel.interruptAnalyzing = YES;
        _analyzingReportModel.interrupt = [NSDate date];
        [_reportModelArray addObject:_analyzingReportModel];
        
        //存入本地
        [self saveReportLocolized];
    }
    
    [BANotificationCenter postNotificationName:BANotificationInterrupAnalyzing object:nil userInfo:@{BAUserInfoKeyReportModel : _analyzingReportModel}];
}


- (void)endAnalyzing{
    _analyzing = NO;
    [self endObserving];

    //停止分析
    if (_analyzingReportModel) {
        _analyzingReportModel.interruptAnalyzing = NO;
        _analyzingReportModel.end = [NSDate date];
        [_reportModelArray addObject:_analyzingReportModel];
        
        //存入本地
        [self saveReportLocolized];
    }
    
    if (_analyzingReportModel) {
        [BANotificationCenter postNotificationName:BANotificationEndAnalyzing object:nil userInfo:@{BAUserInfoKeyReportModel : _analyzingReportModel}];
    }
}


#pragma mark - private
- (void)beginObserving{
    [BANotificationCenter addObserver:self selector:@selector(bullet:) name:BANotificationBullet object:nil];
    [BANotificationCenter addObserver:self selector:@selector(gift:) name:BANotificationGift object:nil];
    
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


- (void)getRoomInfo{
    BAHttpParams *params = [BAHttpParams new];
    params.roomId = _analyzingReportModel.roomId;
    
    //获取房间信息
    [BAHttpTool getRoomInfoWithParams:params success:^(BARoomModel *roomModel) {
        
        _analyzingReportModel.fansCount = roomModel.fans_num;
        _analyzingReportModel.weight = roomModel.owner_weight;
        _analyzingReportModel.roomName = roomModel.room_name;
        _analyzingReportModel.name = roomModel.owner_name;
        _analyzingReportModel.avatar = roomModel.avatar;
        _analyzingReportModel.photo = roomModel.room_src;
        if (_timeCountModel) {
            //存入当前时刻粉丝数量, 主播体重, 在线人数
            _timeCountModel.fansCount = roomModel.fans_num;
            _timeCountModel.weight = roomModel.owner_weight;
            _timeCountModel.online = roomModel.online;
            //存入最大在线人数, 最小在线人数, 最大粉丝数量, 最小粉丝数量, 粉丝增长量
            _analyzingReportModel.maxOnlineCount = _analyzingReportModel.maxOnlineCount > roomModel.online.integerValue ? _analyzingReportModel.maxOnlineCount : roomModel.online.integerValue;
            _analyzingReportModel.minOnlineCount = _analyzingReportModel.minOnlineCount < roomModel.online.integerValue && _analyzingReportModel.minOnlineCount  ? _analyzingReportModel.minOnlineCount : roomModel.online.integerValue;
            _analyzingReportModel.maxFansCount = _analyzingReportModel.maxFansCount > roomModel.fans_num.integerValue ? _analyzingReportModel.maxFansCount : roomModel.fans_num.integerValue;
            _analyzingReportModel.minFansCount = _analyzingReportModel.minFansCount < roomModel.fans_num.integerValue && _analyzingReportModel.minFansCount ? _analyzingReportModel.minFansCount : roomModel.fans_num.integerValue;
            _analyzingReportModel.fansIncrese = _analyzingReportModel.maxFansCount - _analyzingReportModel.minFansCount;
            _timeCountModel = nil;
            
            //根据上面的数据计算在线人数, 粉丝数量绘图坐标数组
            [_onlineTimePointArray removeAllObjects];
            [_fansTimePointArray removeAllObjects];
            [_countTimeArray enumerateObjectsUsingBlock:^(BACountTimeModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CGPoint point1 = CGPointMake(BAFansReportDrawViewWidth * (CGFloat)idx / (_countTimeArray.count - 1), BAFansReportDrawViewHeight * (1 - ((CGFloat)(obj.online.integerValue - _analyzingReportModel.minOnlineCount) / (_analyzingReportModel.maxOnlineCount - _analyzingReportModel.minOnlineCount))));
                [_onlineTimePointArray addObject:[NSValue valueWithCGPoint:point1]];
                
                CGPoint point2 = CGPointMake(BAFansReportDrawViewWidth * (CGFloat)idx / (_countTimeArray.count - 1), BAFansReportDrawViewHeight * (1 - ((CGFloat)(obj.fansCount.integerValue - _analyzingReportModel.minFansCount) / (_analyzingReportModel.maxFansCount - _analyzingReportModel.minFansCount))));
                [_fansTimePointArray addObject:[NSValue valueWithCGPoint:point2]];
            }];
        }
    } fail:^(NSString *error) {
        NSLog(@"获取直播间详情失败");
    }];
}


- (void)gift:(NSNotification *)sender{
    //取出礼物
    NSArray *giftModelArray = sender.userInfo[BAUserInfoKeyGift];
    
    
}


- (void)bullet:(NSNotification *)sender{
    //取出弹幕
    NSArray *bulletModelArray = sender.userInfo[BAUserInfoKeyBullet];
    
    //分析弹幕
    [self caculate:bulletModelArray];
    
    //将弹幕加入公开的弹幕数组, 去除重复的弹幕
    [bulletModelArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![_bulletsArray containsObject:obj]) {
            [_bulletsArray addObject:obj];
            //记录新增弹幕数量
            _bulletsCount += 1;
        }
    }];
}


- (void)cleanMemory{
    
    dispatch_sync(self.analyzingQueue, ^{
      
        //只保留最新100个弹幕
        if (_bulletsArray.count > 200) {
            [_bulletsArray removeObjectsInRange:NSMakeRange(0, _bulletsArray.count - 100)];
        }
        
        //根据词出现的频次排序
        [_wordsArray sortUsingComparator:^NSComparisonResult(BAWordsModel *wordsModel1, BAWordsModel *wordsModel2) {
            return wordsModel1.count.integerValue > wordsModel2.count.integerValue ? NSOrderedAscending : NSOrderedDescending;
        }];
        //去掉排序400之后的词
        if (_wordsArray.count > 700) {
            [_wordsArray removeObjectsInRange:NSMakeRange(400, _wordsArray.count - 400)];
        }
        
        //根据用户发言的次数排序
        NSInteger params = 4;
        if ((double)_timeRepeatCount/params - _timeRepeatCount/params == 0) { //10秒处理一次用户/用户等级
            
            [_userBulletCountArray sortUsingComparator:^NSComparisonResult(BAUserModel *userModel1, BAUserModel *userModel2) {
                return userModel1.count.integerValue > userModel2.count.integerValue ? NSOrderedAscending : NSOrderedDescending;
            }];
            BAUserModel *userModel = [_userBulletCountArray firstObject];
            _analyzingReportModel.maxActiveCount = userModel.count.integerValue;
            
            //去掉发言数排名100名之后的人
            if (_userBulletCountArray.count > 200) {
                [_userBulletCountArray removeObjectsInRange:NSMakeRange(100, _userBulletCountArray.count - 100)];
            }
        }
        
        params = 6;
        if ((double)_timeRepeatCount/params - _timeRepeatCount/params == 0) { //30秒处理弹幕数量 以及当前观看人数 主播体重
            
            //新建弹幕信息与时间关系的模型
            BACountTimeModel *countTimeModel = [BACountTimeModel new];
            countTimeModel.count = BAStringWithInteger(_bulletsCount);
            countTimeModel.time = [NSDate date];
            
            _timeCountModel = countTimeModel;
            [self getRoomInfo];
            
            [_countTimeArray addObject:countTimeModel];
            
            //记录最大弹幕数字
            _analyzingReportModel.maxBulletCount = _bulletsCount > _analyzingReportModel.maxBulletCount ? _bulletsCount : _analyzingReportModel.maxBulletCount;
            
            //计算弹幕数量与时间的坐标
            CGFloat width = BAScreenWidth;
            CGFloat height = width;
            
            [_countTimePointArray removeAllObjects];
            [_countTimeArray enumerateObjectsUsingBlock:^(BACountTimeModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CGPoint point = CGPointMake(width * (CGFloat)idx / (_countTimeArray.count - 1), height * (1 - ((CGFloat)obj.count.integerValue / _analyzingReportModel.maxBulletCount)));
                [_countTimePointArray addObject:[NSValue valueWithCGPoint:point]];
            }];
            
            _bulletsCount = 0;
        }
    });
}


- (void)caculate:(NSArray *)bulletsArray{
    
    dispatch_sync(self.analyzingQueue, ^{
        [bulletsArray enumerateObjectsUsingBlock:^(BABulletModel *bulletModel, NSUInteger idx, BOOL * _Nonnull stop1) {
            
            if (!_analyzingReportModel.roomId.length) {
                _analyzingReportModel.roomId = bulletModel.rid;
                [self getRoomInfo];
            }
            
            //分析单词
            [self analyzingWords:bulletModel];
            
            //分析发送人
            [self analyzingUser:bulletModel];
        }];
    });
}


- (void)analyzingWords:(BABulletModel *)bulletModel{
    
    //结巴分词
    NSArray *wordsArray = [self stringCutByJieba:bulletModel.txt];
    [wordsArray enumerateObjectsUsingBlock:^(NSString *words, NSUInteger idx, BOOL * _Nonnull stop2) {
        
        if (![self isIgnore:words]) { //筛选
            
            //记录词的出现频率
            __block BOOL contained = NO;
            [_wordsArray enumerateObjectsUsingBlock:^(BAWordsModel *wordsModel, NSUInteger idx, BOOL * _Nonnull stop3) {
                
                contained = [wordsModel isEqual:words];
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


- (BOOL)isIgnore:(NSString *)string{
    //过滤小于2的词, 过滤表情
    return string.length < 2 || [string containsString:@"emot"] || [string containsString:@"dy"];
}


- (void)analyzingUser:(BABulletModel *)bulletModel{
    
    //记录用户发言次数
    __block BOOL contained1 = NO;
    [_userBulletCountArray enumerateObjectsUsingBlock:^(BAUserModel *userModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        contained1 = [bulletModel.uid isEqualToString:userModel.uid];
        if (contained1) {
            *stop = YES;
            userModel.count = BAStringWithInteger(userModel.count.integerValue + 1);
        }
    }];
    
    if (!contained1) {
        [_userBulletCountArray addObject:[BAUserModel userModelWithBullet:bulletModel]];
    }
  
    //记录用户等级分布
    if (bulletModel.level.integerValue <= 10) {
        _levelCountArray[0] = @([_levelCountArray[0] integerValue] + 1);
    } else if (bulletModel.level.integerValue <= 20) {
        _levelCountArray[1] = @([_levelCountArray[1] integerValue] + 1);
    } else if (bulletModel.level.integerValue <= 30) {
        _levelCountArray[2] = @([_levelCountArray[2] integerValue] + 1);
    } else if (bulletModel.level.integerValue <= 40) {
        _levelCountArray[3] = @([_levelCountArray[3] integerValue] + 1);
    } else if (bulletModel.level.integerValue <= 50) {
        _levelCountArray[4] = @([_levelCountArray[4] integerValue] + 1);
    } else if (bulletModel.level.integerValue <= 60) {
        _levelCountArray[5] = @([_levelCountArray[5] integerValue] + 1);
    } else if (bulletModel.level.integerValue <= 70) {
        _levelCountArray[6] = @([_levelCountArray[6] integerValue] + 1);
    } else {
        _levelCountArray[7] = @([_levelCountArray[7] integerValue] + 1);
    }
    
    //计算总等级以及总用户量, 用以计算平均等级
    _analyzingReportModel.levelSum += bulletModel.level.integerValue;
    _analyzingReportModel.levelCount += 1;
    
    //计算等级分布图的坐标
    [_levelCountPointArray removeAllObjects];
    NSInteger maxLevelCount = [[_levelCountArray valueForKeyPath:@"@max.integerValue"] integerValue];
    [_levelCountArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGPoint point = CGPointMake(BAFansReportDrawViewWidth * (CGFloat)idx / (_levelCountArray.count - 1), BAFansReportDrawViewHeight * (1 - ((CGFloat)obj.integerValue / maxLevelCount)));
        [_levelCountPointArray addObject:[NSValue valueWithCGPoint:point]];
    }];
}


- (NSArray *)stringCutByJieba:(NSString *)string{
    
    //结巴分词, 转为词数组
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


- (dispatch_queue_t)analyzingQueue{
    //用来计算的子线程
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
        
        [BANotificationCenter postNotificationName:BANotificationUpdateReporsComplete object:nil userInfo:@{BAUserInfoKeyReportModelArray : _reportModelArray}];
    }];
}


- (void)saveReportLocolized{
    //存入本地
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
