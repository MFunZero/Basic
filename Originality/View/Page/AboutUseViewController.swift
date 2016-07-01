//
//  AboutUseViewController.swift
//  Originality
//
//  Created by fanzz on 16/4/9.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class AboutUseViewController: UIViewController {
    var cancelButton:UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalTransitionStyle = .FlipHorizontal
        
        
        cancelButton = UIButton(frame: CGRect(x: 15, y: 30, width: 30, height: 30))
        self.view.addSubview(cancelButton)
        
        cancelButton.setBackgroundImage(UIImage(named: "cm2_playlist_icn_dlt"), forState: .Normal)
        cancelButton.addTarget(self, action: #selector(AboutUseViewController.userClick(_:)), forControlEvents: .TouchUpInside)
        cancelButton.tintColor = UIColor.whiteColor();
        
        let aboutView:UIImageView = UIImageView()
        aboutView.frame = self.view.frame
        self.view.addSubview(aboutView)
        
        aboutView.image = UIImage(named: "loginBG")
        
        let versionLabel = UILabel()
        versionLabel.frame = CGRect(x: 20, y: 264, width: screenWidth-40, height: 25)
        aboutView.addSubview(versionLabel)
        
        versionLabel.textAlignment = .Center
        versionLabel.text = "Originality 1.0.0 版本"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    func userClick(sender:UIButton)
    {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
