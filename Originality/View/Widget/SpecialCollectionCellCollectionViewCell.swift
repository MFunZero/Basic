//
//  SpecialCollectionCellCollectionViewCell.swift
//  Originality
//
//  Created by fanzz on 16/3/31.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class SpecialCollectionCellCollectionViewCell: UICollectionViewCell {
    //设置数据项，不在界面中显示，但是在跳转到下一级界面中作为数据源
    var singlePictureId:String!
    var userId:String!
    var tagId:Int!
    
    
    var topContentView:UIView = UIView()
    
    var imageView:UIImageView = UIImageView()
    var textlabel:UIView = UIView()
    var titleLabel:UILabel = UILabel()
    var detailLabel:UILabel = UILabel()

    var detail:[String]!{
        willSet{
            self.detailLabel.text = "张图片"+" · "+"0人喜欢"
        }
        didSet{
            self.detailLabel.text = detail[0]+"张图片"+" · "+detail[1]+"人喜欢"
        }
    }

    
    
    
    //-------分割线
   
    
    //图片所属用户信息展示视图
    
    

  
    
    
    
    
    var filename:String? {
        
        willSet{
            
        }
        didSet{
            let home = NSHomeDirectory() as NSString
            let path = home.stringByAppendingPathComponent("Library/Caches/DownloadFile") as NSString
            let imagePath = path.stringByAppendingPathComponent(filename!)
            let isExits:Bool = NSFileManager.defaultManager().fileExistsAtPath(imagePath)
            let image = UIImage(contentsOfFile: imagePath)
            if isExits && image != nil{
                print("111111")
                self.imageView.image = image
            }
            else {
                print("222222")
                
                var url:NSURL!
                BmobProFile.getFileAcessUrlWithFileName(filename) { (file, error) -> Void in
                    if error != nil {
                        print("error:\(error)")
                    }else{
                        url = NSURL(string: file.url)
                        
                        let request = NSURLRequest(URL: url)
                        let session = NSURLSession.sharedSession()
                        
                        let dataTask = session.dataTaskWithRequest(request,
                                                                   completionHandler: {(data, response, error) -> Void in
                                                                    //将获取到的数据转化成图像
                                                                    if data != nil {
                                                                        let image = UIImage(data: data!)
                                                                        //对UI的更新必须在主队列上完成
                                                                        NSOperationQueue.mainQueue().addOperationWithBlock({
                                                                            () -> Void in
                                                                            //将已加载的图像赋予图像视图
                                                                            self.imageView.image = image
                                                                            //图像视图可能已经因为新图像而改变了尺寸
                                                                            //所以需要重新调整单元格的布局
                                                                            self.setNeedsLayout()
                                                                        })
                                                                    }
                                                                    else{
                                                                        self.imageView.image = UIImage(named:"bg6")
                                                                    }
                                                                    
                        }) as NSURLSessionTask
                        
                        //使用resume方法启动任务
                        dataTask.resume()
                    }
                    
                    
                }
            }
        }
    }
    
    
    override func drawRect(rect: CGRect) {
        
        topContentView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height * 4 / 5 )
        
        imageView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: topContentView.frame.height)
        
        
        
        
        textlabel.frame = CGRect(x: 10, y: topContentView.frame.height , width: self.frame.width - 20, height: topContentView.frame.height * 1 / 5 )
     
        
        titleLabel.frame = CGRect(x: 0, y: 0, width: textlabel.frame.width , height: textlabel.frame.height * 2 / 3)
        //titleLabel.backgroundColor = UIColor.redColor()
        titleLabel.textAlignment = NSTextAlignment.Left
        titleLabel.font = nomalFont
        titleLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.textColor = titleCorlor
        
        
        
        detailLabel.frame = CGRect(x: 0, y: textlabel.frame.height * 2 / 3 + 2, width: textlabel.frame.width , height: textlabel.frame.height * 1 / 3 )
        detailLabel.textAlignment = NSTextAlignment.Left
        detailLabel.font = smallFont
      

        self.layer.borderWidth = 1.0
        self.layer.borderColor = contentColor.CGColor
        
        

        
     
        
        

        
        
        self.contentView.backgroundColor = contentColor
        
        self.contentView.addSubview(topContentView)
        self.topContentView.addSubview(imageView)
        self.contentView.addSubview(textlabel)
        
        
        self.textlabel.addSubview(titleLabel)
        self.textlabel.addSubview(detailLabel)
        
        
        
        
    }
}
