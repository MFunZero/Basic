//
//  EditTitleViewController.swift
//  Originality
//
//  Created by suze on 16/2/18.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class EditTitleViewController: BaseViewController {

    var activityIndicator:UIActivityIndicatorView!
    var photoView:UIImageView = UIImageView()
    var textView:UITextView = UITextView()
    
    //
    var specialId:String?
    var special:SpecialInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "发布"
        setNavigationItem(cancel, selector: #selector(EditTitleViewController.doLeft), isRight: false)
        
  
        setNavigationItem("下一步", selector: #selector(BaseViewController.doRight), isRight: true)

        configView()
        
        

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EditTitleViewController.notificationAction(_:)), name: "Notificationspecial", object: nil);
    }
    
    func notificationAction(fication : NSNotification){
        let dict = fication.userInfo! as NSDictionary
       self.special = dict.objectForKey("special") as? SpecialInfo

        setNavigationItem("完成", selector: #selector(EditTitleViewController.done), isRight: true)
    }
    
    func done()
    {
        let title = self.textView.text
        if title == ""{
            
            SVProgressHUD.showSuccessWithStatus("请输入标题内容")
            self.textView.becomeFirstResponder()
        }
        else {
      
            
          
            
            SVProgressHUD.show()
            self.navigationController!.navigationBar.userInteractionEnabled=false //将nav事件禁止
            
            
            self.view.userInteractionEnabled=false //界面

            let home = NSHomeDirectory() as NSString
        let path = home.stringByAppendingPathComponent("Documents") as NSString
        let imagePath = path.stringByAppendingPathComponent(currentImageName)
        let isExits:Bool = NSFileManager.defaultManager().fileExistsAtPath(imagePath)
        let image = UIImage(contentsOfFile: imagePath)
            let data = NSData(contentsOfFile: imagePath)
        if isExits && image != nil{
            print("111111")
            BmobProFile.uploadFileWithFilename(currentImageName, fileData: data, block:  { (success, error, filename, url, file) -> Void in
                if error != nil {
                    
                    SVProgressHUD.showErrorWithStatus("\(error)")
                    print("error:\(error)")
                    self.navigationController!.navigationBar.userInteractionEnabled=true //将nav事件禁止
                    self.view.userInteractionEnabled=true //界面
                }
                else{
                    print("str:\(filename),cstr:\(url)")
                    
                   // print("file:\(file.url),:::\(file.name)")
                  
                    let currentUserId = BmobUser.getCurrentUser().objectId
                    let user = BmobObject(outDatatWithClassName: "_User", objectId: currentUserId)
                    let specialRelation = BmobObject(outDatatWithClassName: "special", objectId: self.special?.objectId)
                    let obj = BmobObject(className: "SinglePicture")
                    obj.setObject(filename, forKey: "url")
                    obj.setObject(user, forKey: "userId")
                    obj.setObject(specialRelation, forKey: "specialId")
                    obj.setObject(title, forKey: "title")
                    obj.saveInBackgroundWithResultBlock({ (isSuccessful, error) -> Void in
                        if error != nil {

                            SVProgressHUD.showErrorWithStatus("\(error)")
                            self.navigationController!.navigationBar.userInteractionEnabled=true //将nav事件禁止
                            self.view.userInteractionEnabled=true //界面
                            print("create special:\(self.special?.objectId)")
                        }else {
                            NSLog("comment:\(obj)")
                            
                            self.dismissViewControllerAnimated(true, completion: nil)
                            
                        }
                       
                    })
                    }
                }, progress: { (index) -> Void in
                    print("progress:\(index)")
                    if index >= 1.00 {
                       SVProgressHUD.showSuccessWithStatus("successful")
                    }
            })
        }
        else {
            SVProgressHUD.showErrorWithStatus("图片上传出错")
            self.navigationController!.navigationBar.userInteractionEnabled=true //将nav事件禁止
            self.view.userInteractionEnabled=true //界面
            print("图片上传出错")
        }
              }
         }
    func configView()
    {
        photoView.frame = CGRect(x: 25, y: 89, width: 40, height: 40)
        
        self.view.addSubview(photoView)
        
        photoView.layer.borderWidth = 1.0
        photoView.layer.borderColor = splitViewColor.CGColor
        
        textView.frame = CGRect(x: 90, y: 89, width: screenWidth - 115, height: screenHeight / 2 - 119)
        
        self.view.addSubview(textView)
        
        textView.layer.cornerRadius = 5.0
        textView.layer.borderColor = splitViewColor.CGColor
        textView.layer.borderWidth = 1.0
        
        textView.becomeFirstResponder()
    }
    
    
    
     func doLeft() {
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }


    override func doRight()
    {
        let csVC = ChoseSpecialTableViewController()
        let vc = UINavigationController(rootViewController: csVC)
        
        let singlePicture = SinglePictureInfo()
        singlePicture.title = self.textView.text
        
        //csVC.singlePictureInfo = self.singlePictureInfo
        
        let query = BmobQuery(className: "special")
        
        var specials:[SpecialInfo] = []
        
        query.includeKey("userId,categoryId")
        
        let currentUser = BmobUser.getCurrentUser().objectId
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
                    
                    if let picture = obj.objectForKey("mainPicture") as? String {
                        special.pictureName = picture
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
                    
                 
                    
                    specials.append(special)
                }
                
                csVC.specials = specials
                
                self.presentViewController(vc, animated: true, completion: nil)
            }
        }
        
        

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
