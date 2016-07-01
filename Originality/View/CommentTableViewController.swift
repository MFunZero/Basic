//
//  CommentTableViewController.swift
//  Originality
//
//  Created by suze on 16/2/21.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class CommentTableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate {

    let tableView:UITableView = UITableView()
    
    
    var commentArray:NSMutableArray = NSMutableArray()
    var singlePictureUserId:String!
    var singlePictureInfo:SinglePictureInfo!
    
    var storeCount:Int!
    var bottomView:UIView = UIView()
    //评论textview
    var commentTextView:UITextField = UITextField()
    var replytoLabel:UILabel = UILabel()
    var replytoUser:String?{
        didSet {
            let userQuery = BmobQuery(className: "_User")
            
            userQuery.getObjectInBackgroundWithId(replytoUser) { (obj, error) -> Void in
                let username = obj.objectForKey("username") as? String
                
                self.replytoLabel.text = preReply + " " + username!
                if self.replytoUser != self.singlePictureInfo.userId {
                self.commentTextView.placeholder = "  "+preReply + ":" + username!
                }
            }
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

         print("b:\(self.storeCount),a:\(commentArray.count)")
        
        self.view.backgroundColor = bgColor
        self.title = "评论"
        let leftButton = UIBarButtonItem(image: UIImage(named: "cancel"), style: UIBarButtonItemStyle.Done, target: self, action: #selector(CommentTableViewController.back(_:)))
        
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.leftBarButtonItem?.tintColor = titleCorlor
        
        self.addCommentTextfield()
        
    
       
        tableView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 50)
        self.view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = bgColor
        
        tableView.registerClass(CustomTableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    func addCommentTextfield()
    {
        bottomView.frame = CGRect(x: 0, y: screenHeight-50, width: screenWidth, height: 50)
        bottomView.layer.borderWidth = 1
        bottomView.backgroundColor = contentColor
        bottomView.layer.borderColor = splitViewColor.CGColor
        
        self.view.addSubview(bottomView)
        
        
        commentTextView.frame =  CGRect(x: 10, y: 5, width: screenWidth - 20, height: 40)
        commentTextView.layer.cornerRadius = 10
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = splitViewColor.CGColor
        commentTextView.delegate = self
//        commentTextView.showsHorizontalScrollIndicator = false
         replytoLabel.frame = CGRect(x: 10, y: 5, width: screenWidth / 2, height: 30)
       // commentTextView.addSubview(replytoLabel)
        commentTextView.placeholder = "  评论..."
        replytoLabel.textColor = bgColor
        
        bottomView.addSubview(commentTextView)
        
     
        commentTextView.font = bigFont
        
        commentTextView.returnKeyType = .Send
        commentTextView.enablesReturnKeyAutomatically  = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(CommentTableViewController.handleTouches(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(CommentTableViewController.keyBoardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(CommentTableViewController.keyBoardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        
        
       
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    func textFieldShouldReturn(textField:UITextField) -> Bool
    {
        commentTextView.resignFirstResponder()
        click()
        return true;
    
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    func checkTextFielLength(textField: UITextField, str: NSString) -> Bool {
        let rect = str.boundingRectWithSize(CGSizeMake(CGFloat(MAXFLOAT), CGFloat(MAXFLOAT)), options: .UsesLineFragmentOrigin, attributes: textField.defaultTextAttributes, context: nil)
        if rect.width > textField.frame.width {
            return false
        } else {
            return true
        }
    }
    func click()
    {
        print("getMessage:\(commentTextView.text)")
        if currentUser == nil {
            let vc = LoginViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
        
        
        if commentTextView.text!.isEmpty {
            
            SVProgressHUD.showErrorWithStatus("输入内容为空，请重新输入")
            self.commentTextView.becomeFirstResponder()
        }
        else {
            
            
            let beingCommentUserId = self.replytoUser
           
          
            let commentUserId = currentUser.objectId
            
            let user = BmobObject(outDatatWithClassName: "_User", objectId: commentUserId)
            
            let content = commentTextView.text
            
            let commentArray = self.commentArray
            
            let obj = BmobObject(className: "comment")
            obj.setObject(content, forKey: "content")
            obj.setObject(user, forKey: "userId")
            let sp = BmobObject(outDatatWithClassName: "SinglePicture", objectId: self.singlePictureInfo.objectId)
            obj.setObject(sp, forKey: "sgId")
            
            obj.saveInBackgroundWithResultBlock({ (isSuccessful, error) -> Void in
                
                if isSuccessful {
                    NSLog("comment:\(obj)")
                    let commentId = obj.objectId
                    
                    
                    //[{"userId":"bPVX555A","commentId":"GTrU999C","replyto":"xFWO111A","content":"超赞，心水!"},{"userId":"xFWO111A","commentId":"DFktIIIS","replyto":"VL4u777D","content":"赞一个"}]
                    let dict = NSDictionary(objects: [commentUserId,commentId,beingCommentUserId!,content!], forKeys: ["userId","commentId","replyto","content"])
                    //let array = Array(object: dict)
                    
                    
                    commentArray.addObject(dict)
                    
                    let comentObject = BmobObject(outDatatWithClassName: "SinglePicture", objectId: self.singlePictureInfo?.objectId)
                    comentObject.setObject(commentArray, forKey: "comment")
                    comentObject.updateInBackgroundWithResultBlock({ (isSuccessful, error) -> Void in
                        if isSuccessful {
                            print("评论成功")
                            self.commentTextView.text = ""
                            self.singlePictureInfo?.commentCount = commentArray.count
                            self.commentArray = commentArray
                            self.replytoUser = self.singlePictureInfo.userId
                            self.tableView.beginUpdates()
                        
                            let row = commentArray.count - 1
                            let indexPath = NSIndexPath(forRow:row , inSection: 0)
                            self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                            
                            self.tableView.endUpdates()
                            
                            print("b:\(self.storeCount),a:\(commentArray.count)")
                            
                            
                        }
                        else {
                            print("error:\(error)")
                        }
                    })
                }
                else {
                    print("CommentSaveerror:\(error)")
                }
                
            })
            
            }}
    }
    
    func keyBoardWillShow(note:NSNotification)
    {
        
        
        let userInfo  = note.userInfo as! NSDictionary
        
        
        print("will:\(userInfo)")
        let  keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        var keyBoardBoundsRect = self.view.convertRect(keyBoardBounds, toView:nil)
        
        //var keyBaoardViewFrame = keyBoardView.frame
        let deltaY:CGFloat = 256.0
        self.view.bringSubviewToFront(bottomView)
        let animations:(() -> Void) = {
            
            self.bottomView.transform = CGAffineTransformMakeTranslation(0,-deltaY)
        }
        
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
            
            
        }else{
            
            animations()
        }
        
        
    }
    
    func keyBoardWillHide(note:NSNotification)
    {
        
        let userInfo  = note.userInfo as! NSDictionary
        print("hide:\(commentTextView.text)")
        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        
        let animations:(() -> Void) = {
            
            self.bottomView.transform = CGAffineTransformIdentity
            
        }
        
        if duration > 0 {
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).integerValue << 16))
            
            UIView.animateWithDuration(duration, delay: 0, options:options, animations: animations, completion: nil)
            
            
        }else{
            
            animations()
        }
        
        
        
        
    }
    
    func handleTouches(sender:UITapGestureRecognizer){
        
        if sender.locationInView(self.view).y < self.view.bounds.height - 250{
            commentTextView.resignFirstResponder()
            
            
        }
        
        
    }
    


    // MARK: - Table view data source

     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
      
            return self.commentArray.count
       
    }

    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as? CustomTableViewCell
        
        let dict = self.commentArray[indexPath.row]
        
        
       // cell?.detailLabel.text =

        let userId = dict.objectForKey("userId") as! String
        let query = BmobQuery(className: "_User")
        query.getObjectInBackgroundWithId(userId) { (obj, error) -> Void in
            if error != nil {
                NSLog("%@", error)
                
            }
            else {
                let filename = obj.objectForKey("avatar") as! String
                cell?.fileName = filename
                cell?.titleLabel.text = obj.objectForKey("username") as? String
                
            }
        }
        
        let CommentId = dict.objectForKey("commentId") as? String
        let commentQuery = BmobQuery(className: "comment")
        commentQuery.getObjectInBackgroundWithId(CommentId) { (comment, error) -> Void in
            if error != nil {
                NSLog("%@", error)
                
            }
            else {
                let replyto = dict.objectForKey("replyto") as? String
                let content = dict.objectForKey("content") as? String
                
                if replyto == self.singlePictureUserId {
                    cell?.detailLabel.text = content
                    
                    format.dateFormat = "MM/dd hh:mm"
                    let dateString = format.stringFromDate(comment.createdAt)
                    cell?.timeLabel.text = dateString
                }
                else {
                    let query = BmobQuery(className: "_User")
                    query.getObjectInBackgroundWithId(replyto) { (replyto, error) -> Void in
                        if error != nil {
                            NSLog("%@", error)
                            
                        }
                        else {
                            let replyto = replyto.objectForKey("username") as! String
                            cell?.detailLabel.text = preReply + replyto + " : " + content!
                            
                        }
                    }
                }
                
            }
        }

        
        
        return cell!
    }
    

     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dict = commentArray[indexPath.row] as? NSDictionary
        
        self.replytoUser = dict?.objectForKey("userId") as? String
        
//        self.commentTextView.becomeFirstResponder()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        
    }
     func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
     func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    

}

extension CommentTableViewController{
    
    func back(sender:UIBarButtonItem)
    {
        
        let array = NSMutableArray()
        for i in self.storeCount ..< commentArray.count {
            array.addObject(self.commentArray[i] as! NSDictionary)
        }
        print("arr:\(array)")
        NSNotificationCenter.defaultCenter().postNotificationName("addCommont", object: array)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
