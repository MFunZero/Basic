//
//  Collection.swift
//  Originality
//
//  Created by suze on 16/1/16.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class Collection: UICollectionViewController{

   
    var status:Bool!
    var datas:Int = PageDataCount
    var page:Int = 0
    var singleData:NSMutableArray = NSMutableArray()
   
    
    internal override  init(collectionViewLayout layout: UICollectionViewLayout){
   
        let layout = CollectionViewLayout()
    
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        
        self.collectionView?.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
      
        self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FootView")
        self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        self.collectionView!.registerClass(CollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
       
        self.collectionView!.nowRefreshWithCallback({
            self.singleData.removeAllObjects()
            self.page = 0
            self.getPageDatas()
            
            let delayInSeconds:Int64 = 1000000000 * 2
            let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                self.collectionView!.contentSize = self.view.frame.size
                self.collectionView!.reloadData()
                
                self.collectionView!.headerEndRefreshing()
            
  
               
            })
        })
       
        self.collectionView?.backgroundColor = bgColor
        self.setupRefresh()
        self.collectionView!.alwaysBounceVertical = true
    }
    
    func getPageDatas()
    {
        let query:BmobQuery = BmobQuery(className:"SinglePicture")
        query.limit = PageDataCount
        
        query.includeKey("userId,specialId")
        query.orderByDescending("createdAt")
        query.skip = page * PageDataCount
        query.findObjectsInBackgroundWithBlock({array,error in
            var tag:Int = 0
            for obj in array{
                if obj is BmobObject{
                   

                    let spInfo:SinglePictureInfo = SinglePictureInfo()
                  
                    spInfo.objectId = obj.objectId
                    spInfo.title = obj.objectForKey("title") as! String
                    
                    if let url = obj.objectForKey("url"){
                        spInfo.url = url as! String
                        Collection.downLoadPicture(url as! String, callback: { (flag) in
                            print("count:\(self.singleData.count),\(flag)")
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
                
                    if let title = special.objectForKey("title") {
                       spInfo.specialName = title as! String
                    }
                    else{
                        spInfo.title = ""
                    }

                   
                   //根据评论、点赞、收藏情况获取计数情况以及具体内容
                    
                   
                    
                    if obj.objectForKey("comment") != nil {
                        
                    spInfo.comment = obj.objectForKey("comment") as! Array
                    spInfo.commentCount = spInfo.comment.count
                        
                    }
                    else {
                        spInfo.commentCount = 0
                    }
                    self.getVoterCount(obj.objectId, callback: { (num) in
                        spInfo.upvoteCount = num
                      
                        self.getCollectionCount(obj.objectId, callback: { (count) in
                            spInfo.collectionCount = count
                            
                            
                        })
                    })
                    
                    self.singleData.addObject(spInfo)
                    tag = tag + 1
                    
                    
                }
            }
            }
        )
    }
    

    
    func setupRefresh()
    {
      
        self.collectionView!.addFooterWithCallback({
            let startRow = self.singleData.count
            self.page = self.page + 1
            self.getPageDatas()
            
            
            let delayInSeconds:Int64 =  1000000000 * 2
            let popTime:dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW,delayInSeconds)
            dispatch_after(popTime, dispatch_get_main_queue(), {
                
                var size = self.collectionView!.contentSize
                size.height = size.height + CGFloat(screenWidth / 2)  * CGFloat(PageDataCount / 2) * 1.8
                
                
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    
                    
                    let rowEnd = self.singleData.count
                    var indexpaths = [NSIndexPath]()
                    for i in startRow ..< rowEnd {
                        let indexPath = NSIndexPath(forRow:i , inSection: 0)
                        indexpaths.append(indexPath)
                    }
                    
                    self.collectionView?.insertItemsAtIndexPaths(indexpaths)
                })
                
                self.collectionView!.headerEndRefreshing()
                
               
                self.collectionView!.footerEndRefreshing()
                
                
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView:UICollectionReusableView!
        if kind ==  UICollectionElementKindSectionFooter {
            reusableView = collectionView.dequeueReusableSupplementaryViewOfKind( kind, withReuseIdentifier: "FootView", forIndexPath: indexPath)
            print("Footer")
           //reusableView.backgroundColor = UIColor(red:234/255.0, green:235/255.0,blue:236/255.0,alpha: 1)
            self.confirEnding({ (num) in
                if num == self.singleData.count {
                    self.collectionView?.setFooterHidden(true)
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
                }
            })
        }else if kind == UICollectionElementKindSectionHeader{
            reusableView = collectionView.dequeueReusableSupplementaryViewOfKind( kind, withReuseIdentifier: "HeaderView", forIndexPath: indexPath)
            
            let imageScroll:ImageScroll = ImageScroll()
            let viewScroll:ViewScroll = ViewScroll()
            
            imageScroll.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 160)
            imageScroll.imagesName = ["bg1","bg3","bg7","bg8"]
            imageScroll.time = 5
            imageScroll.addImages()
            
            
            
            viewScroll.frame = CGRect(x: 0, y: 160, width: screenWidth, height: 120)
            viewScroll.backgroundColor = UIColor.whiteColor()
            viewScroll.imagesName = ["bg1","bg3","bg7","bg8"]
            viewScroll.imageTitle = ["泛黄银杏","记忆之秋","光漏","风起时，云翩然"]
            viewScroll.time = 5
            viewScroll.addImages()
            
            reusableView.addSubview(imageScroll)
            reusableView.addSubview(viewScroll)
            
           
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
        var cell:CollectionCell!
        
        if cell == nil {
         cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? CollectionCell
    
        if singleData.count != 0 {
           
            let sp:SinglePictureInfo = singleData[indexPath.row] as! SinglePictureInfo
            
            cell.filename = sp.url
           
            if sp.userAvator != nil{
            cell.avatar = sp.userAvator
            }
            cell.titleLabel.text = sp.title
            SinglePictureDetailController.getCollectionCount(sp.objectId, callback: { (count) in
                sp.collectionCount = count + 1
                cell.collectionLabel.text = String(count + 1)
            })
            
                cell.commentLable.text = String(sp.commentCount)
                cell.nameLabel.text = preString+sp.userName
                cell.specialName.text = sp.specialName
                Collection.getVoteCount(sp.objectId, callback: {(num) in
                    cell.voteLabel.text = "\(num)"
                })
                
                cell.singlePictureId = sp.objectId
                cell.userId = sp.userId
            
    
           
            let tag = indexPath.row
            print("click:detail1111:::\(tag)")
            cell.topContentView.tag = tag
            cell.topContentView.userInteractionEnabled = true
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Collection.detailClick(_:)))
            
            cell.topContentView.addGestureRecognizer(tap)
            
            cell.textView.tag = tag
            cell.textView.userInteractionEnabled = true
            cell.textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Collection.userClick(_:))))
            
        }
     
        }
        return cell!
    }

