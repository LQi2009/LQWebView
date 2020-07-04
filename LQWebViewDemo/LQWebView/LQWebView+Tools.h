//
//  LQWebView+Tools.h
//  LQWebViewDemo
//
//  Created by 刘启强 on 2020/4/15.
//  Copyright © 2020 LiuQiqiang. All rights reserved.
//

#import "LQWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface LQWebView (Tools)

- (NSString *)encodeURL:(NSString *) url ;
// 对txt文本的编码，如果加载txt文本时乱码，可尝试使用这个编码一下
- (NSString *) encodeTXT:(NSString *) urlString ;
//判断是否有中文
- (BOOL)isURLContainChinese:(NSString *) url ;

//+ (NSString *)MIMETypeFromUrlString:(NSString *) urlString ;
@end

NS_ASSUME_NONNULL_END
