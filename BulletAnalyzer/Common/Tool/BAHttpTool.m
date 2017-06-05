//
//  BAHttpTool.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/4.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAHttpTool.h"
#import "BATransModelTool.h"
#import "ZJAFNetworking.h"
#import "MJExtension.h"

static NSString *const BANetworkError = @"上帝关了门窗, 还顺便断了网";

@implementation BAHttpTool

+ (void)getAllRoomListWithParams:(BAHttpParams *)params success:(successBlock)success fail:(failBlock)fail{
    
    NSString *url = @"http://open.douyucdn.cn/api/RoomApi/live/";
    
    [ZJAFNetworking GET:url params:params.mj_keyValues success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {

        if ([responseObject[@"error"] integerValue] == 0) {
            
            [BATransModelTool transModelWithRoomDicArray:responseObject[@"data"] compete:^(NSMutableArray *array) {
                
                success(array);
            }];
        }
    } fail:^(NSURLSessionDataTask *task, NSError *error) {
       
        fail(BANetworkError);
    }];
}


@end
