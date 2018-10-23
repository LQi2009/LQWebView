//
//  LQWebView.h
//  LQWebViewDemo
//
//  Created by LiuQiqiang on 2018/8/15.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

/**
 注入JS协议回调Block

 @param key key
 @param info 详细信息, 如果回调的内容为基本类型, 则info为NSNumber
 例如进度条, 可这样接收:
 `
 NSNumber *num = info;
 CGFloat progress = [num floatValue] ;
 `
 */
typedef void(^LQWebViewScriptMessageHandler)(NSString *key, id info);

/**
 执行注入的JS方法回调Block

 @param info 描述信息
 @param error 错误信息
 */
typedef void(^LQWebViewJavaScriptCompletionHandler)(id info, NSError *error);
@protocol LQWebViewDelegate ;
@protocol LQWebViewUIDelegate ;
@interface LQWebView : UIView

/** WKWebView 可根据需要在外部设置一些属性 */
@property (nonatomic, strong, readonly) WKWebView *webView;

/** 代理 */
@property (nonatomic, weak) id <LQWebViewDelegate> delegate;

/** 弹框代理, 用于替换JS的一些弹框提醒 */
@property (nonatomic, weak) id <LQWebViewUIDelegate> uiDelegate;

/** 是否在销毁时清除缓存, 所有的缓存: web存储的数据/数据库/cookie等 */
@property (nonatomic, assign) BOOL isAutoClearCache;

/** 是否正在加载网页 */
@property (nonatomic, assign, readonly) BOOL isLoading;

/** 是否允许播放网页内视频 */
@property (nonatomic, assign) BOOL allowsInlineMediaPlay;

/** 是否使用手势滑动返回 */
@property (nonatomic, assign) BOOL backGestureEnable;

/** 加载时是否显示指示器, 默认为系统 UIActivityIndicatorView */
@property (nonatomic, assign) BOOL isShowIndicator;

/** 是否显示加载进度, 如果自己通过进度观察添加, 则不需要设置此属性 */
@property (nonatomic, assign) BOOL isShowProgressIndicator;

/** 是否显示状态栏左上角的网络指示器 */
@property (nonatomic, assign) BOOL isShowNetIndicator;

/** 加载进度条颜色, 如果设置此属性, 则自动设置 isShowProgressIndicator 为YES */
@property (nonatomic, strong) UIColor * progressColor ;

- (void) clearCache ;
- (BOOL) canGoBack ;
- (void) goBack ;
- (void) stopLoading ;
- (void) reload ;

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
 加载本地文件(pdf/excel/world/图片等)

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
 @param handler 回调结果
 */
- (void) addJavaScriptMethod:(NSString *)methodName param:(NSDictionary *)param completionHandler:(LQWebViewJavaScriptCompletionHandler) handler ;

/**
 添加需要执行的JS方法
 （携带多个参数的方法，单个参数可使用 ‘addJavaScriptMethod: param:’）

 @param methodName JS 方法名称
 @param params 多个参数（参数值）
 @param handler 回调结果
 */
- (void) addJavaScriptMethod:(NSString *)methodName params:(NSArray *) params completionHandler:(LQWebViewJavaScriptCompletionHandler) handler ;

/**
 添加需要执行的JS代码

 @param js js 代码
 @param handler 回调结果
 */
- (void) addJavaScript:(NSString *) js completionHandler:(LQWebViewJavaScriptCompletionHandler) handler ;
- (void) addUserScript:(NSString *)js ;

// 以上方法都是在加载WebView完成的同时执行的JavaScript方法，如果在页面加载后某个时机想要执行js方法，可使用下面的方法

#pragma mark - ============= 单独执行JavaScript方法 ================
/**
 单独执行一段JS代码（在WebView显示完成后）

 @param methodName JS 方法名称
 @param param 参数（会转换为Json传递）
 @param handler 执行后的回调
 */
- (void) runJavaScriptMethod:(NSString *) methodName param:(NSDictionary *)param completionHandler:(LQWebViewJavaScriptCompletionHandler) handler ;

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

@optional
- (void) webViewStartLoad:(LQWebView *) webView ;

- (void) webViewLoadSuccess:(LQWebView *) webView ;

- (void) webView:(LQWebView *) webView loadFailed:(NSError *) error ;

/** 需要验证服务/证书时调用, 例如HTTPS
 `
 if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
 
 NSURLCredential * cred = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
 
 completionHandler(NSURLSessionAuthChallengeUseCredential, cred);
 }
 `
 */
- (void) webView:(LQWebView *) webView authenticationChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler ;

@end

/**
 替换web中的js弹框代理方法
 */
@protocol LQWebViewUIDelegate <NSObject>

@optional
/**
 webView中弹出警告框时调用, 只能有一个按钮
 
 @param webView webView
 @param msg 提示信息
 @param completionHandler 警告框消失的时候调用, 回调给JS
 */
- (void) webView:(LQWebView *) webView alertJSMessage:(NSString *) msg completionHandler:(void (^)(void))completionHandler ;

/** 对应js的confirm方法
 webView中弹出选择框时调用, 两个按钮
 
 @param webView webView description
 @param msg 提示信息
 @param completionHandler 确认框消失的时候调用, 回调给JS, 参数为选择结果: YES or NO
 */
- (void) webView:(LQWebView *) webView confirmJSMessage:(NSString *) msg completionHandler:(void (^)(BOOL result))completionHandler ;

/** 对应js的prompt方法
 webView中弹出输入框时调用, 两个按钮 和 一个输入框
 
 @param webView webView description
 @param msg 提示信息
 @param defaultText 默认提示文本
 @param completionHandler 输入框消失的时候调用, 回调给JS, 参数为输入的内容
 */
- (void) webView:(LQWebView *) webView textInputJSMessage:(NSString *) msg defaultText:(nullable NSString *)defaultText completionHandler:(void (^)(NSString * _Nullable result))completionHandler ;

@end
