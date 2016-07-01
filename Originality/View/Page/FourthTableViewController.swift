//
//  FourthTableViewController.swift
//  Originality
//
//  Created by suze on 16/2/9.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class FourthTableViewController: UITableViewController {
    var avatar:String!
    var username:String!
    var user:BmobUser!
    override func viewWillAppear(animated: Bool) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我"
        
        user = BmobUser.getCurrentUser()
        
        username = user.username
        if user.objectForKey("avatar") != nil{
            avatar = user.objectForKey("avatar") as! String
        }
        self.view.backgroundColor = bgColor
        
        
        
        self.tableView.registerClass(UserTableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        self.tableView.registerClass(PersonTableViewCell.self, forCellReuseIdentifier: "reuse")
        
        self.tableView.contentSize = CGSize(width: screenWidth, height: self.tableView.frame.height + 100)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(FourthTableViewController.changeStatus(_:)), name: "changeAvatar", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(FourthTableViewController.changeUsername(_:)), name: "changeUsername", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(FourthTableViewController.changeAutograph(_:)), name: "changeAutograph", object: nil)
    }
    
    func changeAutograph(notification:NSNotification)
    {
        self.user = BmobUser.getCurrentUser()
        self.tableView.reloadData()
    }
    func changeUsername(notification:NSNotification)
    {
        self.user = BmobUser.getCurrentUser()
        self.tableView.reloadData()
    }

    
    func changeStatus(notification:NSNotification)
    {let dict = notification.userInfo! as NSDictionary
        self.avatar = dict.objectForKey("avatar") as? String
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 2
        }
        else if section == 2 {
            return 3
        }
        else {
            return 1
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UserTableViewCell
            
            if avatar != nil {
            cell.avatar = self.avatar
            }
            else {
                cell.avatarView.image = UIImage(named: defaultHeaderImage)
            }
            cell.nameLabel.text = username
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            return cell
        }
      else {
            let cell = tableView.dequeueReusableCellWithIdentifier("reuse", forIndexPath: indexPath) as! PersonTableViewCell
            let tag = indexPath.row
            switch tag {
            case 0:
                cell.picture.image = UIImage(named: "tabbar_compose_photo@2x.png")
                cell.titleLabel.text = "我的专辑"
            case 1:
                cell.picture.image = UIImage(named: "tabbar_compose_review@2x")
                cell.titleLabel.text = "我喜欢的专辑"
            default:
                cell.picture.image = UIImage(named: "messagescenter_good")
                cell.titleLabel.text = "我的赞"
        }
            
            if indexPath.section == 2 {
            
                let tag = indexPath.row
                switch tag {
                case 0:
                    cell.picture.image = UIImage(named: "cm2_login_icn_nickname@2x")
                    cell.titleLabel.text = "个人信息"
                case 1:
                    cell.picture.image = UIImage(named: "cm2_list_detail_icn_infor")
                    cell.titleLabel.text = "通用"
                default:
                    cell.picture.image = UIImage(named: "cm2_set_icn_set")
                    cell.titleLabel.text = "关于我们"
            }
                }
             if indexPath.section == 3 {
                
                    cell.picture.image = UIImage(named: "")
                    cell.titleLabel.text = "退出当前账号"
                    cell.titleLabel.textAlignment = .Center
                cell.titleLabel.textColor = UIColor.redColor()
                }
            
            return cell
    }
    
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3{
            return 0.01
        }
        else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            return 100
            
        }
        else {
            return 40
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 64
        }
        else {
            return 10
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            
            let view = UIView()
            view.backgroundColor = bgColor
            return view
        }
        else {
            let view = UIView()
            view.backgroundColor = bgColor
            return view
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
         if indexPath.row == 0 && indexPath.section == 0{
            let vc = UserMessageDetailController(collectionViewLayout: UserCollectionLayout())
            vc.userId = self.user.objectId
            vc.user = self.user
            vc.avatar = self.avatar
            if self.user.objectForKey("autograph") != nil{
            vc.autograph = self.user.objectForKey("autograph") as! String
            }
            vc.autograph = "当我第一次知道要签名的时候，我是拒绝的！"
            
            self.getData(self.user.objectId) { (singleData) -> Void in
                vc.singleData = singleData
                 if (self.navigationController!.topViewController!.isKindOfClass(MainController)) {
                  self.navigationController?.pushViewController(vc, animated: true)
                    
                }
            }
         }else if (indexPath.section == 1) {
                
                let tag = indexPath.row
                switch tag {
                case 0:
                    let vc = SpecialCollectionViewController(collectionViewLayout: SpecialCollectionViewLayout())
                   
                    self.getSpecials(self.user.objectId) { (singleData) -> Void in
                        vc.specials = singleData
                         if (self.navigationController!.topViewController!.isKindOfClass(MainController)) {
                        self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                case 1:
                    let vc = LikeSpecialsCollectionViewController(collectionViewLayout: SpecialCollectionViewLayout())
                    
                    self.getLikeSpecials(self.user.objectId) { (singleData) -> Void in
                        vc.specials = singleData
                         if (self.navigationController!.topViewController!.isKindOfClass(MainController)) {
                        self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                default:
                    break
                }
            }
          else  if indexPath.section == 2 {
                
                let tag = indexPath.row
                switch tag {
                case 0:
                    
                    let vc = SettingPageTableViewController()
                    vc.user = self.user
                    if let atr = user.objectForKey("avatar") {
                        print("avatar:\(self.avatar)")
                        vc.avatar = atr as! String
                    }
                     if (self.navigationController!.topViewController!.isKindOfClass(MainController)) {
                     self.navigationController?.pushViewController(vc, animated: true)
                    }
                case 1:
                    if (self.navigationController!.topViewController!.isKindOfClass(MainController)) {self.navigationController?.pushViewController(ClearCacheViewController(), animated: true)
                    }
                case 2:
                    if (self.navigationController!.topViewController!.isKindOfClass(MainController)) {self.navigationController?.pushViewController(AboutUseViewController(), animated: true)
                    }

                    break
                    
                default:
                    break
                }
            }
            else{
            self.logout();
                
            }
  tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
  
    
}

extension FourthTableViewController{
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
                    if let url = obj.objectForKey("url"){
                        spInfo.url = url  as! String
                        Collection.downLoadPicture(url as! String, callback: { (flag) in
                            print("\(flag)")
                        })
                    }
                    
                    
                    
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
                    
                    if let title = special.objectForKey("title"){
                        spInfo.specialName  = title as! String
                    }
                    else {
                        spInfo.specialName  = "默认专辑"
                    }
                    
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
    func alertView(alertView:UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if(buttonIndex==alertView.cancelButtonIndex){
            print("点击了取消")
        }
        else
        {
            print("点击了确认")
            
            BmobUser.logout()
            if (self.navigationController!.topViewController!.isKindOfClass(MainController)) {
                self.navigationController?.pushViewController(LoginViewController(), animated: true)
                
            }
        }
    }
    func logout(){
        let alertView = UIAlertView()
        alertView.title = "系统提示"
        alertView.message = "您确定要退出登录吗？"
        alertView.addButtonWithTitle("取消")
        alertView.addButtonWithTitle("确定")
        alertView.cancelButtonIndex=0
        alertView.delegate=self;
        alertView.show()
      
    }
    func userClick(sender:UITapGestureRecognizer){
      //  let tap:UITapGestureRecognizer = sender

    }
    
    func getSpecials(userId:String, callback:((NSMutableArray) -> Void)!){
        let data:NSMutableArray = NSMutableArray()
        let query:BmobQuery = BmobQuery(className:"special")
        query.whereKey("userId", equalTo: userId)
        query.includeKey("userId")
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock({array,error in
            var tag:Int = 0
            for obj in array{
                if obj is BmobObject{
                    let spInfo:SpecialInfo = SpecialInfo()
                    
                    if preLoading {
                        spInfo.tagId = tag
                    }
                    else {
                        spInfo.tagId = data.count
                    }
                    spInfo.objectId = obj.objectId
                    spInfo.title = obj.objectForKey("title") as! String
                    
                    if let pictureName = obj.objectForKey("mainPicture"){
                    spInfo.pictureName = pictureName as! String
                    }
                    
                    
                    BmobProFile.downloadFileWithFilename(spInfo.pictureName, block: { (successful, error, str) -> Void in
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
                    
                    spInfo.userId = self.user.objectId
                    
                    spInfo.username = self.user.username
                    if self.avatar != nil {
                    spInfo.userAvator = self.avatar
                    //根据收藏情况获取计数情况以及具体内容
                    }
                    
                    if obj.objectForKey("liker") != nil {
                        
                        spInfo.liker = obj.objectForKey("liker") as! Array
                        spInfo.likerCount = spInfo.liker.count
                        
                    }
                    else {
                        spInfo.likerCount = 0
                    }
                    
                    data.addObject(spInfo)
                    tag = tag + 1
                    if (tag == array.count){
                        callback(data)
                    }
                }
            }
            callback(data)
            }
        )
        
    }
    func getLikeSpecials(userId:String, callback:((NSMutableArray) -> Void)!){
        let data:NSMutableArray = NSMutableArray()
        let bquery = BmobQuery(className: "special")
        
        let obj = BmobObject(outDatatWithClassName: "_User", objectId: userId)
        bquery.whereObjectKey("likeSpecials", relatedTo: obj)
        bquery.includeKey("userId")
        bquery.orderByDescending("createdAt")
        bquery.findObjectsInBackgroundWithBlock({array,error in
            var tag:Int = 0
            for obj in array{
                if obj is BmobObject{
                    
                    
                    let spInfo:SpecialInfo = SpecialInfo()
                    
                    if preLoading {
                        spInfo.tagId = tag
                    }
                    else {
                        spInfo.tagId = data.count
                    }
                    spInfo.objectId = obj.objectId
                    spInfo.title = obj.objectForKey("title") as! String
                    
                    if let pictureName = obj.objectForKey("mainPicture"){
                        spInfo.pictureName = pictureName as! String
                    }
                    
                    
                    BmobProFile.downloadFileWithFilename(spInfo.pictureName, block: { (successful, error, str) -> Void in
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
                    spInfo.userId = self.user.objectId
                    
                    spInfo.username = self.user.username
                    if self.avatar != nil {
                        spInfo.userAvator = self.avatar
                        //根据收藏情况获取计数情况以及具体内容
                    }
                    
                    //根据收藏情况获取计数情况以及具体内容
                    
                    if obj.objectForKey("liker") != nil {
                        
                        spInfo.liker = obj.objectForKey("liker") as! Array
                        spInfo.likerCount = spInfo.liker.count
                        
                    }
                    else {
                        spInfo.likerCount = 0
                    }
                    
                    data.addObject(spInfo)
                    tag = tag + 1
                    if (tag == array.count){
                        callback(data)
                    }
                }
            }
            callback(data)
            }
        )
        
    }

}
