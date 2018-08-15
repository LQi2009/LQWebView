//
//  LQWebView.h
//  LQWebViewDemo
//
//  Created by LiuQiqiang on 2018/8/15.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@protocol LQWebViewDelegate ;

typedef void(^LQWebViewScriptMessageHandler)(NSString *key, id info);
@interface LQWebView : UIView

@property (nonatomic, strong, readonly) WKWebView *webView;
@property (nonatomic, weak) id <LQWebViewDelegate> delegate;
@property (nonatomic, assign) BOOL isAutoClearCache;
@property (nonatomic, assign) BOOL isShowIndicator;

- (BOOL) canGoBack ;
- (void) goBack ;

- (void) loadURLString:(NSString *)urlString ;
- (void) loadUrlString:(NSString *)urlStr params:(NSDictionary *)param ;
- (void) loadURL:(NSURL *)url ;

/**
 加载本地HTML文件
 
 @param file html文件名
 */
- (void) loadLocalFile:(NSString *)file ;

/**
 加载本地的html文件（蓝色文件夹）
 
 @param path 文件在文件夹内的相对路径（包含文件夹名称）
 @param ext 扩展字段，比如链接中拼接的子路径/参数等
 */

- (void) loadLocalFilePath:(NSString *)path withExtension:(NSString *)ext ;

/**
 添加需要执行的JS方法

 @param methodName JS 方法名称
 @param param 参数（会转换为Json传递）
 */
- (void) addJavaScriptMethod:(NSString *)methodName param:(NSDictionary *)param ;

/**
 添加需要执行的JS方法
 （携带多个参数的方法，单个参数可使用 ‘addJavaScriptMethod: param:’）

 @param methodName JS 方法名称
 @param params 多个参数
 */
- (void) addJavaScriptMethod:(NSString *)methodName params:(NSArray *) params ;


/**
 添加需要执行的JS代码

 @param js js 代码
 */
- (void) addJavaScript:(NSString *) js ;
- (void) addUserScript:(NSString *)js ;


- (void) addProgressObserverWithHandler:(LQWebViewScriptMessageHandler) handler ;
- (void) addTitleObserverWithHandler:(LQWebViewScriptMessageHandler) handler ;

/**
 注入JS需要调用的原生协议

 @param name 与H5商定的协议名称
 @param handler 当H5调用该协议方法时的回调
 */
- (void) addScriptMessageHandler:(NSString *)name handler:(LQWebViewScriptMessageHandler) handler ;
@end

@protocol LQWebViewDelegate <NSObject>

- (void) webViewStartLoad:(LQWebView *) webView ;

- (void) webViewLoadSuccess:(LQWebView *) webView ;

- (void) webView:(LQWebView *) webView loadFailed:(NSError *) error ;
@end
