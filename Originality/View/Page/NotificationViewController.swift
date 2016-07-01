//
//  NotificationViewController.swift
//  Originality
//
//  Created by fanzz on 16/6/3.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var cancel: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalTransitionStyle = .FlipHorizontal

        
        // Do any additional setup after loading the view.
    }
    @IBAction func cancelButtonClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
