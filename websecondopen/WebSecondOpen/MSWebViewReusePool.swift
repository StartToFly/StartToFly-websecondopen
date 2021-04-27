//
//  MSWebViewReusePool.swift
//  WebView复用池
//
//  Created by 冯笑 on 2021/4/6.
//  Copyright © 2021 MS. All rights reserved.
//

import UIKit
import WebKit


protocol MSWebViewReusePoolProtocol {
    //复用WebView将要被复用
    func reuseWebViewWillReuse()
    //复用WebView将要结束复用
    func reuseWebViewWillEndReuse()
}

open class MSWebViewReusePool: NSObject {
    
    //可用复用WebView集合
    public var visiableReuseWebViewSet = Set<MSReuseWebView>()
    //已复用WebView集合
    public var reusableReuseWebViewSet = Set<MSReuseWebView>()
    //信号量线程锁
    public  var semaphoreLock:DispatchSemaphore = DispatchSemaphore.init(value: 1)
    
    //单例初始WebView复用池
    public static var shared: MSWebViewReusePool {
        struct Static {
            static let instance: MSWebViewReusePool = MSWebViewReusePool.init()
        }
        return Static.instance
    }
    
    //WKWebViewConfiguration默认配置
    public lazy var defaultConfigeration: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        //用于自动播放音频
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = .init(rawValue: 0)
        } else {
            // Fallback on earlier versions
            config.requiresUserActionForMediaPlayback = false
        }

        if #available(iOS 12.0, *) {
            //插入同步Cookie的JS
            let jsPath =  Bundle.main.url(forResource: "synCookieJS", withExtension: "txt" )
            do {
                if let path = jsPath{
                    let jsString = try String(contentsOf: path, encoding: .utf8)
                    let userScript = WKUserScript.init(source: jsString, injectionTime: .atDocumentStart, forMainFrameOnly: false)
                    config.userContentController.addUserScript(userScript)
                }
            } catch {

            }
            
            // 校验自定义 customScheme 是否已经可用，没有注册过才能使用
            guard let _ =  config.urlSchemeHandler(forURLScheme: "https"),let _ =  config.urlSchemeHandler(forURLScheme: "http") else {
                let urlSchemeHandler = MSURLSchemeHandler()
                config.setURLSchemeHandler(urlSchemeHandler, forURLScheme: "https")
                config.setURLSchemeHandler(urlSchemeHandler, forURLScheme: "http")
                return config
            }

        }

        return config
    }()
    

    func prepareReuseWebView()  {
        debugPrint("准备复用池")
        DispatchQueue.main.async {
            let reuseWebView = MSReuseWebView.init(frame: CGRect.zero, configuration: self.defaultConfigeration)
            self.visiableReuseWebViewSet.insert(reuseWebView)
        }
    }
    
   public func disposalReuseWebView()  {
        semaphoreLock.wait()
        var canUseReuseWebViewSet = Set<MSReuseWebView>()
        for webView in self.visiableReuseWebViewSet{
            guard let  _ = webView.holdObject else {
                canUseReuseWebViewSet.insert(webView)
                continue
            }
        }
        
        for webView in canUseReuseWebViewSet {
            webView.reuseWebViewWillEndReuse()
            self.visiableReuseWebViewSet.remove(webView)
            self.reusableReuseWebViewSet.insert(webView)
        }
        
        semaphoreLock.signal()
    }
}

//MARK: MSWebViewReusePool复用池相关操作
extension MSWebViewReusePool{
    
    //获取WebView
    public func getReuseWebView(ForHolder holder: AnyObject?,preLoad:Bool = true) -> MSReuseWebView? {
        guard let _ = holder else { return nil }
        disposalReuseWebView()
        let webViewHolder:MSReuseWebView
        semaphoreLock.wait()
        if reusableReuseWebViewSet.count > 0{
            webViewHolder = reusableReuseWebViewSet.randomElement()!
            reusableReuseWebViewSet.remove(webViewHolder)
            visiableReuseWebViewSet.insert(webViewHolder)
            webViewHolder.reuseWebViewWillReuse()
        }else{
            webViewHolder = MSReuseWebView.init(frame: CGRect.zero, configuration: self.defaultConfigeration)
            visiableReuseWebViewSet.insert(webViewHolder)
        }
        webViewHolder.holdObject = holder
        if #available(iOS 12.0, *) {
            if let schemeHandler = webViewHolder.configuration.urlSchemeHandler(forURLScheme: "https") as? MSURLSchemeHandler{
                schemeHandler.preload = preLoad
            }
        }
        semaphoreLock.signal()
        return webViewHolder
    }
    
    //回收WebView
    func recycleReuseWebView(_ webView: MSReuseWebView?)  {
        guard let reuseWebView = webView else { return }
        
        semaphoreLock.wait()
        if visiableReuseWebViewSet.contains(reuseWebView){
            reuseWebView.reuseWebViewWillEndReuse()
            visiableReuseWebViewSet.remove(reuseWebView)
            reusableReuseWebViewSet.insert(reuseWebView)
        }
        semaphoreLock.signal()
    }
    
    
}
