//
//  MSReuseWebView.swift
//  复用WebView
//
//  Created by 冯笑 on 2021/4/6.
//  Copyright © 2021 MS. All rights reserved.
//

import UIKit
import WebKit


public class MSReuseWebView: WKWebView {
    
     weak var holdObject: AnyObject?
    
    deinit {
        //清除所有UserScript
        configuration.userContentController.removeAllUserScripts()
        //停止加载
        stopLoading()
        //代理和持有都置为空
        holdObject = nil
        uiDelegate = nil
        navigationDelegate = nil
        scrollView.delegate = nil
    }
    
    
     public class func msChangeHandlesURLScheme()  {
        if #available(iOS 12.0, *) {
            let originalSelector = #selector(handlesURLScheme(_:))
            let swizzledSelector = #selector(msHandlesURLScheme(_:))
            guard let originMethod = class_getClassMethod(self, originalSelector) else {return}
            guard let replaceMethod = class_getClassMethod(self, swizzledSelector) else { return }
            method_exchangeImplementations(originMethod, replaceMethod)
        }
    }
    
    @objc public class func msHandlesURLScheme(_ urlScheme: String) -> Bool {
        
        if #available(iOS 12.0, *) {
            if urlScheme == "https" || urlScheme == "http"{
                return false
            }
            return self.msHandlesURLScheme(urlScheme)
        } else {
            return true
        }
    }
}

extension MSReuseWebView:MSWebViewReusePoolProtocol{
    
    func reuseWebViewWillReuse() {
        
    }
    
    func reuseWebViewWillEndReuse() {
        
        if #available(iOS 12.0, *) {
            if let schemeHandler = self.configuration.urlSchemeHandler(forURLScheme: "https") as? MSURLSchemeHandler{
                schemeHandler.stopAllURLSchemeTask()
            }
        }
        
        stopLoading()
        holdObject = nil
        scrollView.delegate = nil
        navigationDelegate = nil
        uiDelegate = nil
        loadHTMLString("", baseURL: nil)
    }
    
}
