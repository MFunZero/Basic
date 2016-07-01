//
//  LoginViewController.swift
//  Originality
//
//  Created by suze on 16/2/3.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController,UITextFieldDelegate {
    
    var contentView:UIView!
    var usernameTextfield:UITextField!
    var passwordTextfield:UITextField!
    var loginButton:UIButton!
    
    var gorgetPasswordButton:UIButton!
    
    
    override func viewDidAppear(animated: Bool) {
        
        
        if NSUserDefaults.standardUserDefaults().objectForKey("loginUserName") != nil {
            
            self.usernameTextfield.text = NSUserDefaults.standardUserDefaults().objectForKey("loginUserName") as? String
            
            self.passwordTextfield.text = NSUserDefaults.standardUserDefaults().objectForKey("loginPassword") as? String
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
        
        
        self.title = "登陆"
        let leftButton = UIBarButtonItem(image: UIImage(named: "grey_left"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(LoginViewController.back(_:)))
        
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.leftBarButtonItem?.tintColor = titleCorlor
        
        let rightButton = UIBarButtonItem(title: "注册", style: .Done, target: self, action: #selector(LoginViewController.regesiterButtonClick(_:)))
        
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.rightBarButtonItem?.tintColor = titleCorlor
        
        
        
        
        
        
        
        configView()
        
        usernameTextfield.delegate = self
        // passwordTextfield.delegate = self
        
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.didChange(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
        
        
        
        // Do any additional setup after loading the view.
    }
    
    func regesiterButtonClick(sender:UIButton)
    {
        let vc = RegesiterViewController()
        self.navigationController?.pushViewController(vc, animated: true)
//        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func back(sender:UIBarButtonItem)
    {
//        let mainViewController = MainController(nibName:nil,  bundle: nil)
//        let navigationViewController = UINavigationController(rootViewController: mainViewController)
//        self.presentViewController(navigationViewController, animated: true, completion: nil)
        self.navigationController?.popToRootViewControllerAnimated(true)
        
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didChange(sender:NSNotification)
    {
        
        if usernameTextfield.text!.isEmpty {
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
        contentView = UIView(frame: CGRect(x: 20, y: 74, width: screenWidth - 40, height: 88))
        self.view.addSubview(contentView)
        
        contentView.backgroundColor = contentColor
        
        usernameTextfield = UITextField(frame: CGRect(x: 0, y: 0, width: screenWidth - 40, height: 44))
        
        self.contentView.addSubview(usernameTextfield)
        
        usernameTextfield.clearButtonMode = .WhileEditing
        usernameTextfield.placeholder = "昵称／手机"
        
        
        
        
        let splitView = UIView(frame: CGRect(x: 0, y: usernameTextfield.frame.origin.y + usernameTextfield.frame.height - 1, width: usernameTextfield.frame.width, height: 1))
        
        splitView.backgroundColor = splitViewColor
        self.contentView.addSubview(splitView)
        
        passwordTextfield = UITextField(frame: CGRect(x: 0, y: usernameTextfield.frame.origin.y + usernameTextfield.frame.height, width: usernameTextfield.frame.width, height: usernameTextfield.frame.height))
        
        self.contentView.addSubview(passwordTextfield)
        
        passwordTextfield.clearButtonMode = .WhileEditing
        passwordTextfield.secureTextEntry = true
        passwordTextfield.placeholder = "密码"
        
        
        let bottomView = UIView(frame: CGRect(x: 0, y: passwordTextfield.frame.origin.y + passwordTextfield.frame.height - 1, width: passwordTextfield.frame.width, height: 1))
        
        bottomView.backgroundColor = splitViewColor
        self.contentView.addSubview(bottomView)
        
        
        
        loginButton = UIButton(frame: CGRect(x: 20, y: self.self.contentView.frame.origin.y + self.contentView.frame.height + 25, width: bottomView.frame.width, height: 44))
        
        self.view.addSubview(loginButton)
        
        
        loginButton.backgroundColor = UIColor.grayColor()
        loginButton.setTitle("登陆", forState: .Normal)
        loginButton.setTitleColor(contentColor, forState: .Disabled)
        loginButton.layer.cornerRadius = 4.0
        
        self.loginButton.addTarget(self, action: #selector(LoginViewController.login), forControlEvents: .TouchUpInside)
        self.loginButton.enabled = false
        
        gorgetPasswordButton = UIButton(frame: CGRect(x: screenWidth - 120, y: loginButton.frame.origin.y + loginButton.frame.height + 5, width: 100, height: 25))
        self.view.addSubview(gorgetPasswordButton)
        gorgetPasswordButton.setTitleColor(maincolor, forState: .Normal)
        gorgetPasswordButton.setTitle("忘记密码", forState: .Normal)
        gorgetPasswordButton.addTarget(self, action: #selector(LoginViewController.resetPassword), forControlEvents: .TouchUpInside)
    }
    func resetPassword(){
        let vc = RetPasswordViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func login()
    {
        let username = usernameTextfield.text
        let pwd = passwordTextfield.text
        
        print("name:\(username);pwd:\(pwd)")
        
        if pwd == "" {
            
            passwordTextfield.clearButtonMode = .Always
            passwordTextfield.becomeFirstResponder()
            
            SVProgressHUD.showErrorWithStatus("请输入密码")
            
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
         
            BmobUser.loginWithUsernameInBackground(username, password: pwd, block: { (user, error) -> Void in
                if user != nil {
                    NSLog("%@", user)
                    SVProgressHUD.showSuccessWithStatus("登录成功")
                    currentUser = user
                    let mainViewController = MainController(nibName:nil,  bundle: nil)
                    let navigationViewController = UINavigationController(rootViewController: mainViewController)
                    
                    self.presentViewController(navigationViewController, animated: true, completion: nil)
                }
                else {
                    
                    SVProgressHUD.showErrorWithStatus("请输入正确的账户名以及密码")
                }
                
            })
            
            
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        usernameTextfield.resignFirstResponder()
        passwordTextfield.resignFirstResponder()
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
