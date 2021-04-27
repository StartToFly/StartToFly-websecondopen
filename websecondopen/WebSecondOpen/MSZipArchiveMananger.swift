//
//  MSArchiveMananger.swift
//  未来魔法校解压缩管理类
//
//  Created by 冯笑 on 2021/3/26.
//

import UIKit
import SSZipArchive

public class MSZipArchiveMananger {
    
    //单例初始化解压缩管理类
    public static var shared: MSZipArchiveMananger {
        struct Static {
            static let instance: MSZipArchiveMananger = MSZipArchiveMananger.init()
        }
        return Static.instance
    }
    
    
    /// 单个文件解压
    /// - Parameters:
    ///   - atPath: 压缩包所在路径
    ///   - toDestination: 压缩包解压路径
    ///   - deleateAfterSuccess: 解压成功后是否删除压缩包
    ///   - progress: 解压缩进度
    ///   - completion: 解压缩完成回调
    public func unzipFile(atPath:String,
                          toDestination:String,
                          deleateAfterSuccess:Bool = false,
                          progress:@escaping ((String,unz_file_info,Int,Int)->Void),
                          completion:@escaping ((String,Bool,Error?)->Void)) {
        let concurrentQueue = DispatchQueue.init(label: "com.unzipFiles.asyncConcurrentQueue",attributes: [.concurrent])
        concurrentQueue.async {
            SSZipArchive.unzipFile(atPath: atPath, toDestination: toDestination) { (entry, zipInfo, entryNumber, total) in
                DispatchQueue.main.async {
                    progress(entry,zipInfo,entryNumber,total)
                }
            } completionHandler: { (path, success, error) in
                DispatchQueue.main.async {
                    completion(path, success, error)
                    if deleateAfterSuccess{
                        let fileManager = FileManager.default
                        do {
                            try fileManager.removeItem(atPath: atPath)
                        } catch { }
                    }
                }
            }
            
        }
    }
}
