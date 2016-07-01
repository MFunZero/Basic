//
//  SinglePictureDetailController.swift
//  Originality
//
//  Created by suze on 16/1/23.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class SinglePictureDetailController: UIViewController,UIScrollViewDelegate ,UITextFieldDelegate{
    //单张图片信息
    var singlePictureInfo:SinglePictureInfo?
    //被收藏到的专辑
    var specials:[String] = [String]()
    var userInfo:[UserInfo] = [UserInfo]()
    
    var heightForVote:CGFloat = 0
    
    var offset:CGFloat = 0
    
    
    let contentView = ContentView()
    var endView:UIView!
    
    var scrollView:UIScrollView!
    var image:UIImage!
    var collectionStatus:Bool = false
    var voteStatus:Bool = false
    let VoteTitleView = CommentView()

    //
    var sendMessage:UIButton!
    var bottomView:UIView!
    //评论
    let commenterView = CommentView()
     var commentCellView:[SingleCommentView] = [SingleCommentView]()
    var comView:UIView!
    var commentTextView:UIButton!
    var rightCollectionButton:UIBarButtonItem!
    
    //collection
    var cView = CommentView()
    let specialView:[UIImageView] = [UIImageView(),UIImageView(),UIImageView(),UIImageView()]
    var collectionScrollView = UIScrollView()
    let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "reuseIdentifier")
    
    var voteView:UIView!
    var upvoteView:UIView!
    var userHeaderView:[UserHeaderView] = [UserHeaderView]()
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "share_more"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(SinglePictureDetailController.more))
        rightCollectionButton = UIBarButtonItem(image: UIImage(named: "cl"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(SinglePictureDetailController.collection))
        
        self.navigationItem.rightBarButtonItems = [rightButton,rightCollectionButton]
        self.navigationItem.rightBarButtonItems![0].tintColor = UIColor.grayColor()
        self.navigationItem.rightBarButtonItems![1].tintColor = UIColor.grayColor()
       getCollectionStatus(self.singlePictureInfo!.specialId,singlePictureId: self.singlePictureInfo!.objectId) { (flag) in
                self.collectionStatus = flag
        if self.collectionStatus == true {
            self.rightCollectionButton.tintColor = maincolor
        }
        }
        //视图配置信息
        self.config()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(SinglePictureDetailController.changeStatus(_:)), name: "changeStatus", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(SinglePictureDetailController.addSingleCommentView(_:)), name: "addCommont", object: nil)
    }
   
    func changeStatus(notification:NSNotification)
    {
        let obj = notification.object as! SpecialInfo
        print("d:\(obj.objectId)")
        self.rightCollectionButton.tintColor = maincolor
        self.specials.append(obj.objectId)
        moveSingleSpecialView(self.specials.count - 1, isLeft: false, time: 0.2)
    }
    func config(){
        self.view.backgroundColor = bgColor
        
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        
        self.scrollView.delegate = self
        
        self.view.addSubview(scrollView)
        
        //添加图片内容区
        addContentView()
        
        //添加点赞视图
        addUpvoteView()
        
        
        
      
    
        
        
        //添加评论textfield以及keyboard内容
        addCommentTextfield()
        
        
    }
    
    func addCommentTextfield()
    {
        bottomView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 54, width: screenWidth, height: 64))
        bottomView.layer.borderWidth = 1
        bottomView.backgroundColor = contentColor
        bottomView.layer.borderColor = splitViewColor.CGColor
        self.view.addSubview(bottomView)
        
        
        
        
        commentTextView = UIButton(frame: CGRect(x: 10, y: 10, width: screenWidth - 70, height: 40))
        commentTextView.layer.cornerRadius = 10
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = splitViewColor.CGColor
        let subView = UIImageView(frame: CGRect(x: 10, y: 7, width: 30, height: 30))
        subView.image = UIImage(named: "cm2_operbar_icn_rename")
        commentTextView.addSubview(subView)
        commentTextView.addTarget(self, action: #selector(SinglePictureDetailController.click(_:)), forControlEvents: .TouchUpInside)
        
        bottomView.addSubview(commentTextView)
  
        
        sendMessage = UIButton(frame: CGRect(x: commentTextView.frame.width + 10, y: 0, width: 60 , height: 50))
        
        sendMessage.addTarget(self, action: #selector(SinglePictureDetailController.vote(_:)), forControlEvents: .TouchUpInside)
        
        bottomView.addSubview(sendMessage)
        getVoteStatus(self.singlePictureInfo!.objectId) { (flag) in
            print("vsta:\(flag)")
            self.voteStatus = flag
            if flag == true {
                self.sendMessage.setImage(UIImage(named: "votePressed"), forState: .Normal)
                
            }else {
                self.sendMessage.setImage(UIImage(named: "vote"), forState: .Normal)
            }
        }
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func vote(sender:UIButton){
        
        let currentUser = BmobUser.getCurrentUser()
        if currentUser != nil{
            if voteStatus == false {
       
        let post = BmobObject(outDatatWithClassName: "SinglePicture", objectId: self.singlePictureInfo!.objectId)
        let relation = BmobRelation()
        relation.addObject(BmobObject(outDatatWithClassName: "_User", objectId:currentUser.objectId ))
        
        post.addRelation(relation, forKey: "vote")
        post.updateInBackgroundWithResultBlock({ (success, error) in
            if success {
                self.voteStatus = true
                self.sendMessage.setImage(UIImage(named: "votePressed"), forState: .Normal)
                self.getVoteArray(self.singlePictureInfo!.objectId, callback: { (infos) in
                    if infos.count == 1 {
                        self.insertOrDeleteUpvoteView(true)
                    }
                    if infos.count > 1 && infos.count < 5{
                        for i in 0 ..< infos.count {
                            if !self.userInfo.contains(infos[i]){
                        self.addSingleVoteUserView(i, info: infos[i])
                                self.userInfo.append(infos[i])
                                
                            }
                        }
                    }
                    if infos.count != 0 {
                    self.VoteTitleView.titleLable.text = preUpvoteTitle + String(infos.count)
                    }
                    SVProgressHUD.showSuccessWithStatus("点赞＋1")
                    
                })
            }
            else {
                
                SVProgressHUD.showErrorWithStatus("操作失误，请重试")
            }
        })
         } else {
                let post = BmobObject(outDatatWithClassName: "SinglePicture", objectId: self.singlePictureInfo!.objectId)
                let relation = BmobRelation()
                relation.removeObject(BmobObject(outDatatWithClassName: "_User", objectId:currentUser.objectId ))
                
                post.addRelation(relation, forKey: "vote")
                post.updateInBackgroundWithResultBlock({ (success, error) in
                    if success {
                        self.voteStatus = false
                        self.sendMessage.setImage(UIImage(named: "vote"), forState: .Normal)
                        self.getVoteArray(self.singlePictureInfo!.objectId, callback: { (infos) in
                            if infos.count == 0 {
                                self.insertOrDeleteUpvoteView(false)
                            }
                            let currentUser = BmobUser.getCurrentUser()
                            
                            if infos.count > 1 && infos.count < 5 && currentUser != nil {
                                for i in 0 ..< infos.count {
                                    if self.userHeaderView[i].objectId == currentUser.objectId
                                    {
                                        self.userHeaderView[i].removeFromSuperview()
                                        self.moveUserHeaderView(i+1)
                                    }
                                }
                            }
                            
                            if infos.count >= 0 {
                                self.VoteTitleView.titleLable.text = preUpvoteTitle + String(infos.count)
                            }
                        })

                    }
                    else {
                       
                        SVProgressHUD.showErrorWithStatus("操作失误，请重试")
                    }
                })
            }

        }
        else{
                let vc = LoginViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                return
        }
    }
    func moveUserHeaderView(i:Int) {
        let count = userHeaderView.count
        if i > count {
            return
        }
        for j in i ..< count {
            UIView.animateWithDuration(0.3, animations: { 
                self.userHeaderView[j].center.x -= self.userHeaderView[j-1].frame.width
            })
        }
    }
    func click(sender:UIButton)
    { let vc:CommentTableViewController = CommentTableViewController()
        vc.replytoUser = self.singlePictureInfo?.userId
        if let commentArray = self.singlePictureInfo?.comment {
            var mutableArray = NSMutableArray()
            mutableArray.addObjectsFromArray(commentArray)
            vc.commentArray = mutableArray
            vc.storeCount = mutableArray.count
        }
        vc.singlePictureInfo = self.singlePictureInfo
        vc.singlePictureUserId = self.singlePictureInfo?.userId
        vc.commentTextView.becomeFirstResponder()
        let nav = UINavigationController(rootViewController: vc)
        
        self.presentViewController(nav, animated: true, completion: nil)
    }
    

    func addEndView()
    {
        endView = UIView(frame: CGRect(x: 10, y: heightForVote + 10, width: screenWidth - 20, height: 240))
        self.scrollView.addSubview(endView)
        
        endView.backgroundColor = bgColor
    
        heightForVote = self.endView.frame.origin.y + self.endView.frame.height + 64
        
        let splitViewLeft:UIImageView = UIImageView(frame: CGRect(x: 30, y: 20, width: endView.frame.width/2 - 60, height: 1))
        splitViewLeft.backgroundColor = splitViewColor
        
        self.endView.addSubview(splitViewLeft)
        
        let splitViewRight:UIImageView = UIImageView(frame: CGRect(x: endView.frame.width/2 + 30, y: 20, width: endView.frame.width/2 - 60, height: 1))
        splitViewRight.backgroundColor = splitViewColor
        
        self.endView.addSubview(splitViewRight)
        
        
        let label = UILabel(frame: CGRect(x: splitViewLeft.frame.origin.x + splitViewLeft.frame.width, y: 10, width: 60, height: 20))
        label.text = "End"
        label.textAlignment = NSTextAlignment.Center
        
        self.endView.addSubview(label)
       
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 40, width: screenWidth - 20, height: 200))
        imageView.image = UIImage(named: "bg1")
        
        self.endView.addSubview(imageView)
        
       
        
        self.scrollView.contentSize = CGSize(width: screenWidth, height: heightForVote )
    }
    
    func addContentView()
    {
        
        
        let home = NSHomeDirectory() as NSString
        let path = home.stringByAppendingPathComponent("Library/Caches/DownloadFile") as NSString
        let imagePath = path.stringByAppendingPathComponent(singlePictureInfo!.url)
        let isExits:Bool = NSFileManager.defaultManager().fileExistsAtPath(imagePath)
        self.image = UIImage(contentsOfFile: imagePath)
        if isExits && image != nil{
            print("sp")
            var imageSize = image.scaleImage(image, imageLength: screenWidth - 20)
//            if imageSize.height < 50 {
//                imageSize.height = 50
//            }
            
            contentView.frame = CGRect(x: 10, y: self.heightForVote + 10, width: screenWidth - 20, height: imageSize.height + 95)
            
          
        }else{
       
            contentView.frame = CGRect(x: 10, y: self.heightForVote + 10, width: screenWidth - 20, height: 295)
        
        }
        
        contentView.contentMode = .ScaleAspectFit
        
        heightForVote = contentView.frame.origin.y + contentView.frame.height
        print("hhcccc:\(self.heightForVote)")
        self.scrollView.addSubview(contentView)
        
        contentView.picture.userInteractionEnabled = true
        let tap1:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SinglePictureDetailController.fullScreen))
        contentView.picture.addGestureRecognizer(tap1)
        
        contentView.filename = singlePictureInfo!.url
        image = contentView.picture.image
        contentView.avatar = singlePictureInfo?.userAvator
        contentView.username.text = singlePictureInfo!.userName
        if singlePictureInfo?.specialName != nil {
            contentView.specialName.text = perDetail + singlePictureInfo!.specialName
        }
        contentView.descript.text = singlePictureInfo!.title
        contentView.tagId = singlePictureInfo?.userId
        
        contentView.backgroundColor = contentColor
        
        if  contentView.tagId != nil {
            
            contentView.speView.userInteractionEnabled = true
            let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SinglePictureDetailController.userClick(_:)))
            
            contentView.speView.addGestureRecognizer(tap)
        }
        
    }
   
    
    func fullScreen(){
        print("fullScreen")
        UIView.beginAnimations(nil, context: nil)
        // 动画时间
        UIView.setAnimationDuration(0.2)
     
              if let image = self.contentView.picture.image {
            let vc = PictureViewController()
            vc.imageView.image = image
            self.presentViewController(vc, animated: true, completion: nil)
      
        }
        
        // commit动画
        UIView.commitAnimations()
    }
    func userClick(sender:UITapGestureRecognizer){
        
        let obj:SinglePictureInfo = singlePictureInfo!
        
        let vc:UserCollectionViewController = UserCollectionViewController(collectionViewLayout: UserCollectionLayout())
        vc.userId = obj.userId
        vc.username = obj.userName
        vc.userAvatar = obj.userAvator
        vc.specialName = obj.specialName
        vc.specialId = obj.specialId
        
        if let user = BmobUser.getCurrentUser() {
        let bquery = BmobQuery(className: "special")
        
        let post = BmobObject(outDatatWithClassName: "_User", objectId: user.objectId)
        
        bquery.whereObjectKey("likeSpecials", relatedTo: post)
        
        bquery.findObjectsInBackgroundWithBlock({array,error in
            //var tag:Int = 0
            for bj in array{
                if bj is BmobObject{
                    if obj.specialId == bj.objectId
                    {
                        vc.likeStatus = true
                    }
                    print("array:\(array)")
                    let query = BmobQuery(className: "SinglePicture")
                    query.whereKey("userId", equalTo: obj.userId)
                    query.countObjectsInBackgroundWithBlock({ (num, error) in
                        if error != nil {
                            
                        }
                        else{
                            vc.count =  Int(num)
                            if (self.navigationController!.topViewController!.isKindOfClass(SinglePictureDetailController)) {
                                
                                self.navigationController?.pushViewController(vc, animated: true)
                                print("click:user")
                            }
                        }
                    })
                    
                }
            }
            }
        )
        }
    }
    
    
    func addCollectionView()
    {
        
        
        let count = self.specials.count
        print("count:\(count)")
        print("hh111:\(self.heightForVote)")
        
       
        cView.frame = CGRect(x: 10, y: heightForVote + 20 , width: screenWidth - 20, height: 154)
        //change heightForVote
        
        
        heightForVote = cView.frame.origin.y + cView.frame.height
        
        
        cView.backgroundColor = contentColor
        
        self.scrollView.addSubview(cView)
        
        
        cell.frame = CGRect(x: 0, y: 0, width: cView.frame.width - 20, height: 44)
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.textLabel?.text = collectionDescript
        cell.detailTextLabel?.text = String(count)
        cView.addSubview(cell)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SinglePictureDetailController.moreAboutSpecial(_:)))
        cell.addGestureRecognizer(tap)
        
        
        collectionScrollView.frame = CGRect(x: 0, y: cell.frame.origin.y + 44, width: 470, height: 100)
        
        self.cView.addSubview(collectionScrollView)
        
        if self.specials.count > 0 {
            for i in 0 ..< count {
                print("spe\(i):\(self.specials[i])")
               addSingleSpecialView(i, id: self.specials[i])
                
                if i == 2{
                    break
                }
                
            }
        }
        
        //添加尾部视图
        addEndView()
    }
    func moveSingleSpecialView(i:Int,isLeft:Bool,time:NSTimeInterval){
        cell.detailTextLabel?.text = String(self.specials.count)
        let width:CGFloat = 100.0
        if isLeft {
            
        let  count = self.specials.count > 3 ? 3:self.specials.count
            if i > count {
                return
            }
        for j in i ..< count {
        UIView.animateWithDuration(time) {
            
            self.specialView[j].center.x -= width
           
        }
        }
        }
        else{
            if i > 3 {
                return
            }
            else{
                addSingleSpecialView(i, id: self.specials[i])
            }
        }
    }
    func addSingleSpecialView(i:Int,id:String){
        let width:CGFloat = 100.0
        let height:CGFloat = 100.0
        specialView[i].frame = CGRect(x: CGFloat(i) * (width + 10) + 20 , y: 0, width: width, height: height)
        collectionScrollView.addSubview(specialView[i])
        specialView[i].image = UIImage(named: defaultImage)
        if i == 0 {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            imageView.image = UIImage(named: "shoufa")
            specialView[i].addSubview(imageView)
        }
        let textLabel = UILabel()
        textLabel.frame = CGRectMake(10, 65, 80,15)
        textLabel.font = UIFont(name: "Arial", size: 12)
        textLabel.textColor = contentColor
        specialView[i].addSubview(textLabel)
        
        let userLabel = UILabel()
        userLabel.frame = CGRectMake(10, 80, 65,
                                     15)
        userLabel.textColor = contentColor
        userLabel.font = UIFont (name: "Arial", size: 11)
        specialView[i].addSubview(userLabel)
        getSpecialInfo(id, callback: { (info) in
            print("info:\(info.username)")
            
            userLabel.text = preString + info.username
            textLabel.text = info.title
            if info.pictureName != nil{
            self.getImageBaseOnFilename(info.pictureName, callback: { (image) in
                
                self.specialView[i].image = image
                
            })
            } else{
                     self.specialView[i].image = UIImage(named: defaultImage)
                }
        })
    }
    func insertOrDeleteUpvoteView(add:Bool){
    if add {
    UIView.animateWithDuration(0.3, animations: {
        let deltaY:CGFloat = 124.0
        if self.comView != nil {
//        self.comView.center.y += 124
            self.comView.transform = CGAffineTransformMakeTranslation(0,deltaY)
        }
//        self.bottomView.transform = CGAffineTransformIdentity
        self.cView.transform = CGAffineTransformMakeTranslation(0,deltaY)
//            self.cView.center.y += 124
        
//        self.endView.center.y += 124
        self.endView.transform = CGAffineTransformMakeTranslation(0,deltaY)
        if  self.voteView != nil {
            self.voteView.removeFromSuperview()
        }
        self.addvoteContent()
        
        self.heightForVote = self.endView.frame.origin.y + self.endView.frame.height + 64
        self.scrollView.contentSize = CGSize(width: screenWidth, height: self.heightForVote)
    })
    }else {
        UIView.animateWithDuration(0.3, animations: {
            if  self.voteView != nil {
                self.voteView.removeFromSuperview()
            }
            if self.comView != nil {
//            self.comView.center.y -= 124
                 self.comView.transform = CGAffineTransformIdentity
            }
            self.cView.transform = CGAffineTransformIdentity
            self.endView.transform = CGAffineTransformIdentity

        
//                self.cView.center.y -= 124
//            self.endView.center.y -= 124
//            
            self.heightForVote = self.endView.frame.origin.y + self.endView.frame.height + 64
            self.scrollView.contentSize = CGSize(width: screenWidth, height: self.heightForVote)
        })
        }
    
    }
