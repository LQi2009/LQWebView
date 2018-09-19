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
    
    [web loadLocalFile:@"test.pdf"];
//    [web loadURLString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1531415247542&di=2f753b5f3b5497a978171bbceb97b2a8&imgtype=0&src=http%3A%2F%2Fimg5.zdface.com%2F006yCHQygy1fji19zzsljj30m80etdgu.jpg"];
//    [web loadLocalFile:@"test.xlsx"];
//    [web loadLocalFilePath:@"test.xlsx" withExtension:nil];
//    [web loadURLString:@"http://www.baidu.com"];
//
//    [web addTitleObserverWithHandler:^(NSString *key, id info) {
//        NSLog(@"title : %@", info);
//    }];
//
//    [web addProgressObserverWithHandler:^(NSString *key, id info) {
////        CGFloat progress = (CGFloat)info;
//        NSLog(@"progress: %@", info);
//    }];
    
    web.isShowProgressIndicator = YES;
//    web.progressColor = [UIColor redColor];
    
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
