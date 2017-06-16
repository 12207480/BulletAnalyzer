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
    
    NSArray *addBulletsArray;
    
    //去重
    BABulletModel *lastBullet = [_bulletArray lastObject];
    __block BOOL contained = NO;
    __block NSInteger index = 0;
    [bulletsArray enumerateObjectsUsingBlock:^(BABulletModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        contained = [lastBullet.cid isEqualToString:obj.cid];
        if (contained) {
            *stop = YES;
            index = idx;
        }
    }];
    
    addBulletsArray = contained ? [bulletsArray subarrayWithRange:NSMakeRange(index + 1, bulletsArray.count - index - 1)] : bulletsArray;
    
    [addBulletsArray enumerateObjectsUsingBlock:^(BABulletModel *bulletModel, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [_bulletArray addObject:bulletModel];
        if (_bulletArray.count > 200) {
            [_bulletArray removeObjectsInRange:NSMakeRange(0, _bulletArray.count - 100)];
        }
        
        [self reloadData];
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_bulletArray.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
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
    self.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
}


#pragma mark -tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _bulletArray.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return BABulletListCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BABulletListCell *cell = [tableView dequeueReusableCellWithIdentifier:BABulletListCellReusedId forIndexPath:indexPath];
    cell.bulletModel = _bulletArray[indexPath.row];
    
    return cell;
}

@end
