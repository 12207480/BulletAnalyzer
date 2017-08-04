//
//  BABulletListView.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/4.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BABulletListView.h"
#import "BABulletListCell.h"
#import "BABulletListGiftCell.h"
#import "BABulletModel.h"
#import "BAGiftModel.h"
#import "BAAnalyzerCenter.h"

static NSString *const BABulletListCellReusedId = @"BABulletListCellReusedId";
static NSString *const BABulletListGiftCellReusedId = @"BABulletListGiftCellReusedId";

@interface BABulletListView() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray *statusArray;
@property (nonatomic, assign, getter=isScrollEnabled) BOOL scrollEnable;
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
    self.scrollEnable = YES;
}


#pragma mark - public
- (void)addStatus:(NSArray *)statusArray{
    if (!statusArray.count) return;

    if (self.isScrollEnabled) {
        [statusArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (![_statusArray containsObject:obj]) {
                [_statusArray addObject:obj];
                if (_statusArray.count > 200) {
                    [_statusArray removeObjectsInRange:NSMakeRange(0, _statusArray.count - 100)];
                }
                
                [self reloadData];
                [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:_statusArray.count - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }];
    } else {
        
        //暂停滚动后的数据未处理
        
    }
}


#pragma mark - private
- (void)prepared{
    [self registerClass:[BABulletListCell class] forCellReuseIdentifier:BABulletListCellReusedId];
    [self registerClass:[BABulletListGiftCell class] forCellReuseIdentifier:BABulletListGiftCellReusedId];
    
    _statusArray = [NSMutableArray array];
    
    self.backgroundColor = [UIColor clearColor];
    self.showsVerticalScrollIndicator = NO;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.delegate = self;
    self.dataSource = self;
    self.scrollEnable = YES;
    
    _downBtn = [UIButton buttonWithFrame:CGRectMake(BAScreenWidth - 67, self.height - 67, 47, 47) title:nil color:nil font:nil backgroundImage:[UIImage imageNamed:@"down"] target:self action:@selector(downBtnClicked)];
    _downBtn.hidden = YES;
    _downBtn.transform = CGAffineTransformMakeScale(0.1, 0.1);
    
    [self addSubview:_downBtn];
}


#pragma mark -tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _statusArray.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id statusModel = _statusArray[indexPath.section];
    
    if ([statusModel isKindOfClass:[BABulletModel class]]) {
        BABulletModel *bulletModel = _statusArray[indexPath.section];
        return bulletModel.bulletContentHeight + 22;
    } else {
        return 44;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WeakObj(self);
    id statusModel = _statusArray[indexPath.section];
    
    if ([statusModel isKindOfClass:[BABulletModel class]]) {
        BABulletModel *bulletModel = _statusArray[indexPath.section];
        BABulletListCell *cell = [tableView dequeueReusableCellWithIdentifier:BABulletListCellReusedId forIndexPath:indexPath];
        cell.bulletModel = bulletModel;
        cell.btnClicked = ^(){
            
            
        };
        return cell;
    } else {
        
        BAGiftModel *giftModel = _statusArray[indexPath.section];
        BABulletListGiftCell *cell = [tableView dequeueReusableCellWithIdentifier:BABulletListGiftCellReusedId forIndexPath:indexPath];
        cell.giftModel = giftModel;cell.btnClicked = ^(){
            
            
        };
        cell.bgType = BAGiftCellBgTypeWhole;
        
        NSInteger statusCount = _statusArray.count;
        id lastStatusModel;
        id nextStatusModel;
        if (indexPath.section > 1)lastStatusModel = _statusArray[indexPath.section - 1];
        if (indexPath.section + 1 < statusCount) nextStatusModel = _statusArray[indexPath.section + 1];
        
        if ([lastStatusModel isKindOfClass:[BAGiftModel class]] && [nextStatusModel isKindOfClass:[BAGiftModel class]]) {
            cell.bgType = BAGiftCellBgTypeMiddle;
        } else if (([lastStatusModel isKindOfClass:[BAGiftModel class]] && ![nextStatusModel isKindOfClass:[BAGiftModel class]])) {
            cell.bgType = BAGiftCellBgTypeBottom;
        } else if ((![lastStatusModel isKindOfClass:[BAGiftModel class]] && [nextStatusModel isKindOfClass:[BAGiftModel class]])) {
            cell.bgType = BAGiftCellBgTypeTop;
        }
        
        
        
        
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //BABulletModel *bulletModel = _statusArray[indexPath.section];
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    _downBtn.y = self.height - 67 + scrollView.contentOffset.y;
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.scrollEnable = NO;
}


- (void)setScrollEnable:(BOOL)scrollEnable{
    _scrollEnable = scrollEnable;
    
    if (scrollEnable) {
            
        _downBtn.hidden = YES;
    } else {
        
        _downBtn.hidden = NO;
        [UIView animateWithDuration:0.1 animations:^{
            
            _downBtn.transform = CGAffineTransformIdentity;
            _downBtn.alpha = 1;
            
        } completion:nil];
    }
}

@end
