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

@interface BAAnalyzerCenter()
@property (nonatomic, strong) BAReportModel *analyzingReportModel;
@property (nonatomic, strong) FMDatabaseQueue *queue;

//弹幕数据
@property (nonatomic, strong) NSMutableArray *bulletsArray;
@property (nonatomic, strong) NSMutableArray *wordsArray;

@end

@implementation BAAnalyzerCenter

#pragma mark - public
- (void)beginAnalyzing{
    
    //传入报告则接着分析
    if (!_proceedReportModel) {
        _analyzingReportModel = [BAReportModel new];
        
        BAReportModel *reportModel = [_reportModelArray lastObject];
        NSString *lastID = reportModel.ID;
        
        _analyzingReportModel.ID = [NSString stringWithFormat:@"%zd", lastID.integerValue + 1];
        _analyzingReportModel.begin = [NSDate date];
    } else {
        _analyzingReportModel = _proceedReportModel;
        _analyzingReportModel.proceed = [NSDate date];
        _analyzingReportModel.interruptAnalyzing = NO;
        _proceedReportModel = nil;
    }
    
    _analyzing = YES;
    
    [self beginObserving];
}


- (void)interruptAnalyzing{
    _analyzing = NO;
    [self endObserving];
    
    if (_analyzingReportModel) {
        _analyzingReportModel.interrupt = [NSDate date];
        _analyzingReportModel.interruptAnalyzing = YES;
        [_reportModelArray addObject:_analyzingReportModel];
        
        //存入本地
        [self saveReportLocolized];
    }
}


- (void)endAnalyzing{
    _analyzing = NO;
    [self endObserving];

    if (_analyzingReportModel) {
        _analyzingReportModel.end = [NSDate date];
        _analyzingReportModel.interruptAnalyzing = NO;
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
    BABulletModel *bulletModel = sender.userInfo[BAUserInfoKeyBullet];
    
    //开始分析弹幕...
}


#pragma mark - dataLocolize
- (void)updateReportLocolized{
    
    [_queue inDatabase:^(FMDatabase * _Nonnull db) {
        
        NSMutableArray *tempArray = [NSMutableArray array];
        BOOL open = [db open];
        if (open) {
            //创表
            BOOL createTable = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS report (ID text, interruptanalyzing bool)"];
            if (createTable) {
                NSLog(@"创表成功");
            } else {
                NSLog(@"创表失败");
            }
            
            NSString *select = @"SELECT * FROM report ORDER BY ID DESC";
            FMResultSet *result = [db executeQuery:select];
            while (result.next) {
                BAReportModel *reportModel = [[BAReportModel alloc] init];
                
                reportModel.ID = [result stringForColumn:@"ID"];
                reportModel.interruptAnalyzing = [result boolForColumn:@"interruptAnalyzing"];
                
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
    
            NSString *select = @"INSERT INTO report (ID,interruptanalyzing) VALUES (?,?)";
            BOOL success = [db executeUpdate:select, _analyzingReportModel.ID, _analyzingReportModel.interruptAnalyzing];
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
