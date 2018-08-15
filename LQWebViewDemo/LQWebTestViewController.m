//
//  LQWebTestViewController.m
//  LQWebViewDemo
//
//  Created by LiuQiqiang on 2018/8/15.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

#import "LQWebTestViewController.h"
#import "LQWebView.h"

@interface LQWebTestViewController ()

@end

@implementation LQWebTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    LQWebView *web = [[LQWebView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:web];
    [web loadURLString:@"http://www.baidu.com"];
    [web addTitleObserverWithHandler:^(NSString *key, id info) {
        NSLog(@"title : %@", info);
    }];
    
    
    [web addProgressObserverWithHandler:^(NSString *key, id info) {
//        CGFloat progress = (CGFloat)info;
        NSLog(@"progress: %@", info);
    }];
    
    UIButton *back = [UIButton buttonWithType:(UIButtonTypeCustom)];
    
    back.frame = CGRectMake(40, 40, 100, 40);
    back.backgroundColor = [UIColor redColor];
    [back addTarget:self action:@selector(backAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:back];
}

- (void) backAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
