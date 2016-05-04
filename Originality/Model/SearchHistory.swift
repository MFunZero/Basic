//
//  SearchHistory.swift
//  Originality
//
//  Created by fanzz on 16/4/6.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class SearchHistory: NSObject {
    var title:String!
    var time:NSDate!
    
    
    init(title:String,time:NSDate) {
        self.title = title
        self.time = time
    }
    
    init(coder aDecoder:NSCoder) {
        self.time = aDecoder.decodeObjectForKey("time") as! NSDate
        self.title = aDecoder.decodeObjectForKey("title") as! String
    }
    
    func encodeWithCoder(aDecoder:NSCoder){
        aDecoder.encodeObject(title, forKey: "title")
        aDecoder.encodeObject(time, forKey: "time")
    }
    
    
}
