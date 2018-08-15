//
//  LQWebView.m
//  LQWebViewDemo
//
//  Created by LiuQiqiang on 2018/8/15.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

#import "LQWebView.h"
#import <CommonCrypto/CommonCrypto.h>

#pragma mark - ==== 避免直接使用WKScriptMessageHandler引起循环引用 ====
@interface LQScriptMessageHandler : NSObject <WKScriptMessageHandler>

@property (nonatomic, weak) id <WKScriptMessageHandler> delegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>) delegate ;
@end

@implementation LQScriptMessageHandler
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>) delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (self.delegate && [self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}
@end

#pragma =================== 存储一些方法参数模型 =====================
@interface LQJavaScriptItem : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *jsonString;
@property (nonatomic, copy) NSString *methodName;
@property (nonatomic, copy) LQWebViewScriptMessageHandler handler;
@property (nonatomic) id obj;
@end

@implementation LQJavaScriptItem

@end


#pragma =================== LQWebView ===============================
@interface LQWebView ()<WKScriptMessageHandler, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *wkView;
@property (nonatomic, strong) NSMutableDictionary *messageHandlers;
@property (nonatomic, strong) NSMutableDictionary *javaScriptMethods;
@property (nonatomic, strong) NSMutableDictionary *observers;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end
@implementation LQWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(WKWebView *)webView {
    
    return _wkView;
}

- (BOOL) canGoBack {
    
    return [self.wkView canGoBack];
}

- (void) goBack {
    if ([self.wkView canGoBack]) {
        [self.wkView goBack];
    }
}

#pragma mark - ============= 加载网络URL ====================
- (void) loadURLString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    [self loadURL:url];
}

- (void) loadUrlString:(NSString *)urlStr params:(NSDictionary *)param {
    
    NSMutableString *paramStr = [NSMutableString string];
    for (NSString *key in param.allKeys) {
        if (paramStr.length <= 0) {
            [paramStr appendString:[NSString stringWithFormat:@"%@=%@", key, [self __objToJson:[param objectForKey:key]]]];
        } else {
            [paramStr appendString:[NSString stringWithFormat:@"&%@=%@", key, [self __objToJson:[param objectForKey:key]]]];
        }
    }
    
    urlStr = [NSString stringWithFormat:@"%@?%@", urlStr, paramStr];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    [self loadURL:url];
}

- (void) loadURL:(NSURL *)url {
    
    if (url == nil) {
        NSLog(@"url Error");
        return;
    }
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.wkView loadRequest:req];
}

#pragma mark - ============= 加载本地文件 ========================
- (void) loadLocalFilePath:(NSString *)path withExtension:(NSString *)ext {
    
    if (ext == nil) {
        ext = @"";
    }
    
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    
    NSString *fullPath = [NSString stringWithFormat:@"file://%@/%@%@", bundlePath, path, ext];
    NSURL *url = [NSURL URLWithString:fullPath];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.wkView loadRequest:req];
}

- (void) loadLocalFile:(NSString *)file {
    
    NSURL *url ;
    if ([file hasSuffix:@".html"]) {
        url = [[NSBundle mainBundle] URLForResource:file withExtension:nil];
    } else {
        url = [[NSBundle mainBundle] URLForResource:file withExtension:@"html"];
    }
    
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.wkView loadRequest:req];
}

#pragma mark - ============= 添加需要执行的js方法 ==============
- (void) addJavaScriptMethod:(NSString *)methodName param:(NSDictionary *)param {
    
    LQJavaScriptItem *item = [[LQJavaScriptItem alloc]init];
    
    item.key = [self __md5Encode:methodName];
    item.methodName = methodName;
    item.jsonString = [self __objToJson:param];
    [self.javaScriptMethods setObject:item forKey:item.key];
}

