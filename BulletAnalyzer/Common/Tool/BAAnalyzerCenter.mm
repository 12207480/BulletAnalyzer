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
#import "BAGiftModel.h"
#import "BAGiftValueModel.h"
#import "BAWordsModel.h"
#import "BASentenceModel.h"
#import "BAUserModel.h"
#import "BACountTimeModel.h"
#import "BARoomModel.h"
#import "Segmentor.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

static NSString *const BACompletedReport = @"completedReport"; //完成表
static NSString *const BAAnalyzingReport = @"AnalyzingReport"; //进行表
static NSString *const BAReportID = @"reportID";  //ID
static NSString *const BAReportData = @"reportData"; //数据
static NSString *const BANotice = @"notice"; //关注表
static NSString *const BANoticeData = @"noticeData"; //关注表数据
static NSString *const BAUserIngnore = @"userIngnore"; //屏蔽表
static NSString *const BAUserIngnoreData = @"userIngnoreData"; //屏蔽表数据
static NSString *const BAWordsIngnore = @"wordsIngnore"; //关键词屏蔽表
static NSString *const BAWordsIngnoreData = @"wordsIngnoreData"; //关键词屏蔽表数据
static NSString *const BASearchHistory = @"searchHistory"; //搜索历史表
static NSString *const BASearchHistoryData = @"searchHistoryData"; //搜索历史表数据

@interface BAAnalyzerCenter()
@property (nonatomic, strong) FMDatabaseQueue *dataBaseQueue;
@property (nonatomic, assign) dispatch_queue_t analyzingQueue; //用于计算的子线程

@property (nonatomic, strong) BAReportModel *analyzingReportModel; //正在分析的报告

@property (nonatomic, strong) NSMutableArray *bulletsArray; //弹幕数组 只保留前100个
@property (nonatomic, strong) NSMutableArray *wordsArray;   //单词数组 保留500个 频次低的不保留
@property (nonatomic, strong) NSMutableArray *userBulletCountArray;   //根据发言次数排序的用户数组 保留50个
@property (nonatomic, strong) NSMutableArray *levelCountArray;   //用户等级与数量关系的数组
@property (nonatomic, strong) NSMutableArray *countTimeArray;   //弹幕数量与时间关系的数组
@property (nonatomic, strong) BACountTimeModel *timeCountModel; //当前处理的时间有关模型
@property (nonatomic, strong) NSMutableArray *countTimePointArray; //弹幕数量与时间坐标数组
@property (nonatomic, strong) NSMutableArray *onlineTimePointArray; //在线数量与时间坐标数组
@property (nonatomic, strong) NSMutableArray *fansTimePointArray; //关注数量与时间坐标数组
@property (nonatomic, strong) NSMutableArray *levelCountPointArray; //等级与数量的坐标数组

@property (nonatomic, strong) NSMutableArray *giftsArray; //全部礼物
@property (nonatomic, strong) NSMutableArray *userFishBallCountArray; //根据赠送鱼丸数的用户数组
@property (nonatomic, strong) NSMutableArray *giftValueArray; //礼物价值分布数组
@property (nonatomic, strong) NSMutableArray *giftUserBulletArray; //送礼物的人弹幕的数组

@property (nonatomic, strong) NSMutableArray *sentenceArray; //根据词频 余弦夹角算出来的近似度句子
@property (nonatomic, strong) NSMutableArray *popSentenceArray; //提到最多的句子 保留30条
@property (nonatomic, assign) CGFloat similarity; //相似度高于于此值的句子会被合并 默认0.7

@property (nonatomic, assign) NSInteger timeRepeatCount; //时钟重复次数
@property (nonatomic, assign) NSInteger bulletsCount;   //弹幕次数/在采样时间内
@property (nonatomic, assign) CGFloat repeatTime; //单词重复时间

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
                             @0, //0-5级
                             @0, //6-10级
                             @0, //11-15级
                             @0, //16-20级
                             @0, //21-25级
                             @0, //26-30级
                             @0, //31-35级
                             @0  //35级以上
                             ].mutableCopy;
        
        //初始化礼物数组
        _giftsArray = [NSMutableArray array];
        _userFishBallCountArray = [NSMutableArray array];
        _giftValueArray = [NSMutableArray array];
        _giftUserBulletArray = [NSMutableArray array];
        
        //初始化近似度计算的句子
        _sentenceArray = [NSMutableArray array];
        _popSentenceArray = [NSMutableArray array];
        
        for (NSInteger i = 1; i <= 8; i++) {
            BAGiftValueModel *giftValueModel = [BAGiftValueModel new];
            giftValueModel.giftType = (BAGiftType)i;
            [_giftValueArray addObject:giftValueModel];
        }
        
        //初始化分析报告
        _analyzingReportModel = [BAReportModel new];
        _analyzingReportModel.bulletsArray = _bulletsArray;
        _analyzingReportModel.wordsArray = _wordsArray;
        _analyzingReportModel.userBulletCountArray = _userBulletCountArray;
        _analyzingReportModel.levelCountArray = _levelCountArray;
        _analyzingReportModel.countTimeArray = _countTimeArray;
        _analyzingReportModel.countTimePointArray = _countTimePointArray;
        _analyzingReportModel.onlineTimePointArray = _onlineTimePointArray;
        _analyzingReportModel.fansTimePointArray = _fansTimePointArray;
        _analyzingReportModel.levelCountPointArray = _levelCountPointArray;
        _analyzingReportModel.maxActiveCount = 1;
        _analyzingReportModel.timeID = (NSInteger)[[NSDate date] timeIntervalSince1970];
        
        _analyzingReportModel.giftsArray = _giftsArray;
        _analyzingReportModel.userFishBallCountArray = _userFishBallCountArray;
        _analyzingReportModel.giftValueArray = _giftValueArray;
        _analyzingReportModel.giftUserBulletArry = _giftUserBulletArray;
        
        _analyzingReportModel.sentenceArray = _sentenceArray;
        _analyzingReportModel.popSentenceArray = _popSentenceArray;
        
        //传入开始分析时间
        _analyzingReportModel.begin = [NSDate date];
    } else {
        //从继续分析表中删除
        [self delReport:_analyzingReportModel];
        
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
        
        _giftsArray = _analyzingReportModel.giftsArray;
        _userFishBallCountArray = _analyzingReportModel.userFishBallCountArray;
        _giftValueArray = _analyzingReportModel.giftValueArray;
        _giftUserBulletArray = _analyzingReportModel.giftUserBulletArry;
        
        _sentenceArray = _analyzingReportModel.sentenceArray;
        _popSentenceArray = _analyzingReportModel.popSentenceArray;
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
        
        //存入本地(分析三分钟以上的报告)
        if (_analyzingReportModel.duration > 3) {
            [_reportModelArray addObject:_analyzingReportModel];
            [self saveReportLocolized];
        }
    }
    
    if (_analyzingReportModel) {
        [BANotificationCenter postNotificationName:BANotificationEndAnalyzing object:nil userInfo:@{BAUserInfoKeyReportModel : _analyzingReportModel}];
    }
}


