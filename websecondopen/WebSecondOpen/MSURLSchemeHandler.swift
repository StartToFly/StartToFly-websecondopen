//
//  MSWebViewReusePool.swift
//  MSURLSchemeHandler拦截处理Handler
//
//  Created by 冯笑 on 2021/4/6.
//  Copyright © 2021 MS. All rights reserved.
//

import UIKit
import Foundation
import WebKit
import CoreServices
import CommonCrypto



@available(iOS 11.0, *)
public class MSURLSchemeHandler: NSObject {

    //秒开是否开启
    public var preload:Bool = false
    
    // 防止 urlSchemeTask 实例释放了，但是资源还在处理，导致像nil发送指令导致崩溃
    var holdUrlSchemeTasks = [URLSessionDataTask: WKURLSchemeTask]()

    
    //分发资源请求
    func dispenseResourceRequest(urlSchemeTask:WKURLSchemeTask)  {
        guard let requestUrlString = urlSchemeTask.request.url?.absoluteString else { return }
        debugPrint("H5秒开:" + "拦截到的请求资源地址：",requestUrlString)
        let fileName = requestUrlString.components(separatedBy: "/").last
        let resourceName = fileName?.components(separatedBy: "?").first
        let componetPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] + "/MSPWebSecondOpenComponent"

        var localContainResource = false
        var loaclResourcePath = ""

        if preload{
            for path in MSFileOperation.listFolder(folderUrl: componetPath){
                if let resourceName = resourceName{
                    if resourceName.count > 0 {
                        let fileManager = FileManager.default
                        let resourcePath = componetPath + "/" + path + "/" + resourceName
                        if fileManager.fileExists(atPath: resourcePath){
                            localContainResource = true
                            loaclResourcePath = resourcePath
                            break
                        }
                    }
                }
            }
            //判断本地是否包含该资源，有则加载本地，没有加载远程
            if localContainResource{
                loadLocalResource(urlSchemeTask: urlSchemeTask, filePath: loaclResourcePath)
            }else{
                loadRemoteResource(urlSchemeTask: urlSchemeTask)
            }
        }else{
            loadRemoteResource(urlSchemeTask: urlSchemeTask)
        }
       
    }
    
    //加载本地资源
    private func loadLocalResource(urlSchemeTask:WKURLSchemeTask,filePath:String)  {
        //本地资源命中
        guard let absoluteString = urlSchemeTask.request.url?.absoluteString else { return }
        debugPrint("H5秒开:" + "命中本地资源:", absoluteString)
        guard let data = NSData(contentsOfFile: filePath) else { return }
        let mimeType = String.mimeType(pathExtension: filePath)
        guard let url = urlSchemeTask.request.url else { return }
        let response = URLResponse(url: url, mimeType: mimeType, expectedContentLength: data.count, textEncodingName: "utf-8")
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data as Data)
        urlSchemeTask.didFinish()
    }
    
    //加载远程资源
    private func loadRemoteResource(urlSchemeTask:WKURLSchemeTask) {
        //未命中本地资源，加载远程资源
        guard let urlString = urlSchemeTask.request.url?.absoluteString else { return }
        debugPrint("H5秒开:" + "加载远程资源:" , urlString)
        let request = urlSchemeTask.request
        let config = URLSessionConfiguration.default
        let urlSession = URLSession.init(configuration: config)
        let task = urlSession.dataTask(with: request ) { (data, response, error)  in
                        
            guard let data = data , let response = response else { return }
            urlSchemeTask.didReceive(response)
            urlSchemeTask.didReceive(data)
            
            if let error = error {
                urlSchemeTask.didFailWithError(error)
            }else{
                urlSchemeTask.didFinish()
            }
        }
        self.holdUrlSchemeTasks[task] = urlSchemeTask
        task.resume()
    }
    

    //页面回收时取消所有正在进行的请求,防止SchemeHandler结束，但是请求未结束
    public func stopAllURLSchemeTask() {
        for task in self.holdUrlSchemeTasks.keys{
            task.cancel()
        }
        debugPrint("H5秒开:取消所有URLSchemeTask")
        self.holdUrlSchemeTasks.removeAll()
    }
    
}



@available(iOS 11.0, *)
extension MSURLSchemeHandler:WKURLSchemeHandler{
    
    public func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        print("holdUrlSchemeTasks===",self.holdUrlSchemeTasks)
        dispenseResourceRequest(urlSchemeTask: urlSchemeTask)
    }
    
    public func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        for task in self.holdUrlSchemeTasks.keys{
            if self.holdUrlSchemeTasks[task]?.description == urlSchemeTask.description{
                task.cancel()
                break
            }
        }
    }
    
}

extension String{
    
    //根据后缀获取对应的Mime-Type
    static func mimeType(pathExtension: String?) -> String {
        guard let url = URL(string: pathExtension!) else { return "" }
        let pathExtension = url.pathExtension
        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                           pathExtension as CFString,
                                                           nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?
                .takeRetainedValue() {
                return mimetype as String
            }
        }
        
        //此参数表示通用的二进制类型
        return "application/octet-stream"
    }
}
