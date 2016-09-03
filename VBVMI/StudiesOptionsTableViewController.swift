//
//  StudiesOptionsTableViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 3/09/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit


enum StudySortOption: Int, StaticSelectable {
    
    case ReleaseDate
    case BibleBookIndex
    
    var cellTitle: String {
        switch self {
        case .BibleBookIndex:
            return "Bible book order"
        case .ReleaseDate:
            return "Release date"
        }
    }
    
    static var allOptions: [StudySortOption] = [StudySortOption.BibleBookIndex, StudySortOption.ReleaseDate]
    
    static var currentSortOption: StudySortOption {
        get {
            let value = NSUserDefaults.standardUserDefaults().integerForKey("StudySortOption")
            return StudySortOption(rawValue: value) ?? .ReleaseDate
        }
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue.rawValue, forKey: "StudySortOption")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}

class StudiesOptionsTableViewController: UITableViewController {

    @IBOutlet weak var sortCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        sortCell?.detailTextLabel?.text = StudySortOption.currentSortOption.cellTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

//    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell == sortCell {
                openSortOptions()
            }
        }
        
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func openSortOptions() {
        
        
        
        let controller = StaticSelectionViewController(options: StudySortOption.allOptions, selected: StudySortOption.currentSortOption) { [weak self] (sender, selected) in
            guard let this = self else {
                return
            }
            if let sort = selected.first {
                StudySortOption.currentSortOption = sort
                this.sortCell.detailTextLabel?.text = sort.cellTitle
            }
            
            this.navigationController?.popToViewController(this, animated: true)
            
        }
        controller.title = "Sort"
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
}
