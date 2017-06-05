//
//  BARoomListTableViewController.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/4.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BARoomListTableViewController.h"
#import "BARoomListCell.h"
#import "BARoomModel.h"
#import "UIViewController+MMDrawerController.h"

static NSString *const BARoomListCellReusedId = @"BARoomListCellReusedId";

@interface BARoomListTableViewController ()
@property (nonatomic, strong) BAHttpParams *params;
@property (nonatomic, strong) NSMutableArray *roomModelArray;

@end

@implementation BARoomListTableViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
   
    [super viewDidLoad];
    
    self.title = @"房间列表";
    
    self.view.backgroundColor = BADarkBackgroundColor;
    
    [self setupTableView];
    
    [self getStatus];
    
    [self addNotificationObserver];
}


- (void)dealloc{
    [BANotificationCenter removeObserver:self];
}


#pragma mark - private
- (void)setupTableView{

    WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [selfWeak getStatus];
    }];
    
    [self.tableView registerClass:[BARoomListCell class] forCellReuseIdentifier:BARoomListCellReusedId];
    
    _roomModelArray = [NSMutableArray array];
}


- (void)getStatus{
    
    [BAHttpTool getAllRoomListWithParams:self.params success:^(NSMutableArray *obj) {
        
        if (obj.count) {
            
            [obj enumerateObjectsUsingBlock:^(BARoomModel *roomModel1, NSUInteger idx, BOOL * _Nonnull stop) {
                
                [_roomModelArray enumerateObjectsUsingBlock:^(BARoomModel *roomModel2, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    if (roomModel1.room_id.integerValue == roomModel2.room_id.integerValue) {
                        [obj removeObject:roomModel1];
                        *stop = YES;
                    }
                }];
            }];
            
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


- (void)addNotificationObserver{
    [BANotificationCenter addObserver:self selector:@selector(roomSelected:) name:BANotificationRoomListCellClicked object:nil];
}


#pragma mark - userInteraction
- (void)roomSelected:(NSNotification *)sender{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _roomModelArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BARoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:BARoomListCellReusedId forIndexPath:indexPath];
    cell.roomModel = _roomModelArray[indexPath.section];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BARoomListScreenShotImgHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return BAPadding;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}


@end
