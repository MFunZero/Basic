//
//  LikeSpecialsCollectionViewController.swift
//  Originality
//
//  Created by fanzz on 16/4/5.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class LikeSpecialsCollectionViewController: UICollectionViewController {
    
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
        self.title = "我喜欢的专辑"
        
        self.collectionView?.backgroundColor = bgColor
        // Register cell classes
        self.collectionView!.registerClass(SpecialCollectionCellCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
       
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
        return cell
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
                self.getPicturesCount(obj.objectId, callback: { (count) in
                    vc.count =  Int(num) + count
                    print("count:\(count)")
                    if (self.navigationController!.topViewController!.isKindOfClass(LikeSpecialsCollectionViewController)) {
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                        print("click:user")
                    }
                    
                })
            }
        })
        
    }
    
    
    
}
extension LikeSpecialsCollectionViewController {
    func getPicturesCount(specialId:String,callback: ((Int)->Void)){
        
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
        var pictures:[SinglePictureInfo] = [SinglePictureInfo]()
        let bquery = BmobQuery(className: "SinglePicture")
        
        let post = BmobObject(outDatatWithClassName: "special", objectId: specialId)
        
        bquery.whereObjectKey("collectionSinglePictures", relatedTo: post)
        
        bquery.findObjectsInBackgroundWithBlock({array,error in
            for bj in array{
                if bj is BmobObject{
                    let sp = SinglePictureInfo()
                    pictures.append(sp)
                }
            }
            callback(pictures)
            }
            
        )
    }
    
    
}
