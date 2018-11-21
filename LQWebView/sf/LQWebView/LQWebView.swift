//
//  LQWebView.swift
//  LQWebViewSwift
//
//  Created by LiuQiqiang on 2018/9/17.
//  Copyright © 2018年 LiuQiqiang. All rights reserved.
//

import UIKit
import WebKit

@objc public protocol LQWebViewDelegate {
    
    @objc optional func webViewStartLoad(_ web: LQWebView)
    @objc optional func webViewLoadSuccess(_ web: LQWebView)
    @objc optional func webView(_ web: LQWebView, loadFailed error: Error)
    @objc optional func webView(_ web: LQWebView, authenticationChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}

@objc public protocol LQWebViewUIDelegate {
    
    /// webView中弹出警告框时调用, 只能有一个按钮
    ///
    /// - Parameters:
    ///   - webView: webView
    ///   - msg: 提示信息
    ///   - handler: 警告框消失的时候调用, 回调给JS
    @objc optional func webView(_ webView: LQWebView, alertJSMessage msg: String, completionHandler handler: @escaping () -> Void)
    
    /// 对应js的confirm方法
    /// webView中弹出选择框时调用, 两个按钮

    ///
    /// - Parameters:
    ///   - webView: webView
    ///   - msg: 提示信息
    ///   - handler: 确认框消失的时候调用, 回调给JS, 参数为选择结果: YES or NO
    @objc optional func webView(_ webView: LQWebView, confirmJSMessage msg: String, completionHandler handler: @escaping (Bool) -> Void)
    
    /// 对应js的prompt方法
    /// webView中弹出输入框时调用, 两个按钮 和 一个输入框
    ///
    /// - Parameters:
    ///   - webView: webView
    ///   - msg: 提示信息
    ///   - defaultText: 默认提示文本
    ///   - handler: 输入框消失的时候调用, 回调给JS, 参数为输入的内容
    @objc optional func webView(_ webView: LQWebView, textInputJSMessage msg: String, defaultText: String?, completionHandler handler: @escaping (String?) -> Void)
}

public typealias LQWebViewScriptMessageHandler = (_ key: String, _ info: Any) -> Void
public class LQWebView: UIView {
    
    public weak var delegate: LQWebViewDelegate?
    
    public weak var uiDelegate: LQWebViewUIDelegate? {
        didSet {
            
            self.wkWeb.uiDelegate = self
        }
    }
    
    public var isShowProgressIndicator: Bool = false {
        didSet {
            
            guard isShowProgressIndicator else {
                return
            }
            
            self.progressView.setProgress(0.2, animated: true)
            self.progressView.alpha = 1.0
            
            self.addProgressObserverWithHandler {[weak self] (key, info) in
                
                if let num = info as? NSNumber {
                    let progress = num.floatValue
                    if progress == 1.0 {
                        
                        self?.progressView.setProgress(progress, animated: false)
                        UIView.animate(withDuration: 0.6, animations: {
                            self?.progressView.alpha = 0
                        })
                    } else if progress < 1.0 {
                        self?.progressView.setProgress(progress, animated: true)
                    } else {
                        self?.progressView.alpha = 0
                    }
                }
                
            }
        }
    }
    
    public var isShowIndicator: Bool = false
    public var isAutoClearCache: Bool = false
    public var isShowNetIndicator: Bool = true
    public var isAuthChallenge: Bool = true
    public var isLoading: Bool {
        
        return self.wkWeb.isLoading
    }
    
    public var canGoBack: Bool {
        return self.wkWeb.canGoBack
    }
    
    public var allowsInlineMediaPlay: Bool = true {
        didSet {
            self.wkWeb.configuration.allowsInlineMediaPlayback = allowsInlineMediaPlay
        }
    }
    public var backGestureEnable: Bool = false {
        didSet {
            self.wkWeb.allowsBackForwardNavigationGestures = backGestureEnable
        }
    }
    
    public var progressColor: UIColor? {
        didSet {
            if let color = progressColor {
                if isShowProgressIndicator == false {
                    isShowProgressIndicator = true
                }
                
                self.progressView.progressTintColor = color
            }
        }
    }
    