- (void) addJavaScriptMethod:(NSString *)methodName params:(NSArray *) params {
    
    NSMutableArray *objs = [NSMutableArray arrayWithCapacity:params.count];
    for (id obj in params) {
        [objs addObject:[self __objToJson:obj]];
    }
    
    LQJavaScriptItem *item = [[LQJavaScriptItem alloc]init];
    
    item.key = [self __md5Encode:methodName];
    item.methodName = methodName;
    item.obj = objs;
    [self.javaScriptMethods setObject:item forKey:item.key];
}

#pragma mark - ============= 添加需要执行的js ==================
- (void) addJavaScript:(NSString *) js {
    
    LQJavaScriptItem *item = [[LQJavaScriptItem alloc]init];
    item.key = [self __md5Encode:js];
    item.obj = js;
    [self.javaScriptMethods setObject:item forKey:item.key];
}

- (void) addUserScript:(NSString *)js {
    WKUserScript *us = [[WKUserScript alloc]initWithSource:js injectionTime:(WKUserScriptInjectionTimeAtDocumentStart) forMainFrameOnly:NO];
    
    [self.wkView.configuration.userContentController addUserScript:us];
}

#pragma mark - ============= 添加观察者 ===========================
- (void) addProgressObserverWithHandler:(LQWebViewScriptMessageHandler) handler {
    
    [self.wkView addObserver:self forKeyPath:@"estimatedProgress" options:(NSKeyValueObservingOptionNew) context:nil];
    
    LQJavaScriptItem *item = [[LQJavaScriptItem alloc]init];
    
    item.key = [self __md5Encode:@"estimatedProgress"];
    item.methodName = @"estimatedProgress";
    item.handler = handler;
    [self.observers setObject:item forKey:item.key];
}

- (void) addTitleObserverWithHandler:(LQWebViewScriptMessageHandler) handler {
    
    [self.wkView addObserver:self forKeyPath:@"title" options:(NSKeyValueObservingOptionNew) context:nil];
    
    LQJavaScriptItem *item = [[LQJavaScriptItem alloc]init];
    
    item.key = [self __md5Encode:@"title"];
    item.methodName = @"title";
    item.handler = handler;
    [self.observers setObject:item forKey:item.key];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    NSString *key = [self __md5Encode:keyPath];
    LQJavaScriptItem *item = [self.observers objectForKey:key];
    if (item.handler) {
        
        item.handler(keyPath, [change objectForKey:NSKeyValueChangeNewKey]);
    }
}

#pragma mark: - addScriptMessageHandler 注入js回调方法

