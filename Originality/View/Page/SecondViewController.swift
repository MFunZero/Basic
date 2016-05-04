//
//  SecondViewController.swift
//  Originality
//
//  Created by suze on 16/1/13.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController,UIScrollViewDelegate  {
    
    var scrollView:UIScrollView!
    var recentSearchView:UIView!
    var height:CGFloat = 74.0
    
    var hotSearchView:UIView = UIView()
    
    var historyModel:SearchHistoryModel!
     var tags = ["最新美图","热门图片"]
    
    var titles:[String] = ["beauty lady","love","some one like you"]
    override func viewWillAppear(animated: Bool) {
        if recentSearchView != nil {
            recentSearchView.removeFromSuperview()
        }
        loadHistorySearch()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTagView()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(SecondViewController.addHistorySearch(_:)), name: "searchButtonClicked", object: nil)    }
    
    func addTagView(){
        self.view.backgroundColor = bgColor
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        
        self.scrollView.delegate = self
        
        self.view.addSubview(scrollView)
        
        self.scrollView.contentSize = CGSize(width: screenWidth, height: screenHeight + 25)
        loadHistorySearch()
        
        hotSearchView.frame = CGRect(x: 0, y: self.height, width: screenWidth, height: 120)
        self.scrollView.addSubview(hotSearchView)
        
        hotSearchView.backgroundColor = contentColor
        
        let titleLable = UILabel(frame: CGRect(x: 10, y: 0, width: screenWidth - 10, height: 30))
        hotSearchView.addSubview(titleLable)
        titleLable.text = "内容推荐"
        
        let cells = [PersonTableViewCell(),PersonTableViewCell()]
        var count = 0
        let imgName = ["bg7","bg10"]
        for cell in cells {
            cell.frame = CGRect(x: 0, y: 30.0+CGFloat(count * 40) , width: screenWidth, height: 40)
            cell.backgroundColor = contentColor
            hotSearchView.addSubview(cell)
            
            cell.accessoryType = .DisclosureIndicator
            cell.picture.image = UIImage(named: imgName[count])
            cell.titleLabel.text = tags[count]
            
            cell.tag = count
            cell.userInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(SecondViewController.searchRelyOncell(_:)))
            cell.addGestureRecognizer(gesture)
            count += 1
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        MainController.searchBar.resignFirstResponder()
    }
}
extension SecondViewController{
    func searchRelyOncell(sender:UIGestureRecognizer){
        
        let tag:Int = sender.view!.tag
        print("tag:\(tag)")
        let vc = SearchViewController()
        var singleData:[SinglePictureInfo] = []
       
        let text = self.tags[tag]
        
        vc .searchBar.text = text
        
        let query:BmobQuery = BmobQuery(className:"SinglePicture")

        if tag == 1{
        query.orderByAscending("createdAt")
        }
        else {
           query.orderByDescending("upvote")
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
                    
                    if let title = special.objectForKey("title") {
                    spInfo.specialName = title as! String
                    }
                    else{
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
    func addHistorySearch(fication:NSNotification){
        let text = fication.userInfo! as NSDictionary
        
        let title = text.objectForKey("title") as! String
        print("text:\(title)")
        historyModel = SearchHistoryModel()
        let history = historyModel.loadData()
        var searchNewHistory = [SearchHistory]()
        
        if history.count > 0{
            searchNewHistory.append(SearchHistory(title: title, time: NSDate()))
            if history.count < 3 {
            for item in history {
                searchNewHistory.append(item)
            }
            }
            else {
                for i in 0..<3 {
                    searchNewHistory.append(history[i])
                }
            }
            historyModel.historyList = searchNewHistory
            
        }else{
            historyModel.historyList.append(SearchHistory(title: title, time: NSDate()))
        }
        for item in history {
            if item.title == title {
                historyModel.historyList = history
            }
        }
        print("historyModel:\(historyModel.historyList as Array)")
        historyModel.saveData()
    }
    func loadHistorySearch(){
        historyModel = SearchHistoryModel()
        let data:[SearchHistory] = historyModel.loadData()
        print("loadhistoryModel:\(data)")
        if data.count > 0{
            recentSearchView = UIView()
            recentSearchView.frame = CGRect(x: 0, y: 74, width: screenWidth, height: 100)
            self.scrollView.addSubview(recentSearchView)
            
            recentSearchView.backgroundColor = contentColor
//            self.height = recentSearchView.frame.origin.y + recentSearchView.frame.height + 20
            if self.hotSearchView.frame.origin.y == recentSearchView.frame.origin.y{
                
                    UIView.animateWithDuration(0.3) {
                        self.hotSearchView.center.y += 110.0
                    }
                
            }
            let titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 100, height: 25))
            recentSearchView.addSubview(titleLabel)
            titleLabel.text = "历史记录"
            
            
            let cleanButton = UIButton(frame: CGRect(x: screenWidth - 90, y: 10, width: 80, height: 25))
            recentSearchView.addSubview(cleanButton)
            cleanButton.setTitle("清除记录", forState: .Normal)
            cleanButton.setTitleColor(splitViewColor, forState: .Normal)
            cleanButton.addTarget(self, action: #selector(SecondViewController.cleanHistorySearch(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            var tagButtons:[UIButton] = [UIButton(),UIButton(),UIButton(),UIButton()]
            var i = 0
            let width = Double((screenWidth - 40)/3)
            let w = Double((screenWidth - 10)/3)
            let height = 30.0
            for tag in data {
                if i > 3 {
                    break
                }
                let x = Double(10.0 + Double(w) * Double(i))
                tagButtons[i].frame = CGRect(x: x, y: 45.0, width: width,  height: height)
                
                tagButtons[i].setTitle(tag.title, forState: .Normal)
                tagButtons[i].setTitleColor(UIColor.blackColor(), forState: .Normal)
                tagButtons[i].titleLabel?.lineBreakMode = .ByTruncatingTail
                tagButtons[i].addTarget(self, action: #selector(SecondViewController.historyForSearch(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                recentSearchView.addSubview(tagButtons[i])
                i += 1
                
            }
            
        }
    }
    func historyForSearch(sender: UIButton){
        let text = sender.titleLabel?.text
        print("searchText:\(text)")
        let vc = SearchViewController()
        var singleData:[SinglePictureInfo] = []
        var tag = true
        if  text == defaultSearch{
            tag = false
        }
        vc.searchBar.text = text
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
    
    func cleanHistorySearch(sender:UIButton){
        
        historyModel.deleteFile()
        recentSearchView.removeFromSuperview()
        self.loadHistorySearch()
        
        UIView.animateWithDuration(0.3) {
            self.hotSearchView.center.y -= 110.0
        }
    }
}
