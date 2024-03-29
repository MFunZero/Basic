//
//  ThirdTableViewController.swift
//  Originality
//
//  Created by suze on 16/2/6.
//  Copyright © 2016年 suze. All rights reserved.
//

import UIKit

private let reuseIdentifier = "TableCell"
private let reuseHeaderIdentifier = "TableHeader"

private let reuseFooterIdentifier = "TableFooter"


class ThirdTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
        self.title = "消息"
        self.tableView.contentInset = UIEdgeInsets(top: 84, left: 0, bottom: 0, right: 0)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        self.tableView.registerClass(CustomTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Tablel view header and footer
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 20
        }
        else {
            return 0.01
        }
    }
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        }
        else {
            return 3
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:CustomTableViewCell!
        if cell == nil{
            cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as? CustomTableViewCell
            //
            if indexPath.section == 0 {
                cell.picture.image = UIImage(named: "xitonggonggao")
                cell.titleLabel.text = "官方通知"
                cell.detailLabel.text = "新年你的专属转运神器"
                
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                
            }
            else  {
                
                
                if indexPath.row == 0
                {
                    cell.picture.image = UIImage(named: "messagescenter_comments@2x")
                    cell.titleLabel.text = "评论"
                    cell.detailLabel.text = "有新的评论将在这里通知哦"
                }
                if indexPath.row == 1 {
                    format.dateFormat = "yy/MM/dd"
                    let dateString = format.stringFromDate(date)
                    
                    cell.titleLabel.text = "赞"
                    cell.detailLabel.text = "有新的赞将在这里通知哦"
                    cell.timeLabel.text = dateString
                    cell.picture.image = UIImage(named: "icon_review_redname")
                }
                if indexPath.row == 2 {
                    format.dateFormat = "yy/MM/dd"
                    let dateString = format.stringFromDate(date)
                    
                    cell.titleLabel.text = "赞"
                    cell.detailLabel.text = "有新的赞将在这里通知哦"
                    cell.timeLabel.text = dateString
                    cell.picture.image = UIImage(named: "messagescenter_good")
                }
                
            }
            print("imageView's frame:\(cell.picture.frame)")
        }
        
        // Configure the cell...
        
        return cell
    }
    
    //MARK
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
