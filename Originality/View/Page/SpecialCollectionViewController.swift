//
//  SpecialCollectionViewController.swift
//  Originality
//
//  Created by fanzz on 16/3/31.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SpecialCollectionViewController: UICollectionViewController,UIGestureRecognizerDelegate ,UIAlertViewDelegate{
   
    var specials:NSMutableArray = NSMutableArray()
    
    internal override  init(collectionViewLayout layout: UICollectionViewLayout){
        
        let layout = SpecialCollectionViewLayout()
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "我的专辑"
        
        if self.specials.count == 0 {
            SVProgressHUD.showInfoWithStatus("您还未创建专辑哦")
        }
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "btn_add"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(SpecialCollectionViewController.addSpecial))
        
        self.navigationItem.rightBarButtonItem = rightButton
        
        self.collectionView?.backgroundColor = bgColor
        // Register cell classes
        self.collectionView!.registerClass(SpecialCollectionCellCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ChoseSpecialTableViewController.notificationAction(_:)), name: "NotificationIdentifier", object: nil);
        
        
        
    }
    
    
    
    func notificationAction(fication : NSNotification){
       
        let userId = BmobUser.getCurrentUser().objectId
        self.getSpecials(userId) { (singleData) -> Void in
            self.specials = singleData
            self.collectionView!.reloadData()
        }
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
//        return self.specials.count
        return self.specials.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! SpecialCollectionCellCollectionViewCell
     
        let special = self.specials[indexPath.row] as! SpecialInfo
        cell.titleLabel.text = special.title
        if special.pictureName != nil {
        cell.filename = special.pictureName
        }
        else {
            cell.imageView.image = UIImage(named: defaultImage)
        }
        SpecialCollectionViewController.getPictureCount(special.objectId) { (pCount) in
            
            SpecialCollectionViewController.getLikerCount(special.objectId, callback: { (lCount) in
                let str:[String] = ["\(pCount)","\(lCount)"]
                cell.detail = str
            })
        }
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(SpecialCollectionViewController.handleTouch(_:)))
        cell.addGestureRecognizer(tap)
        tap.minimumPressDuration = 1.0
        tap.delegate = self
        tap.view?.tag = indexPath.row
        return cell
    }
    func handleTouch(tap:UILongPressGestureRecognizer){
        if tap.state == UIGestureRecognizerState.Began {
            NSLog("beginLongPress")
         confirmDelete(tap.view?.tag)
            }else if tap.state == UIGestureRecognizerState.Ended{
            NSLog("endedLongPress")
        }
    }
    func alertView(alertView:UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if(buttonIndex==alertView.cancelButtonIndex){
            print("点击了取消")
        }
        else
        {
            print("点击了确认\(alertView.tag),count:\(self.specials.count)")
            SVProgressHUD.show()
            self.view.userInteractionEnabled = false
            self.navigationController?.navigationBar.userInteractionEnabled = false
            
            let picture = BmobQuery(className: "SinglePicture")
            picture.whereKey("specialId", equalTo: self.specials[(alertView.tag)].objectId)
            picture.findObjectsInBackgroundWithBlock({ (pictures, error) in
                for p in pictures {
                    if p is BmobObject {
                        let objId = p.objectId
                        let obj = BmobObject(outDatatWithClassName: "SinglePicture", objectId: p.objectId)
                        obj.deleteInBackgroundWithBlock({ (isSuccess, error) in
                            if isSuccess {
                                print("delete Success:\(objId)")
                            }
                            else{
                                print("delete error:\(objId)")
                            }
                        })
                    }
                }
                let spId = self.specials[alertView.tag].objectId
                let sp = BmobObject(outDatatWithClassName: "special", objectId: spId)
                sp.deleteInBackgroundWithBlock({ (isSuccess, error) in
                    if isSuccess {
                        print("deleteSp Success:\(spId)")
                        if self.specials.count > 1 {
                            
                            self.specials.removeObjectAtIndex(alertView.tag)
                            let indexPath = NSIndexPath(forRow: alertView.tag, inSection: 0)
//                            self.collectionView?.deleteItemsAtIndexPaths([indexPath])
                            self.collectionView?.reloadData()
                            
                            SVProgressHUD.showSuccessWithStatus(nil)
                            let delta = 2.0 * Double(NSEC_PER_SEC)
                            let dtime = dispatch_time(DISPATCH_TIME_NOW, Int64(delta))
                            dispatch_after(dtime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                                self.view.userInteractionEnabled = true
                                self.navigationController?.navigationBar.userInteractionEnabled = true
                            }
                            
                        }
                        else{
                            self.specials.removeAllObjects()
                            self.collectionView?.reloadData()
                            SVProgressHUD.showSuccessWithStatus(nil)
                            self.view.userInteractionEnabled = true
                            self.navigationController?.navigationBar.userInteractionEnabled = true
                        }
                    }else{
                        print("deleteSp error:\(spId)")
                        SVProgressHUD.showErrorWithStatus(nil)
                        self.view.userInteractionEnabled = true
                        self.navigationController?.navigationBar.userInteractionEnabled = true
                    }
                })
            })
            
        }
    }
    func confirmDelete(i:Int?){
        let alertView = UIAlertView()
        alertView.title = "系统提示"
        alertView.message = "您确定要删除此专辑吗？"
        alertView.addButtonWithTitle("取消")
        alertView.addButtonWithTitle("确定")
        alertView.cancelButtonIndex=0
        alertView.tag = i!
        print("点击了\(alertView.tag)")
        alertView.delegate=self;
        alertView.show()
        
    }
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let tag = indexPath.row
        let obj:SpecialInfo = self.specials[tag] as! SpecialInfo
        
        let vc:UserCollectionViewController = UserCollectionViewController(collectionViewLayout: UserCollectionLayout())
        vc.userId = obj.userId
        vc.username = obj.username
        vc.userAvatar = obj.userAvator
        vc.specialName = obj.title
        vc.specialId = obj.objectId
        
        let query = BmobQuery(className: "SinglePicture")
        query.whereKey("specialId", equalTo: obj.objectId)
        query.countObjectsInBackgroundWithBlock({ (num, error) in
            if error != nil {
                
            }
            else{
                print("num:\(num)")
                SpecialCollectionViewController.getSinglePicturesCount(obj.objectId, callback: { (count) in
                    vc.count =  Int(num) + count
                    print("count:\(count)")
                    if (self.navigationController!.topViewController!.isKindOfClass(SpecialCollectionViewController)) {
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                        print("click:user")
                    }

                })
                            }
        })
        
    }


}
extension SpecialCollectionViewController {
   class  func getSinglePicturesCount(specialId:String,callback: ((Int)->Void)){
    