#pragma mark - private
/**
 开始获取礼物/弹幕并计算
 */
- (void)beginObserving{
    [BANotificationCenter addObserver:self selector:@selector(bullet:) name:BANotificationBullet object:nil];
    [BANotificationCenter addObserver:self selector:@selector(gift:) name:BANotificationGift object:nil];
    
    [_cleanTimer invalidate];
    _cleanTimer = nil;
    if (!_repeatTime) {
        _repeatTime = 1.f; //默认5秒释放一次弹幕
    }

    _cleanTimer = [NSTimer scheduledTimerWithTimeInterval:_repeatTime target:self selector:@selector(sortData) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_cleanTimer forMode:NSRunLoopCommonModes];
}


/**
 停止获取礼物/弹幕,停止计算
 */
- (void)endObserving{
    [BANotificationCenter removeObserver:self];
    
    [_noticeArray removeAllObjects];
    [_cleanTimer invalidate];
    _cleanTimer = nil;
}


#pragma mark - roomAnalyzer
/**
 每30秒获取一次房间信息
 */
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
            [_countTimeArray.copy enumerateObjectsUsingBlock:^(BACountTimeModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CGPoint point1 = CGPointMake(BAReportFansChartPartWidth * (CGFloat)idx / (_countTimeArray.count - 1), BAReportFansChartPartHeight * (1 - ((CGFloat)(obj.online.integerValue - _analyzingReportModel.minOnlineCount) / (_analyzingReportModel.maxOnlineCount - _analyzingReportModel.minOnlineCount))));
                [_onlineTimePointArray addObject:[NSValue valueWithCGPoint:point1]];
                
                CGPoint point2 = CGPointMake(BAReportFansChartPartWidth * (CGFloat)idx / (_countTimeArray.count - 1), BAReportFansChartPartHeight * (1 - ((CGFloat)(obj.fansCount.integerValue - _analyzingReportModel.minFansCount) / (_analyzingReportModel.maxFansCount - _analyzingReportModel.minFansCount))));
                [_fansTimePointArray addObject:[NSValue valueWithCGPoint:point2]];
            }];
        }
    } fail:^(NSString *error) {
        NSLog(@"获取直播间详情失败");
    }];
}


#pragma mark - GCD
/**
 常驻线程, 避免反复创建消耗性能
 */
- (dispatch_queue_t)analyzingQueue{
    //用来计算的子线程
    if (!_analyzingQueue) {
        _analyzingQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return _analyzingQueue;
}


/**
 异步任务
 */
- (void)dispatch_block:(dispatch_block_t)block{
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_block_t semaphoreBlock = ^{
    
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        block();
        
        dispatch_semaphore_signal(semaphore);
    };
    
    dispatch_async(self.analyzingQueue, semaphoreBlock);
}


#pragma mark - giftAnalyzer
/**
 获取到礼物
 */
- (void)gift:(NSNotification *)sender{
    //取出礼物
    NSArray *giftModelArray = sender.userInfo[BAUserInfoKeyGift];
    
    [self giftClassify:giftModelArray];
    
    [_giftsArray addObjectsFromArray:giftModelArray];
}


/**
 礼物分类
 */
- (void)giftClassify:(NSArray *)giftModelArray{
    
    [self dispatch_block:^{
        
        [giftModelArray enumerateObjectsUsingBlock:^(BAGiftModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            switch (obj.giftType) {
                case BAGiftTypeFishBall:
                    
                    [self dealWithFishBall:obj];
                    
                    break;
                    
                case BAGiftTypeFreeGift:
                {
                    BAGiftValueModel *giftValue = _giftValueArray[0];
                    [self dealWithGift:obj giftValue:giftValue];
                    break;
                }
                case BAGiftTypeCostGift:
                {
                    BAGiftValueModel *giftValue = _giftValueArray[1];
                    [self dealWithGift:obj giftValue:giftValue];
                    
                    break;
                }
                case BAGiftTypeDeserveLevel1:
                {
                    BAGiftValueModel *giftValue = _giftValueArray[2];
                    [self dealWithGift:obj giftValue:giftValue];
                    
                    break;
                }
                case BAGiftTypeDeserveLevel2:
                {
                    BAGiftValueModel *giftValue = _giftValueArray[3];
                    [self dealWithGift:obj giftValue:giftValue];
                    
                    break;
                }
                case BAGiftTypeDeserveLevel3:
                {
                    BAGiftValueModel *giftValue = _giftValueArray[4];
                    [self dealWithGift:obj giftValue:giftValue];
                    
                    break;
                }
                case BAGiftTypeCard:
                {
                    BAGiftValueModel *giftValue = _giftValueArray[5];
                    [self dealWithGift:obj giftValue:giftValue];
                    
                    break;
                }
                case BAGiftTypePlane:
                {
                    BAGiftValueModel *giftValue = _giftValueArray[6];
                    [self dealWithGift:obj giftValue:giftValue];
                    
                    break;
                }
                case BAGiftTypeRocket:
                {
                    BAGiftValueModel *giftValue = _giftValueArray[7];
                    [self dealWithGift:obj giftValue:giftValue];
                    
                    break;
                }
                default:
                    
                    break;
            }
        }];
    }];
}


/**
 处理鱼丸礼物
 */
- (void)dealWithFishBall:(BAGiftModel *)fishBall{

    //送鱼丸次数
    __block BOOL contained = NO;
    [_userFishBallCountArray.copy enumerateObjectsUsingBlock:^(BAUserModel *userModel, NSUInteger idx, BOOL * _Nonnull stop3) {
        
        contained = [fishBall isEqual:userModel];
        if (contained) {
            *stop3 = YES;
            userModel.fishBallCount = BAStringWithInteger(userModel.fishBallCount.integerValue + 1);
        }
    }];
    if (!contained) {
        BAUserModel *newUserModel = [BAUserModel userModelWithGift:fishBall];
        [_userFishBallCountArray addObject:newUserModel];
    }
}


/**
 处理其他礼物
 */
- (void)dealWithGift:(BAGiftModel *)giftModel giftValue:(BAGiftValueModel *)giftValue{
    
    __block BOOL contained = NO;
    [giftValue.userModelArray enumerateObjectsUsingBlock:^(BAUserModel *userModel, NSUInteger idx, BOOL * _Nonnull stop3) {
        
        contained = [giftModel isEqual:userModel];
        if (contained) {
            *stop3 = YES;
            userModel.giftCount = BAStringWithInteger(userModel.giftCount.integerValue + 1); //用户礼物计数器+1
        }
    }];
    if (!contained) {
        BAUserModel *newUserModel = [BAUserModel userModelWithGift:giftModel];
        [giftValue.userModelArray addObject:newUserModel];
    }
}


#pragma mark - bulletAnalyzer
/**
 获取到弹幕
 */
- (void)bullet:(NSNotification *)sender{
    //取出弹幕
    NSArray *bulletModelArray = sender.userInfo[BAUserInfoKeyBullet];
    
    //分析弹幕
    [self bulletClassify:bulletModelArray];
    
    //将弹幕加入公开的弹幕数组, 去除重复的弹幕
    [bulletModelArray enumerateObjectsUsingBlock:^(BABulletModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![_bulletsArray containsObject:obj]) {

            [_bulletsArray addObject:obj];
            //记录新增弹幕数量
            _bulletsCount += 1;
            _analyzingReportModel.totalBulletCount += 1;
        }
    }];
}


