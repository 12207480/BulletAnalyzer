//
//  BAReportView.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/7.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAReportView.h"
#import "BAReportCell.h"
#import "BAReplyModel.h"

static NSString *const BAReportCellReusedId = @"BAReportCellReusedId";

@interface BAReportView()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation BAReportView

#pragma mark ---lifeCycle---
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self setupCollectionView];
    }
    return self;
}


#pragma mark ---public---
- (void)setReportModelArray:(NSMutableArray *)reportModelArray{
    _reportModelArray = reportModelArray;
    
    if (reportModelArray.count) {
        [_collectionView reloadData];
        [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:500 * reportModelArray.count inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        _currentIndex = 500 * reportModelArray.count - 1;
    }
}


#pragma mark ---private---
- (void)setupCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.bounces = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.layer.masksToBounds = NO;
    
    [_collectionView registerClass:[BAReportCell class] forCellWithReuseIdentifier:BAReportCellReusedId];
    
    [self addSubview:_collectionView];
}


- (void)adjustImgTransformWithOffsetY:(CGFloat)offsetY{
    CGFloat index = (offsetY + 3 * BAPadding) / (BAScreenWidth - 6 * BAPadding);
    CGFloat deltaIndex = index - _currentIndex;
    CGFloat zoomScale = 1 - fabs(deltaIndex - 1) * 0.15;
    
    CGFloat leftIndex = (offsetY + 3 * BAPadding - (BAScreenWidth - 6 * BAPadding)) / (BAScreenWidth - 6 * BAPadding);
    CGFloat leftDeltaIndex = leftIndex - _currentIndex;
    CGFloat leftZoomScale = fabs(leftDeltaIndex) * 0.15 + 0.85;
    
    CGFloat rightIndex = (offsetY + 3 * BAPadding + (BAScreenWidth - 6 * BAPadding)) / (BAScreenWidth - 6 * BAPadding);
    CGFloat rightDeltaIndex = rightIndex - _currentIndex;
    CGFloat rightZoomScale = fabs(rightDeltaIndex - 2) * 0.15 + 0.85;
    
    [_collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSInteger item = [[_collectionView indexPathForCell:obj] item];
        if (item == _currentIndex + 1) { // 中间一个
            obj.transform = CGAffineTransformMakeScale(zoomScale, zoomScale);
        } else if (item == _currentIndex) { // 左边一个
            obj.transform = CGAffineTransformMakeScale(leftZoomScale, leftZoomScale);
            NSLog(@"%f", leftDeltaIndex);
        } else if (item == _currentIndex + 2){ // 右边一个
            obj.transform = CGAffineTransformMakeScale(rightZoomScale, rightZoomScale);
        }
    }];
}


#pragma mark ---UICollectionViewDelegate---
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 1000 * _reportModelArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BAReportCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:BAReportCellReusedId forIndexPath:indexPath];
    cell.reportModel = _reportModelArray[indexPath.item % _reportModelArray.count];
    cell.transform = indexPath.item == _reportModelArray.count * 500 ? CGAffineTransformMakeScale(1, 1) : CGAffineTransformMakeScale(0.85, 0.85);
    
    return cell;
}

//item大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(BAScreenWidth - 6 * BAPadding, BAScreenHeight * 2 / 3);
}


//纵向间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}


#pragma mark ---UIScrollViewDelegate---
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetX = _collectionView.contentOffset.x;
    
    [self adjustImgTransformWithOffsetY:offsetX];
}


//手动分页
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    float pageWidth = BAScreenWidth - 6 * BAPadding; // width + space
    
    float currentOffset = scrollView.contentOffset.x;
    float targetOffset = targetContentOffset->x;
    float newTargetOffset = 0;
    
    if (targetOffset > currentOffset - 3 * BAPadding) {
        newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth; //向上取整
    } else {
        newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth; //向下取整
    }
    
    if (newTargetOffset < 0) {
        newTargetOffset = 0;
    } else if (newTargetOffset > scrollView.contentSize.width) {
        newTargetOffset = scrollView.contentSize.width;
    }
    
    targetContentOffset->x = currentOffset;
    
    newTargetOffset = newTargetOffset - 3 * BAPadding;
    [scrollView setContentOffset:CGPointMake(newTargetOffset, 0) animated:YES];
    
    _currentIndex = newTargetOffset / pageWidth;
}

@end
