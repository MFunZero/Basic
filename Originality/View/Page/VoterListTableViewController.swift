//
//  VoterListTableViewController.swift
//  Originality
//
//  Created by fanzz on 16/4/9.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class VoterListTableViewController: UITableViewController {

    var voter:[String] = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()

      self.tableView.registerClass(CustomTableViewCell.self, forCellReuseIdentifier: "identi")
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.voter.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("identi", forIndexPath: indexPath)
        as! CustomTableViewCell

        getSpecialMessage(self.voter[indexPath.row]) { (sp) in
            if sp.avatar != nil {
                cell.fileName = sp.avatar
            }
            cell.titleLabel.text = sp.autograph
            cell.detailLabel.text = "by " + sp.username
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tag = indexPath.row
        let vc = UserMessageDetailController(collectionViewLayout: UserCollectionLayout())
        vc.userId = self.voter[tag]
        getSpecialMessage(self.voter[tag]) { (user) in
            vc.user = user
            if user.avatar != nil {
            vc.avatar = user.avatar
            }
            vc.autograph = user.autograph
            
            self.getData(user.objectId) { (singleData) -> Void in
                vc.singleData = singleData
                if (self.navigationController!.topViewController!.isKindOfClass(VoterListTableViewController)) {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
        }
           }


}
extension VoterListTableViewController {
    func getData(userId:String, callback:((NSMutableArray) -> Void)!){
        let data:NSMutableArray = NSMutableArray()
        let query:BmobQuery = BmobQuery(className:"SinglePicture")
        query.limit = PageDataCount
        query.whereKey("userId", equalTo: userId)
        query.includeKey("userId,specialId")
        
        let date:NSDate = NSDate()
        
        query.whereKey("updatedAt", lessThanOrEqualTo: date)
        
        query.findObjectsInBackgroundWithBlock({array,error in
            var tag:Int = 0
            for obj in array{
                if obj is BmobObject{
                    
                    
                    let spInfo:SinglePictureInfo = SinglePictureInfo()
                    
                  
                    spInfo.objectId = obj.objectId
                    spInfo.title = obj.objectForKey("title") as! String
                    
                    spInfo.url = obj.objectForKey("url") as! String
                    
                    BmobProFile.downloadFileWithFilename(spInfo.url, block: { (successful, error, str) -> Void in
                        if successful {
                            
                            print("downloadFileWithFilename GET successful to:\(str):home:\(NSHomeDirectory())")
                        }
                        else if error != nil {
                            print("error:\(error)")
                        }
                        }, progress: { (pro) -> Void in
                            print("progress:\(pro)")
                    })
                    
                    //根据所关联的用户信息获取用户头像
                    let user:BmobUser = obj.objectForKey("userId") as! BmobUser
                    spInfo.userId = user.objectId
                    spInfo.userName = user.username
                    if user.objectForKey("avatar") != nil {
                        spInfo.userAvator = user.objectForKey("avatar") as! String
                    }
                    //获取专辑信息
                    let special:BmobObject = obj.objectForKey("specialId") as! BmobObject
                    spInfo.specialId = special.objectId
                    
                    spInfo.specialName = special.objectForKey("title") as! String
                    
                    //根据评论、点赞、收藏情况获取计数情况以及具体内容
                    
                    if obj.objectForKey("upvote") != nil {
                        
                        spInfo.upvote = obj.objectForKey("upvote") as! Array
                        spInfo.upvoteCount = spInfo.upvote.count
                        
                    }
                    else {
                        spInfo.upvoteCount = 0
                    }
                    
                    if obj.objectForKey("collection") != nil {
                        
                        spInfo.collection = obj.objectForKey("collection") as! Array<NSDictionary>
                        spInfo.collectionCount = spInfo.collection.count
                        
                    }
                    else {
                        spInfo.collectionCount = 0
                    }
                    
                    if obj.objectForKey("comment") != nil {
                        
                        spInfo.comment = obj.objectForKey("comment") as! Array<NSDictionary>
                        spInfo.commentCount = spInfo.comment.count
                        
                    }
                    else {
                        spInfo.commentCount = 0
                    }
                    data.addObject(spInfo)
                    tag = tag + 1
                    if (tag == array.count){
                        callback(data)
                    }
                }
            }
            }
        )
        
    }

    func getSpecialMessage(id:String,callback:(UserInfo -> Void)){
        let obj = BmobUser(outDatatWithClassName: "_User", objectId: id)
     
            let sp = UserInfo()
           
                sp.objectId = obj.objectId
                sp.username = obj.username
                if let avatar = obj.objectForKey("avatar") {
                    sp.avatar = avatar as! String
                    
                }
                if let autograph = obj.objectForKey("autograph") {
                    sp.autograph = autograph as! String
                    
                }
            callback(sp)

    }

}