/**
 对弹幕进行分类处理
 */
- (void)bulletClassify:(NSArray *)bulletsArray{
    
    [bulletsArray enumerateObjectsUsingBlock:^(BABulletModel *bulletModel, NSUInteger idx, BOOL * _Nonnull stop1) {
        
        if (!_analyzingReportModel.roomId.length) {
            _analyzingReportModel.roomId = bulletModel.rid;
            [self getRoomInfo];
        }
        
        //分析单词及语义
        [self analyzingWords:bulletModel];
        
        //分析发送人
        [self analyzingUser:bulletModel];
    }];
}


/**
 词义分析/句子分析
 */
- (void)analyzingWords:(BABulletModel *)bulletModel{
    
    [self dispatch_block:^{
        
        //结巴分词
        NSArray *wordsArray = [self stringCutByJieba:bulletModel.txt];
        
        //词频计算
        [self caculateWords:wordsArray bullet:bulletModel];
        
        //语义分析
        //忽略纯数字
        if ([self isSentenceIgnore:bulletModel.txt]) return;
        
        //构造一个句子对象
        BASentenceModel *newSentence = [BASentenceModel sentenceWithText:bulletModel.txt words:wordsArray.copy];
        
        //dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        //将句子与之前每一个句子进行对比
        __block BOOL similar = NO;
        [_sentenceArray.copy enumerateObjectsUsingBlock:^(BASentenceModel *sentence, NSUInteger idx, BOOL * _Nonnull stop) {
            
            CGFloat percent = [self similarityPercentWithSentenceA:sentence sentenceB:newSentence];
            
            if (percent > self.similarity) { //7成相似 则合并
                *stop = YES;
                similar = YES;
                sentence.count += 1;
                sentence.realCount += 1;
            }
        }];
        
        //若没有相似度高的句子则添加容器 并新增
        if (!similar) {
            newSentence.container = _sentenceArray;
            [_sentenceArray addObject:newSentence];
            [_popSentenceArray addObject:newSentence];
        }
    }];
}


/**
 词频分析
 */
- (void)caculateWords:(NSArray *)wordsArray bullet:(BABulletModel *)bulletModel{
    
    [self dispatch_block:^{
        
        //词频分析
        [wordsArray enumerateObjectsUsingBlock:^(NSString *words, NSUInteger idx, BOOL * _Nonnull stop2) {
            
            if (![self isIgnore:words]) { //筛选
                
                //记录词的出现频率
                __block BOOL contained = NO;
                [_wordsArray.copy enumerateObjectsUsingBlock:^(BAWordsModel *wordsModel, NSUInteger idx, BOOL * _Nonnull stop3) {
                    
                    contained = [wordsModel isEqual:words];
                    if (contained) {
                        *stop3 = YES;
                        wordsModel.count = BAStringWithInteger(wordsModel.count.integerValue + 1);
                        [wordsModel.bulletArray addObject:bulletModel];
                    }
                }];
                if (!contained) {
                    BAWordsModel *newWordsModel = [BAWordsModel new];
                    newWordsModel.words = words;
                    newWordsModel.count = BAStringWithInteger(1);
                    newWordsModel.bulletArray = [NSMutableArray array];
                    [newWordsModel.bulletArray addObject:bulletModel];
                    
                    [_wordsArray addObject:newWordsModel];
                }
            }
        }];
    }];
}


/**
 特殊过滤词语
  */
- (BOOL)isIgnore:(NSString *)string{
    //过滤小于2的词, 过滤表情
    return string.length < 2 || [string containsString:@"emot"] || [string containsString:@"dy"] || [string isEqualToString:@"666"];
}


