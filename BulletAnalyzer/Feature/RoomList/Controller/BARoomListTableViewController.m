//
//  BARoomListTableViewController.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/4.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BARoomListTableViewController.h"

@interface BARoomListTableViewController ()
@property (nonatomic, strong) BAHttpParams *params;
@property (nonatomic, strong) NSMutableArray *roomModelArray;

@end

@implementation BARoomListTableViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self setupTableView];
    
    [self getStatus];
}


#pragma mark - private
- (void)setupTableView{

    WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [selfWeak getStatus];
    }];
    
    _roomModelArray = [NSMutableArray array];
}


- (void)getStatus{
    
    [BAHttpTool getAllRoomListWithParams:_params success:^(NSMutableArray *obj) {
        
        if (obj.count) {
            
            [_roomModelArray addObjectsFromArray:obj];
            [self.tableView.mj_footer endRefreshing];
            self.params.offset = BAStringWithInteger(self.params.offset.integerValue + 1);
        } else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        
        [self.tableView reloadData];
        
    } fail:^(NSString *error) {

        [self.tableView.mj_footer endRefreshing];
        [BATool showHUDWithText:error ToView:self.view];
    }];
}


- (BAHttpParams *)params{
    if (!_params) {
        _params = [BAHttpParams new];
        _params.offset = @"1";
        _params.limit = @"30";
    }
    return _params;
}


#pragma mark - tableViewDelegate


@end
