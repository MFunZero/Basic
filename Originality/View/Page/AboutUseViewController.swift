//
//  AboutUseViewController.swift
//  Originality
//
//  Created by fanzz on 16/4/9.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class AboutUseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let aboutView:UIImageView = UIImageView()
        aboutView.frame = self.view.frame
        self.view.addSubview(aboutView)
        
        aboutView.image = UIImage(named: "loginBG")
        
        let versionLabel = UILabel()
        versionLabel.frame = CGRect(x: 20, y: 254, width: screenWidth-40, height: 25)
        aboutView.addSubview(versionLabel)
        
        versionLabel.textAlignment = .Center
        versionLabel.text = "Originality 1.0.0 版本"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

}
