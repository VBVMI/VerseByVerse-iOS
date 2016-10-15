//
//  StudiesOptionsTableViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 3/09/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit


enum StudySortOption: Int, StaticSelectable {
    
    case releaseDate
    case bibleBookIndex
    
    var cellTitle: String {
        switch self {
        case .bibleBookIndex:
            return "Bible book order"
        case .releaseDate:
            return "Release date"
        }
    }
    
    static var allOptions: [StudySortOption] = [StudySortOption.bibleBookIndex, StudySortOption.releaseDate]
    
    static var currentSortOption: StudySortOption {
        get {
            let value = UserDefaults.standard.integer(forKey: "StudySortOption")
            return StudySortOption(rawValue: value) ?? .releaseDate
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "StudySortOption")
            UserDefaults.standard.synchronize()
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell == sortCell {
                openSortOptions()
            }
        }
        
    }
    
    @IBAction func close(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
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
