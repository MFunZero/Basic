//
//  ChangeNicknameViewController.swift
//  Originality
//
//  Created by fanzz on 16/4/1.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class ChangeNicknameViewController: UIViewController {
   
    var usernameTextfield:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        
        let rightButton = UIBarButtonItem(title: "完成", style: .Done, target: self, action: #selector(ChangeNicknameViewController.done(_:)))
        
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.tintColor = titleCorlor
    }
    
    func configView()
    {
      
        
        usernameTextfield = UITextField(frame: CGRect(x: 20, y: 74, width: screenWidth - 40, height: 44))
        
        self.view.addSubview(usernameTextfield)
        
        usernameTextfield.clearButtonMode = .WhileEditing
        usernameTextfield.placeholder = "昵称"
        usernameTextfield.layer.borderColor = splitViewColor.CGColor
        usernameTextfield.layer.borderWidth = 1.0
        usernameTextfield.layer.cornerRadius = 10
    
   
        
        
  
        
        
    }
    
    func done(item:UIBarButtonItem)
    {
        let username = usernameTextfield.text
        
        print("name:\(username)")
        
        if username == "" {
          SVProgressHUD.showInfoWithStatus("请输入昵称")
        }
        else {
            let user = BmobUser.getCurrentUser()
            user.setObject(username, forKey: "username")
            user.updateInBackgroundWithResultBlock({ (success, error) in
                if error != nil {
                    print("updateUserAvatarError:\(error)")
                    SVProgressHUD.showErrorWithStatus("\(error)")
                }
                else {
                    SVProgressHUD.showSuccessWithStatus("修改昵称成功")
                    NSNotificationCenter.defaultCenter().postNotificationName("changeUsername", object: nil, userInfo: ["username":username!])
                    self.navigationController?.popToRootViewControllerAnimated(true)

                }
            })
            
            
        }
        
    }
}
