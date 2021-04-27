//
//  MSFileOperation.swift
//  MSPUI
//
//  Created by gang zhao on 2021/4/6.
//

import Foundation

public class MSFileOperation {
    
    // 复制一个文件，到目标位置
    public static func copyFile(sourceUrl:String, targetUrl:String) {
        let fileManager = FileManager.default
        do{
            try fileManager.copyItem(atPath: sourceUrl, toPath: targetUrl)
            print("Success to copy file.")
        }catch let error as NSError{
            print(error)
        }
    }
    
    // 移动文件到目标位置
    public static func movingFile(sourceUrl:String, targetUrl:String,completion:@escaping (Bool)->()){
        let fileManager = FileManager.default
        let targetUrl = targetUrl
        print("targetUrl = \(targetUrl)")
        do{
            try fileManager.moveItem(atPath: sourceUrl, toPath: targetUrl)
            completion(true)
            print("Succsee to move file.")
        }catch{
            completion(false)
            print("Failed to move file.")
        }
    }
    
    // 删除目标文件
    public static func removeFile(sourceUrl:String){
        let fileManger = FileManager.default
        do{
            try fileManger.removeItem(atPath: sourceUrl)
            print("Success to remove file.")
        }catch{
            print("Failed to remove file.")
        }
    }
    
    // 删除目标文件夹下所有的内容
    public static func removeFolder(folderUrl:String){
        let fileManger = FileManager.default
        //        然后获得所有该目录下的子文件夹
        guard let files:[AnyObject] = fileManger.subpaths(atPath: folderUrl) as [AnyObject]? else { return }
        //        创建一个循环语句，用来遍历所有子目录
        for file in files
        {
            do{
                //删除指定位置的内容
                try fileManger.removeItem(atPath: folderUrl + "/\(file)")
                print("Success to remove folder.")
            }catch{
                print("Failder to remove folder")
            }
        }
        
    }
    
    // 遍历目标文件夹
    public static func listFolder(folderUrl:String) -> [String] {
        let manger = FileManager.default
        var contents = [String]()
        do {
            //获得文档目录下的所有目录，并存储在一个数组对象中
            contents = try manger.contentsOfDirectory(atPath: folderUrl)
            print("contents:\(contents)\n")
            //        获得文档目录下所有的内容，以及子文件夹下的内容，在控制台打印所有的数组内容
            //        let contents = manger.enumerator(atPath: folderUrl)
            //            print("contents:\(String(describing: contents?.allObjects))")
            
        } catch {
            
        }
        return contents
    }
    
    public static func writeFile(filepath:String,info:String,completion:@escaping (Bool)->())  {
        do{
            //            将文本文件写入到指定位置的文本文件，并且使用utf-8的编码方式
            try info.write(toFile: filepath, atomically: true, encoding: .utf8)
            completion(true)
            print("Success to write a file.\n")
        }catch{
            print("Error to write a file.\n")
            completion(false)
        }
    }
    
  
    
    //按照创建日期进行排序
    public static func sortFileArray(sort array:inout [String],filePath:String){
        for i in 0 ..< array.count {
            for j in i + 1 ..< array.count {
                let fullPath = filePath + array[i]
                let nextPath = filePath + array[j]
                do {
                    if let fileDate = try FileManager.default.attributesOfItem(atPath: fullPath)[.creationDate] as? Date
                       ,let nextDate = try FileManager.default.attributesOfItem(atPath: nextPath)[.creationDate] as? Date,
                       fileDate.compare(nextDate) == .orderedAscending{
                        exchangeValue(&array, i, j)
                    }
                } catch let error as NSError {
                    print("error  \(error)")
                }
            }
        }
    }
    public static func exchangeValue<T>(_ nums:inout [T],_ a:Int,_ b:Int){
        (nums[a],nums[b]) = (nums[b],nums[a])
    }
}