/**
 忽略纯数字句子
 */
- (NSInteger)isSentenceIgnore:(NSString *)string{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(string.length > 0) {
        return NO;
    }
    return YES;
}


/**
 结巴分词
 */
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


/**
 余弦夹角算法计算句子近似度
 */
- (CGFloat)similarityPercentWithSentenceA:(BASentenceModel *)sentenceA sentenceB:(BASentenceModel *)sentenceB{
    //计算余弦角度
    //两个向量内积
    //两个向量模长乘积
    __block NSInteger A = 0; //两个向量内积
    __block NSInteger B = 0; //第一个句子的模长乘积的平方
    __block NSInteger C = 0; //第二个句子的模长乘积的平方
    [sentenceA.wordsDic enumerateKeysAndObjectsUsingBlock:^(NSString *key1, NSNumber *value1, BOOL * _Nonnull stop) {
        
        NSNumber *value2 = [sentenceB.wordsDic objectForKey:key1];
        if (value2.integerValue) {
            A += (value1.integerValue * value2.integerValue);
        }
        
        B += value1.integerValue * value1.integerValue;
    }];
    
    [sentenceB.wordsDic enumerateKeysAndObjectsUsingBlock:^(NSString *key2, NSNumber *value2, BOOL * _Nonnull stop) {
        
        C += value2.integerValue * value2.integerValue;
    }];
    
    CGFloat percent = A / (sqrt(B) * sqrt(C));
   
    return percent;
}


//编辑距离分析法 中文不精确, 暂时未使用
//- (CGFloat)similarPercentWithStringA:(NSString *)stringA andStringB:(NSString *)stringB{
//    NSInteger n = stringA.length;
//    NSInteger m = stringB.length;
//    if (m == 0 || n == 0) return 0;
//
//    //Construct a matrix, need C99 support
//    NSInteger matrix[n + 1][m + 1];
//    memset(&matrix[0], 0, m + 1);
//    for(NSInteger i=1; i<=n; i++) {
//        memset(&matrix[i], 0, m + 1);
//        matrix[i][0] = i;
//    }
//    for(NSInteger i = 1; i <= m; i++) {
//        matrix[0][i] = i;
//    }
//    for(NSInteger i = 1; i <= n; i++) {
//        unichar si = [stringA characterAtIndex:i - 1];
//        for(NSInteger j = 1; j <= m; j++) {
//            unichar dj = [stringB characterAtIndex:j-1];
//            NSInteger cost;
//            if(si == dj){
//                cost = 0;
//            } else {
//                cost = 1;
//            }
//            const NSInteger above = matrix[i - 1][j] + 1;
//            const NSInteger left = matrix[i][j - 1] + 1;
//            const NSInteger diag = matrix[i - 1][j - 1] + cost;
//            matrix[i][j] = MIN(above, MIN(left, diag));
//        }
//    }
//
//    CGFloat percent = 1.0 - (CGFloat)matrix[n][m] / stringA.length;
//    if (percent > 1) {
//        percent = 0;
//    }
//
//    return MAX(percent, 0);
//}

#pragma mark - userAnalyzer
/**
 根据弹幕信息分析用户数据
 */
- (void)analyzingUser:(BABulletModel *)bulletModel{
    
    [self dispatch_block:^{
        
        //记录用户发言次数
        __block BOOL contained1 = NO;
        [_userBulletCountArray.copy enumerateObjectsUsingBlock:^(BAUserModel *userModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
            contained1 = [bulletModel.uid isEqualToString:userModel.uid];
            if (contained1) {
                *stop = YES;
                userModel.count = BAStringWithInteger(userModel.count.integerValue + 1);
                [userModel.bulletArray addObject:bulletModel];
            }
        }];
        
        if (!contained1) {
            BAUserModel *userModel = [BAUserModel userModelWithBullet:bulletModel];
            [userModel.bulletArray addObject:bulletModel];
            
            [_userBulletCountArray addObject:userModel];
        }
        
        //记录用户发言(鱼丸)
        [_userBulletCountArray.copy enumerateObjectsUsingBlock:^(BAUserModel *userModel, NSUInteger idx, BOOL * _Nonnull stop) {
            
            BOOL contained = [bulletModel.uid isEqualToString:userModel.uid];
            if (contained) {
                *stop = YES;
                [userModel.bulletArray addObject:bulletModel];
            } else {
                *stop = idx == 49;
            }
        }];
        
        //记录用户发言(礼物)
        [_giftValueArray.copy enumerateObjectsUsingBlock:^(BAGiftValueModel *giftValueModel, NSUInteger idx1, BOOL * _Nonnull stop1) {
            
            NSArray *userModelArrayTemp = [NSArray arrayWithArray:giftValueModel.userModelArray];
            [userModelArrayTemp enumerateObjectsUsingBlock:^(BAUserModel *userModel, NSUInteger idx2, BOOL * _Nonnull stop2) {
                
                BOOL contained = [bulletModel.uid isEqualToString:userModel.uid];
                if (contained) {
                    *stop2 = YES;
                    [userModel.bulletArray addObject:bulletModel];
                } else {
                    *stop2 = idx2 == 49;
                }
            }];
        }];
        
        //记录用户等级分布
        if (bulletModel.level.integerValue <= 5) {
            _levelCountArray[0] = @([_levelCountArray[0] integerValue] + 1);
        } else if (bulletModel.level.integerValue <= 10) {
            _levelCountArray[1] = @([_levelCountArray[1] integerValue] + 1);
        } else if (bulletModel.level.integerValue <= 15) {
            _levelCountArray[2] = @([_levelCountArray[2] integerValue] + 1);
        } else if (bulletModel.level.integerValue <= 20) {
            _levelCountArray[3] = @([_levelCountArray[3] integerValue] + 1);
        } else if (bulletModel.level.integerValue <= 25) {
            _levelCountArray[4] = @([_levelCountArray[4] integerValue] + 1);
        } else if (bulletModel.level.integerValue <= 30) {
            _levelCountArray[5] = @([_levelCountArray[5] integerValue] + 1);
        } else if (bulletModel.level.integerValue <= 35) {
            _levelCountArray[6] = @([_levelCountArray[6] integerValue] + 1);
        } else {
            _levelCountArray[7] = @([_levelCountArray[7] integerValue] + 1);
        }
        
        //计算总等级以及总用户量, 用以计算平均等级
        _analyzingReportModel.levelSum += bulletModel.level.integerValue;
        _analyzingReportModel.levelCount += 1;
    }];
}


