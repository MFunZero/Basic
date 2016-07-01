//
//  UserCollectionViewController.swift
//  Originality
//
//  Created by suze on 16/1/29.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class UserCollectionViewController: UICollectionViewController {

    var likeStatus:Bool = false
    
    var likeTagView:UIImageView = UIImageView()
    //
    var specialNameLabel:UILabel = UILabel()
    var userAvatarView:UIImageView = UIImageView()
    var userNameLabel:UILabel = UILabel()
    
    //跳转到当前界面中所传递过来的参数
    var specialId:String!
    var specialName:String!
    var username:String!
    var userId:String!
    var userAvatar:String?{
        willSet{
            self.userAvatarView.image = UIImage(named: "default_avatar")
        }
        didSet{
            BmobProFile.getFileAcessUrlWithFileName(userAvatar) { (file, error) -> Void in
                    if error != nil {
                        print("error:\(error)")
                    }
                    else {
                        let url = file.url
                        let data = NSData(contentsOfURL: NSURL(string: url)!)
                        if data != nil {
                            self.userAvatarView.image = UIImage(data: data!)
                        }
                    }
            }
    }
    }
    
  
    var count:Int!
  
    var singleData:NSMutableArray = NSMutableArray()
    
    
    var startContentOffsetY:CGFloat!
    var willEndContentOffsetY:CGFloat!
    var endContentOffsetY:CGFloat!
    
    var _lastPosition:CGFloat = 0
    
    override  init(collectionViewLayout layout: UICollectionViewLayout){
        
        let layout = UserCollectionLayout()
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        let leftBarView = UIImageView(image: UIImage(named: "white_left"))
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBarView)
        
        
        
        
        self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FootView")
        self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        self.collectionView!.registerClass(UserCollectioncell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
            self.addLikeView()
       
                   self.getPageDatas()
        
        self.collectionView?.backgroundColor = bgColor
        self.collectionView!.alwaysBounceVertical = true
        
        
        self.collectionView!.alwaysBounceVertical = true
        
       
    }
    
    func addLikeView(){
        let x = screenWidth / 2 - 30
        let y = screenHeight - 70
        likeTagView.frame = CGRect(x: x, y: y, width: 60.0, height: 60.0)
        
        if likeStatus {
        likeTagView.image = UIImage(named: "woxinshui_frame1")
    
        }
        else {
            likeTagView.image = UIImage(named: "xinshui_like_active")

        }
        if let user = BmobUser.getCurrentUser(){
            Collection.getLikeStatus(user.objectId, specialId: self.specialId, callback: { (flag) in
                self.likeStatus = flag
                print("falg:\(flag)")
                if self.likeStatus {
                    self.likeTagView.image = UIImage(named: "woxinshui_frame1")
                    
                }
                else {
                    self.likeTagView.image = UIImage(named: "xinshui_like_active")
                    
                }
            })
        }
        likeTagView.layer.borderColor = contentColor.CGColor
        likeTagView.layer.cornerRadius = 30.0
        likeTagView.layer.borderWidth = 4.0
        
        
        self.view.addSubview(likeTagView)
        
        likeTagView.userInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(UserCollectionViewController.handleTouches(_:)))
        likeTagView.addGestureRecognizer(tapGestureRecognizer)
    }
    func getPageDatas()
    {
       self.getSinglePicturesFromSpecial(self.specialId) { (infos) in
        if infos.count > 0 {
        self.singleData.addObjectsFromArray(infos)
        print("infos:\(self.singleData.count)")
        }
        self.getSinglePicturesFromCollection(self.specialId, callback: { (spInfos) in
            
            self.singleData.addObjectsFromArray(spInfos)
            print("singleDataC:\(self.singleData.count)")
            self.collectionView!.reloadData()
        })
        }
    }
  
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView:UICollectionReusableView!
        if kind ==  UICollectionElementKindSectionFooter {
            reusableView = collectionView.dequeueReusableSupplementaryViewOfKind( kind, withReuseIdentifier: "FootView", forIndexPath: indexPath)
            print("Footer")
            let splitViewLeft:UIImageView = UIImageView(frame: CGRect(x: 50, y:25, width: screenWidth/2 - 80, height: 1))
            splitViewLeft.backgroundColor = splitViewColor
            
            reusableView.addSubview(splitViewLeft)
            
            let splitViewRight:UIImageView = UIImageView(frame: CGRect(x: screenWidth/2 + 30, y: 25, width: splitViewLeft.frame.width, height: 1))
            splitViewRight.backgroundColor = splitViewColor
            
            reusableView.addSubview(splitViewRight)
            
            
            let label = UILabel(frame: CGRect(x: splitViewLeft.frame.origin.x + splitViewLeft.frame.width, y: 15, width: 60, height: 20))
            label.text = "End"
            label.textAlignment = NSTextAlignment.Center
            label.textColor = splitViewColor
            
            reusableView.addSubview(label)
            
            
        }else if kind == UICollectionElementKindSectionHeader{
            reusableView = collectionView.dequeueReusableSupplementaryViewOfKind( kind, withReuseIdentifier: "HeaderView", forIndexPath: indexPath)
            
            let imageBG:UIImageView = UIImageView(frame: reusableView.frame)
            imageBG.image = UIImage(named: "img_login")
            
            reusableView.addSubview(imageBG)
            
            specialNameLabel.frame = CGRect(x: screenWidth / 2 - 50, y: 30, width: 100, height: 20)
            specialNameLabel.textAlignment = .Center
            specialNameLabel.text = specialName
            
            imageBG.addSubview(specialNameLabel)
            
            let splitView:UIImageView = UIImageView(frame: CGRect(x: specialNameLabel.frame.origin.x, y: specialNameLabel.frame.origin.y + specialNameLabel.frame.height + 15, width: specialNameLabel.frame.width, height: 1))
            splitView.backgroundColor = splitViewColor
            
            imageBG.addSubview(splitView)
            
            
            
            
            userAvatarView.frame = CGRect(x: screenWidth / 2 - 20, y: splitView.frame.origin.y + 15, width: 40, height: 40)
            userAvatarView.layer.cornerRadius = userAvatarView.frame.width / 2
            userAvatarView.clipsToBounds = true
            imageBG.addSubview(userAvatarView)

            if self.userAvatar == nil {
            userAvatarView.image = UIImage(named: "default_avatar")
            }
            userAvatarView.layer.borderWidth = 1
            userAvatarView.layer.borderColor = contentColor.CGColor
            BmobProFile.getFileAcessUrlWithFileName(self.userAvatar) { (file, error) -> Void in
                if error != nil {
                    print("error:\(error)")
                }
                else {
                    let url = file.url
                    let data = NSData(contentsOfURL: NSURL(string: url)!)
                    if data != nil {
                        self.userAvatarView.image = UIImage(data: data!)
                    }
                }
            }
            
            userNameLabel.frame = CGRect(x: screenWidth / 2 - 50, y: userAvatarView.frame.origin.y + 40 + 10, width: 100, height: 20)
            userNameLabel.textAlignment = .Center
            imageBG.addSubview(userNameLabel)
            
            userNameLabel.text = username

            
        }
        return reusableView
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return  1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
            return self.singleData.count
       
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UserCollectioncell!
        
        if cell == nil {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? UserCollectioncell
            
            if singleData.count != 0 {
                // print("sgData:\(singleData[indexPath.row])")
                
                let sp:SinglePictureInfo = singleData[indexPath.row] as! SinglePictureInfo
                
                cell.filename = sp.url
                cell.titleLabel.text = sp.title
                SinglePictureDetailController.getCollectionCount(sp.objectId, callback: { (count) in
                    sp.collectionCount = count + 1
                    cell.collectionLabel.text = String(count + 1)
                })
                
                cell.commentLable.text = String(sp.commentCount)
                Collection.getVoteCount(sp.objectId, callback: {(num) in
                    cell.voteLabel.text = "\(num)"
                })
                
                    
                    
                    cell.singlePictureId = sp.objectId
                    cell.userId = sp.userId
                    cell.contentView.tag = indexPath.row
                    
                    

                
            }
            
        }
        return cell!
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tag = indexPath.row
        
        
        let vc:SinglePictureDetailController = SinglePictureDetailController()
        vc.singlePictureInfo = singleData[tag] as? SinglePictureInfo
        vc.title = titleForDetail
        var specialIds:[String] = [String]()
        specialIds.append(singleData[tag].specialId)
        print("flag1:\(specialIds)")
        
        UserCollectionViewController.getCollectionList(singleData[tag].objectId, callback: { (specialsId) in
            if specialsId.count > 0{
                for id in specialsId {
                    specialIds.append(id)
                }
            }
            vc.specials = specialIds
            print("flag2:\(specialIds),count:\(specialsId.count)")
            
            if (self.navigationController!.topViewController!.isKindOfClass(UserCollectionViewController)) {
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            
        })
        
        
        
    }
    
  
    
   
    

    override func scrollViewWillBeginDragging(scrollView: UIScrollView)
    {
        startContentOffsetY = scrollView.contentOffset.y
    }
    
    override func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        willEndContentOffsetY = scrollView.contentOffset.y
    }
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView)
    {
        endContentOffsetY = scrollView.contentOffset.x;
        if (endContentOffsetY < willEndContentOffsetY && willEndContentOffsetY < startContentOffsetY) { //画面从右往左移动,前一页
            print("前一页")
        } else if (endContentOffsetY > willEndContentOffsetY && willEndContentOffsetY > startContentOffsetY) {//画面从左往右移动,后一页
            print("后一页")
        }
    }

    override func scrollViewDidScroll(scrollView: UIScrollView) {
        print("scroll")
        let currentPostion = scrollView.contentOffset.y
        if (currentPostion  > 60) {
            _lastPosition = currentPostion
            NSLog("ScrollDown now")
          // self.navigationController?.navigationBar.hidden = true
       
            
        }
        else if ( currentPostion < 64)
        {
           // self.navigationController?.navigationBar.hidden = false
            _lastPosition = currentPostion
            NSLog("ScrollUP now")
        }
    }
}

