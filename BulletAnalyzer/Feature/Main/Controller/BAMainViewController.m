//
//  BAMainViewController.m
//  BulletAnalyzer
//
//  Created by Zj on 17/6/1.
//  Copyright © 2017年 Zj. All rights reserved.
//

#import "BAMainViewController.h"
#import "BASocketTool.h"
#import "BABulletModel.h"

@interface BAMainViewController ()
@property (nonatomic, assign, getter=isConnected) BOOL connected;

@end

@implementation BAMainViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor greenColor];
    
    [BASocketTool defaultSocket].bullet = ^(NSArray *bulletModelArray){
        BABulletModel *bulletModel = [bulletModelArray firstObject];
        NSLog(@"%@: %@", bulletModel.nn, bulletModel.txt);
    };
}


#pragma mark - private
- (void)setConnected:(BOOL)connected{
    _connected = connected;
    
    if (connected) {
        [[BASocketTool defaultSocket] connectSocketWithRoomId:@"58428"];
    } else {
        [[BASocketTool defaultSocket] cutOff];
    }
}


#pragma mark - userInteraction
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.connected = !self.connected;
}


@end