/**
 计算等级分布曲线
 */
- (void)caculateLevelPoint{
    //计算等级分布图的坐标
    NSMutableArray *tempCountPointArray = [NSMutableArray array];
    NSInteger maxLevelCount = [[_levelCountArray valueForKeyPath:@"@max.integerValue"] integerValue];
    
    [_levelCountArray.copy enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGPoint point = CGPointMake(BAReportFansChartPartWidth * (CGFloat)idx / (_levelCountArray.count - 1), BAReportFansChartPartHeight * (1 - ((CGFloat)obj.integerValue / maxLevelCount)));
        [tempCountPointArray addObject:[NSValue valueWithCGPoint:point]];
    }];
    
    if (_levelCountArray.count) {
        [_levelCountPointArray removeAllObjects];
    }
    [_levelCountPointArray addObjectsFromArray:tempCountPointArray];
}


#pragma mark - sort
/**
 按间隔整理数据
 */
- (void)sortData{
    
    _timeRepeatCount += 1;
    [self dispatch_block:^{
        
        //根据用户发言的次数排序
        NSInteger params = 5;
        if ((CGFloat)_timeRepeatCount/params - _timeRepeatCount/params == 0) { //5秒处理一次用户/用户等级/句子/鱼丸/其他礼物
        
            //只保留最新100个弹幕
            if (_bulletsArray.count > 300) {
                [_bulletsArray removeObjectsInRange:NSMakeRange(0, _bulletsArray.count - 100)];
            }
            
            //根据词出现的频次排序
            [_wordsArray sortUsingComparator:^NSComparisonResult(BAWordsModel *wordsModel1, BAWordsModel *wordsModel2) {
                return wordsModel1.count.integerValue > wordsModel2.count.integerValue ? NSOrderedAscending : NSOrderedDescending;
            }];
            //去掉排序400之后的词
            if (_wordsArray.count > 800) {
                [_wordsArray removeObjectsInRange:NSMakeRange(200, _wordsArray.count - 200)];
            }
            
            //赠送鱼丸排序
            [_userFishBallCountArray sortUsingComparator:^NSComparisonResult(BAUserModel *userModel1, BAUserModel *userModel2) {
                return userModel1.fishBallCount.integerValue > userModel2.fishBallCount.integerValue ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            //去掉排名50后的
            if (_userFishBallCountArray.count > 400) {
                [_userFishBallCountArray removeObjectsInRange:NSMakeRange(50, _userFishBallCountArray.count - 50)];
            }
            
            //礼物赠送数量排序
            for (BAGiftValueModel *giftValueModel in _giftValueArray) {
                
                [giftValueModel.userModelArray sortUsingComparator:^NSComparisonResult(BAUserModel *userModel1, BAUserModel *userModel2) {
                    return userModel1.giftCount.integerValue > userModel2.giftCount.integerValue ? NSOrderedAscending : NSOrderedDescending;
                }];
                
                if (giftValueModel.userModelArray.count > 200) {
                    [giftValueModel.userModelArray removeObjectsInRange:NSMakeRange(50, giftValueModel.userModelArray.count - 50)];
                }
            }
        }
        
        //根据用户发言的次数排序
        params = 10;
        if ((CGFloat)_timeRepeatCount/params - _timeRepeatCount/params == 0) { //20秒处理一次用户/用户等级
            
            [_userBulletCountArray sortUsingComparator:^NSComparisonResult(BAUserModel *userModel1, BAUserModel *userModel2) {
                return userModel1.count.integerValue > userModel2.count.integerValue ? NSOrderedAscending : NSOrderedDescending;
            }];
            BAUserModel *userModel = [_userBulletCountArray firstObject];
            _analyzingReportModel.maxActiveCount = userModel.count.integerValue;
            
            //去掉发言数排名50名之后的人
            if (_userBulletCountArray.count > 500) {
                [_userBulletCountArray removeObjectsInRange:NSMakeRange(50, _userBulletCountArray.count - 50)];
            }
            
            //句子数量全部减一
            [_sentenceArray sortUsingComparator:^NSComparisonResult(BASentenceModel *obj1, BASentenceModel *obj2) {
                return obj1.count > obj2.count ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            [_sentenceArray enumerateObjectsUsingBlock:^(BASentenceModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj decrease];
            }];
            
            //说的多的句子排名 保留30个
            [_popSentenceArray sortUsingComparator:^NSComparisonResult(BASentenceModel *obj1, BASentenceModel *obj2) {
                return obj1.realCount > obj2.realCount ? NSOrderedAscending : NSOrderedDescending;
            }];
            if (_popSentenceArray.count > 50) {
                [_popSentenceArray removeObjectsInRange:NSMakeRange(30, _popSentenceArray.count - 30)];
            }
        }
        
        params = 20;
        if ((CGFloat)_timeRepeatCount/params - _timeRepeatCount/params == 0) { //30秒处理弹幕数量 以及当前观看人数 主播体重 等级分布
            
            //新建弹幕信息与时间关系的模型
            BACountTimeModel *countTimeModel = [BACountTimeModel new];
            countTimeModel.count = BAStringWithInteger(_bulletsCount);
            countTimeModel.time = [NSDate date];
            
            _timeCountModel = countTimeModel;
            [self getRoomInfo];
            [self caculateLevelPoint];
            
            [_countTimeArray addObject:countTimeModel];
            
            //记录最大弹幕数字
            _analyzingReportModel.maxBulletCount = _bulletsCount > _analyzingReportModel.maxBulletCount ? _bulletsCount : _analyzingReportModel.maxBulletCount;
            
            //计算弹幕数量与时间的坐标
            
            [_countTimePointArray removeAllObjects];
            [_countTimeArray.copy enumerateObjectsUsingBlock:^(BACountTimeModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                CGPoint point = CGPointMake(BAReportCountChartWidth * (CGFloat)idx / (_countTimeArray.count - 1), BAReportCountChartHeight * (1 - ((CGFloat)obj.count.integerValue / _analyzingReportModel.maxBulletCount)));
                [_countTimePointArray addObject:[NSValue valueWithCGPoint:point]];
            }];
            
            _bulletsCount = 0;
        }
    }];
}


#pragma mark - dataLocolize
/**
 从本地数据库取出报告
 */
- (void)updateReportLocolized{
    
    [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        NSMutableArray *tempArray = [NSMutableArray array];
        NSMutableArray *searchHistoryTempArray = [NSMutableArray array];
        //NSMutableArray *noticeTempArray;
        NSMutableArray *userIgnoreTempArray;
        NSMutableArray *wordsIgnoreTempArray;
        BOOL open = [db open];
        if (open) {
            //创表(若无) 1.完成分析表
            NSString *execute1 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID integer primary key autoincrement, %@ integer, %@ Blob)", BACompletedReport, BAReportID, BAReportData];
            BOOL createCompletedReportTable = [db executeUpdate:execute1];
            if (createCompletedReportTable) {
                NSLog(@"completedReport创表成功");
            } else {
                NSLog(@"completedReport创表失败");
            }
            
            //未完成分析表
            NSString *execute2 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID integer primary key autoincrement, %@ integer, %@ Blob)", BAAnalyzingReport, BAReportID, BAReportData];
            BOOL createAnalyzingReportTable = [db executeUpdate:execute2];
            if (createAnalyzingReportTable) {
                NSLog(@"AnalyzingReportTable创表成功");
            } else {
                NSLog(@"AnalyzingReportTable创表失败");
            }
            
            //先取出完成表来里的数据解档
            NSString *select1 = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ID DESC", BACompletedReport];
            FMResultSet *result1 = [db executeQuery:select1];
            while (result1.next) {
                NSData *reportData = [result1 dataForColumn:BAReportData];
                BAReportModel *reportModel = [NSKeyedUnarchiver unarchiveObjectWithData:reportData];
                
                if (reportModel) {
                    [tempArray addObject:reportModel];
                }
            }
            
            //再取出未完成表来里的数据解档
            NSString *select2 = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ID DESC", BAAnalyzingReport];
            FMResultSet *result2 = [db executeQuery:select2];
            while (result2.next) {
                
                NSData *reportData = [result2 dataForColumn:BAReportData];
                BAReportModel *reportModel = [NSKeyedUnarchiver unarchiveObjectWithData:reportData];
                
                if (reportModel) {
                    [tempArray addObject:reportModel];
                }
            }

//暂时关注表不存本地
//            //关注表
//            NSString *execute3 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID integer primary key autoincrement, %@ Blob)", BANotice, BANoticeData];
//            BOOL createNoticeTable = [db executeUpdate:execute3];
//            if (createNoticeTable) {
//                NSLog(@"noticeTable创表成功");
//            } else {
//                NSLog(@"noticeTable创表失败");
//            }
//            
//            //再取出关注表来里的数据解档
//            NSString *select3 = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ID DESC", BANotice];
//            FMResultSet *result3 = [db executeQuery:select3];
//            while (result3.next) {
//                
//                NSData *noticeData = [result3 dataForColumn:BANoticeData];
//                NSArray *userNameArray = [NSKeyedUnarchiver unarchiveObjectWithData:noticeData];
//                
//                noticeTempArray = userNameArray.mutableCopy;
//            }
            
            //搜索历史表
            NSString *execute4 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID integer primary key autoincrement, %@ Blob)", BASearchHistory, BASearchHistoryData];
            BOOL createSearchHistoryTable = [db executeUpdate:execute4];
            if (createSearchHistoryTable) {
                NSLog(@"searchHistoryTable创表成功");
            } else {
                NSLog(@"searchHistoryTable创表失败");
            }
            
            //再取出历史表来里的数据解档
            NSString *select4 = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ID ASC", BASearchHistory];
            FMResultSet *result4 = [db executeQuery:select4];
            while (result4.next) {
                
                NSData *searchHistoryData = [result4 dataForColumn:BASearchHistoryData];
                BARoomModel *roomModel = [NSKeyedUnarchiver unarchiveObjectWithData:searchHistoryData];
                
                if (roomModel) {
                    [searchHistoryTempArray addObject:roomModel];
                }
            }
            
            //用户屏蔽表
            NSString *execute5 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID integer primary key autoincrement, %@ Blob)", BAUserIngnore, BAUserIngnoreData];
            BOOL createUserIgnoreTable = [db executeUpdate:execute5];
            if (createUserIgnoreTable) {
                NSLog(@"userIgnoreTable创表成功");
            } else {
                NSLog(@"userIgnoreTable创表失败");
            }
            
            //再取出用户屏蔽表来里的数据解档
            NSString *select5 = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ID ASC", BAUserIngnore];
            FMResultSet *result5 = [db executeQuery:select5];
            while (result5.next) {
                
                NSData *userIgnoreData = [result5 dataForColumn:BAUserIngnoreData];
                NSArray *userNameArray = [NSKeyedUnarchiver unarchiveObjectWithData:userIgnoreData];
                
                userIgnoreTempArray = userNameArray.mutableCopy;
            }
            
            //用户屏蔽表
            NSString *execute6 = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID integer primary key autoincrement, %@ Blob)", BAWordsIngnore, BAWordsIngnoreData];
            BOOL createWordsIgnoreTable = [db executeUpdate:execute6];
            if (createWordsIgnoreTable) {
                NSLog(@"wordsIgnoreTable创表成功");
            } else {
                NSLog(@"wordsIgnoreTable创表失败");
            }
            
            //再取出用户屏蔽表来里的数据解档
            NSString *select6 = [NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY ID ASC", BAWordsIngnore];
            FMResultSet *result6 = [db executeQuery:select6];
            while (result6.next) {
                
                NSData *wordsIgnoreData = [result6 dataForColumn:BAWordsIngnoreData];
                NSArray *wordsArray = [NSKeyedUnarchiver unarchiveObjectWithData:wordsIgnoreData];
                
                wordsIgnoreTempArray = wordsArray.mutableCopy;
            }
            
            [db close];
        }
        _reportModelArray = tempArray;
        //_noticeArray = noticeTempArray;
        _searchHistoryArray = searchHistoryTempArray;
        _userIgnoreArray = userIgnoreTempArray;
        _wordsIgnoreArray = wordsIgnoreTempArray;
        
        [BANotificationCenter postNotificationName:BANotificationDataUpdateComplete object:nil userInfo:@{BAUserInfoKeyReportModelArray : _reportModelArray,
                                                                                                          BAUserInfoKeySearchHistoryArray : _searchHistoryArray}];
    }];
}