func addvoteContent(){
    getVoteArray(self.singlePictureInfo!.objectId) { (voteArray) in
        if voteArray.count > 0 {
            self.userInfo = voteArray
            let count = voteArray.count
            self.voteView = UIView(frame: CGRect(x: 10, y: self.contentView.frame.origin.y + self.contentView.frame.height + 20 , width: screenWidth - 20, height: 104))
            self.scrollView.addSubview(self.voteView)
            
            self.scrollView.bringSubviewToFront(self.voteView)
            
            self.VoteTitleView.frame = CGRect(x: 0, y: 0 , width: screenWidth - 20, height: 44)
            
            self.VoteTitleView.titleLable.text = preUpvoteTitle + String(count)
            
            
            self.VoteTitleView.backgroundColor = contentColor
            
            self.voteView.addSubview(self.VoteTitleView)
            
            self.upvoteView = UIView()
            self.upvoteView.frame = CGRect(x: 0, y: 44, width: self.VoteTitleView.frame.width, height: 60)
            self.upvoteView.backgroundColor = contentColor
            
            
            
            
            self.voteView.addSubview(self.upvoteView)
            
            let splitView = UIImageView(frame:CGRect(x: 10, y: 0, width: self.upvoteView.frame.width - 20, height: 1))
            splitView.backgroundColor = splitViewColor
            
            self.upvoteView.addSubview(splitView)
            
            for i in 0 ..< count {
                self.addSingleVoteUserView(i, info: voteArray[i])
            }
      
        }
     
    }

    
    }

    func addUpvoteView()
    {
        getVoteArray(self.singlePictureInfo!.objectId) { (voteArray) in
            if voteArray.count > 0 {
                self.userInfo = voteArray
                let count = voteArray.count
                self.voteView = UIView(frame: CGRect(x: 10, y: self.contentView.frame.origin.y + self.contentView.frame.height + 20 , width: screenWidth - 20, height: 104))
                self.scrollView.addSubview(self.voteView)
               
                
                self.heightForVote = self.voteView.frame.origin.y + self.voteView.frame.height
                print("vote:\(self.heightForVote)")
                
                self.voteView.backgroundColor = UIColor.redColor()
                self.VoteTitleView.frame = CGRect(x: 0, y: 0 , width: screenWidth - 20, height: 44)

                self.VoteTitleView.titleLable.text = preUpvoteTitle + String(count)
                
                
                self.VoteTitleView.backgroundColor = contentColor
                
                self.voteView.addSubview(self.VoteTitleView)
                
                self.upvoteView = UIView()
                self.upvoteView.frame = CGRect(x: 0, y: 44, width: self.VoteTitleView.frame.width, height: 60)
                self.upvoteView.backgroundColor = contentColor
                
            
                
                
                self.voteView.addSubview(self.upvoteView)
                
                let splitView = UIImageView(frame:CGRect(x: 10, y: 0, width: self.upvoteView.frame.width - 20, height: 1))
                splitView.backgroundColor = splitViewColor
                
                self.upvoteView.addSubview(splitView)
                
                for i in 0 ..< count {
                    self.addSingleVoteUserView(i, info: voteArray[i])
                }
                self.addCommentView()
            }
            else {
                self.heightForVote = self.contentView.frame.origin.y + self.contentView.frame.height
                self.addCommentView()

            }
        }
        
    }
    func addSingleVoteUserView(i:Int,info:UserInfo){
        if i == 5{
            self.userHeaderView.append(UserHeaderView())
            userHeaderView[i].frame = CGRect(x: userHeaderView[i-1].frame.origin.x + userHeaderView[i-1].frame.width + distance, y: 10, width: 40, height: 40)
            
            
            userHeaderView[i].layer.cornerRadius = userHeaderView[i].frame.width / 2
            userHeaderView[i].clipsToBounds = true
            
            userHeaderView[i].image = UIImage(named: "more")
            
            upvoteView.addSubview(userHeaderView[i])
            userHeaderView[i].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SinglePictureDetailController.moreVoteUser(_:))))
          return
        }

        if i == 0 {
            self.userHeaderView.append(UserHeaderView())
            userHeaderView[i].frame = CGRect(x: 10, y: 10, width: 40, height: 40)
            
            
        }else {
            self.userHeaderView.append(UserHeaderView())
            userHeaderView[i].frame = CGRect(x: (40.0 + distance) * CGFloat(i) + 10 , y: 10, width: 40, height: 40)
        }
        
        userHeaderView[i].layer.cornerRadius = userHeaderView[i].frame.width / 2
        userHeaderView[i].clipsToBounds = true
        upvoteView.addSubview(userHeaderView[i])

        userHeaderView[i].objectId = info.objectId
        userHeaderView[i].avatar = info.avatar
        userHeaderView[i].tag = i
        userHeaderView[i].userInteractionEnabled = true
        userHeaderView[i].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SinglePictureDetailController.userMessage(_:))))
   
}
func moreVoteUser(sender:UITapGestureRecognizer){
    getVoterList(self.singlePictureInfo!.objectId) { (ids) in
      let vc = VoterListTableViewController()
        vc.voter = ids
        self.navigationController?.pushViewController(vc, animated: true)
    }
    }
