# LQWebView
对WKWebView 的封装，继承自UIView，方便使用！

# 添加
##### 手动
可直接将项目目录下的 ‘LQWebView’ 文件夹拖入项目使用

##### Cocoapods
在Pidfile文件添加
```
pod 'LQWebView'
```

Swift版本
```
pod 'LQWebView/SF'
```

# 使用
使用简单，只需要创建/添加到视图即可：
```
LQWebView *web = [[LQWebView alloc]initWithFrame:self.view.bounds];
[self.view addSubview:web];
```

然后，调用相应的方法，加载URL：
##### 加载网络URL
```
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
```
使用：
```
[web loadURLString:@"http://www.baidu.com"];
```

##### 加载本地URL
```
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
```

##### 代理
加载情况的回调，使用代理来实现：
```
- (void) webViewStartLoad:(LQWebView *) webView ;

- (void) webViewLoadSuccess:(LQWebView *) webView ;

- (void) webView:(LQWebView *) webView loadFailed:(NSError *) error ;
```

##### 调用JavaScript方法
调用JS的方法，我这里提供了两种：
```
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

```
区别只是携带参数方式不同，如果不需要参数，可直接传nil；

##### 执行JavaScript代码
如果需要执行一段JS代码，可直接使用下面的方法：
```
/**
 添加需要执行的JS代码

 @param js js 代码
 */
- (void) addJavaScript:(NSString *) js ;
- (void) addUserScript:(NSString *)js ;
```

##### 观察标题/加载进度变化
```
/**
 添加属性观察者，常用的为title，加载进度

 @param handler 回调
 */
- (void) addProgressObserverWithHandler:(LQWebViewScriptMessageHandler) handler ;
- (void) addTitleObserverWithHandler:(LQWebViewScriptMessageHandler) handler ;
```

##### 提供原生协议方法供JS调用
如果需要和JS进行交互，可使用下面的方法，将约定的协议方法名称注入到JS中：
```
/**
 注入JS需要调用的原生协议

 @param name 与H5商定的协议名称
 @param handler 当H5调用该协议方法时的回调
 */
- (void) addScriptMessageHandler:(NSString *)name handler:(LQWebViewScriptMessageHandler) handler ;
```

    


