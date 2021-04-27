//
//  WebViewController.swift
//  websecondopen
//
//  Created by 冯笑 on 2021/4/26.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var urlString: String
    var timer: DispatchSourceTimer?
    var lastTime: Double?
    
    lazy var webview: WKWebView = {
        let wkwebView = MSWebViewReusePool.shared.getReuseWebView(ForHolder: self,preLoad: true)!
        wkwebView.navigationDelegate = self
        wkwebView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)

        return wkwebView
    }()
    
    lazy var progressLine: UIProgressView = {
        let line = UIProgressView(frame: CGRect.zero)
        line.backgroundColor = UIColor.white
        line.progressTintColor = UIColor.red
        line.isHidden = true
        return line
    }()
    
    lazy var loadTimeLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.textColor = UIColor.red
        label.backgroundColor = UIColor.gray
        label.font = UIFont.systemFont(ofSize: 18)
        return label
    }()
    
    init(urlString: String) {
        self.urlString = urlString
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webview.frame = view.bounds
        view.addSubview(webview)
        progressLine.frame = CGRect(x: 0, y: 88, width: view.bounds.width, height: 1)
        view.addSubview(progressLine)
        view.bringSubviewToFront(progressLine)
        
        view.addSubview(loadTimeLabel)
        loadTimeLabel.frame = CGRect(x: UIScreen.main.bounds.size.width - 100, y: 100, width: 100, height: 50)
        view.bringSubviewToFront(loadTimeLabel)
        
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webview.load(request)
        
        
        // 开启定时器
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        timer!.schedule(deadline: .now(), repeating: DispatchTimeInterval.microseconds(1))
        lastTime = CFAbsoluteTimeGetCurrent()
        self.loadTimeLabel.text = String(format: "%.3f", lastTime!)
        timer!.setEventHandler {
            let time = CFAbsoluteTimeGetCurrent() - self.lastTime!
            self.loadTimeLabel.text = String(format: "%.3f秒", time)
        }
        timer?.activate()
    }
    
    deinit {
       webview.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        MSWebViewReusePool.shared.recycleReuseWebView(webview as? MSReuseWebView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if webview.title == nil {
            webview.reload()
        }
        webview.configuration.userContentController.add(self, name: "jsObj")
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webview.configuration.userContentController.removeScriptMessageHandler(forName: "jsObj")
    }
    
    // 观察者
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let value = change?[NSKeyValueChangeKey.newKey] as! NSNumber
        progressLine.progress = value.floatValue
    }
}

// MARK: - WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {
    
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressLine.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.title", completionHandler: { [weak self] (x, error) in
            print(x as Any)
            print(error as Any)
            self?.title = (x as! String)
        })
        
        progressLine.isHidden = true
        timer?.cancel()
        timer = nil
    }
    
}

extension WebViewController:WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let dic = message.body as? [String: Any] {
            guard let key = dic["key"]! as? String else { return }
            switch key {
            case "postBannerJSBridge":
                self.postJSBridgeParm()
                break
            default: break
            }
        }
    }
    
    func postJSBridgeParm() {
        webview.evaluateJavaScript("Hybird && Hybird.JSBridge && Hybird.JSBridge('{\"article_id\":\"\",\"exam_id\":\"\",\"status_id\":\"\",\"status\":\"\",\"oral_homework_id\":\"\",\"type\":\"\",\"page_type\":\"16\",\"question_id\":\"\",\"token\":\"LLqBNoB7F2heLOOhFvI1lhNSNicOvWClKyxkifonSxn2NlSdHPf8o2Ncd4pq\",\"encrypted_id\":\"\",\"stu_id\":\"454140\",\"lesson_id\":\"\",\"version\":\"4.1.1\",\"assignment_id\":\"\",\"org_lesson_id\":\"\",\"class_id\":\"\",\"video_url\":\"\",\"num\":\"\",\"lesson_name\":\"\",\"nav_is_hidden\":false,\"school_id\":3742,\"organization_name\":\"shirley测试机构001\",\"org_class_id\":\"\",\"evaluate_type\":0,\"live_class_id\":\"\",\"challenge_id\":\"\",\"feedback_id\":\"\",\"imei\":\"iOS\",\"navbarHeight\":44,\"assignment_type\":\"\",\"device_type\":1}')") {
            (item, error) in
            print(error ?? "no error")
        }
    }
    
}
