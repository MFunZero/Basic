//
//  SettingPageTableViewController.swift
//  Originality
//
//  Created by fanzz on 16/3/31.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class SettingPageTableViewController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

//    var activityIndicator:UIActivityIndicatorView!
    
    var user:BmobUser!
    var avatar:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
        self.navigationItem.leftBarButtonItem?.tintColor = maincolor
        self.title = "个人信息"
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        
        self.tableView.registerClass(AvatarTableViewCell.self, forCellReuseIdentifier: "avatar")
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(SettingPageTableViewController.changeUsername(_:)), name: "changeUsername", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(SettingPageTableViewController.changeAutograph(_:)), name: "changeAutograph", object: nil)
    }
    
    func changeAutograph(notification:NSNotification)
    {
        self.user = BmobUser.getCurrentUser()
        self.tableView.reloadData()
    }
    
    func changeUsername(notification:NSNotification)
    {
        self.user = BmobUser.getCurrentUser()
        self.tableView.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
        return 3
        }
        else {
            return 2
        }
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            return 100
            
        }
        else {
            return 40
        }
    }
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        else {
         return 0.01
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0{
           
                let cell = tableView.dequeueReusableCellWithIdentifier("avatar", forIndexPath: indexPath) as! AvatarTableViewCell
                if avatar != nil {
                    cell.avatar = self.avatar
                }
                else {
                    cell.avatarView.image = UIImage(named: defaultHeaderImage)
                }
                cell.textLabel?.text = "头像"
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                return cell

        }else if indexPath.section == 0 && indexPath.row > 0 {
            let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "reuseIdentifier")
           cell.selectionStyle = .None
           cell.focusStyle = .Custom
            let tag = indexPath.row
            switch tag {
            case 1:
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.textLabel?.text = "昵称"
                cell.detailTextLabel?.text = self.user.username
                
                return cell
            case 2:
                cell.textLabel?.text = "账号"
                cell.detailTextLabel?.text = self.user.mobilePhoneNumber
                return cell
            default:
                return cell
            }
        }
        else {
             let cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "reuseIdentifier")
            
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            let tag = indexPath.row
            switch tag {
            case 0:
            cell.textLabel?.text = "性别"
            if let gender = user.objectForKey("gender") {
                cell.detailTextLabel?.text = gender as? String
            }
            else {
                cell.detailTextLabel?.text = "设置性别"
                }
            case 1:
              cell.textLabel?.text = "个性签名"
              if let autograph = user.objectForKey("autograph") {
                cell.detailTextLabel?.text = autograph as? String
                }
              else {
                cell.detailTextLabel?.text = "设置自定义签名"
                }
            default:
            cell.textLabel?.text = ""
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            
            let tag = indexPath.row
            switch tag {
            case 0:
                changeAvatar()
            case 1:
                self.navigationController?.pushViewController(ChangeNicknameViewController(), animated: true)
            default:
                break
            }
            
        }else  {
            
            let tag = indexPath.row
            switch tag {
            case 0:
                changeGender()
            case 1:
                self.navigationController?.pushViewController(ChangeAutographViewController(), animated: true)
            default:
                break
            }
            
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        print("choose--------->>")
        SVProgressHUD.show()
        picker.view.userInteractionEnabled = false
        
        
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
       
        let imageData = UIImageJPEGRepresentation(img, 0.5)
        // 获取沙盒目录
        format.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let dateString = format.stringFromDate(date)
     
       
            let id = user.objectId
            currentImageName = id+"_avatar_"+dateString+".jpg"
            let fullPath = ((NSHomeDirectory() as NSString).stringByAppendingPathComponent("Documents") as NSString).stringByAppendingPathComponent(currentImageName)
            imageData?.writeToFile(fullPath, atomically: true)

            // 将图片写入文件
            let data = NSData(contentsOfFile: fullPath)

        BmobProFile.uploadFileWithFilename(currentImageName, fileData: data,block:  { (success, error, filename, url, file) -> Void in
            if error != nil {
                SVProgressHUD.showErrorWithStatus("\(error)")
                
                print("error:\(error)")
                picker.dismissViewControllerAnimated(true, completion: nil)
            }
            else{
                self.user.setObject(filename, forKey: "avatar")
                self.user.updateInBackgroundWithResultBlock({ (success, error) in
                    if error != nil {
                        SVProgressHUD.showErrorWithStatus("\(error)")
                        print("updateUserAvatarError:\(error)")
                        picker.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else {
                        
                        self.avatar = filename
                        self.tableView.reloadData()
                        NSNotificationCenter.defaultCenter().postNotificationName("changeAvatar", object: nil, userInfo: ["avatar":filename])
                         picker.dismissViewControllerAnimated(true, completion: nil)
                        
                    }
                })
            }
            }) { (progress) in
                print("updateUserAvatar:\(progress)")
                if progress >= 1.00 {
                   SVProgressHUD.showSuccessWithStatus("succeful")
                }
        }

       
            
            
        }
        
        
        
    }

extension SettingPageTableViewController{
    func changeAvatar(){
                let alertController = UIAlertController(title: "修改头像", message: "",
                                                        preferredStyle: .ActionSheet)
                let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "相机", style: .Destructive){ (action) in
            let page = UIImagePickerController()
            
            page.delegate = self
            
            page.sourceType = .Camera
            
            if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary){
                page.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                page.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(page.sourceType)!
            }
            
            
            self.presentViewController(page, animated: true, completion: nil)
            
        }

                let archiveAction = UIAlertAction(title: "照片", style: .Default) { (action) in
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
    }
    func changeGender(){
        let alertController = UIAlertController(title: "修改性别", message: "",
                                                preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "女", style: .Destructive) { (action) in
            self.user.setObject("女", forKey: "gender")
            self.user.updateInBackgroundWithResultBlock({ (success, error) in
                if error != nil {
                    print("updateUserAvatarError:\(error)")
                }
                else {
                    self.user = BmobUser.getCurrentUser()
                    self.tableView.reloadData()
                  
                }
            })

        }
        let archiveAction = UIAlertAction(title: "男", style: .Default){ (action) in
            self.user.setObject("男", forKey: "gender")
            self.user.updateInBackgroundWithResultBlock({ (success, error) in
                if error != nil {
                    print("updateUserAvatarError:\(error)")
                }
                else {
                    self.user = BmobUser.getCurrentUser()
                    self.tableView.reloadData()
                    
                }
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.addAction(archiveAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}