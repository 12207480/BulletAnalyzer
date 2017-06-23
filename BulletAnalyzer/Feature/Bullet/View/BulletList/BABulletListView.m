//
//  BABulletListView.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/4.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BABulletListView.h"
#import "BABulletListCell.h"
#import "BABulletModel.h"

static NSString *const BABulletListCellReusedId = @"BABulletListCellReusedId";

@interface BABulletListView() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *bulletArray;

@end

@implementation BABulletListView

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self prepared];
    }
    return self;
}


#pragma mark - public
- (void)addBullets:(NSArray *)bulletsArray{
    if (!bulletsArray.count) return;

    [bulletsArray enumerateObjectsUsingBlock:^(BABulletModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (![_bulletArray containsObject:obj]) {
            [_bulletArray addObject:obj];
            if (_bulletArray.count > 200) {
                [_bulletArray removeObjectsInRange:NSMakeRange(0, _bulletArray.count - 100)];
            }
            
            [self reloadData];
            [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_bulletArray.count - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}


#pragma mark - private
- (void)prepared{
    [self registerClass:[BABulletListCell class] forCellReuseIdentifier:BABulletListCellReusedId];
    
    _bulletArray = [NSMutableArray array];
    
    self.backgroundColor = [UIColor clearColor];
    self.showsVerticalScrollIndicator = NO;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.delegate = self;
    self.dataSource = self;
}


#pragma mark -tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _bulletArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BABulletListCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BABulletListCell *cell = [tableView dequeueReusableCellWithIdentifier:BABulletListCellReusedId forIndexPath:indexPath];
    cell.bulletModel = _bulletArray[indexPath.section];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 6;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}

@end
