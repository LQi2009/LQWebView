//
//  ViewController.m
//  LQWebViewDemo
//
//  Created by LiuQiqiang on 2018/8/15.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

#import "ViewController.h"
#import "LQWebTestViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSDate *date = [NSDate date];
//    Creates and returns a new date object set to the current date and time
    NSDateFormatter *fm = [[NSDateFormatter alloc]init];
    
    fm.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *st = [fm stringFromDate:date];
    NSLog(@"%@---| %@", date, st);
    
    NSString *dateStr = @"2016年8月24日 11时05分23秒";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日 hh时mm分ss秒"];
    NSDate *date1 = [dateFormatter dateFromString:dateStr];
    

    NSLog(@"%@", date1) ;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    LQWebTestViewController *test = [[LQWebTestViewController alloc]init];
    
    [self presentViewController:test animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
