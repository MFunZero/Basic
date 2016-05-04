//
//  SearchViewController.swift
//  Originality
//
//  Created by suze on 16/2/17.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController,UISearchBarDelegate ,UICollectionViewDataSource,UICollectionViewDelegate {

    var searchBar:UISearchBar = UISearchBar()
    var collectionView : UICollectionView!
    
    // 所有组件
    var ctrls:[SinglePictureInfo]!
    // 搜索匹配的结果，Table View使用这个数组作为datasource
    var ctrlsel:[SinglePictureInfo] = [SinglePictureInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = bgColor
       

        collectionView = UICollectionView(frame:CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight), collectionViewLayout: SearchResultViewLayout())
        collectionView.backgroundColor = bgColor
        self.view.addSubview(collectionView)
         collectionView.alwaysBounceVertical = true
        
        // 起始加载全部内容
        self.ctrlsel = self.ctrls
        
        let leftButton = UIBarButtonItem(image: UIImage(named: "grey_left"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(SearchViewController.back(_:)))
        
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.leftBarButtonItem?.tintColor = maincolor
        
        searchBar.frame = CGRect(x: 0, y: 0, width: screenWidth - 50, height: 20)

        
        let rightButton = UIBarButtonItem(customView: searchBar)
        self.navigationItem.rightBarButtonItem = rightButton
        
        searchBar.delegate = self
        searchBar.showsSearchResultsButton = false
        searchBar.showsScopeBar = false
        searchBar.returnKeyType = UIReturnKeyType.Done

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        // 注册
        self.collectionView.registerClass(UserCollectioncell.self,
            forCellWithReuseIdentifier: "SwiftCell")
        self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "FootView")
        self.collectionView!.registerClass(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView")
    }
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableView:UICollectionReusableView!
        if kind ==  UICollectionElementKindSectionFooter {
            reusableView = collectionView.dequeueReusableSupplementaryViewOfKind( kind, withReuseIdentifier: "FootView", forIndexPath: indexPath)
            print("Footer")
            //reusableView.backgroundColor = UIColor(red:234/255.0, green:235/255.0,blue:236/255.0,alpha: 1)
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
            
      
            
            
        }

        
        return reusableView
    }
     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return  1
    }
    
    
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.ctrlsel.count
    
    }
    
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UserCollectioncell!
        
        if cell == nil {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("SwiftCell", forIndexPath: indexPath) as? UserCollectioncell
            
            if self.ctrls.count != 0 {
                // print("sgData:\(singleData[indexPath.row])")
                
                let sp:SinglePictureInfo = self.ctrlsel[indexPath.row]
                
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
    
     func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let tag = indexPath.row
       
        let vc:SinglePictureDetailController = SinglePictureDetailController()
            vc.singlePictureInfo = self.ctrls[tag]
            vc.title = titleForDetail
            
            var specialIds:[String] = [String]()
            specialIds.append(self.ctrlsel[tag].specialId)
            print("flag1:\(specialIds)")
            
            Collection.getCollectionList(self.ctrlsel[tag].objectId, callback: { (specialsId) in
                if specialsId.count > 0{
                    for id in specialsId {
                        specialIds.append(id)
                    }
                }
                vc.specials = specialIds
                print("flag2:\(specialIds),count:\(specialsId.count)")
                
                if (self.navigationController!.topViewController!.isKindOfClass(SearchViewController)) {
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                }
                
                
            })
        
    }
    

    

    
    // 搜索代理UISearchBarDelegate方法，每次改变搜索内容时都会调用
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        // 没有搜索内容时显示全部组件
        if searchText == "" {
            self.ctrlsel = self.ctrls
        }
        else { // 匹配用户输入内容的前缀(不区分大小写)
            self.ctrlsel = []
            for ctrl in self.ctrls {
                if ctrl.title.containsString(searchText) {
                    self.ctrlsel.append(ctrl)
                }
            }
        }
        // 刷新Table View显示
        self.collectionView.reloadData()
    }
    
    func back(sender:UIBarButtonItem)
    {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        searchBar.resignFirstResponder()

    }
    // 搜索代理UISearchBarDelegate方法，点击虚拟键盘上的Search按钮时触发
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