/**
 将报告存在本地
 */
- (void)saveReportLocolized{
    
    dispatch_async(self.analyzingQueue, ^{
        
        //存入本地
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            
            BOOL open = [db open];
            if (open) {
                
                //判断是否为未完成分析表分别存入表单
                NSString *insert;
                if (_analyzingReportModel.isInterruptAnalyzing) {
                    insert = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@) VALUES (?, ?)", BAAnalyzingReport, BAReportID, BAReportData];
                } else {
                    insert = [NSString stringWithFormat:@"INSERT INTO %@ (%@, %@) VALUES (?, ?)", BACompletedReport, BAReportID, BAReportData];
                }
                NSData *reportData = [NSKeyedArchiver archivedDataWithRootObject:_analyzingReportModel];
                BOOL success = [db executeUpdate:insert, @(_analyzingReportModel.timeID), reportData];
                if (!success) {
                    NSLog(@"储存失败");
                }
                [db close];
            }
        }];
    });
}


/**
 删除本地报告
 */
- (void)delReport:(BAReportModel *)report{
    
    dispatch_async(self.analyzingQueue, ^{

        BOOL isInterruptAnalyzing = report.isInterruptAnalyzing;
        
        [self.dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL open = [db open];
            if (open) {
                
                //判断是否为未完成分析表分别存入表单
                NSString *del;
                if (isInterruptAnalyzing) {
                    del = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = (?)", BAAnalyzingReport, BAReportID];
                } else {
                    del = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = (?)", BACompletedReport, BAReportID];
                }
                BOOL success = [db executeUpdate:del, @(report.timeID)];
                if (!success) {
                    NSLog(@"删除失败");
                } else {
                    if (!isInterruptAnalyzing) {
                        [_reportModelArray removeObject:report];
                    }
                }
                [db close];
            }
        }];
    });
}