func userMessage(sender:UITapGestureRecognizer){
    let tap:UITapGestureRecognizer = sender
    let tag:Int = (tap.view?.tag)!
    let vc = UserMessageDetailController(collectionViewLayout: UserCollectionLayout())
    vc.userId = self.userInfo[tag].objectId
    vc.user = self.userInfo[tag]
    vc.avatar = self.userInfo[tag].avatar
    vc.autograph = self.userInfo[tag].autograph
    
    self.getData(self.userInfo[tag].objectId) { (singleData) -> Void in
        vc.singleData = singleData
        if (self.navigationController!.topViewController!.isKindOfClass(SinglePictureDetailController)) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
    
    func addSingleCommentView(notification:NSNotification){
        let array = notification.object as! NSMutableArray
        print("arr:\(array)")
        print("arrC:\(array.count)")

        if array.count == 1 {
            let obj = array[0] as! NSDictionary
            
        var countOrigin = 0
        
        var count = 0
        if let c = self.singlePictureInfo?.comment{
            countOrigin = c.count
        }
        if self.singlePictureInfo?.comment == nil {
            self.singlePictureInfo?.comment = Array<NSDictionary>()
            self.singlePictureInfo?.comment.append(obj)
            count = self.singlePictureInfo!.comment.count
        }
        else {
            self.singlePictureInfo?.comment.append(obj)
            count = self.singlePictureInfo!.comment.count

        }
        if count > 1 && count < 5{
            comView.frame = CGRect(x: 10.0, y: comView.frame.origin.y , width: screenWidth - 20, height: comView.frame.height + CGFloat((count - countOrigin) * 50))
           insertOrDeleteCommentView(true,isFirst: false,i: 1)
            
           self.addSingleCommentCell(count-1,dict: obj)
            
            
        }
        if count == 1 {
            insertOrDeleteCommentView(true,isFirst: true,i: 1)
            addCommentContent()
        }
        
        if count > 4 {
        commenterView.titleLable.text = preCommentTitle + String(count)
            return
        }
        }
        if array.count > 1 {
            var countOrigin = 0
            
            var count = 0
            if let c = self.singlePictureInfo?.comment{
                countOrigin = c.count
            }
            if self.singlePictureInfo?.comment == nil {
                self.singlePictureInfo?.comment = Array<NSDictionary>()
                for bj in array{
                    self.singlePictureInfo?.comment.append(bj as! NSDictionary)
                }
                count = self.singlePictureInfo!.comment.count
            }
            else {
                for bj in array{
                    self.singlePictureInfo?.comment.append(bj as! NSDictionary)
                }
                count = self.singlePictureInfo!.comment.count
                
            }
            if count > 1 && count < 5{
                comView.frame = CGRect(x: 10.0, y: comView.frame.origin.y , width: screenWidth - 20, height: comView.frame.height + CGFloat((count - countOrigin) * 50))
                insertOrDeleteCommentView(true,isFirst: false,i: count - countOrigin)
                if count > countOrigin {
                    for i in countOrigin ..< count {
                        self.addSingleCommentCell(i,dict: array[i - countOrigin] as! NSDictionary)
                    }
                }
            }
            if countOrigin == 0 {
                insertOrDeleteCommentView(true,isFirst: true,i: count - countOrigin)
                addCommentContent()
            }
            
            if count > 4 {
                commenterView.titleLable.text = preCommentTitle + String(count)
                return
            }
        }
        
    }
    func addSingleCommentCell(i:Int,dict:NSDictionary) {
        
        if i > 3 {
            return
        }
        if i == 3 {
            commentCellView.append(SingleCommentView())
            commentCellView[i].frame = CGRect(x: 0, y: commentCellView[i-1].frame.origin.y + commentCellView[i-1].frame.height, width: commentCellView[i-1].frame.width, height: 50)
            self.comView.addSubview(commentCellView[i])
            commentCellView[i].backgroundColor = contentColor
            
            
            let theSubviews : Array = commentCellView[i].subviews
            
            for subview in theSubviews {
                subview.removeFromSuperview()
            }
            
            let lookLabel = UILabel(frame: CGRect(x: 0, y: 5, width: commentCellView[i-1].frame.width - 20, height: commentCellView[i-1].frame.height - 10))
            lookLabel.text = lookAll
            lookLabel.textAlignment = .Center
            
            commentCellView[i].addSubview(lookLabel)
            
            commentCellView[i].userInteractionEnabled = true
            commentCellView[i].tag = i
            commentCellView[i].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SinglePictureDetailController.reply(_:))))
            return
        }
        print("i:\(i)")
        //发出评论者
       
        let commenter = dict.objectForKey("userId") as! String
        
        let userId = dict.objectForKey("replyto") as! String
        
        //                let commentId = commentArray[i].objectForKey("commentId") as! String
        
        let content = dict.objectForKey("content") as! String
        
        
        var str = content
        
        if singlePictureInfo!.userId != userId {
            print("i:userid:\(i)")
            let query:BmobQuery = BmobQuery(className: "_User")
            query.getObjectInBackgroundWithId(userId, block: { (user, error) -> Void in
                if error != nil {
                    print("getUserError:\(error)")
                }
                else {
                    let username = user.objectForKey("username") as! String
                    str = str + preReply + username
                }
            })
            
        }
        
        
        let strAsNsstring = str as NSString
        let contrainsts = CGSizeMake(screenWidth - 40 , 30)
        
        
        let size =  strAsNsstring.textSizeWithFont(nomalFont, constrainedToSize: contrainsts)
        let height = size.height > 50 ? size.height + 20:50
        
        if i == 0 {
            commentCellView.append(SingleCommentView())
            commentCellView[i].frame = CGRect(x: 0, y: 44, width: screenWidth - 20, height: height)
            print("0:\(commentCellView[i].frame)")
            self.comView.addSubview(commentCellView[i])
            commentCellView[i].authorId = singlePictureInfo!.userId
            
        }
        else {
            commentCellView.append(SingleCommentView())

            commentCellView[i].frame = CGRect(x: 0, y: commentCellView[i-1].frame.origin.y + commentCellView[i-1].frame.height, width: commentCellView[i-1].frame.width, height: height)
            self.comView.addSubview(commentCellView[i])
            
            heightForVote = commentCellView[i].frame.height + commentCellView[i].frame.origin.y
            
        }
        commentCellView[i].commenter = commenter
        commentCellView[i].authorId = singlePictureInfo!.userId
        commentCellView[i].commentDetail = dict
        
        commentCellView[i].backgroundColor = contentColor
        
        commentCellView[i].userInteractionEnabled = true
        commentCellView[i].tag = i
        commentCellView[i].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SinglePictureDetailController.reply(_:))))
    

    }
    
    func insertOrDeleteCommentView(add:Bool,isFirst:Bool,i:Int){
        if add {
            UIView.animateWithDuration(0.3, animations: {
                var height:CGFloat = 50.0 * CGFloat(i)
                if isFirst {
                    height = 60.0 + 50.0 * CGFloat(i)
                }
                self.cView.center.y += height
                self.endView.center.y += height
                self.addvoteContent()
                self.offset = 50.0 + self.offset
                
                self.heightForVote = self.endView.frame.origin.y + self.endView.frame.height + 64
                self.scrollView.contentSize = CGSize(width: screenWidth, height: self.heightForVote)
            })
        }else {
            UIView.animateWithDuration(0.3, animations: {
                
                if self.comView != nil {
                    self.comView.center.y -= 100
                }
                self.cView.center.y -= 100
                self.endView.center.y -= 100

                self.heightForVote = self.endView.frame.origin.y + self.endView.frame.height + 64
                self.scrollView.contentSize = CGSize(width: screenWidth, height: self.heightForVote)
            })
        }
        
    }
    func addCommentContent(){
        comView = UIView()
        var count = self.singlePictureInfo!.comment.count
        if count > 4 {
            count = 4
        }
        var comViewY = self.contentView.frame.origin.y + self.contentView.frame.height
        if voteView != nil {
            comViewY = self.voteView.frame.origin.y + self.voteView.frame.height
        }
        
        comView.frame = CGRect(x: 10.0, y: comViewY + 20 , width: screenWidth - 20, height: 44.0 + CGFloat(count * 50))
        self.scrollView.addSubview(comView)
        
        comView.backgroundColor = UIColor.redColor()
        
        commenterView.frame = CGRect(x: 0, y: 0 , width: screenWidth - 20, height: 44)
       
        
        print("hhmmmm:\(self.heightForVote)")
        //添加被收藏到专辑视图
        
        
        commenterView.backgroundColor = contentColor
        
        self.comView.addSubview(commenterView)
        
        commenterView.titleLable.text = preCommentTitle + String(singlePictureInfo!.commentCount)
        
        for i in 0 ..< count {
            
            addSingleCommentCell(i, dict: self.singlePictureInfo!.comment[i])
        }
    }