    public var webView: WKWebView {
        return wkWeb
    }
    
    
    private lazy var wkWeb: WKWebView = {
        
        let user = WKUserContentController()
        let config = WKWebViewConfiguration()
        
        config.userContentController = user
        let web = WKWebView(frame: .zero, configuration: config)
        
        web.navigationDelegate = self
        self.addSubview(web)
        
        return web
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let act = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        act.hidesWhenStopped = true
        act.center = self.center
        self.addSubview(act)
        return act
    }()
    
    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: UIProgressViewStyle.default)
        progress.trackTintColor = self.backgroundColor
        self.addSubview(progress)
        return progress
    }()

    private var messageHandlers: [String: LQJavaScriptItem] = [:]
    private var javaScriptMethods: [String: LQJavaScriptItem] = [:]
    private var observers: [String: LQJavaScriptItem] = [:]
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        self.wkWeb.frame = self.bounds
        self.wkWeb.backgroundColor = self.backgroundColor
        
        if self.isShowProgressIndicator {
            self.progressView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 3)
        }
        
        if self.isShowIndicator {
            self.activityIndicator.center = self.center
        }
    }
    
    deinit {
        
        print("\(self.description) deinit")
        if self.wkWeb.isLoading {
            self.wkWeb.stopLoading()
        }
        
        if self.isAutoClearCache {
            self.clearCache()
        }
        
        if self.observers.count > 0 {
            for (_ ,item ) in self.observers {
                if let name = item.methodName {
                    self.wkWeb.removeObserver(self, forKeyPath: name)
                }
            }
        }
        
        if self.messageHandlers.count > 0 {
            for (_ , item) in self.messageHandlers {
                if let name = item.methodName {
                    self.wkWeb.configuration.userContentController.removeScriptMessageHandler(forName: name)
                }
                
            }
        }
    }
}

// MARK - Public methods
public extension LQWebView {
    