/**
 添加关注
 */
- (void)addNotice:(NSString *)notice{
    
    dispatch_async(self.analyzingQueue, ^{
        
        //先添加入数组
        [_noticeArray addObject:notice];
//暂时关注不存本地
//        [self.dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
//            BOOL open = [db open];
//            if (open) {
//                
//                //删除这个用户所有的标记
//                NSString *del = [NSString stringWithFormat:@"DELETE FROM %@", BANotice];
//                BOOL success = [db executeUpdate:del];
//                if (!success) {
//                    NSLog(@"删除失败");
//                } else {
//          
//                    //存入表单
//                    NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (?)", BANotice, BANoticeData];
//                    NSData *noticeData = [NSKeyedArchiver archivedDataWithRootObject:_noticeArray];
//                    BOOL success = [db executeUpdate:insert, noticeData];
//                    if (!success) {
//                        NSLog(@"储存失败");
//                    }
//                }
//                
//                [db close];
//            }
//        }];
    });
}


/**
 删除关注
 */
- (void)delNotice:(NSString *)notice{
    
    if (!_noticeArray) {
        _noticeArray = [NSMutableArray array];
    }
    
    dispatch_async(self.analyzingQueue, ^{
        
        [_noticeArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isEqualToString:notice]) {
                [_noticeArray removeObject:obj];
            }
        }];
        
        [self.dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL open = [db open];
            if (open) {
                
                //删除这个用户所有的标记
                NSString *del = [NSString stringWithFormat:@"DELETE FROM %@", BANotice];
                BOOL success = [db executeUpdate:del];
                if (!success) {
                    NSLog(@"删除失败");
                } else {
                    
                    //存入表单
                    NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (?)", BANotice, BANoticeData];
                    NSData *noticeData = [NSKeyedArchiver archivedDataWithRootObject:_noticeArray];
                    BOOL success = [db executeUpdate:insert, noticeData];
                    if (!success) {
                        NSLog(@"储存失败");
                    }
                }
                
                [db close];
            }
        }];
    });
}


/**
 清除关注表
 */
- (void)clearNotice{
    
    dispatch_async(self.analyzingQueue, ^{
        
        //先删除
        [_noticeArray removeAllObjects];
//暂时关注不存本地
//        [self.dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
//            BOOL open = [db open];
//            if (open) {
//                
//                NSString *del = [NSString stringWithFormat:@"DELETE FROM %@", BANotice];
//                BOOL success = [db executeUpdate:del];
//                if (!success) {
//                    NSLog(@"删除失败");
//                }
//                
//                [db close];
//            }
//        }];
    });
}


/**
 添加用户屏蔽
 */
- (void)ingnoreUserName:(NSString *)userName{
    
    dispatch_async(self.analyzingQueue, ^{
        
        //先添加入数组
        [_userIgnoreArray addObject:userName];

        [self.dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL open = [db open];
            if (open) {
                
                NSString *del = [NSString stringWithFormat:@"DELETE FROM %@", BAUserIngnore];
                BOOL success = [db executeUpdate:del];
                if (!success) {
                    NSLog(@"删除失败");
                } else {
          
                    //存入表单
                    NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (?)", BAUserIngnore, BAUserIngnoreData];
                    NSData *userIgnoreData = [NSKeyedArchiver archivedDataWithRootObject:_userIgnoreArray];
                    BOOL success = [db executeUpdate:insert, userIgnoreData];
                    if (!success) {
                        NSLog(@"储存失败");
                    }
                }
                
                [db close];
            }
        }];
    });
}



