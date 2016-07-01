//
//  CreateSpecialViewController.swift
//  Originality
//
//  Created by suze on 16/2/21.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class CreateSpecialViewController: UIViewController {

    var specialnameLabel:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalTransitionStyle = .CrossDissolve
        
        config()
        // Do any additional setup after loading the view.
    }

    func config()
    {
        specialnameLabel = UITextField(frame: CGRect(x: 10, y: 84, width: screenWidth - 20, height: 44))
        
        self.view.addSubview(specialnameLabel)
        
        specialnameLabel.backgroundColor = contentColor
        specialnameLabel.placeholder = "输入专辑名称"
        
        self.view.backgroundColor = bgColor
        self.title = "评论"
        let leftButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(CreateSpecialViewController.back(_:)))
        
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.leftBarButtonItem?.tintColor = titleCorlor

        
        let rightButton = UIBarButtonItem(title: "完成", style: UIBarButtonItemStyle.Done, target: self, action: #selector(CreateSpecialViewController.done))
        
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.tintColor = maincolor
    }
    
    func done()
    {
        
        let specialName = specialnameLabel.text
        
        if specialName!.isEmpty {
            
            SVProgressHUD.showErrorWithStatus("请输入专辑名称")
            return
        }
        SVProgressHUD.show()
        self.view.userInteractionEnabled = false
        self.navigationController?.navigationBar.userInteractionEnabled = false
        
        let currentUser = BmobUser.getCurrentUser().objectId
        let user = BmobObject(outDatatWithClassName: "_User", objectId: currentUser)
        let category = BmobObject(outDatatWithClassName: "category", objectId: "bPVX555A")
        let obj = BmobObject(className: "special")
        obj.setObject(specialName, forKey: "title")
        obj.setObject(user, forKey: "userId")
        obj.setObject(category, forKey: "categoryId")
        obj.saveInBackgroundWithResultBlock({ (isSuccessful, error) -> Void in
            
            if isSuccessful {
                NSLog("comment:\(obj)")
                let dic:NSDictionary = ["objId":"\(obj.objectId)"]
                NSNotificationCenter.defaultCenter().postNotificationName("NotificationIdentifier", object: dic)
                SVProgressHUD.showSuccessWithStatus(nil)
                self.view.userInteractionEnabled = true
                self.navigationController?.navigationBar.userInteractionEnabled = true
                self.navigationController?.popToRootViewControllerAnimated(true)
              
            }
            else {
                SVProgressHUD.showErrorWithStatus(nil)
                self.view.userInteractionEnabled = true
                self.navigationController?.navigationBar.userInteractionEnabled = true
                print("create special:\(specialName)")
            }
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}

extension CreateSpecialViewController{
    
    func back(sender:UIBarButtonItem)
    {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}