    /// 异步配置某个webView的UserAgent，使用的是WKWebView的方法
    ///
    /// - Parameters:
    ///   - appendUserAgent: 追加的UserAgent字符串
    ///   - handler: 在该回调方法里加载网页
    func configUserAgentAsync(_ appendUserAgent: String, completionHandler handler: @escaping ((_ info: Any?, _ error: Error?) -> Void)) {
        
        self.wkWeb.evaluateJavaScript("navigator.userAgent") { (info, error) in
            if let oldAgent = info as? String {
                if oldAgent.hasSuffix(appendUserAgent) {
                    handler(info, error)
                } else {
                    let agent = oldAgent + appendUserAgent
                    let dic = ["UserAgent": agent]
                    UserDefaults.standard.register(defaults: dic)
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }
    
    /// 配置全局的UserAgent，使用的是UIWebView的方法，该方法是同步执行的
    ///
    /// - Parameter apendUserAgent: 追加的UserAgent字符串
    class func configGlobalUserAgentSync(_ apendUserAgent: String) {
        
        var agent = apendUserAgent
        
        if let oldAgent = UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent") {
            if oldAgent.hasSuffix(apendUserAgent) {
                return
            }
            
            agent = oldAgent + agent
        }
        
        let dic = ["UserAgent": agent]
        UserDefaults.standard.register(defaults: dic)
        UserDefaults.standard.synchronize()
        
    }
    
    /// 配置全局自定义 UserAgent，会覆盖WebView原有的UserAgent
    ///
    /// - Parameter userAgent: 自定义UserAgent
    class func configCustomGlobalUserAgentSync(_ userAgent: String) {
        
        let dic = ["UserAgent": userAgent]
        UserDefaults.standard.register(defaults: dic)
        UserDefaults.standard.synchronize()
    }
    
    func clearCache() {
        
        let types = WKWebsiteDataStore.allWebsiteDataTypes()
        
        let date = Date.init(timeIntervalSince1970: 0)
        
        WKWebsiteDataStore.default().removeData(ofTypes: types, modifiedSince: date) {
            print("WKWebView clear")
        }
    }
    
    func goBack() {
        self.wkWeb.goBack()
    }
    
    func stopLoading() {
        self.wkWeb.stopLoading()
    }
    
//    MARK: - ============= 加载网络URL ====================
    func loadURLString(_ urlString: String) {
        
        let url = URL(string: urlString)
        self.loadURL(url)
    }
    
    func loadURLString(_ urlString: String, params: [String: Any]?) {
        
        guard let params = params else {
            self.loadURLString(urlString)
            return
        }
        
        var paramString: String = ""
        
        for (key, value) in params {
            
            if paramString.count == 0 {
                
                if let vl = self.objToJSON(value) {
                    paramString += "\(key)=\(vl)"
                }
            } else {
                if let vl = self.objToJSON(value) {
                    paramString += "&\(key)=\(vl)"
                }
            }
        }
        
        let str = urlString + "?" + paramString
        self.loadURLString(str)
    }
    
    func loadURL(_ url: URL?) {
        guard let url = url else { return }
        
        let req = URLRequest(url: url)
        self.loadRequest(req)
    }
    
    func loadRequest(_ req: URLRequest) {
        self.wkWeb.load(req)
    }

//    MARK: - ============= 加载本地文件 ========================
    func loadLocalHTML(_ file: String) {
        
        var url: URL!
        if file.hasPrefix(".html") {
            url = Bundle.main.url(forResource: file, withExtension: nil)
        } else {
            url = Bundle.main.url(forResource: file, withExtension: "html")
        }
        
        self.loadURL(url)
    }

    func loadLocalHTML(_ path: String, with ext: String = "") {
        
        let bundlePath = Bundle.main.bundlePath
        
        let path = "\(bundlePath)/" + path + ext
//        let path = "file://\(bundlePath)/" + path + ext
        
        let url = URL.init(fileURLWithPath: path)
        self.loadURL(url)
    }
    
    func loadLocakFile(_ file: String, with ext: String? = nil) {
        let url = Bundle.main.url(forResource: file, withExtension: ext)
        self.loadURL(url)
    }
    
    
    //    MARK: -  ============= 添加需要执行的js方法 ==============
    func addJavaScriptMethod(_ methodName: String, param: [String: Any] = [:]) {
        var item = LQJavaScriptItem()
        item.key = methodName
        item.methodName = methodName
        item.jsonString = self.objToJSON(param)
        self.javaScriptMethods[item.key] = item
    }
    
    func addJavaScriptMethod(_ methodName: String, params: [Any] = []) {
        
        var objs:  [String] = []
        for item in params {
            if let it = self.objToJSON(item) {
                objs.append(it)
            }
        }
        
        var item = LQJavaScriptItem()
        item.key = methodName
        item.methodName = methodName
        item.obj = objs
        
        self.javaScriptMethods[item.key] = item
    }
    
    //    MARK: -  ============= 添加需要执行的js ==================
    
    func addJavaScript(_ js: String) {
        
        let user = WKUserScript(source: js, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
        
        self.wkWeb.configuration.userContentController.addUserScript(user)
    }
    
    
    func runJavaScriptMethod(_ methodName: String, params: [String: Any], completionHandler handler: ((Any?, Error?) -> Void)? = nil) {
        
        var json = ""
        
        if let jn = objToJSON(params) {
            json = jn
        }
        
        let js = "\(methodName)('\(json)')"
        
        wkWeb.evaluateJavaScript(js, completionHandler: handler)
    }
    
}

//MARK: - ============= 添加观察者 ===========================
public extension LQWebView {
    
    func addWebViewObserverForKeyPath(_ keyPath: String, completHandler handler: @escaping LQWebViewScriptMessageHandler) {
        
        self.wkWeb.addObserver(self, forKeyPath: keyPath, options: NSKeyValueObservingOptions.new, context: nil)
        
        var item = LQJavaScriptItem()
        item.key = keyPath
        item.methodName = keyPath
        item.handler = handler
        self.observers[item.key] = item
    }
    
    func addProgressObserverWithHandler(_ handler: @escaping LQWebViewScriptMessageHandler) {
        
        self.addWebViewObserverForKeyPath("estimatedProgress", completHandler: handler)
    }
    
    func addTitleObserverWithHandler(_ handler: @escaping LQWebViewScriptMessageHandler) {
        
        self.addWebViewObserverForKeyPath("title", completHandler: handler)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let key = keyPath {
            let item = self.observers[key]
            if let handler = item?.handler {
                if let value = change?[NSKeyValueChangeKey.newKey] {
                    handler(key, value)
                }
            }
        }
    }
}

// MARK: - addScriptMessageHandler 注入js回调方法
extension LQWebView: WKScriptMessageHandler {
    
    public func addScriptMessageHandler(_ name: String, complteHandler handler: LQWebViewScriptMessageHandler? = nil) {
        
        self.wkWeb.configuration.userContentController.add(LQScriptMessageHandler.init(self), name: name)
        
        if let handler = handler {
            var item = LQJavaScriptItem()
            item.key = name
            item.methodName = name
            item.handler = handler
            self.messageHandlers[item.key] = item
        }
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let key = message.name
        guard let item = self.messageHandlers[key] else {
            return
        }
        
        guard let handler = item.handler else { return }
        
        handler(key, message.body)
    }
}

extension LQWebView: WKNavigationDelegate {
    
    private func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("begin")
        self.resetIndicatorState(true)
        self.delegate?.webViewStartLoad?(self)
    }
    
    private func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("load success")
        self.resetIndicatorState(false)
        self.delegate?.webViewLoadSuccess?(self)
        
        var js: String!
        
        for ( _ , item) in self.javaScriptMethods {
            if let method = item.methodName {
                
                if let obj = item.obj {
                    if let objArr = obj as? [String] {
                        
                        var param = ""
                        
                        for tmp in objArr {
                            if param.count == 0 {
                                param += "'\(tmp)'"
                            } else {
                                param += ",'\(tmp)'"
                            }
                        }
                        if let method = item.methodName {
                            js = method + "('\(param)')"
                        }
                    }
                } else if let json = item.jsonString {
                    
                    js = method + "\(method)('\(json)')"
                } else {
                    js = method + "('')"
                }
            }
            
            webView.evaluateJavaScript(js) { (info, error) in
                print(error?.localizedDescription ?? "error")
            }
        }
    }
    
    private func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.resetIndicatorState(false)
        self.delegate?.webView?(self, loadFailed: error)
    }
    
