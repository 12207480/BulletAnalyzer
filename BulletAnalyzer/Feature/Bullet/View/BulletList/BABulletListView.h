//
//  BABulletListView.h
//  BulletAnalyzer
//
//  Created by Zj on 17/6/4.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BABulletListView : UITableView

/**
 传入新的弹幕
 */
- (void)addBullets:(NSArray *)bulletsArray;

@end
