//
//  LQWebTestViewController.m
//  LQWebViewDemo
//
//  Created by LiuQiqiang on 2018/8/15.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

#import "LQWebTestViewController.h"
#import "LQWebView.h"

@interface LQWebTestViewController ()<LQWebViewDelegate>

@end

@implementation LQWebTestViewController
- (void)webViewLoadSuccess:(LQWebView *)webView {
    
    sleep(2);
    NSURL *url = [NSURL URLWithString:@"https://www.meipian3.cn/2she2g2v?first_share_to=singlemessage&first_share_uid=39887708&from=singlemessage&share_depth=1&share_from=self&share_user_mpuuid=a493de8ea1d4324f416cbc2e85107409&user_id=39887708&utm_medium=meipian_android&utm_source=singlemessage&uuid=45a3951fe4e1d06d395c95f9df1d0424"];
//https://www.meipian3.cn/2she2g2v?first_share_to=singlemessage&first_share_uid=39887708&from=singlemessage&share_depth=1&share_from=self&share_user_mpuuid=a493de8ea1d4324f416cbc2e85107409&user_id=39887708&utm_medium=meipian_android&utm_source=singlemessage&uuid=45a3951fe4e1d06d395c95f9df1d0424
    [webView loadURL:url];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    LQWebView *web = [[LQWebView alloc]initWithFrame:self.view.bounds];
    web.delegate = self;
    [self.view addSubview:web];
    
//    NSURL *url = [NSURL URLWithString:@""];
    NSURL *url = [NSURL URLWithString:@"http://115.182.9.47:81//0/private/283/你干嘛你干嘛你干嘛你你干嘛你干嘛/文章.doc"];
    
    if (self.url) {
        [web loadURL:url];
    } else if (self.fileName) {
        [web loadLocalFile:self.fileName];
    } else if (self.html) {
        [web loadHTMLString:self.html baseURL:@"http://i0.hdslb.com"];
    } else {
        [web loadURLString:self.urlStrig];
    }
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
