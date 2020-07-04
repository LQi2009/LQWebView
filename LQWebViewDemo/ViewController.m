//
//  ViewController.m
//  LQWebViewDemo
//
//  Created by LiuQiqiang on 2018/8/15.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

#import "ViewController.h"
#import "LQWebTestViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    http://123.56.191.196:8888/api/jurong/v3.0/task_list.jsp
    [self.datas addObject:@{@"title": @"百度一下", @"url": @"https://www.baidu.com"}];
    [self.datas addObject:@{@"title": @"本地PDF文件", @"url": @"test.pdf"}];
    [self.datas addObject:@{@"title": @"链接带汉字的docx文件", @"url": @"http://115.182.9.47:81/0/private/572/我自己的世界/文章.docx"}];
    [self.datas addObject:@{@"title": @"链接带汉字的PDF文件", @"url": @"http://115.182.9.47:81/0/private/572/我自己的世界/1.接口自动化测试平台介绍.pdf"}];
    [self.datas addObject:@{@"title": @"链接带汉字的xlsx文件", @"url": @"http://115.182.9.47:81/0/private/572/我自己的世界/截止23日11：50分做在线作业情况（东丽）.xlsx"}];
    [self.datas addObject:@{@"title": @"链接带汉字的txt文件", @"url": @"http://115.182.9.47:81/0/private/572/我自己的世界/课程计划.txt"}];
    
    
    NSString *htmlString = @"<p><strong><span style=\"font-family: 宋体;font-size: 21px\"><span style=\"font-family:宋体\">静夜思</span></span></strong><strong><span style=\"font-family: 宋体;font-size: 21px\"><br/></span></strong><span style=\"font-family: 宋体;font-size: 14px\"><br/></span><span style=\"font-family: 宋体;font-size: 14px\"><span style=\"font-family:宋体\">窗前明月光，疑是地上霜；</span></span><span style=\"font-family: 宋体;font-size: 14px\">举头望明月，低头思故乡。</span>";
    
    [self.datas addObject:@{@"title": @"HTML 字符串", @"url": htmlString}];
    
    NSString *s = @"<img src=\"http://i0.hdslb.com/bfs/archive/839b48daee6bed189d49aa6eac912b353ce0db3d.jpg\" alt=\"\" /><br /> <ul class=\"attributes-list\" style=\"font-family:tahoma, arial, \" background-color:#ffffff;\"=\"\">\<li style=\"text-indent:5px;\">\
        品牌:&nbsp;鼠绘动漫\
    </li>";
    
    [self.datas addObject:@{@"title": @"含有图片链接的 HTML 字符串", @"url": s}];
    
    }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = self.datas[indexPath.row];
    NSString *url = dic[@"url"];
    
    LQWebTestViewController *test = [[LQWebTestViewController alloc]init];
    
    if (indexPath.row == 6 || indexPath.row == 7) {
        test.html = url;
    } else {
        if ([url isKindOfClass:[NSURL class]]) {
            test.url = (NSURL*)url;
        } else {
            if ([url hasPrefix:@"http"]) {
                test.urlStrig = url;
            } else {
                test.fileName = url;
            }
        }
    }
    
    [self presentViewController:test animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellid"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"UITableViewCellid"];
    }
    
    NSDictionary *dic = self.datas[indexPath.row];
    cell.textLabel.text = dic[@"title"];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray array];
    }
    
    return _datas;
}
@end
