//
//  RetPasswordViewController.swift
//  Originality
//
//  Created by fanzz on 16/4/10.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class RetPasswordViewController: UIViewController ,UITextFieldDelegate {
    
    var contentView:UIView = UIView()
    var phoneNumberTextfield:UITextField!
    var passwordTextfield:UITextField!
    var loginButton:UIButton!
    var validButton:UIButton!
    var pwdTextField:UITextField!
    
    
    var smscode:String!
    
    var secondsCountDown:Int!
    var countDownTimer:NSTimer!
    
    var resetContentView:UIView = UIView()
    var pwdField:UITextField!
    var pwdFieldConfirm:UITextField!
    var confirmButton:UIButton!
    
    
    override func viewDidAppear(animated: Bool) {
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("loginUserName") != nil {
            
            self.phoneNumberTextfield.text = NSUserDefaults.standardUserDefaults().objectForKey("loginUserName") as? String
            
            self.passwordTextfield.text = NSUserDefaults.standardUserDefaults().objectForKey("loginPassword") as? String
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
        
        
        self.title = "密码重置"
        
        
        let rightButton = UIBarButtonItem(title: "登陆", style: .Done, target: self, action: #selector(RegesiterViewController.loginButtonClick(_:)))
        
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.tintColor = titleCorlor
        
        
        
        
        
        configView()
        
        phoneNumberTextfield.delegate = self
        // passwordTextfield.delegate = self
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RegesiterViewController.didChange(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func loginButtonClick(sender:UIButton)
    {
        let vc = LoginViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        //        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func back(sender:UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didChange(sender:NSNotification)
    {
        
        if phoneNumberTextfield.text!.isEmpty {
            self.loginButton.enabled = false
            self.loginButton.backgroundColor = UIColor.grayColor()
        }
        else {
            self.loginButton.backgroundColor = maincolor
            self.loginButton.enabled = true
        }
        
        
    }
    
    
    func configView()
    {
        contentView.frame = CGRect(x: 0, y: 74, width: screenWidth , height: 180)
        self.view.addSubview(contentView)
        
        contentView.backgroundColor = contentColor
        
        phoneNumberTextfield = UITextField(frame: CGRect(x: 20, y: 0, width: screenWidth - 40, height: 44))
        
        self.contentView.addSubview(phoneNumberTextfield)
        
        phoneNumberTextfield.clearButtonMode = .WhileEditing
        phoneNumberTextfield.placeholder = "手机号码"
        phoneNumberTextfield.backgroundColor = contentColor

        
        
        
        let splitView = UIView(frame: CGRect(x: 20, y: phoneNumberTextfield.frame.origin.y + phoneNumberTextfield.frame.height, width: phoneNumberTextfield.frame.width, height: 1))
        
        splitView.backgroundColor = splitViewColor
        self.contentView.addSubview(splitView)
        
        passwordTextfield = UITextField(frame: CGRect(x: 20, y: splitView.frame.origin.y + splitView.frame.height, width: phoneNumberTextfield.frame.width - 100, height: phoneNumberTextfield.frame.height))
        
        self.contentView.addSubview(passwordTextfield)
        
        passwordTextfield.clearButtonMode = .WhileEditing
        passwordTextfield.secureTextEntry = true
        passwordTextfield.placeholder = "验证码"
        passwordTextfield.backgroundColor = contentColor
        
        validButton = UIButton(frame: CGRect(x: phoneNumberTextfield.frame.width - 80, y: passwordTextfield.frame.origin.y, width: phoneNumberTextfield.frame.width - passwordTextfield.frame.width, height: passwordTextfield.frame.height))
        
        self.contentView.addSubview(validButton)
        
        
        validButton.setTitle("获取验证码", forState: .Normal)
        validButton.setTitleColor(titleCorlor, forState: .Normal)
        validButton.addTarget(self, action: #selector(RegesiterViewController.requestSMSCode), forControlEvents: .TouchUpInside)
        validButton.backgroundColor = contentColor
        
        let leftBorderView = UIImageView(frame: CGRect(x: validButton.frame.origin.x, y: validButton.frame.origin.y + 5, width: 1, height: validButton.frame.height - 10))
        
        self.contentView.addSubview(leftBorderView)
        
        leftBorderView.backgroundColor = splitViewColor
        
        
        let bottomView = UIView(frame: CGRect(x: 20, y: passwordTextfield.frame.origin.y + passwordTextfield.frame.height - 1, width: phoneNumberTextfield.frame.width, height: 1))
        
        bottomView.backgroundColor = splitViewColor
        self.contentView.addSubview(bottomView)
        
        pwdField = UITextField(frame: CGRect(x: 20, y: bottomView.frame.origin.y + bottomView.frame.height , width: screenWidth - 40, height: 44))
        
        self.contentView.addSubview(pwdField)
        
        pwdField.clearButtonMode = .WhileEditing
        pwdField.placeholder = "新密码"
        pwdField.backgroundColor = contentColor
        
        let splitView1 = UIView(frame: CGRect(x: 20, y: pwdField.frame.origin.y + pwdField.frame.height, width: pwdField.frame.width, height: 1))
        
        splitView1.backgroundColor = splitViewColor
        self.contentView.addSubview(splitView1)
        
        pwdFieldConfirm = UITextField(frame: CGRect(x: 20, y: splitView1.frame.origin.y + splitView1.frame.height, width: screenWidth - 40, height: 44))
        
        self.contentView.addSubview(pwdFieldConfirm)
        
        pwdFieldConfirm.clearButtonMode = .WhileEditing
        pwdFieldConfirm.placeholder = "再次输入新密码"
        pwdFieldConfirm.backgroundColor = contentColor
        
        let splitView2 = UIView(frame: CGRect(x: 20, y: pwdFieldConfirm.frame.origin.y + pwdFieldConfirm.frame.height, width: pwdField.frame.width, height: 1))
        
        splitView2.backgroundColor = splitViewColor
        self.contentView.addSubview(splitView2)
        
        
        loginButton = UIButton(frame: CGRect(x: 20, y:self.contentView.frame.origin.y + self.contentView.frame.height + 25, width: bottomView.frame.width, height: 44))
        
        self.view.addSubview(loginButton)
        
        
        loginButton.backgroundColor = UIColor.grayColor()
        loginButton.setTitle("确定", forState: .Normal)
        loginButton.setTitleColor(contentColor, forState: .Disabled)
        loginButton.layer.cornerRadius = 4.0
        
        self.loginButton.addTarget(self, action: #selector(RetPasswordViewController.regesiter), forControlEvents: .TouchUpInside)
        self.loginButton.enabled = false
        
        //resetView
        
        
    }
  
    
    func confirmButtonClick(sender:UIButton){
        
        let pwd1 = pwdField.text
        let pwd2 = pwdFieldConfirm.text
            if pwd1 == pwd2 && pwd1 != ""{
            BmobUser.resetPasswordInbackgroundWithSMSCode(smscode, andNewPassword: pwd1, block: { (success, error) in
                
                if success {
                   
                    SVProgressHUD.showSuccessWithStatus("密码重置成功，请使用新密码登录")

                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
            else{
                
                SVProgressHUD.showErrorWithStatus("俩次输入新密码不一致，请重新输入")
                pwdFieldConfirm.becomeFirstResponder()
        }
    }
    func requestSMSCode()
    {
        let phoneNumber = phoneNumberTextfield.text
        
        BmobSMS.requestSMSCodeInBackgroundWithPhoneNumber(phoneNumber, andTemplate: "test") { (number, error) -> Void in
            if error != nil {
                NSLog("%@", error)
                
                
                SVProgressHUD.showErrorWithStatus("请输入正确的手机号")
            }
            else {
                
                NSLog("sms ID: %d",number )
                
                self.setRequestSMSCodeBtnCountDown()
            }
        }
        
        
    }
    
    func setRequestSMSCodeBtnCountDown()
    {
        self.validButton.enabled = true
        
        self.secondsCountDown = 60
        
        countDownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(RegesiterViewController.countDownTimeWithSeconds(_:)), userInfo: nil, repeats: true)
        countDownTimer.fire()
        
    }
    
    func countDownTimeWithSeconds(timerInfo:NSTimer){
        if (secondsCountDown == 0) {
            self.validButton.enabled = true
            self.validButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            self.validButton.setTitle("获取验证码", forState: .Normal)
            
            countDownTimer.invalidate()
            
        } else {
            self.validButton.setTitle(String(secondsCountDown), forState: UIControlState.Normal)
            self.secondsCountDown = self.secondsCountDown - 1
        }
        
    }
    
    func regesiter()
    {
        let phoneNumber = phoneNumberTextfield!.text
        let smsCode = passwordTextfield!.text
        
        print("name:\(phoneNumber!);pwd:\(smsCode!)")
        
        if smsCode == "" {
            
            passwordTextfield.clearButtonMode = .Always
            passwordTextfield.becomeFirstResponder()
            
            
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.passwordTextfield.center.x -= 15
                }, completion: nil)
            UIView.animateWithDuration(0.3, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.passwordTextfield.center.x += 15
                }, completion: nil)
            UIView.animateWithDuration(0.3, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.passwordTextfield.center.x += 15
                }, completion: nil)
            UIView.animateWithDuration(0.3, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.passwordTextfield.center.x -= 15
                }, completion: nil)
            
            
            
        }
        else {
            let pwd1 = pwdField.text
            let pwd2 = pwdFieldConfirm.text
            if pwd1 == pwd2 && pwd1 != ""{
                BmobUser.resetPasswordInbackgroundWithSMSCode(smscode, andNewPassword: pwd1, block: { (success, error) in
                    
                    if success {
                        
                        SVProgressHUD.showSuccessWithStatus("密码重置成功，请使用新密码登录")

                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            }
            else{
                
               SVProgressHUD.showErrorWithStatus("俩次输入新密码不一致，请重新输入")
                pwdFieldConfirm.becomeFirstResponder()
            }

//                      BmobSMS.verifySMSCodeInBackgroundWithPhoneNumber(phoneNumber, andSMSCode: smsCode, resultBlock: { (isSuccessful, error) -> Void in
//                            if isSuccessful {
//                               print("手机号验证成功")
//                        }
//                            else {
//                                let alertView = UIAlertView(title: "系统提示", message: " 手机验证失败，请稍候重试", delegate: self, cancelButtonTitle: "ok")
//                                
//                                alertView.show()
//                        }
//            })
            
        }
       
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        phoneNumberTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
    }

}
