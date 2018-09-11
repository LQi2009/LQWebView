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

#pragma mark - ============= 加载网络URL ====================
/**
 加载网络URL（无参数）

 @param urlString URL地址
 */
- (void) loadURLString:(NSString *)urlString ;

/**
 加载网络URL（带参数），拼接在URL后

 @param urlStr URL地址
 @param param 参数（参数名称为key，参数内容为value）
 */
- (void) loadUrlString:(NSString *)urlStr params:(NSDictionary *)param ;


- (void) loadURL:(NSURL *)url ;
- (void) loadRequest:(NSURLRequest *) req ;

#pragma mark - ============= 加载本地文件 ========================
/**
 加载本地HTML文件
 
 @param file html文件名
 */
- (void) loadLocalHTML:(NSString *) file ;

/**
 加载本地的html文件（蓝色文件夹）
 
 @param path 文件在文件夹内的相对路径（包含文件夹名称）
 @param ext 扩展字段，比如链接中拼接的子路径/参数等
 */
- (void) loadLocalHTML:(NSString *) path withExtension:(NSString *)ext ;

/**
 加载本地文件(pdf/excel/world)

 @param file 文件名称
 @param ext 扩展字段，比如,后缀名称, 如果名称含后缀, 可传nil
 */
- (void) loadLocalFile:(NSString *) file withExtension:(NSString *)ext ;
- (void) loadLocalFile:(NSString *) file ;

#pragma mark - ============= 添加需要执行的js方法 ==============
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
 @param params 多个参数（参数值）
 */
- (void) addJavaScriptMethod:(NSString *)methodName params:(NSArray *) params ;


/**
 添加需要执行的JS代码

 @param js js 代码
 */
- (void) addJavaScript:(NSString *) js ;
- (void) addUserScript:(NSString *)js ;

#pragma mark - ============= 添加观察者 ===========================
/**
 添加WebView的属性观察者，常用的为title，加载进度

 @param keyPath 待观察的属性名称
 @param handler 回调
 */
- (void) addWebViewObserverForKeyPath:(NSString *) keyPath handler:(LQWebViewScriptMessageHandler) handler ;
- (void) addProgressObserverWithHandler:(LQWebViewScriptMessageHandler) handler ;
- (void) addTitleObserverWithHandler:(LQWebViewScriptMessageHandler) handler ;

#pragma mark: - addScriptMessageHandler 注入js回调方法
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
