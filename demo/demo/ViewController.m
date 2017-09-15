//
//  ViewController.m
//  demo
//
//  Created by TouzhijiaAdmi on 15/09/2017.
//  Copyright © 2017 Touzhijia. All rights reserved.
//

#import "ViewController.h"
#import "TZJTouchMoveButton.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)addTouchMoveButton {
    TZJTouchMoveButton *btn = [[TZJTouchMoveButton alloc] initWithFrame:CGRectZero];
    [btn setImageWithName:@"FloatBonus"];
    btn.stayment = StaymentRight;
    [btn setTapActionWithBlock:^{
        NSLog(@"跳转到邀请好友界面");
        UIViewController *v = [UIViewController new];
        v.view.backgroundColor = [UIColor redColor];
        v.title = @"邀请好友界面";
        [self.navigationController pushViewController:v animated:YES];
    }];
    [self.view addSubview:btn];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addTouchMoveButton];
    self.title = @"哈哈，请给我个star";
}


@end
