//
//  AvatarTableViewCell.swift
//  Originality
//
//  Created by fanzz on 16/3/31.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class AvatarTableViewCell: UITableViewCell {

    var avatarView:UIImageView = UIImageView()
    var nameLabel:UILabel = UILabel()
    
    
    var avatar:String?{
//        willSet {
//            self.avatarView.image = UIImage(named: defaultHeaderImage)
//        }
        didSet {
            BmobProFile.getFileAcessUrlWithFileName(avatar) { (file, error) -> Void in
                if error != nil {
                    print("error:\(error)")
                }else{
                    let  url = NSURL(string: file.url)
                    let data = NSData(contentsOfURL: url!)
                    if data != nil {
                        
                        self.avatarView.image = UIImage(data: data!)
                        
                    }
                }
            }
        }
    }
    
    override func drawRect(rect: CGRect) {
        avatarView.frame = CGRect(x: screenWidth - 120, y: self.frame.height / 2 - 30, width: 70, height: 70)
        
        self.addSubview(avatarView)   
        
        
        self.avatarView.clipsToBounds = true
        self.avatarView.layer.cornerRadius = self.avatarView.frame.width / 2
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    

}
