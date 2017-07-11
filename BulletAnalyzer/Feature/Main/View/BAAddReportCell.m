
//
//  BAAddReportCell.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/7/11.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAAddReportCell.h"
#import "BASearchHistoryCell.h"

static NSString *const BASearchHistoryCellReusedId = @"BASearchHistoryCellReusedId";

@interface BAAddReportCell() <UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *addBtn;
@property (nonatomic, strong) UIImageView *roomNumBgView;
@property (nonatomic, strong) UITextField *roomNumField;
@property (nonatomic, strong) UILabel *searchHistory;
@property (nonatomic, strong) UIButton *historyDelBtn;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *blockView;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation BAAddReportCell

#pragma mark - lifeCycle
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        [self setupAddReportView];
        
        self.layer.contents = (id)[UIImage imageNamed:@"newReport"].CGImage;
    }
    return self;
}


#pragma mark - userInteraction
- (void)historyDelBtnClicked{
    
}


#pragma mark - public
- (void)setSearchHistoryArray:(NSArray *)searchHistoryArray{
    _searchHistoryArray = searchHistoryArray;
    
    [_collectionView reloadData];
}


#pragma mark - private
- (void)setupStatus{
    
 
}


- (void)setupAddReportView{
    
    _titleLabel = [UILabel labelWithFrame:CGRectMake(0, 3 * BAPadding, BAReportCellWidth, 30) text:@"房间搜索" color:BAWhiteColor font:BABlodFont(BALargeTextFontSize) textAlignment:NSTextAlignmentCenter];
    
    [self.contentView addSubview:_titleLabel];
    
    _roomNumBgView = [[UIImageView alloc] initWithFrame:CGRectMake(2 * BAPadding, _titleLabel.bottom + 2 * BAPadding, BAReportCellWidth - 4 * BAPadding, 60)];
    _roomNumBgView.image = [UIImage imageNamed:@"numFieldBg"];
    _roomNumBgView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.contentView addSubview:_roomNumBgView];
    
    _roomNumField = [UITextField textFieldWithFrame:CGRectMake(3.5 * BAPadding, _roomNumBgView.y + BAPadding, _roomNumBgView.width - 3.5 * BAPadding, 40) placeholder:nil color:BAWhiteColor font:BACommonFont(BALargeTextFontSize) secureTextEntry:NO delegate:self];
    NSAttributedString *placeHolder = [[NSAttributedString alloc] initWithString:@"请输入房间号" attributes: @{NSForegroundColorAttributeName:BAWhiteColor,
                                                                                                              NSFontAttributeName:_roomNumField.font
                                                                                                            }];
    _roomNumField.attributedPlaceholder = placeHolder;
    UIImageView *leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"roomListSel"]];
    leftView.frame = CGRectMake(0, 0, 36, 20);
    leftView.contentMode = UIViewContentModeScaleAspectFit;
    _roomNumField.leftView = leftView;
    _roomNumField.leftViewMode = UITextFieldViewModeAlways;
    _roomNumField.tintColor = [UIColor clearColor];
    
    [self.contentView  addSubview:_roomNumField];
    
    _historyDelBtn = [UIButton buttonWithFrame:CGRectMake(2 * BAPadding, _roomNumBgView.bottom + 1.5 * BAPadding, BAReportCellWidth - 4 * BAPadding, 60) title:@"连接" color:BAWhiteColor font:BACommonFont(BALargeTextFontSize) backgroundImage:[UIImage imageNamed:@"openBtn"] target:self action:@selector(historyDelBtnClicked)];
    
    [self.contentView addSubview:_historyDelBtn];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.itemSize = CGSizeMake(BAReportCellWidth / 4, 90);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, BAReportCellHeight - 90 - 3 * BAPadding, BAReportCellWidth, 90) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.bounces = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = BAWhiteColor;
    
    [_collectionView registerClass:[BASearchHistoryCell class] forCellWithReuseIdentifier:BASearchHistoryCellReusedId];
    
    [self.contentView addSubview:_collectionView];
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(2 * BAPadding, _collectionView.y - 1, BAReportCellWidth - 4 * BAPadding, 1)];
    _lineView.backgroundColor = BASpratorColor;
    
    [self.contentView addSubview:_lineView];
    
    _blockView = [[UIView alloc] initWithFrame:CGRectMake(2 * BAPadding, _lineView.y - 0.5, 50, 2)];
    _blockView.backgroundColor = BAThemeColor;
    
    [self.contentView addSubview:_blockView];
    
    _searchHistory = [UILabel labelWithFrame:CGRectMake(2 * BAPadding, _lineView.y - BAPadding - 20, BAReportCellWidth / 2, 20) text:@"搜索历史" color:BAColor(76, 76, 76) font:BABlodFont(16) textAlignment:NSTextAlignmentLeft];
    
    [self.contentView addSubview:_searchHistory];
    
    _historyDelBtn = [UIButton buttonWithFrame:CGRectMake(BAReportCellWidth - 2 * BAPadding - 20, _searchHistory.y + 3, 20, 14) title:nil color:nil font:nil backgroundImage:nil target:self action:@selector(historyDelBtnClicked)];
    _historyDelBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_historyDelBtn setImage:[UIImage imageNamed:@"historyDel"] forState:UIControlStateNormal];
    
    [self.contentView addSubview:_historyDelBtn];
}


#pragma mark ---UICollectionViewDelegate---
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BASearchHistoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:BASearchHistoryCellReusedId forIndexPath:indexPath];
    
    return cell;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.contentOffset.x;
    _blockView.x = 2 * BAPadding + (_lineView.width - _blockView.width) * offsetX / (scrollView.contentSize.width - _collectionView.width +  BAPadding);
}

@end