//    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        let cell:CollectionCell = collectionView.cellForItemAtIndexPath(indexPath) as! CollectionCell
//          let tag = indexPath.row
//        print("click:detail1111:::\(tag)")
//        cell.topContentView.tag = tag
//        cell.topContentView.userInteractionEnabled = true
//        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Collection.detailClick(_:)))
//       
//        cell.topContentView.addGestureRecognizer(tap)
//
//        cell.textView.tag = tag
//        cell.textView.userInteractionEnabled = true
//        cell.textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Collection.userClick(_:))))
//        
//    }
    
    func detailClick(sender:UITapGestureRecognizer){
        let tap:UITapGestureRecognizer = sender 
        let tag:Int = tap.view!.tag
        let obj:SinglePictureInfo = singleData[tag] as! SinglePictureInfo
        
         print("click:detail:::\(tap.view!.tag)")
        
        
        let vc:SinglePictureDetailController = SinglePictureDetailController()
        vc.singlePictureInfo = obj
        vc.title = titleForDetail
        var specialIds:[String] = [String]()
        specialIds.append(obj.specialId)
        print("flag1:\(specialIds)")
       
            Collection.getCollectionList(obj.objectId, callback: { (specialsId) in
                if specialsId.count > 0{
                    for id in specialsId {
                       specialIds.append(id)
                    }
                }
                vc.specials = specialIds
                print("flag2:\(specialIds),count:\(specialsId.count)")
              
                if (self.navigationController!.topViewController!.isKindOfClass(MainController)) {
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                    }
            
                
            })
        
       
        
    }
    
    func userClick(sender:UITapGestureRecognizer){
        let tap:UITapGestureRecognizer = sender
        let tag:Int = tap.view!.tag
        let obj:SinglePictureInfo = singleData[tag] as! SinglePictureInfo
        
        let vc:UserCollectionViewController = UserCollectionViewController(collectionViewLayout: UserCollectionLayout())
        vc.userId = obj.userId
        vc.username = obj.userName
        vc.userAvatar = obj.userAvator
        vc.specialName = obj.specialName
        vc.specialId = obj.specialId
        
        
            let query = BmobQuery(className: "SinglePicture")
            query.whereKey("userId", equalTo: obj.userId)
            query.countObjectsInBackgroundWithBlock({ (num, error) in
                if error != nil {
                    
                }
                else{
                    vc.count =  Int(num)
                    
                    if (self.navigationController!.topViewController!.isKindOfClass(MainController)) {
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                        print("click:user")
                    }
                }
            })

        }
        
    
    
    }


extension Collection {
    class func getLikeStatus(userId:String,specialId:String,callback:(Bool -> Void)){
        var likeStatus = false
        let bquery = BmobQuery(className: "special")
        let post = BmobObject(outDatatWithClassName: "_User", objectId: userId)
        
        bquery.whereObjectKey("likeSpecials", relatedTo: post)
        
        bquery.findObjectsInBackgroundWithBlock({array,error in
            //var tag:Int = 0
            for bj in array{
                if bj is BmobObject{
                    if specialId == bj.objectId
                    {
                        likeStatus = true
                    }
                }
            }
            callback(likeStatus)
        })
    }
    func confirEnding(callback:((Int) -> Void)!){
        let query = BmobQuery(className: "SinglePicture")
        query.countObjectsInBackgroundWithBlock { (num, error) in
            if error != nil{
                print("countAllError:\(error)")
            }
            else{
                callback(Int(num))
            }
        }
        
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
    
   class func getVoteCount(singlePictureId:String,callback:(Int->Void)){
        let bquery = BmobQuery(className: "_User")
        
        let post = BmobObject(outDatatWithClassName: "SinglePicture", objectId: singlePictureId)
        bquery.whereObjectKey("vote", relatedTo: post)
        bquery.countObjectsInBackgroundWithBlock { (num, error) in
            if error != nil {
                callback(0)
            }
            else {
                callback(Int(num))
            }
        }
    }
    class  func downLoadPicture(url:String,callback:(Bool -> Void)){
        BmobProFile.downloadFileWithFilename(url, block: { (success, error, str) in
            if error != nil{
                print("downLoadError:\(error)")
                callback(false)
            }else{
                callback(true)
                print("downLoadsuccess:\(success)")
            }
            }, progress: { (index) in
                if index >= 1.0 {
                    print("success")
                }
        })
        callback(false)
    }
   }
