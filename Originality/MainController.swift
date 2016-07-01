//
//  TabViewController.swift
//  Originality
//
//  Created by suze on 16/1/13.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class MainController: UITabBarController,UISearchBarDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var myTabbar :UIView?
    var slider :UIView?
    let btnBGColor:UIColor =  UIColor(red:125/255.0, green:236/255.0,blue:198/255.0,alpha: 1)
    let tabBarBGColor:UIColor =    UIColor(red:0/255.0, green:179/255.0,blue:138/255.0,alpha: 1)
    let titleColor:UIColor =  UIColor(red:52/255.0, green:156/255.0,blue:150/255.0,alpha: 1)
    
    let titles = ["首页","","消息","我"]
    let itemArray = ["首页","发现","消息","我"]
    let imageArray = ["selected1","a2","a3","a4"]
    let widthSingle = screenWidth / 4
    var items:[UIBarButtonItem]!
    var leftItems:[UIBarButtonItem]!
    
    static var searchBar:UISearchBar!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
        self.title = "首页"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let rightButton = UIBarButtonItem(image: UIImage(named: "icon_homepage_search"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(MainController.search))
        
        
        
        let rightButton1 = UIBarButtonItem(title: "取消", style: UIBarButtonItemStyle.Done, target: self, action: #selector(MainController.cancelSearch))
        
        let rightButton2 = UIBarButtonItem()
        
        let rightButton3 = UIBarButtonItem()
        items = [rightButton,rightButton1,rightButton2,rightButton3]
        self.navigationItem.setRightBarButtonItem(rightButton, animated: true)
        self.navigationItem.rightBarButtonItem?.tintColor = maincolor
        //
        let leftButton = UIBarButtonItem(image: UIImage(named: "btn_add"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(MainController.addPhotos))
        MainController.searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: screenWidth - 70, height: 20))
        MainController.searchBar.placeholder = defaultSearch
        MainController.searchBar.delegate = self
        MainController.searchBar.returnKeyType = .Search
        
        let leftButton1 = UIBarButtonItem(customView: MainController.searchBar)
        
        
        let leftButton2 = UIBarButtonItem()
        
        let leftButton3 = UIBarButtonItem()
        leftItems = [leftButton,leftButton1,leftButton2,leftButton3]
        self.navigationItem.setLeftBarButtonItem(leftButton, animated: true)
        self.navigationItem.leftBarButtonItem?.tintColor = maincolor
        
        setupViews()
        initViewControllers()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(MainController.getLocalNotification(_:)), name: "localNotification", object: nil)
    }
    
    func getLocalNotification(notification:NSNotification)
    {
        let obj = notification.object as! NSDictionary
        if (obj.objectForKey("id") as? Int) == 1 {
            self.presentViewController(AboutUseViewController(), animated: true, completion: nil)
        }
    }
    
    
    
    func cancelSearch(){
        MainController.searchBar.resignFirstResponder()
        MainController.searchBar.text = ""
    }
   
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search()
    }
    func search()
    {
        let vc = SearchViewController()
        var singleData:[SinglePictureInfo] = []
        var text = MainController.searchBar.text
        var tag = true
        if text == "" {
            tag = false
            text = defaultSearch
        }
        vc.searchBar.text = text
        
        MainController.searchBar.text = ""
        NSNotificationCenter.defaultCenter().postNotificationName("searchButtonClicked", object: nil, userInfo: ["title":text!])
        let query:BmobQuery = BmobQuery(className:"SinglePicture")
        if tag {
            let pattern = ".*?"+text!+".*?"
            query.whereKey("title", matchesWithRegex: pattern)
        }
        query.includeKey("userId,specialId")
        query.findObjectsInBackgroundWithBlock({array,error in
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
                    
                    if obj.objectForKey("avatar") != nil {
                        
                        spInfo.userAvator = user.objectForKey("avatar") as! String
                        
                    }
                    
                    
                    //获取专辑信息
                    let special:BmobObject = obj.objectForKey("specialId") as! BmobObject
                    spInfo.specialId = special.objectId
                    
                    if let title = special.objectForKey("title") {   spInfo.specialName = title as! String
                    }
                    else {
                        spInfo.specialName = "默认专辑"
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
                        
                        spInfo.collection = obj.objectForKey("collection") as! Array
                        spInfo.collectionCount = spInfo.collection.count
                        
                    }
                    else {
                        spInfo.collectionCount = 0
                    }
                    
                    if obj.objectForKey("comment") != nil {
                        
                        spInfo.comment = obj.objectForKey("comment") as! Array
                        spInfo.commentCount = spInfo.comment.count
                        
                    }
                    else {
                        spInfo.commentCount = 0
                    }
                    
                    singleData.append(spInfo)
                    //singleData.addObject(spInfo)
                    
                    tag = tag + 1
                    
                    
                }
            }
            vc.ctrls = singleData
            self.navigationController?.pushViewController(vc, animated: true)
            }
        )
        
        
        
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        print("choose--------->>")
        
        
        
        print(info)
        
        
        
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let editPage = EditPhotoViewController()
        
        let nav = UINavigationController(rootViewController: editPage)
        
        
        
        
        editPage.photoView.image = img
        
        
        let imageData = UIImageJPEGRepresentation(img, 0.5)
        // 获取沙盒目录
        format.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let dateString = format.stringFromDate(date)
        let curUser = BmobUser.getCurrentUser()
        if curUser == nil {
            let vc = EnterPageViewController()
            self.presentViewController(vc, animated: true, completion: nil)
        }
        else {
            let currentUser = curUser.objectId
            currentImageName = currentUser+"_CurrentImage_"+dateString+".jpg"
            let fullPath = ((NSHomeDirectory() as NSString).stringByAppendingPathComponent("Documents") as NSString).stringByAppendingPathComponent(currentImageName)
            print("home:\(NSHomeDirectory())")
            // 将图片写入文件
            
            imageData?.writeToFile(fullPath, atomically: true)
            
            
            picker.dismissViewControllerAnimated(true, completion: nil)
            
            self.presentViewController(nav, animated: true, completion: nil)
        }
        
        
        
    }

    //addPhotos
    func addPhotos()
    {
        if let user = BmobUser.getCurrentUser()
        {
        let alertController = UIAlertController(title: "上传图片", message: "",
                                                preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "拍照", style: .Destructive){ (action) in
            let page = UIImagePickerController()
            
            page.delegate = self
            
            page.sourceType = .Camera
            
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                page.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                page.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(page.sourceType)!
            }
            
            
            self.presentViewController(page, animated: true, completion: nil)
            
        }
        
        let archiveAction = UIAlertAction(title: "图片库", style: .Default) { (action) in
            let page = UIImagePickerController()
            
            page.delegate = self
            
            page.sourceType = .PhotoLibrary
            
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                
                
                
                page.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                
                
                
                page.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(page.sourceType)!
                
                
            }
            
            
            self.presentViewController(page, animated: true, completion: nil)
            
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.addAction(archiveAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        }else{
            let vc = LoginViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func setupViews()
    {
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.whiteColor()
        self.tabBar.hidden = true
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        self.myTabbar = UIView(frame: CGRectMake(0,height-44,width,44))
        self.myTabbar!.backgroundColor = tabBarBGColor
        self.slider = UIView(frame:CGRectMake(0,0,widthSingle,44))
        self.slider!.backgroundColor = UIColor.whiteColor()//btnBGColor
        self.myTabbar!.addSubview(self.slider!)
        
        self.view.addSubview(self.myTabbar!)
        
        let count = self.itemArray.count
        
        for index in 0 ..< count
        {
            let btnWidth = CGFloat(index) * widthSingle
            
            let imageView = UIImageView(frame: CGRectMake(btnWidth,0,widthSingle,44))
            
            imageView.image = UIImage(named:imageArray[index])
            imageView.tag = index
            
            let button  = UIButton(type: UIButtonType.Custom)
            button.frame = CGRectMake(btnWidth, 0,widthSingle,44)
            button.tag = index+100
            let title = self.itemArray[index]
            //设置标题
            
            button.setTitle(title, forState: UIControlState.Normal)
            button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            button.setTitleColor(tabBarBGColor, forState: UIControlState.Selected)
            
            button.addTarget(self, action: #selector(MainController.tabBarButtonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.myTabbar?.addSubview(button)
            if index == 0
            {
                button.selected = true
            }
            
        }
    }
    
    func initViewControllers()
    {
        
        let vc1 = Collection(collectionViewLayout: CollectionViewLayout())
        
        // vc1.jokeType = .NewestJoke
        let vc2 = SecondViewController()
        // vc2.jokeType = .HotJoke
        let vc3 = ThirdTableViewController()
        //  vc3.jokeType = .ImageTruth
        let vc4 = FourthTableViewController()
    
        self.viewControllers = [vc1,vc2,vc3,vc4]
    }
    
    
    func tabBarButtonClicked(sender:UIButton)
    {
        let index = sender.tag
        let currentUser = BmobUser.getCurrentUser()
        if (index == 102 || index == 103) && currentUser == nil{
            let vc = LoginViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
            
            
            
        else {
            for i in 0 ..< self.itemArray.count
            {
                let button = self.view.viewWithTag(i+100) as! UIButton
                
                if button.tag == index
                {
                    button.selected = true
                    self.selectedIndex = index-100
                    
                    
                    
                }
                else
                {
                    button.selected = false
                    
                }
            }
            UIView.animateWithDuration( 0.3,
                                        animations:{
                                            
                                            self.slider!.frame = CGRectMake(CGFloat(index-100) * self.widthSingle,0,self.widthSingle,44)
                                            
            })
            
            self.title = titles[index-100] as String
            self.navigationItem.rightBarButtonItem = self.items[index-100]
            self.navigationItem.leftBarButtonItem = self.leftItems[index-100]
            self.navigationItem.leftBarButtonItem?.tintColor = maincolor
            self.navigationItem.rightBarButtonItem?.tintColor = maincolor
        }
    }
    
    
    
}