    private func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if self.delegate?.webView?(self, authenticationChallenge: challenge, completionHandler: completionHandler) == nil {
            
            if isAuthChallenge == false {
                
                completionHandler(URLSession.AuthChallengeDisposition.performDefaultHandling, nil)
                return
            }
            
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                
                if let trust = challenge.protectionSpace.serverTrust {
                    let cred = URLCredential(trust: trust)
                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, cred)
                }
                
            } else {
                
                completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            }
        }
    }
    
    
}
//MARK: - WKUIDelegate
extension LQWebView: WKUIDelegate {
    
    /**
     webView中弹出警告框时调用, 只能有一个按钮
     
     @param webView webView
     @param message 提示信息
     @param frame 可用于区分哪个窗口调用的
     @param completionHandler 警告框消失的时候调用, 回调给JS
     */
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        self.uiDelegate?.webView?(self, alertJSMessage: message, completionHandler: completionHandler)
    }
    
    /** 对应js的confirm方法
     webView中弹出选择框时调用, 两个按钮
     
     @param webView webView description
     @param message 提示信息
     @param frame 可用于区分哪个窗口调用的
     @param completionHandler 确认框消失的时候调用, 回调给JS, 参数为选择结果: YES or NO
     */
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        self.uiDelegate?.webView?(self, confirmJSMessage: message, completionHandler: completionHandler)
    }
    
    /** 对应js的prompt方法
     webView中弹出输入框时调用, 两个按钮 和 一个输入框
     
     @param webView webView description
     @param prompt 提示信息
     @param defaultText 默认提示文本
     @param frame 可用于区分哪个窗口调用的
     @param completionHandler 输入框消失的时候调用, 回调给JS, 参数为输入的内容
     */
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        self.uiDelegate?.webView?(self, textInputJSMessage: prompt, defaultText: defaultText, completionHandler: completionHandler)
    }
}



extension LQWebView {
    
    private func resetIndicatorState(_ isShow: Bool) {
        
        if isShow {
            if self.isShowIndicator {
                self.activityIndicator.startAnimating()
            }
            
            if self.isShowNetIndicator {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
            
            if self.isShowProgressIndicator {
                self.progressView.alpha = 1.0
                self.progressView.transform = CGAffineTransform(scaleX: 1.0, y: 1.5)
            }
        } else {
            
            if self.isShowIndicator {
                self.activityIndicator.stopAnimating()
            }
            
            if self.isShowNetIndicator {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            if self.isShowProgressIndicator {
                self.progressView.alpha = 0.0
                self.progressView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }
    }
    
    private func objToJSON(_ obj: Any) -> String? {
        
        if let obj = obj as? String {
            
            return obj
        } else if let obj = obj as? Data {
            
            return String.init(data: obj, encoding: String.Encoding.utf8)
        }
        
        let data = try? JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        
        guard let dt = data else { return nil }
        
        return String.init(data: dt, encoding: String.Encoding.utf8)
    }
}

//MARK: - ========= 存储一些方法参数模型 =========
private struct LQJavaScriptItem {
    var key: String = ""
    var jsonString: String?
    var methodName: String?
    var handler: LQWebViewScriptMessageHandler?
    var obj: Any?
    
}

//MARK: - 解决使用 WKUserContentController 实例时的内存泄露问题
/*
 将
 let user = WKUserContentController()
 // 向js中注入协议, 作为ios和js交互的依据
 user.add(self, name: "appProtocol")
 
 改为:
 let user = WKUserContentController()
 // 向js中注入协议, 作为ios和js交互的依据
 user.add(LQScriptMessage.init(self), name: "appProtocol")
 
 或者使用方法
 user.addHandler(self, name: "appProtocol")
 即可!
 */
public class LQScriptMessageHandler: NSObject, WKScriptMessageHandler {
    
    weak var delegate: WKScriptMessageHandler?
    
    init(_ delegate: WKScriptMessageHandler) {
        super.init()
        
        self.delegate = delegate
    }
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}

public extension WKUserContentController {
    func addHandler(_ message: Any, name: String) {
        if let msg = message as? WKScriptMessageHandler {
            self.add(LQScriptMessageHandler(msg), name: name)
        }
    }
}

