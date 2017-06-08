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
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"

static NSString *const BACompletedReport = @"completedReport"; //完成表
static NSString *const BAAnalyzingReport = @"AnalyzingReport"; //进行表
static NSString *const BAReportID = @"ID";  //ID
static NSString *const BAReportData = @"reportData"; //数据

@interface BAAnalyzerCenter()
@property (nonatomic, strong) BAReportModel *analyzingReportModel;
@property (nonatomic, strong) FMDatabaseQueue *queue;

@end

@implementation BAAnalyzerCenter

#pragma mark - public
- (void)beginAnalyzing{
    _analyzing = YES;
    
    //传入报告则接着分析
    if (!_proceedReportModel) {
        _analyzingReportModel = [BAReportModel new];
        _analyzingReportModel.bulletsArray = [NSMutableArray array];
        _analyzingReportModel.begin = [NSDate date];
    } else {
        _analyzingReportModel = _proceedReportModel;
        _analyzingReportModel.interruptAnalyzing = NO;
        _analyzingReportModel.proceed = [NSDate date];
        _proceedReportModel = nil;
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
}


- (void)endObserving{
    [BANotificationCenter removeObserver:self];
}


- (void)bullet:(NSNotification *)sender{
    NSArray *bulletModelArray = sender.userInfo[BAUserInfoKeyBullet];
    
    [_analyzingReportModel addBullets:bulletModelArray];
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
