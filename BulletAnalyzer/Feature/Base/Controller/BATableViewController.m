//
//  BATableViewController.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/1.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BATableViewController.h"

@interface BATableViewController ()

@end

@implementation BATableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layer.contents = (id)[UIImage imageNamed:@"backgroundView"].CGImage;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

@end
