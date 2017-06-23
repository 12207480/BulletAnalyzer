//
//  BAActiveReport.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/18.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAActiveReport.h"
#import "BAActiveCell.h"
#import "BAReportModel.h"
#import "BAUserModel.h"

static NSString *const BAActiveCellReusedId = @"BAActiveCellReusedId";

@interface BAActiveReport() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *activeTableView;
@property (nonatomic, strong) NSMutableArray *userBulletCountArray;
@property (nonatomic, assign) NSInteger maxActiveCount;
@property (nonatomic, assign) NSInteger cellCount;

@end

@implementation BAActiveReport

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = BADark2BackgroundColor;
        
        _cellCount = -1;
        
        [self setupActiveTableView];
    }
    return self;
}


#pragma mark - public
- (void)setReportModel:(BAReportModel *)reportModel{
    _reportModel = reportModel;
    
    _userBulletCountArray = reportModel.userBulletCountArray.copy;
    _maxActiveCount = reportModel.maxActiveCount;
    
    [self animation];
}


- (void)animation{
    _cellCount = -1;
    if (_activeTableView.visibleCells.count != 0) {
        [_activeTableView reloadData];
    };
    for (NSInteger i = 0; i < MIN(_userBulletCountArray.count, 8); i++) {
        [self performSelector:@selector(animatedInsertCell) withObject:nil afterDelay:i * 0.2];
    }
}


- (void)hide{
    _cellCount = -1;
    [_activeTableView reloadData];
}


#pragma mark - private
- (void)animatedInsertCell{
    if (_cellCount + 1 < MIN(_userBulletCountArray.count, 8)) {
        _cellCount += 1;
        [_activeTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_cellCount inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }
}


- (void)setupActiveTableView{
    _activeTableView = [[UITableView alloc] initWithFrame:CGRectMake(BAPadding, BAPadding + BABulletActiveCellHeight * 2, BAScreenWidth - 2 * BAPadding, BAScreenHeight - 2 * BAPadding - BABulletActiveCellHeight * 2) style:UITableViewStylePlain];
    _activeTableView.backgroundColor = BADark1BackgroundColor;
    _activeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _activeTableView.dataSource = self;
    _activeTableView.delegate = self;
    _activeTableView.scrollEnabled = NO;
    _activeTableView.layer.shadowOffset = CGSizeMake(2, 2);
    _activeTableView.layer.shadowOpacity = 0.5;
    _activeTableView.layer.shadowColor = BABlackColor.CGColor;
    _activeTableView.layer.masksToBounds = NO;
    
    [_activeTableView registerClass:[BAActiveCell class] forCellReuseIdentifier:BAActiveCellReusedId];
    
    [self addSubview:_activeTableView];
}


#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _cellCount + 1 > 8 ? 8 : _cellCount + 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    BAUserModel *userModel = _userBulletCountArray[indexPath.row];
    return userModel.isActiveCellSelect ? BABulletActiveCellHeight + 30 : BABulletActiveCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BAActiveCell *cell = [tableView dequeueReusableCellWithIdentifier:BAActiveCellReusedId forIndexPath:indexPath];
    BAUserModel *userModel = _userBulletCountArray[indexPath.row];
    userModel.maxActiveCount = _maxActiveCount;
    cell.userModel = userModel;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BAUserModel *userModel = _userBulletCountArray[indexPath.row];
    userModel.activeCellSelect = !userModel.isActiveCellSelect;
    [_activeTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end
