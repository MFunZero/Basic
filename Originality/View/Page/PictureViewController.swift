//
//  PictureViewController.swift
//  Originality
//
//  Created by fanzz on 16/4/19.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController ,UIActionSheetDelegate{

    var imageView:UIImageView = UIImageView()
    
    var lastScaleFactor : CGFloat! = 1  //放大、缩小
    var netRotation : CGFloat = 1;//旋转
    var netTranslation : CGPoint!//平移
//    var images : NSArray = ["bg11.jpg","bg7.jpg","bg8.jpg","bg5.jpg","bg6.jpg","bg12.jpg"]// 图片数组
//    var imageIndex : Int = 0 //数组下标
   
    override func viewDidLoad() {
        super.viewDidLoad()
        netTranslation = CGPoint(x: 0, y: 0)

        self.view.backgroundColor = UIColor.blackColor()
     
      
        let imageSize = imageView.image!.scaleImage(imageView.image!, imageLength: self.view.frame.width)
        imageView.frame = CGRect(x: 0, y:0, width: imageSize.width, height: imageSize.height)
        imageView.center = self.view.center
        self.view.addSubview(imageView)
        
        var tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        //设置手势点击数,双击：点2下
        tapGesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tapGesture)
        
        var tapGestureCancel = UITapGestureRecognizer(target: self, action: "handleCancelTapGesture:")
        //设置手势点击数,双击：点2下
        tapGestureCancel.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGestureCancel)
        
        //手势为捏的姿势:按住option按钮配合鼠标来做这个动作在虚拟器上
        var pinchGesture = UIPinchGestureRecognizer(target: self, action: "handlePinchGesture:")
        self.view.addGestureRecognizer(pinchGesture)
        
        //旋转手势:按住option按钮配合鼠标来做这个动作在虚拟器上
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: "handleRotateGesture:")
        self.view.addGestureRecognizer(rotateGesture)
        
        //拖手势
        var panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
                self.view.addGestureRecognizer(panGesture)
        
        //划动手势
        //右划
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeGesture:"))
        self.view.addGestureRecognizer(swipeGesture)
        //左划
        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipeGesture:"))
        swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left //不设置是右
        self.view.addGestureRecognizer(swipeLeftGesture)
        
        //长按手势
        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: #selector(PictureViewController.handleLongpressGesture(_:)))
        //长按时间为1秒
        longpressGesutre.minimumPressDuration = 1
        //允许15秒运动
        longpressGesutre.allowableMovement = 15
        //所需触摸1次
        longpressGesutre.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(longpressGesutre)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //双击屏幕时会调用此方法,放大和缩小图片
    func handleTapGesture(sender: UITapGestureRecognizer){
        //判断imageView的内容模式是否是UIViewContentModeScaleAspectFit,该模式是原比例，按照图片原时比例显示大小
        if imageView.contentMode == UIViewContentMode.ScaleAspectFit{
            //把imageView模式改成UIViewContentModeCenter，按照图片原先的大小显示中心的一部分在imageView
            imageView.contentMode = UIViewContentMode.Center
        }else{
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
        }
    }
    
    func handleCancelTapGesture(sender: UITapGestureRecognizer){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //捏的手势，使图片放大和缩小，捏的动作是一个连续的动作
    func handlePinchGesture(sender: UIPinchGestureRecognizer){
        var factor = sender.scale
        if factor > 1{
            //图片放大
            imageView.transform = CGAffineTransformMakeScale(lastScaleFactor+factor-1, lastScaleFactor+factor-1)
        }else{
            //缩小
            imageView.transform = CGAffineTransformMakeScale(lastScaleFactor*factor, lastScaleFactor*factor)
        }
        //状态是否结束，如果结束保存数据
        if sender.state == UIGestureRecognizerState.Ended{
            if factor > 1{
                lastScaleFactor = lastScaleFactor + factor - 1
            }else{
                lastScaleFactor = lastScaleFactor * factor
            }
        }
    }
    
    //旋转手势
    func handleRotateGesture(sender: UIRotationGestureRecognizer){
        //浮点类型，得到sender的旋转度数
        var rotation : CGFloat = sender.rotation
        //旋转角度CGAffineTransformMakeRotation,改变图像角度
        imageView.transform = CGAffineTransformMakeRotation(rotation+netRotation)
        //状态结束，保存数据
        if sender.state == UIGestureRecognizerState.Ended{
            netRotation += rotation
        }
    }
    //拖手势
    func handlePanGesture(sender: UIPanGestureRecognizer){
        //得到拖的过程中的xy坐标
        var translation : CGPoint = sender.translationInView(imageView)
        //平移图片CGAffineTransformMakeTranslation
        imageView.transform = CGAffineTransformMakeTranslation(netTranslation.x+translation.x, netTranslation.y+translation.y)
        if sender.state == UIGestureRecognizerState.Ended{
            netTranslation.x += translation.x
            netTranslation.y += translation.y
        }
    }
//    //划动手势
//    func handleSwipeGesture(sender: UISwipeGestureRecognizer){
//        //划动的方向
//        var direction = sender.direction
//        //判断是上下左右
//        switch (direction){
//        case UISwipeGestureRecognizerDirection.Left:
//            print("Left")
//            imageIndex++;//下标++
//            break
//        case UISwipeGestureRecognizerDirection.Right:
//            print("Right")
//            imageIndex--;//下标--
//            break
//        case UISwipeGestureRecognizerDirection.Up:
//            print("Up")
//            break
//        case UISwipeGestureRecognizerDirection.Down:
//            print("Down")
//            break
//        default:
//            break;
//        }
//        //得到不越界不<0的下标
//        imageIndex = imageIndex < 0 ? images.count-1:imageIndex%images.count
//        //imageView显示图片
//        imageView.image = UIImage(named: images[imageIndex] as! String)
//    }
    
    //长按手势
    func handleLongpressGesture(sender : UILongPressGestureRecognizer){
        
        if sender.state == UIGestureRecognizerState.Began{
            //创建警告
//            var actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "cancel", destructiveButtonTitle: "保存图片", otherButtonTitles: "分享图片到pyq")
//            actionSheet.showInView(self.view)
            
            let alertController = UIAlertController(title: nil, message: nil,
                                                    preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
            
            let archiveAction = UIAlertAction(title: "保存图片", style: .Default) { (action) in
                UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, #selector(PictureViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                
            }
            
            
            alertController.addAction(cancelAction)
            alertController.addAction(archiveAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    func image(image: UIImage, didFinishSavingWithError: NSError?,contextInfo: AnyObject)
    {
        if didFinishSavingWithError != nil
        {
            print("error!")
            SVProgressHUD.showErrorWithStatus("图片保存出错")
            return
        }
        
        else{
          SVProgressHUD.showSuccessWithStatus("图片已保存到您的相册中")
        }
    }
}

