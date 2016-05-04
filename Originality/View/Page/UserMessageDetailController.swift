//
//  UserMessageDetailController.swift
//  Originality
//
//  Created by fanzz on 16/3/28.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class UserMessageDetailController: UICollectionViewController {

    var userAvatarView:UIImageView = UIImageView()
    var specialNameLabel:UILabel = UILabel()
    var userNameLabel:UILabel = UILabel()
    
    var user:BmobUser!
    var userId:String!
    var autograph:String!
    var avatar:String? {
        willSet{
            BmobProFile.getFileAcessUrlWithFileName(avatar) { (file, error) -> Void in
                if error != nil {
                    print("error:\(error)")
                }else{
                    let  url = NSURL(string: file.url)
                    let data = NSData(contentsOfURL: url!)
                    if data != nil {
                        
                        self.userAvatarView.image = UIImage(data: data!)
                        
                    }
                }
                
                }
        }
    }
    var singleData:NSMutableArray = NSMutableArray()
    
    internal override  init(collectionViewLayout layout: UICollectionViewLayout){
        
        let layout = UserCollectionLayout()
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
        self.collectionView?.backgroundColor = bgColor
//        self.collectionView!.contentSize = CGSize(width: screenWidth, height: 500)
        self.collectionView!.alwaysBounceVertical = true
        
      
        userAvatarView.userInteractionEnabled = true
        let tap1:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserMessageDetailController.fullScreen))
        userAvatarView.addGestureRecognizer(tap1)
       
        self.navigationItem.leftBarButtonItem?.tintColor = maincolor
        
        self.collectionView!.registerClass(UserCollectioncell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FootView")
        self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
    }
    
    func fullScreen(){
        print("fullScreen")
        UIView.beginAnimations(nil, context: nil)
        // 动画时间
        UIView.setAnimationDuration(0.2)
        
        
        let vc = PictureViewController()
        vc.imageView.image = self.userAvatarView.image
        self.presentViewController(vc, animated: true, completion: nil)
        
        
        
        // commit动画
        UIView.commitAnimations()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView:UICollectionReusableView!
        if kind ==  UICollectionElementKindSectionFooter {
            reusableView = collectionView.dequeueReusableSupplementaryViewOfKind( kind, withReuseIdentifier: "FootView", forIndexPath: indexPath)
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
            
            specialNameLabel.frame = CGRect(x: screenWidth / 2 - 75, y: 30, width: 150, height: 20)
            specialNameLabel.textAlignment = .Center
            specialNameLabel.text = self.autograph
            specialNameLabel.font = smallFont
            imageBG.addSubview(specialNameLabel)
            
            let splitView:UIImageView = UIImageView(frame: CGRect(x: specialNameLabel.frame.origin.x, y: specialNameLabel.frame.origin.y + specialNameLabel.frame.height + 15, width: specialNameLabel.frame.width, height: 1))
            splitView.backgroundColor = splitViewColor
            
            imageBG.addSubview(splitView)
            
            
            
            
            userAvatarView.frame = CGRect(x: screenWidth / 2 - 20, y: splitView.frame.origin.y + 15, width: 40, height: 40)
            userAvatarView.layer.cornerRadius = userAvatarView.frame.width / 2
            userAvatarView.clipsToBounds = true
            imageBG.addSubview(userAvatarView)
            if avatar == nil {
            userAvatarView.image = UIImage(named: "default_avatar")
            }
            print("MessageDetail:\(self.avatar)")
            userAvatarView.layer.borderWidth = 1
            userAvatarView.layer.borderColor = contentColor.CGColor
            
            BmobProFile.getFileAcessUrlWithFileName(self.avatar) { (file, error) -> Void in
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
            
            userNameLabel.text = self.user.username
            
            
        }
        return reusableView
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.singleData.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UserCollectioncell!
        
        if cell == nil {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? UserCollectioncell
            
            if singleData.count != 0 {
                // print("sgData:\(singleData[indexPath.row])")
                
                let sp:SinglePictureInfo = singleData[indexPath.row] as! SinglePictureInfo
                print("sp:\(sp)")
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
                   
                
            }
            
        }
        return cell!
    }

override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
   
    let tag = indexPath.row
  
        let info = singleData[tag] as! SinglePictureInfo
        let vc:SinglePictureDetailController = SinglePictureDetailController()
        vc.singlePictureInfo = info
        vc.title = titleForDetail
        
        var specialIds:[String] = [String]()
        specialIds.append(info.specialId)
        print("flag1:\(specialIds)")
        
        UserCollectionViewController.getCollectionList(singleData[tag].objectId, callback: { (specialsId) in
            if specialsId.count > 0{
                for id in specialsId {
                    specialIds.append(id)
                }
            }
            vc.specials = specialIds
            print("flag2:\(specialIds),count:\(specialsId.count)")
            
            if (self.navigationController!.topViewController!.isKindOfClass(UserMessageDetailController)) {
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
            
            
        })

        
    
}
}


extension UserMessageDetailController{
    
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