        let bquery = BmobQuery(className: "SinglePicture")
        
        let post = BmobObject(outDatatWithClassName: "special", objectId: specialId)
        
        bquery.whereObjectKey("collectionSinglePictures", relatedTo: post)
        
        bquery.countObjectsInBackgroundWithBlock { (num, error) in
            var count = 0
            if error != nil {
                print("error")
            }
            else {
               count = Int(num)
            }
            callback(count)
        }
        
    }
    
    func getSinglePicturesFromCollection(specialId:String,callback: (([SinglePictureInfo])->Void)){
        let pictures:[SinglePictureInfo] = [SinglePictureInfo]()
        let bquery = BmobQuery(className: "SinglePicture")
        
        let post = BmobObject(outDatatWithClassName: "special", objectId: specialId)
        
        bquery.whereObjectKey("collectionSinglePictures", relatedTo: post)
        
        bquery.findObjectsInBackgroundWithBlock({array,error in
            for bj in array{
                if bj is BmobObject{
                    _ = SinglePictureInfo()
                    
                }
            }
            callback(pictures)
            }
            
        )
}

    class func getPictureCount(specialId:String,callback: ((Int)->Void)){
    var allcount = 0
    let query = BmobQuery(className: "SinglePicture")
    query.whereKey("specialId", equalTo: specialId)
    query.countObjectsInBackgroundWithBlock({ (num, error) in
    if error != nil {
        callback(allcount)
    }
    else{
    print("num:\(num)")
    SpecialCollectionViewController.getSinglePicturesCount(specialId, callback: { (count) in
    allcount =  Int(num) + count
    print("count:\(count)")
        callback(allcount)
    })
    }
    })
    
    }
   class func getLikerCount(specialId:String,callback: ((Int)->Void)){
        var count = 0
        let query = BmobQuery(className: "_User")
        let post = BmobObject(outDatatWithClassName: "special", objectId: specialId)
        query.whereObjectKey("beingCollection", relatedTo: post)
        query.countObjectsInBackgroundWithBlock { (num, error) in
            if error != nil{
                print("error")
            }
            else {
                count = Int(num)
            }
            callback(count)
        }
        
    }

    func addSpecial(){
        let vc = CreateSpecialViewController()
        self.navigationController?.pushViewController(vc, animated: true)
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
                    
                    spInfo.userId = BmobUser.getCurrentUser().objectId
                    
                    spInfo.username = BmobUser.getCurrentUser().username
                    if let avatar = BmobUser.getCurrentUser().objectForKey("avatar") {
                        spInfo.userAvator = avatar as! String
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
    
    }
