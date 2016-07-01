//
//  ChangeAutographViewController.swift
//  Originality
//
//  Created by fanzz on 16/4/1.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class ChangeAutographViewController: UIViewController {

    var usernameTextView:UITextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        let rightButton = UIBarButtonItem(title: "完成", style: .Done, target: self, action: #selector(ChangeAutographViewController.done(_:)))
        
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.tintColor = titleCorlor
        
         configView()
    }
    
    func configView()
    {
       
        
        usernameTextView.frame = CGRect(x: 20, y: 84, width: screenWidth - 40, height: 100)
        
        self.view.addSubview(usernameTextView)
        
        self.automaticallyAdjustsScrollViewInsets = false
        usernameTextView.text = "当我第一次知道要写签名的时候。我是拒绝的"
        usernameTextView.showsHorizontalScrollIndicator = false
        usernameTextView.layer.cornerRadius = 10.0
        usernameTextView.layer.borderColor = splitViewColor.CGColor
        usernameTextView.layer.borderWidth = 1.0
        usernameTextView.textAlignment = .Left
        usernameTextView.becomeFirstResponder()
        
        
        
        
        
        
        
    }
    
    func done(item:UIBarButtonItem)
    {
        let autograph = usernameTextView.text
        
        print("name:\(autograph)")
        
        if autograph == "" {
            
            SVProgressHUD.showInfoWithStatus("自定义签名不能为空")
        }
        else {
            let user = BmobUser.getCurrentUser()
            user.setObject(autograph, forKey: "autograph")
            user.updateInBackgroundWithResultBlock({ (success, error) in
                if error != nil {
                    print("updateUserAvatarError:\(error)")
                    SVProgressHUD.showErrorWithStatus("\(error)")
                }
                else {
                    SVProgressHUD.showSuccessWithStatus("更改自定义签名成功")
                    NSNotificationCenter.defaultCenter().postNotificationName("changeAutograph", object: nil, userInfo: ["autograph":autograph!])
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                }
            })
            
        }
    }
}
