//
//  BAMainViewController.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/4.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAMainViewController.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "BASocketTool.h"
#import "BARoomModel.h"
#import "BABulletModel.h"

@interface BAMainViewController ()

@end

@implementation BAMainViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = BAThemeColor;
    
    [self setupNavigation];
    
    [self setupDrawer];
    
    [self addNotificationObserver];
}


- (void)dealloc{
    [BANotificationCenter removeObserver:self];
}


#pragma mark - userInteraction
- (void)roomBtnClicked{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


#pragma mark - private
- (void)setupNavigation{
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem BarButtonItemWithTitle:@"房间" target:self action:@selector(roomBtnClicked)];
}


- (void)setupDrawer{
    
}


- (void)addNotificationObserver{
    [BANotificationCenter addObserver:self selector:@selector(roomSelected:) name:BANotificationRoomListCellClicked object:nil];
}


#pragma mark - userInteraction
- (void)roomSelected:(NSNotification *)sender{
    BARoomModel *roomModel = sender.userInfo[@"roomModel"];
    
    [[BASocketTool defaultSocket] connectSocketWithRoomId:roomModel.room_id];
    [BASocketTool defaultSocket].bullet = ^(NSArray *array) {
        [array enumerateObjectsUsingBlock:^(BABulletModel *bulletModel, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%@:%@", bulletModel.nn, bulletModel.txt);
        }];
    };
}



@end
