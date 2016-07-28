//
//  SettingsViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 28/07/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var autoMarkCompleteSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        autoMarkCompleteSwitch.on = Settings.sharedInstance.autoMarkLessonsComplete
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggledAutoMarkAsComplete(sender: UISwitch) {
        Settings.sharedInstance.autoMarkLessonsComplete = sender.on
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func close(sender: AnyObject?) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
}
