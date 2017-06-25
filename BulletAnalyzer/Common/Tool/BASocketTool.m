//
//  BASocketTool.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/1.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BASocketTool.h"
#import "BAReplyModel.h"
#import "BATransModelTool.h"
#import "BAAnalyzerCenter.h"
#import "NSData+HexExtension.h"


@implementation BASocketTool {
    NSTimer *_heartbeatTimer;
    NSString *_roomId;
    BOOL _serviceConnected;
    BOOL _roomConnected;
    NSMutableData *_contentData;
}

#pragma mark - service
/**
 链接服务器
 */
- (void)connectSocketWithRoomId:(NSString *)roomId{
    
    _roomId = roomId;
    
    if (_socket.isConnected) {
        [self cutOff];
    }
    
    // 1. 与服务器的socket链接起来
    NSError *error = nil;
    BOOL result = [self.socket connectToHost:BAServiceAddress onPort:BAServicePort error:&error];
    
    // 2. 判断端口号是否开放成功
    if (result) {
        
        NSLog(@"客户端连接服务器成功");
        
        _serviceConnected = YES;
        
        [self connectRoom];
        
    } else {
        NSLog(@"客户端连接服务器失败");
        
        _serviceConnected = NO;
    }
}


/**
 链接房间弹幕服务器
 */
- (void)connectRoom{
    
    NSLog(@"链接服务器");
    
    NSData *pack = [self packDataWith:[NSString stringWithFormat:@"type@=loginreq/roomid@=%@/", _roomId]];
    [self.socket writeData:pack withTimeout:BAReadTimeOut tag:1];
}


/**
 入组
 */
- (void)joinGroup{
    
    NSLog(@"发送入组消息");
    //-9999 海量弹幕
    NSData *pack = [self packDataWith:[NSString stringWithFormat:@"type@=joingroup/rid@=%@/gid@=-9999/", _roomId]];
    [self.socket writeData:pack withTimeout:BAReadTimeOut tag:1];
}


/**
 开始发送心跳消息
 */
- (void)startHeartbeat{
    
    [_heartbeatTimer invalidate];
    _heartbeatTimer = nil;
    
    _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:40 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        NSLog(@"发送心跳包");
        
        NSData *pack = [self packDataWith:[NSString stringWithFormat:@"type@=keeplive/tick@=%@/", [self timeString]]];
        [self.socket writeData:pack withTimeout:BAReadTimeOut tag:1];
    }];
    [_heartbeatTimer fire];
}


/**
 用户切断链接
 */
- (void)cutOff{
    
    NSLog(@"断开链接");
    
    NSData *pack = [self packDataWith:[NSString stringWithFormat:@"type@=logout/"]];
    [self.socket writeData:pack withTimeout:BAReadTimeOut tag:1];
    [[BAAnalyzerCenter defaultCenter] endAnalyzing];
    [_heartbeatTimer invalidate];
    [_socket disconnect];
}


/**
 按斗鱼协议拼接数据
 */
- (NSData *)packDataWith:(NSString *)string{
    
    NSMutableData *stringData = [NSData HexDataWithString:string];
    unsigned int hexLength = (int)string.length + 9;
    PostPack pack = {hexLength, hexLength, BAPostCode};
    
    NSMutableData *postDate = [NSData dataWithBytes:&pack length:sizeof(pack)].mutableCopy;
    [postDate appendData:stringData];
    [postDate appendBytes:&BAEndCode length:1];
    
    return postDate;
}


/**
 处理服务器返回数据
 */
- (void)handleServiceReply:(BAReplyModel *)replayModel{
    
    if ([replayModel.type isEqualToString:BAInfoTypeLoginReplay]) { //登录消息则入组 并开启心跳包
        [self joinGroup];
        [[BAAnalyzerCenter defaultCenter] beginAnalyzing];
        [self startHeartbeat];
    } 
}


#pragma mark - private
- (NSString *)timeString{
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.f", time];
    return timeString;
}


#pragma mark - GCDAsyncSocketDelegate
/**
 连接成功
 @discussion 客户端链接服务器端成功, 客户端获取地址和端口号
 @param sock socket
 @param host IP
 @param port 端口号
 */
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    //NSLog(@"链接服务器成功:openbarrage.douyutv.com");
    BASocketTool *socket = [BASocketTool defaultSocket];
    socket.socket = self.socket;
}


/**
 断开连接
 
 @param sock socket
 @param err 错误信息
 */
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    if (err) {
        NSLog(@"连接失败:%@", err.description);
        if ([err.description containsString:@"Code=7"]) { //服务器认为心跳包问题断开, 重连
            [self connectSocketWithRoomId:_roomId];
        }
        
    }else{
        NSLog(@"正常断开");
    }
}


/**
 读取数据
 @discussion 客户端已经获取到内容
 @param sock socket
 @param data 数据
 @param tag tag
 */
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    if (data.length != 0){
        
        NSInteger endCode = 0;
        //获取data末尾字节
        [data getBytes:&endCode range:NSMakeRange(data.length - 1, 1)];
        
        if (_contentData == nil) {
            _contentData = [[NSMutableData alloc] init];
        }
        
        //如果为0则代表这是一段完整的数据，可以进行解析
        //若无，则需要拼接至一段完整数据才进行解析
        if (endCode == 0) {
            [_contentData appendData:data];
            
            [BATransModelTool transModelWithData:_contentData complete:^(NSMutableArray *array, BAModelType modelType) {
                
                if (modelType == BAModelTypeBullet) {
                    
                    [BANotificationCenter postNotificationName:BANotificationBullet object:nil userInfo:@{BAUserInfoKeyBullet : array}];
                    
                } else if (modelType == BAModelTypeGift) {
                    
                    [BANotificationCenter postNotificationName:BANotificationGift object:nil userInfo:@{BAUserInfoKeyGift : array}];
                    
                } else if (modelType == BAModelTypeReply) {
                    
                    [self handleServiceReply:[array firstObject]];
                }
            }];
            _contentData = nil;
        }else{
            [_contentData appendData:data];
        }
    }
    
    [self.socket readDataWithTimeout:BAReadTimeOut tag:0];
}


/**
 数据发送成功
 
 @param sock socket
 @param tag tag
 */
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //NSLog(@"数据发送成功");
    //发送完数据手动读取，-1不设置超时
    [sock readDataWithTimeout:BAReadTimeOut tag:tag];
}


#pragma mark - singleton
//单例类的静态实例对象，因对象需要唯一性，故只能是static类型
static BASocketTool *defaultSocket = nil;

/**
 单例模式对外的唯一接口，用到的dispatch_once函数在一个应用程序内只会执行一次，且dispatch_once能确保线程安全
 */
+ (BASocketTool *)defaultSocket{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (defaultSocket == nil) {
            defaultSocket = [[self alloc] init];
            defaultSocket.socket = [[GCDAsyncSocket alloc] initWithDelegate:defaultSocket delegateQueue:dispatch_get_main_queue()];
        }
    });
    return defaultSocket;
}

/**
 覆盖该方法主要确保当用户通过[[Singleton alloc] init]创建对象时对象的唯一性，alloc方法会调用该方法，只不过zone参数默认为nil，因该类覆盖了allocWithZone方法，所以只能通过其父类分配内存，即[super allocWithZone:zone]
 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (defaultSocket == nil) {
            defaultSocket = [super allocWithZone:zone];
        }
    });
    return defaultSocket;
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
