//
//  SearchHistoryModel.swift
//  Originality
//
//  Created by fanzz on 16/4/6.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class SearchHistoryModel: NSObject {
    var historyList = [SearchHistory]()
    
    override init() {
        super.init()
        print("沙盒文件夹路径:\(NSHomeDirectory().stringByAppendingString("/tmp"))")
        print("数据文件路径:\(self.dataFilePath())")
    }
    
    func saveData(){
        let path = self.dataFilePath()
        
        let defaultManager = NSFileManager.defaultManager()
        
        let exist = defaultManager.fileExistsAtPath(path)
        if !exist {
            let data = NSMutableData()
            
            let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
            
            archiver.encodeObject(historyList, forKey: "historyList")
            
            archiver.finishEncoding()
            
           // data.writeToFile(dataFilePath(), atomically: true)
            
            defaultManager.createFileAtPath(path, contents: data, attributes: nil)
        }
        else{
            let data = NSMutableData()
            
            let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
            
            archiver.encodeObject(historyList, forKey: "historyList")
            
            archiver.finishEncoding()
            
            data.writeToFile(dataFilePath(), atomically: true)
        }
        
        
    }
    
    func loadData()->[SearchHistory]{
        let path = self.dataFilePath()
        
        let defaultManager = NSFileManager.defaultManager()
        
        if defaultManager.fileExistsAtPath(path){
            
            let data = NSData(contentsOfFile: path)
            
            let unarchiver = NSKeyedUnarchiver(forReadingWithData: data!)
            
            if let  list = unarchiver.decodeObjectForKey("historyList") {
                historyList = list as! Array
            }
            
            unarchiver.finishDecoding()
        }
        
    return historyList
    }
    
    func deleteFile(){
        let path = self.dataFilePath()
        
        let defaultManager = NSFileManager.defaultManager()
        
        if defaultManager.fileExistsAtPath(path){
        
            print("coming")
            try! defaultManager.removeItemAtPath(path)
        }

    }
    
    func documentsDirectory()->String{
        let paths = NSHomeDirectory().stringByAppendingString("/tmp")
        
        let documnetsDirectory:String = paths
        
        return documnetsDirectory
    }
    
    func dataFilePath()->String{
        
        return self.documentsDirectory().stringByAppendingString("/historySearch.plist")
    }
}