func addCommentView()
    {
        
        if singlePictureInfo?.commentCount > 0 {
            let commentArray = singlePictureInfo!.comment
            var count = commentArray.count
            if count > 4 {
                count = 4
            }
            print("hh2222:\(self.heightForVote)")
            comView = UIView()
            
            comView.frame = CGRect(x: 10.0, y: self.heightForVote + 20 , width: screenWidth - 20, height: 44.0 + CGFloat(count * 50))
            self.scrollView.addSubview(comView)
            
            commenterView.frame = CGRect(x: 0, y: 0 , width: screenWidth - 20, height: 44)
            //change heightForVote
            self.heightForVote = comView.frame.height + comView.frame.origin.y
            
            print("hhmmmm:\(self.heightForVote)")
            //添加被收藏到专辑视图
            addCollectionView()
            
            commenterView.backgroundColor = contentColor
            
            self.comView.addSubview(commenterView)
            
            commenterView.titleLable.text = preCommentTitle + String(singlePictureInfo!.commentCount)
            
            for i in 0 ..< count {
               
                addSingleCommentCell(i, dict: commentArray[i])
            }}
        else {
            //添加被收藏到专辑视图
            addCollectionView()
        }
        
        
        
    }
    
    
    
    
    
    func reply(sender:UITapGestureRecognizer){
        let tap:UITapGestureRecognizer = sender
        let tag:Int = tap.view!.tag
        let dict = (self.singlePictureInfo?.comment[tag])! as NSDictionary
        
        print("click:detail:::\(tap.view!.tag)")
        let vc:CommentTableViewController = CommentTableViewController()
        if tag == 3{
            vc.replytoUser = self.singlePictureInfo?.userId
        }
        else {
            vc.replytoUser = dict.objectForKey("userId") as? String
        }
        if let commentArray = self.singlePictureInfo?.comment {
            var mutableArray = NSMutableArray()
            mutableArray.addObjectsFromArray(commentArray)
        vc.commentArray = mutableArray
            vc.storeCount = mutableArray.count
        }
        vc.singlePictureInfo = self.singlePictureInfo
        vc.singlePictureUserId = self.singlePictureInfo?.userId
        vc.commentTextView.becomeFirstResponder()

        let nav = UINavigationController(rootViewController: vc)
        
        self.presentViewController(nav, animated: true, completion: nil)
        
    }
    
    
    override  func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}