- (void) addScriptMessageHandler:(NSString *)name handler:(LQWebViewScriptMessageHandler) handler {
    
    WKUserContentController *user = self.wkView.configuration.userContentController;
    [user addScriptMessageHandler:[[LQScriptMessageHandler alloc] initWithDelegate:self] name:name];
    
    if (handler) {
        LQJavaScriptItem *item = [[LQJavaScriptItem alloc]init];
        
        item.key = [self __md5Encode:name];
        item.methodName = name;
        item.handler = handler;
        [self.messageHandlers setObject:item forKey:item.key];
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSString *key = [self __md5Encode:message.name];
    LQJavaScriptItem *item = [self.messageHandlers objectForKey:key];
    if (item && item.handler) {
        
        item.handler(message.name, message.body);
    }
}

#pragma mark: - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    
    NSLog(@"开始调用");
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewStartLoad:)]) {
        [self.delegate webViewStartLoad:self];
    }
    
    if (self.isShowIndicator) {
        [self.activityIndicator startAnimating];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"页面加载完成");
    if (self.isShowIndicator) {
        [self.activityIndicator stopAnimating];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(webViewLoadSuccess:)]) {
        [self.delegate webViewLoadSuccess:self];
    }
    
    NSArray *keys = [self.javaScriptMethods allKeys];
    if (keys > 0) {
        for (NSString *key in keys) {
            LQJavaScriptItem *item = [self.javaScriptMethods objectForKey:key];
            if (item.methodName.length > 0) {
                
                NSString *js ;
                if (item.jsonString && item.jsonString.length > 0) {
                    js = [NSString stringWithFormat:@"%@('%@')", item.methodName, item.jsonString];
                } else if (item.obj) {
                    if ([item.obj isKindOfClass:[NSArray class]]) {
                        NSArray *params = (NSArray *)item.obj;
                        NSMutableString *param = [NSMutableString string];
                        for (NSString *obj in params) {
                            if (param.length == 0) {
                                [param appendString:[NSString stringWithFormat:@"'%@'", obj]];
                            } else {
                                [param appendString:[NSString stringWithFormat:@",'%@'", obj]];
                            }
                        }
                        
                        js = [NSString stringWithFormat:@"%@(%@)", item.methodName, param];
                    }
                } else {
                    js = [NSString stringWithFormat:@"%@('')", item.methodName];
                }
                
                [webView evaluateJavaScript:js completionHandler:^(id _Nullable info, NSError * _Nullable error) {
                    NSLog(@"%@", error);
                }];
            } else if (item.obj && [item.obj isKindOfClass:[NSString class]] && (item.methodName== nil || item.methodName.length <= 0)) {
                NSString *js = (NSString *)item.obj;
                [webView evaluateJavaScript:js completionHandler:^(id _Nullable info, NSError * _Nullable error) {
                    NSLog(@"%@", error);
                }];
            }
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"页面加载失败");
    if (self.delegate && [self.delegate respondsToSelector:@selector(webView:loadFailed:)]) {
        [self.delegate webView:self loadFailed:error];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.wkView.frame = self.bounds;
    self.wkView.backgroundColor = self.backgroundColor;
    if (self.isShowIndicator) {
        self.activityIndicator.center = self.center;
    }
}

- (void)dealloc {
    
    NSLog(@"[%@] dealloc",NSStringFromClass([self class]));
    [self.wkView stopLoading];
    
    if (self.isAutoClearCache) {
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            // Done
            NSLog(@"清除缓存");
        }];
    }
    
    @try {
        // 移除观察者
        if (self.observers.count > 0) {
            for (LQJavaScriptItem *item in self.observers.allValues) {
                [self.wkView removeObserver:self forKeyPath:item.methodName];
            }
        }
        
        // 移除注册的交互协议
        if (self.messageHandlers.count > 0) {
            for (LQJavaScriptItem *item in self.messageHandlers.allValues) {
                [self.wkView.configuration.userContentController removeScriptMessageHandlerForName:item.methodName];
            }
        }
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

#pragma mark - Getters
- (NSMutableDictionary *)messageHandlers {
    if (_messageHandlers == nil) {
        _messageHandlers = [NSMutableDictionary dictionary];
    }
    
    return _messageHandlers;
}

- (NSMutableDictionary *)javaScriptMethods {
    if (_javaScriptMethods == nil) {
        _javaScriptMethods = [NSMutableDictionary dictionary];
    }
    
    return _javaScriptMethods;
}

- (NSMutableDictionary *)observers {
    if (_observers == nil) {
        _observers = [NSMutableDictionary dictionary];
    }
    
    return _observers;
}

- (WKWebView *)wkView {
    if (_wkView == nil) {
        
        WKUserContentController *user = [[WKUserContentController alloc]init];
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
        config.userContentController = user;
        _wkView = [[WKWebView alloc]initWithFrame:self.frame configuration:config];
        _wkView.navigationDelegate = self;
        [self addSubview:_wkView];
    }
    
    return _wkView;
}

- (UIActivityIndicatorView *)activityIndicator {
    if (_activityIndicator == nil) {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.center = self.center;
        [self addSubview:_activityIndicator];
    }
    
    return _activityIndicator;
}

#pragma mark - Private Methods
- (NSString *) __objToJson:(id) obj {
    if ([obj isKindOfClass:[NSString class]]) {
        return (NSString *)obj;
    } else if ([obj isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)obj encoding:NSUTF8StringEncoding];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:kNilOptions error:nil];
    
    if (data == nil) {
        return nil;
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *) __md5Encode:(NSString *) string {
    
    const char *cStr = [string UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02X", digest[i]];
    
    return output;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end



