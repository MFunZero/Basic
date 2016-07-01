//
//  extension.swift
//  Originality
//
//  Created by suze on 16/1/24.
//  Copyright © 2016年 suze. All rights reserved.
//

import Foundation

extension NSString {
    func textSizeWithFont(font: UIFont, constrainedToSize size:CGSize) -> CGSize {
        var textSize:CGSize!
        if CGSizeEqualToSize(size, CGSizeZero) {
            let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
            textSize = self.sizeWithAttributes(attributes as? [String : AnyObject])
        } else {
            let option = NSStringDrawingOptions.UsesLineFragmentOrigin
            let attributes = NSDictionary(object: font, forKey: NSFontAttributeName)
            let stringRect = self.boundingRectWithSize(size, options: option, attributes: attributes as? [String : AnyObject], context: nil)
            textSize = stringRect.size
        }
        return textSize
    }
}

enum ImageViewStatus {
    case  fullScreen             // 全屏状态
    case  normal             // 正常状态
    case  icon               //缩小图标状态
    
    func next()->ImageViewStatus{
        if self == fullScreen {
            return ImageViewStatus.normal
        }
        else if self == icon {
            return ImageViewStatus.normal
        }else {
            return ImageViewStatus.normal
        }
    }
}
extension UIImage {
    ///对指定图片进行拉伸
    func resizableImage(normal: UIImage,status:ImageViewStatus) -> UIImage {
        var returnImage:UIImage!
        switch status {
        case .fullScreen:
            let imageWidth = screenWidth
            let imageHeight = screenHeight
            returnImage = resizableImageWithCapInsets(UIEdgeInsetsMake(imageHeight, imageWidth, imageHeight, imageWidth))
        case .normal:
            let imageWidth = normal.size.width * 0.5
            let imageHeight = normal.size.height * 0.5
            returnImage = resizableImageWithCapInsets(UIEdgeInsetsMake(imageHeight, imageWidth, imageHeight, imageWidth))
        case .icon:
            let imageWidth:CGFloat = 50
            let imageHeight:CGFloat = 50
            returnImage = resizableImageWithCapInsets(UIEdgeInsetsMake(imageHeight, imageWidth, imageHeight, imageWidth))
 
        }
        
        
        
        return returnImage
    }
    ///对指定图片进行拉伸
    func resizableImage(name: String) -> UIImage {
        
        var normal = UIImage(named: name)!
        let imageWidth = normal.size.width * 0.5
        let imageHeight = normal.size.height * 0.5
        normal = resizableImageWithCapInsets(UIEdgeInsetsMake(imageHeight, imageWidth, imageHeight, imageWidth))
        
        return normal
    }
    
    /**
     *  压缩上传图片到指定字节
     *
     *  image     压缩的图片
     *  maxLength 压缩后最大字节大小
     *
     *  return 压缩后图片的二进制
     */
    func compressImage(image: UIImage, maxLength: Int) -> NSData? {
        
        let newSize = self.scaleImage(image, imageLength: 300)
        let newImage = self.resizeImage(image, newSize: newSize)
        
        var compress:CGFloat = 0.9
        var data = UIImageJPEGRepresentation(newImage, compress)
        
        while data?.length > maxLength && compress > 0.01 {
            compress -= 0.02
            data = UIImageJPEGRepresentation(newImage, compress)
        }
        
        return data
    }
    
    /**
     *  通过指定图片最长边，获得等比例的图片size
     *
     *  image       原始图片
     *  imageLength 图片允许的最长宽度（高度）
     *
     *  return 获得等比例的size
     */
    func  scaleImage(image: UIImage, imageLength: CGFloat) -> CGSize {
        
        var newWidth:CGFloat = 0.0
        var newHeight:CGFloat = 0.0
        let width = image.size.width
        let height = image.size.height
        
        if (width > imageLength || height > imageLength){
            
            if (width > height) {
                
                newWidth = imageLength;
                newHeight = newWidth * height / width;
                
            }else if(height > width){
                
                newHeight = imageLength;
                newWidth = newHeight * width / height;
                
            }else{
                
                newWidth = imageLength;
                newHeight = imageLength;
            }
            
        }
        if (width < imageLength || height < imageLength){
            
            if (width > height) {
                
                newWidth = imageLength;
                newHeight = newWidth * height / width;
                
            }else if(height > width){
                
                newHeight = imageLength;
                newWidth = newHeight * width / height;
                
            }else{
                
                newWidth = imageLength;
                newHeight = imageLength;
            }
            
        }
        
        
        return CGSize(width: newWidth, height: newHeight)
    }
    
    /**
     *  获得指定size的图片
     *
     *  image   原始图片
     *  newSize 指定的size
     *
     *  return 调整后的图片
     */
    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        image.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    }
