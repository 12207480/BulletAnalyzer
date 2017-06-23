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
#import "BAAnalyzerCenter.h"

static NSString *const BABulletListCellReusedId = @"BABulletListCellReusedId";

@interface BABulletListView() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *bulletArray;
@property (nonatomic, assign, getter=isScrollEnabled) BOOL scrollEnable;
@property (nonatomic, strong) NSMutableArray *openCellArray;
@property (nonatomic, assign) NSInteger openCellCount;
@property (nonatomic, strong) UIButton *downBtn;

@end

@implementation BABulletListView

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self prepared];
    }
    return self;
}


#pragma mark - userInteraction
- (void)downBtnClicked{
    [_openCellArray enumerateObjectsUsingBlock:^(BABulletModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.bulletCellSelect = NO;
        self.openCellCount = 0;
    }];
    
    [self reloadData];
}


#pragma mark - public
- (void)addBullets:(NSArray *)bulletsArray{
    if (!bulletsArray.count) return;

    if (self.isScrollEnabled) {
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
    } else {
        
        //暂停滚动后的数据未处理
        
    }
}


#pragma mark - private
- (void)prepared{
    [self registerClass:[BABulletListCell class] forCellReuseIdentifier:BABulletListCellReusedId];
    
    _bulletArray = [NSMutableArray array];
    _openCellArray = [NSMutableArray array];
    
    self.backgroundColor = [UIColor clearColor];
    self.showsVerticalScrollIndicator = NO;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.delegate = self;
    self.dataSource = self;
    self.scrollEnable = YES;
    
    _downBtn = [UIButton buttonWithFrame:CGRectMake(BAScreenWidth - 57, BAScreenHeight - BABulletMenuHeight - 57, 47, 47) title:nil color:nil font:nil backgroundImage:[UIImage imageNamed:@"down"] target:self action:@selector(downBtnClicked)];
    _downBtn.hidden = YES;
    _downBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [self addSubview:_downBtn];
}


- (void)setOpenCellCount:(NSInteger)openCellCount{
    _openCellCount = openCellCount;
    
    if (_openCellCount == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (_openCellCount == 0) {
                _downBtn.hidden = YES;
                _downBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
            }
            _scrollEnable = _openCellCount == 0;
        });
    } else {
        _scrollEnable = NO;
        
        _downBtn.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            _downBtn.transform = CGAffineTransformIdentity;
        }];
    }
}


#pragma mark -tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _bulletArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    BABulletModel *bulletModel = _bulletArray[indexPath.section];
    return bulletModel.isBulletCellSelect ? BABulletListCellHeight + 36 : BABulletListCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WeakObj(self);
    BABulletModel *bulletModel = _bulletArray[indexPath.section];
    BABulletListCell *cell = [tableView dequeueReusableCellWithIdentifier:BABulletListCellReusedId forIndexPath:indexPath];
    cell.bulletModel = bulletModel;
    cell.btnClicked = ^(NSInteger tag){
    
        switch (tag) {
            case 0: //关注
                
                [[BAAnalyzerCenter defaultCenter] addNotice:bulletModel];
                
                break;
                
            default: //取消关注
                
                [[BAAnalyzerCenter defaultCenter] delNotice:bulletModel];
                
                break;
        }
        
        bulletModel.bulletCellSelect = NO;
        [_openCellArray removeObject:bulletModel];
        selfWeak.openCellCount -= 1;
        [selfWeak reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 6;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [UIView new];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BABulletModel *bulletModel = _bulletArray[indexPath.section];
    bulletModel.bulletCellSelect = !bulletModel.isBulletCellSelect;
    self.openCellCount = bulletModel.isBulletCellSelect ? _openCellCount + 1 : _openCellCount - 1;
    if (bulletModel.isBulletCellSelect) {
        [_openCellArray addObject:bulletModel];
    }
    
    [UIView performWithoutAnimation:^{
        [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _downBtn.y = BAScreenHeight - BABulletMenuHeight - 57 + scrollView.contentOffset.y;
}

@end
