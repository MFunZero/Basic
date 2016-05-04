//
//  ClearCacheViewController.swift
//  Originality
//
//  Created by fanzz on 16/4/9.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class ClearCacheViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "reuse")
        cell.frame = CGRect(x: 0, y: 74, width: screenWidth, height: 50)
        self.view.addSubview(cell)
        
        cell.textLabel?.textAlignment = .Center
        cell.textLabel?.text = "清除缓存"
        cell.backgroundColor = contentColor
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ClearCacheViewController.clearCache(_:)))
        cell.addGestureRecognizer(tap)
    }

   
}
extension ClearCacheViewController {
    func clearCache(tap:UITapGestureRecognizer){
        SVProgressHUD.show()
        
        self.navigationController!.navigationBar.userInteractionEnabled=false //将nav事件禁止
        
        
        
        self.view.userInteractionEnabled=false //界面
        
        let model = SearchHistoryModel()
        model.deleteFile()
        let fileManager = NSFileManager.defaultManager()
        let enumerator:NSDirectoryEnumerator = fileManager.enumeratorAtPath(folder)!
        
            while let element = enumerator.nextObject() as? String {
                if element.hasSuffix("jpg") || element.hasSuffix("png") {
                    try! fileManager.removeItemAtPath(folder + "/"+element)
                }
            }
        let home = NSHomeDirectory() as NSString
        let path = home.stringByAppendingPathComponent("Documents") as String
        let enumerator1:NSDirectoryEnumerator = fileManager.enumeratorAtPath(path)!
        while let element = enumerator1.nextObject() as? String {
            if element.hasSuffix("jpg") || element.hasSuffix("png") {
                try! fileManager.removeItemAtPath(path + "/"+element)
            }
        }
        let delta = 2.0 * Double(NSEC_PER_SEC)
        let dtime = dispatch_time(DISPATCH_TIME_NOW, Int64(delta))
        dispatch_after(dtime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            SVProgressHUD.showSuccessWithStatus("清除缓存完成")
            self.navigationController!.navigationBar.userInteractionEnabled=true //将nav事件禁止
            
            self.view.userInteractionEnabled=true //界面
        }

    }
}
