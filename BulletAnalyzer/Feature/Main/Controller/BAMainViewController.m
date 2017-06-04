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

@interface BAMainViewController ()

@end

@implementation BAMainViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = BAThemeColor;
    
    [self setupNavigation];
    
    [self setupDrawer];
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





@end