/**
 删除用户屏蔽
 */
- (void)uningnoreUserName:(NSString *)userName{
    
    dispatch_async(self.analyzingQueue, ^{
        
        //先删除
        [_userIgnoreArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:userName]) {
                [_userIgnoreArray removeObject:obj];
            }
        }];
        
        [self.dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL open = [db open];
            if (open) {
                
                NSString *del = [NSString stringWithFormat:@"DELETE FROM %@", BAUserIngnore];
                BOOL success = [db executeUpdate:del];
                if (!success) {
                    NSLog(@"删除失败");
                } else {
                    
                    //存入表单
                    NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (?)", BAUserIngnore, BAUserIngnoreData];
                    NSData *userIgnoreData = [NSKeyedArchiver archivedDataWithRootObject:_userIgnoreArray];
                    BOOL success = [db executeUpdate:insert, userIgnoreData];
                    if (!success) {
                        NSLog(@"储存失败");
                    }
                }
                
                [db close];
            }
        }];
    });
}


/**
 清除用户屏蔽
 */
- (void)clearIngnoreUserName{
    
    dispatch_async(self.analyzingQueue, ^{
        
        //先删除
        [_userIgnoreArray removeAllObjects];
        
        [self.dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL open = [db open];
            if (open) {
                
                NSString *del = [NSString stringWithFormat:@"DELETE FROM %@", BAUserIngnore];
                BOOL success = [db executeUpdate:del];
                if (!success) {
                    NSLog(@"删除失败");
                }
                
                [db close];
            }
        }];
    });
}


/**
 添加单词屏蔽
 */
- (void)ingnoreWords:(NSString *)words{
    
    dispatch_async(self.analyzingQueue, ^{
        
        //先添加入数组
        [_wordsIgnoreArray addObject:words];
        
        [self.dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL open = [db open];
            if (open) {
                
                NSString *del = [NSString stringWithFormat:@"DELETE FROM %@", BAWordsIngnore];
                BOOL success = [db executeUpdate:del];
                if (!success) {
                    NSLog(@"删除失败");
                } else {
                    
                    //存入表单
                    NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (?)", BAWordsIngnore, BAWordsIngnoreData];
                    NSData *userIgnoreData = [NSKeyedArchiver archivedDataWithRootObject:_wordsIgnoreArray];
                    BOOL success = [db executeUpdate:insert, userIgnoreData];
                    if (!success) {
                        NSLog(@"储存失败");
                    }
                }
                
                [db close];
            }
        }];
    });
}


/**
 删除单词屏蔽
 */
- (void)uningnoreWords:(NSString *)words{
    
    dispatch_async(self.analyzingQueue, ^{
        
        //先删除
        [_wordsIgnoreArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:words]) {
                [_wordsIgnoreArray removeObject:obj];
            }
        }];
        
        [self.dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL open = [db open];
            if (open) {
                
                NSString *del = [NSString stringWithFormat:@"DELETE FROM %@", BAWordsIngnore];
                BOOL success = [db executeUpdate:del];
                if (!success) {
                    NSLog(@"删除失败");
                } else {
                    
                    //存入表单
                    NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (?)", BAWordsIngnore, BAWordsIngnoreData];
                    NSData *userIgnoreData = [NSKeyedArchiver archivedDataWithRootObject:_wordsIgnoreArray];
                    BOOL success = [db executeUpdate:insert, userIgnoreData];
                    if (!success) {
                        NSLog(@"储存失败");
                    }
                }
                
                [db close];
            }
        }];
    });
}


/**
 清除单词屏蔽
 */
- (void)clearIngnoreWords{
    
    dispatch_async(self.analyzingQueue, ^{
        
        //先删除
        [_wordsArray removeAllObjects];
        
        [self.dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL open = [db open];
            if (open) {
                
                NSString *del = [NSString stringWithFormat:@"DELETE FROM %@", BAWordsIngnore];
                BOOL success = [db executeUpdate:del];
                if (!success) {
                    NSLog(@"删除失败");
                }
                
                [db close];
            }
        }];
    });
}


/**
 添加搜索历史记录
 */
- (void)addSearchHistory:(BARoomModel *)roomModel{
    
    dispatch_async(self.analyzingQueue, ^{
    
        [_searchHistoryArray insertObject:roomModel atIndex:0];
        
        //存入本地
        [_dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            
            BOOL open = [db open];
            if (open) {
                
                //判断是否为未完成分析表分别存入表单
                NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (?)", BASearchHistory, BASearchHistoryData];
                NSData *searchHistoryData = [NSKeyedArchiver archivedDataWithRootObject:roomModel];
                BOOL success = [db executeUpdate:insert, searchHistoryData];
                if (!success) {
                    NSLog(@"储存失败");
                }
                [db close];
            }
        }];
    });
}


/**
 清空搜索历史记录
 */
- (void)clearSearchHistory{
    
    dispatch_async(self.analyzingQueue, ^{
        
        [_searchHistoryArray removeAllObjects];
        
        [self.dataBaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            BOOL open = [db open];
            if (open) {
                
                //判断是否为未完成分析表分别存入表单
                NSString *del = [NSString stringWithFormat:@"DELETE FROM %@", BASearchHistory];
                BOOL success = [db executeUpdate:del];
                if (!success) {
                    NSLog(@"删除失败");
                }
                [db close];
            }
        }];
    });
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
            defaultCenter.dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
            [defaultCenter updateReportLocolized];
            defaultCenter.similarity = 0.7f;
            
            NSString *dictPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/jieba.dict.small.utf8"];
            NSString *hmmPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/hmm_model.utf8"];
            NSString *userDictPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/user.dict.utf8"];
            
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