extension UserCollectionViewController{
    func handleTouches(sender:UITapGestureRecognizer){
         if let obj = BmobUser.getCurrentUser() {
        if likeStatus {
            let post = BmobObject(outDatatWithClassName: "_User", objectId: obj.objectId)
            let relation = BmobRelation()
            relation.removeObject(BmobObject(outDatatWithClassName: "special", objectId: self.specialId))
            
            post.addRelation(relation, forKey: "likeSpecials")
            post.updateInBackgroundWithResultBlock({ (success, error) in
                if success {
                    
                    let post = BmobObject(outDatatWithClassName: "special", objectId: self.specialId)
                    let relation = BmobRelation()
                    relation.removeObject(BmobObject(outDatatWithClassName: "_User", objectId: obj.objectId))
                    
                    post.addRelation(relation, forKey: "beingCollection")
                    post.updateInBackgroundWithResultBlock({ (success, error) in
                        if success {
                    self.likeStatus = false
                    //喜欢状态
                    self.likeTagView.image = UIImage(named: "xinshui_like_active")
                        }
                        else{
                        
                            SVProgressHUD.showErrorWithStatus("操作失误\(error)，请重试")
                        }
                    })
                }
                else {
                    SVProgressHUD.showErrorWithStatus("操作失误\(error)，请重试")
                }
            })
           
        }
        else {
            
            let post = BmobObject(outDatatWithClassName: "_User", objectId: obj.objectId)
            let relation = BmobRelation()
            relation.addObject(BmobObject(outDatatWithClassName: "special", objectId: self.specialId))
            
            post.addRelation(relation, forKey: "likeSpecials")
            post.updateInBackgroundWithResultBlock({ (success, error) in
                if success {
                    let post = BmobObject(outDatatWithClassName: "special", objectId: self.specialId)
                    let relation = BmobRelation()
              
                    relation.addObject(BmobObject(outDatatWithClassName: "_User", objectId: obj.objectId))
                    
                    post.addRelation(relation, forKey: "beingCollection")
                    post.updateInBackgroundWithResultBlock({ (success, error) in
                        if success {
                            
                            self.likeStatus = true
                            //取消喜欢状态
                            self.likeTagView.image = UIImage(named: "woxinshui_frame1")
                        }
                        else{
                            SVProgressHUD.showErrorWithStatus("操作失误\(error)，请重试")
                        }
                    })

                }
                else {
                    SVProgressHUD.showErrorWithStatus("操作失误\(error)，请重试")
                }
            })
            

        }
        }
         else {
            
            let vc = LoginViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    
        }
    func getSinglePicturesFromSpecial(specialId:String,callback:([SinglePictureInfo]->Void)){
    var pictures:[SinglePictureInfo] = [SinglePictureInfo]()
        let query = BmobQuery(className: "SinglePicture")
    query.whereKey("specialId", equalTo: specialId)
    query.includeKey("userId,specialId")
    query.orderByDescending("createdAt")
    query.findObjectsInBackgroundWithBlock({array,error in
    for obj in array{
    if obj is BmobObject{
    let spInfo:SinglePictureInfo = SinglePictureInfo()
    
    spInfo.objectId = obj.objectId
    spInfo.title = obj.objectForKey("title") as! String
    
    spInfo.url = obj.objectForKey("url") as! String
    
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
    
    if let title = special.objectForKey("title") {
    spInfo.title = title as? String
    }
    else{
    spInfo.title = ""
    }
    
    
    //根据评论、点赞、收藏情况获取计数情况以及具体内容
    
   
       if obj.objectForKey("comment") != nil {
    
    spInfo.comment = obj.objectForKey("comment") as! Array<NSDictionary>
    spInfo.commentCount = spInfo.comment.count
    
    }
    else {
    spInfo.commentCount = 0
    }
    pictures.append(spInfo)
        print("1111:\(pictures.count)")
    }
    }
        print("ccc:\(pictures.count)")
        callback(pictures)

    }
    )
    
    

    }
    func getSinglePicturesFromCollection(specialId:String,callback: (([SinglePictureInfo])->Void)){
        var pictures:[SinglePictureInfo] = [SinglePictureInfo]()
        let bquery = BmobQuery(className: "SinglePicture")
        
        let post = BmobObject(outDatatWithClassName: "special", objectId: specialId)
        
        bquery.whereObjectKey("collectionSinglePictures", relatedTo: post)
        bquery.includeKey("userId")
        bquery.findObjectsInBackgroundWithBlock({array,error in
            var tag:Int = 0
            for obj in array{
                if obj is BmobObject{
                    let spInfo:SinglePictureInfo = SinglePictureInfo()
                    
                    spInfo.objectId = obj.objectId
                    spInfo.title = obj.objectForKey("title") as! String
                    
                    spInfo.url = obj.objectForKey("url") as! String
                    
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
                    
                    if let title = special.objectForKey("title") {
                        spInfo.title = title as? String
                    }
                    else{
                        spInfo.title = ""
                    }
                    
                    
                    
                    if obj.objectForKey("comment") != nil {
                        
                        spInfo.comment = obj.objectForKey("comment") as! Array<NSDictionary>
                        spInfo.commentCount = spInfo.comment.count
                        
                    }
                    else {
                        spInfo.commentCount = 0
                    }
                    
                    
                    
                    pictures.append(spInfo)
                    // print("spinfo:\(self.singleData)")
                    tag = tag + 1

                }
            }
            callback(pictures)
            }
            
        )
    }
    
   class func getCollectionList(singlePictureId:String,callback:(([String]) -> Void)!){
        var specialsId:[String] = [String]()
        let bquery = BmobQuery(className: "special")
        
        let post = BmobObject(outDatatWithClassName: "SinglePicture", objectId: singlePictureId)
        
        bquery.whereObjectKey("beingCollection", relatedTo: post)
        
        bquery.findObjectsInBackgroundWithBlock({array,error in
            for bj in array{
                if bj is BmobObject{
                    specialsId.append(bj.objectId)
                    print("bj:\(bj.objectId)")
                }
            }
            callback(specialsId)
            }
            
        )
        
    }
    func getVoterCount(singlePictureId:String,callback:((Int) -> Void)!){
        let bquery = BmobQuery(className: "_User")
        
        let post = BmobObject(outDatatWithClassName: "SinglePicture", objectId: singlePictureId)
        
        bquery.whereObjectKey("vote", relatedTo: post)
        
        bquery.countObjectsInBackgroundWithBlock { (num, error) in
            var count = 0
            if error != nil{
                print("error")
            }
            else {
                count = Int(num)
            }
            callback(count)
        }
        
        
    }
    func getCollectionCount(singlePictureId:String,callback:((Int) -> Void)!){
        let bquery = BmobQuery(className: "special")
        
        let post = BmobObject(outDatatWithClassName: "SinglePicture", objectId: singlePictureId)
        
        bquery.whereObjectKey("beingCollection", relatedTo: post)
        
        bquery.countObjectsInBackgroundWithBlock { (num, error) in
            var count = 0
            if error != nil{
                print("error")
            }
            else {
                count = Int(num)
            }
            callback(count)
        }
    }


}