extension SinglePictureDetailController {
    
    func more()
    {
        
        sharePicture()
        
    }
    func alertView(alertView:UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if(buttonIndex==alertView.cancelButtonIndex){
            print("点击了取消")
        }
        else
        {
            print("点击了确认")
            let query = BmobQuery(className: "special")
            let postQ = BmobObject(outDatatWithClassName: "SinglePicture", objectId: self.singlePictureInfo!.objectId)
            query.whereObjectKey("beingCollection", relatedTo: postQ)
           
            
            if let currentUser = BmobUser.getCurrentUser() {
            query.whereKey("userId", equalTo: currentUser.objectId)
            query.findObjectsInBackgroundWithBlock({array,error in
                //var tag:Int = 0
                for bj in array{
                    if bj is BmobObject{
                        
                        
                        let spId = bj.objectId
                        
                                let post = BmobObject(outDatatWithClassName: "SinglePicture", objectId: self.singlePictureInfo!.objectId)
                                let relation = BmobRelation()
                                relation.removeObject(BmobObject(outDatatWithClassName: "special", objectId: spId))
                                
                                post.addRelation(relation, forKey: "beingCollection")
                                post.updateInBackgroundWithResultBlock({ (success, error) in
                                    if success {
                                        
                                        let post = BmobObject(outDatatWithClassName: "special", objectId: spId)
                                        let relation = BmobRelation()
                                        relation.removeObject(BmobObject(outDatatWithClassName: "SinglePicture", objectId: self.singlePictureInfo!.objectId))
                                        
                                        post.addRelation(relation, forKey: "collectionSinglePictures")
                                        post.updateInBackgroundWithResultBlock({ (success, error) in
                                            if success {
                                                print("successCancel")
                                              
                                                
                                                for j in 0 ..< self.specials.count {
                                                    print("sp:\(j)::\(self.specials[j])")
                                                    if self.specials[j] == spId {
                                                      self.specialView[j].removeFromSuperview()
                                                        self.specials.removeAtIndex(j)
                                                        self.moveSingleSpecialView(j+1, isLeft: true, time: 0.2)
                                                    }
                                                }
                                                self.rightCollectionButton.tintColor = bgColor
                                            }
                                            else {
                                                SVProgressHUD.showErrorWithStatus("操作失误，请重试")
                                            }
                                        })
                                    }
                                    else {
                                       SVProgressHUD.showErrorWithStatus("操作失误，请重试")
                                    }
                                })
                                
                            }
                        }
                }
            )
            }
        }
        
    }
    func collection()
    {
        if rightCollectionButton.tintColor == maincolor {
            
            let alertView = UIAlertView()
            alertView.title = "系统提示"
            alertView.message = "您确定要取消收藏吗？"
            alertView.addButtonWithTitle("取消")
            alertView.addButtonWithTitle("确定")
            alertView.cancelButtonIndex=0
            alertView.delegate=self;
            alertView.show()
            
            return
        }
        
        if let user = BmobUser.getCurrentUser(){
            if self.singlePictureInfo?.userId == user.objectId {
                
               SVProgressHUD.showErrorWithStatus("您不能收藏自己的图片哦！")
                
                return
            }
        }
        else {
            let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        let csVC = ChoseSpecialTableViewController()
        let vc = UINavigationController(rootViewController: csVC)
        csVC.singlePictureInfo = self.singlePictureInfo
        
        let query = BmobQuery(className: "special")
        
        var specials:[SpecialInfo] = []
        
        query.includeKey("userId,categoryId")
        
            query.whereKey("userId", equalTo: currentUser)
            query.findObjectsInBackgroundWithBlock { (objs, error) -> Void in
                if error != nil {
                    NSLog("specialQuery:\(error)")
                }
                else {
                    for obj in objs {
                        let special = SpecialInfo()
                        special.objectId = obj.objectId
                        special.title = obj.objectForKey("title") as? String
                        
                        if let picture = obj.objectForKey("mainPicture") {
                            special.pictureName = picture as? String
                        }
                        else {
                            special.pictureName = defaultImage
                        }
                        
                        if let account = obj.objectForKey("count") {
                            special.pictureCount = account as? Int
                        }
                        else {
                            special.pictureCount = 0
                        }
                        
                        let user:BmobUser = obj.objectForKey("userId") as! BmobUser
                        special.userId = user.objectId
//                        
//                        //获取专辑信息
//                        let category:BmobObject = obj.objectForKey("categoryId") as! BmobObject
//                        special.categoryId = category.objectId
                        
                        specials.append(special)
                    }
                    
                    csVC.specials = specials
                    
                    self.presentViewController(vc, animated: true, completion: nil)
                }
            
            
        }
        
    }
    
    
    
    //share
    
    //sendText("这是来自Mandarava(鳗驼螺)的分享", inScene: WXSceneTimeline) //分享文本到朋友圈
    // sendImage(UIImage(named: "MyImage.png")!, inScene: WXSceneTimeline)
    
    func sendText(text:String, inScene: WXScene)->Bool{
        let req=SendMessageToWXReq()
        req.text=text
        req.bText=true
        req.scene=Int32(inScene.rawValue)
        return WXApi.sendReq(req)
    }
    ///分享图片
    func sendImage(image:UIImage, inScene:WXScene)->Bool{
        print("error:\(3333)")
        let message =  WXMediaMessage()
        
        let imageObject =  WXImageObject()
        imageObject.imageData = UIImagePNGRepresentation(image)
        message.mediaObject = imageObject
        
        let compressData = image.compressImage(image, maxLength: 28)
        
        message.setThumbImage(UIImage(data: compressData!))
        let req =  SendMessageToWXReq()
        
        req.text=self.singlePictureInfo!.title
        req.bText = false
        req.message = message
        req.scene = Int32(inScene.rawValue)
        return WXApi.sendReq(req)
    }
    
    
    func sharePicture(){
        let alertController = UIAlertController(title: "分享", message: "",
                                                preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        
        let archiveAction = UIAlertAction(title: "分享到朋友圈", style: .Default) { (action) in
            SVProgressHUD.show()
            self.navigationController!.navigationBar.userInteractionEnabled=false //将nav事件禁止
            self.view.userInteractionEnabled=false //界面
            BmobProFile.getFileAcessUrlWithFileName(self.singlePictureInfo!.url) { (file, error) -> Void in
                if error != nil {
                    print("error:\(error)")
                    SVProgressHUD.showErrorWithStatus("获取图片失败")
                    self.navigationController!.navigationBar.userInteractionEnabled=true //将nav事件禁止
                    self.view.userInteractionEnabled=true //界面
                }else{
                    print("error:\(11111)")
                    let  url = NSURL(string: file.url)
                    let data = NSData(contentsOfURL: url!)
                    if data != nil {
                        
                        self.image = UIImage(data: data!)
                        if  WXApi.isWXAppInstalled() {
                            let delayInSeconds:Float = 0.1
                            let popTime = dispatch_time(DISPATCH_TIME_NOW,  Int64(delayInSeconds)*Int64(NSEC_PER_SEC))
                            dispatch_after(popTime, dispatch_get_main_queue(), {
                                let status = self.sendImage(self.image, inScene: WXSceneTimeline)
                                print("获取图片失败\(status)")
                                SVProgressHUD.showErrorWithStatus("获取图片失败")
                                self.navigationController!.navigationBar.userInteractionEnabled=true //将nav事件禁止
                                self.view.userInteractionEnabled=true //界面

                            })
                           
                            
                          
                        }
                    }
                    else{
                        print("获取图片失败")
                        SVProgressHUD.showErrorWithStatus("获取图片失败")
                        self.navigationController!.navigationBar.userInteractionEnabled=true //将nav事件禁止
                        self.view.userInteractionEnabled=true //界面
                    }
                    
                }
            }
        }
        let archiveAction1 = UIAlertAction(title: "分享给好友", style: .Default) { (action) in
            // if  WXApi.isWXAppInstalled() {
            if self.sendText(self.singlePictureInfo!.title, inScene: WXSceneSession) == true{
                print("share successful")
            }
            else{
                print("share had failed")
            }
            //  }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(archiveAction)
        alertController.addAction(archiveAction1)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func getSpecialInfo(specialId:String,callback:((SpecialInfo) -> Void)!){
       
                let userQuery = BmobQuery(className: "special")
                userQuery.includeKey("userId")
                userQuery.getObjectInBackgroundWithId(specialId, block: { (obj, error) in
                    if error != nil {
                        print("error:\(error)")
                    }
                    else{
                        let spInfo:SpecialInfo = SpecialInfo()
                        let post = obj
                        spInfo.objectId = post.objectId
                        if let pictureName = post.objectForKey("mainPicture"){
                             spInfo.pictureName = pictureName as! String
                        }
                      
                        
                        if let title = post.objectForKey("title") {
                            spInfo.title = title as? String
                        }
                        else{
                            spInfo.title = ""
                        }
                        let user:BmobUser = post.objectForKey("userId") as! BmobUser
                        spInfo.userId = user.objectId
                        if let username = user.username {
                            spInfo.username = username
                        }
                        else{
                            spInfo.username = ""
                        }
                        callback(spInfo)
                    }
             
        })
      
        
    }
    func getImageBaseOnFilename(name:String,callback:((UIImage) ->Void)){
        var image:UIImage?
        BmobProFile.getFileAcessUrlWithFileName(name) { (file, error) in
            if error != nil {
                print("error:\(error)")
                callback(image!)
            }else{
                let  url = NSURL(string: file.url)
                let data = NSData(contentsOfURL: url!)
                if data != nil {
                    image = UIImage(data: data!)
                }
                callback(image!)
            }
        }
    }

    func getVoteStatus(singlePictureId:String,callback:((Bool) -> Void)!){
        let bquery = BmobQuery(className: "_User")
        
        let post = BmobObject(outDatatWithClassName: "SinglePicture", objectId: singlePictureId)
        bquery.whereObjectKey("vote", relatedTo: post)
        if let currentUser = BmobUser.getCurrentUser(){
        
        bquery.findObjectsInBackgroundWithBlock({array,error in
            var flag = false
            for bj in array{
                if bj is BmobObject{
                   
                    let userId = bj.objectId
                        if currentUser.objectId == userId {
                            print("true")
                            flag = true
                            break
                        
                    }else{
                        continue
                    }
                    
                }
            }
            callback(flag)
            }
        )
        }else{
            callback(false)
        }
        
    }
    func getVoteArray(singlePictureId:String,callback:(([UserInfo]) -> Void)!){
        var users = [UserInfo]()    
        let bquery = BmobQuery(className: "_User")
        let post = BmobObject(outDatatWithClassName: "SinglePicture", objectId: singlePictureId)
        bquery.whereObjectKey("vote", relatedTo: post)
        bquery.findObjectsInBackgroundWithBlock({array,error in
            for bj in array{
                if bj is BmobObject{
                    let user = UserInfo()
                    user.objectId = bj.objectId
                    user.username = bj.username
                    if let avatar = bj.objectForKey("avatar") {
                        user.avatar = avatar as! String
                    }
                    if let autograph = bj.objectForKey("autograph") {
                        user.autograph = autograph as! String
                    }
                    else {
                        user.autograph = "当我第一次知道要签名的时候，我是拒绝的！"
                    }
                    if let gender = bj.objectForKey("gender") {
                        user.gender = gender as! String
                    }
                    else {
                        user.gender = "未设置"
                    }
                    users.append(user)
                }
            }
            callback(users)
            }
        )
        
    }

    func getCollectionStatus(specialId:String,singlePictureId:String,callback:((Bool) -> Void)!){
        let bquery = BmobQuery(className: "special")
        
        let post = BmobObject(outDatatWithClassName: "SinglePicture", objectId: singlePictureId)
        
        bquery.whereObjectKey("beingCollection", relatedTo: post)
        bquery.includeKey("userId")
        bquery.findObjectsInBackgroundWithBlock({array,error in
            var flag = false
            for bj in array{
                if bj is BmobObject{
                    let user:BmobUser = bj.objectForKey("userId") as! BmobUser
                    let userId = user.objectId
                    
                    if let currentUser = BmobUser.getCurrentUser(){
                        if currentUser.objectId == userId {
                            flag = true
                            break
                        }
                    }
                    else{
                        continue
                    }
                }
            }
            callback(flag)
            }
        )
        
    }
    
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
                    
                    
                    if obj.objectForKey("comment") != nil {
                        
                        spInfo.comment = obj.objectForKey("comment") as! Array<NSDictionary>
                        spInfo.commentCount = spInfo.comment.count
                        
                    }
                    else {
                        spInfo.commentCount = 0
                    }
                    
                    self.getVoterCount(obj.objectId, callback: { (num) in
                        spInfo.upvoteCount = num
                        
                        SinglePictureDetailController.getCollectionCount(obj.objectId, callback: { (count) in
                            spInfo.collectionCount = count
                            
                            
                        })
                    })
                    
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

    func getCollectionList(singlePictureId:String,callback:(([String]) -> Void)!){
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
    func getVoterList(singlePictureId:String,callback:(([String]) -> Void)!){
        var specialsId:[String] = [String]()
        let bquery = BmobQuery(className: "_User")
        
        let post = BmobObject(outDatatWithClassName: "SinglePicture", objectId: singlePictureId)
        
        bquery.whereObjectKey("vote", relatedTo: post)
        
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

    

     func moreAboutSpecial(tap:UITapGestureRecognizer){
        self.getCollectionList((self.singlePictureInfo?.objectId)!) { (ids) in
            let vc = SpecialsAboutCollectionTableViewController()
            vc.specials = ids
            if ids.count > 0 {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
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
   class func getCollectionCount(singlePictureId:String,callback:((Int) -> Void)!){
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
   class func getImageAndSize(fileName:String,callback:((UIImage,CGSize) -> Void)!){
    var image:UIImage!
    var frame:CGSize!
    
    BmobProFile.getFileAcessUrlWithFileName(fileName) { (file, error) in
        if (error != nil){
            callback(image,frame)
        }else{
            let  url = NSURL(string: file.url)
            let data = NSData(contentsOfURL: url!)
            if data != nil {
                image = UIImage(data: data!)
                frame = CGSize(width: image.size.width, height: image.size.height)
                callback(image,frame)
            }
        }
    }
    }
}
