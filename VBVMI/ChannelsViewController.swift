//
//  ChannelsViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 10/07/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import CoreData

class ChannelsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var fetchedResultsController: NSFetchedResultsController!
    private var aboutActionsController: AboutActionsController!
    
    private let dateFormatter = NSDateFormatter()
    private let channelCellIdentifier = "ChannelCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "ChannelTableViewCell", bundle: nil), forCellReuseIdentifier: channelCellIdentifier)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        dateFormatter.dateStyle = .ShortStyle
        
        // Setup about Menu
        self.aboutActionsController = AboutActionsController(presentingController: self)
        self.navigationItem.leftBarButtonItem = self.aboutActionsController.barButtonItem
        
        
        
        setupFetchedResultsController()
    }

    private func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest(entityName: Channel.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext
        fetchRequest.entity = Channel.entity(context)
        let indexSort = NSSortDescriptor(key: ChannelAttributes.channelIndex.rawValue, ascending: false)
        
        fetchRequest.sortDescriptors = [indexSort]
        
        fetchRequest.shouldRefreshRefetchedObjects = true
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.tableView.reloadData()
            }
        } catch let error {
            log.error("Error fetching: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        if self.parentViewController == nil {
            let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destination = segue.destinationViewController as? ChannelViewController, channel = sender as? Channel {
            destination.channel = channel
        }
    }
}

// MARK: - UITableViewDataSource
extension ChannelsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(channelCellIdentifier, forIndexPath: indexPath) as! ChannelTableViewCell
        let channel = fetchedResultsController.objectAtIndexPath(indexPath) as! Channel
        
        cell.titleLabel.text = channel.title
        let plural = channel.videos.count == 1 ? "" : "s"
        cell.countLabel.text = "\(channel.videos.count) video\(plural)"
        if let date = channel.postedDate {
            cell.dateLabel.text = dateFormatter.stringFromDate(date)
        } else {
            cell.dateLabel.text = nil
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChannelsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let channel = fetchedResultsController.objectAtIndexPath(indexPath) as! Channel
        self.performSegueWithIdentifier("showChannel", sender: channel)
        
    }
}


// MARK: - NSFetchedResultsControllerDelegate
extension ChannelsViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            guard let newIndexPath = newIndexPath else { return }
            let myNewIndexPath = NSIndexPath(forRow: newIndexPath.row, inSection: newIndexPath.section)
            tableView.insertRowsAtIndexPaths([myNewIndexPath], withRowAnimation: .Automatic)
        case .Delete:
            guard let indexPath = indexPath else { return }
            let myIndexPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section)
            tableView.deleteRowsAtIndexPaths([myIndexPath], withRowAnimation: .Automatic)
        case .Move:
            guard let indexPath = indexPath, newIndexPath = newIndexPath else { return }
            let myNewIndexPath = NSIndexPath(forRow: newIndexPath.row, inSection: newIndexPath.section)
            let myIndexPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section)
            if myIndexPath == myNewIndexPath {
                if let cell = tableView.cellForRowAtIndexPath(myIndexPath) where cell.editing == false {
                    tableView.deleteRowsAtIndexPaths([myIndexPath], withRowAnimation: .None)
                    tableView.insertRowsAtIndexPaths([myNewIndexPath], withRowAnimation: .None)
                }
            } else {
                //Don't perform a move here because for some reason it doesn't work
                tableView.deleteRowsAtIndexPaths([myIndexPath], withRowAnimation: .Automatic)
                tableView.insertRowsAtIndexPaths([myNewIndexPath], withRowAnimation: .Automatic)
            }
        case .Update:
            guard let indexPath = indexPath else { return }
            let myIndexPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section)
            tableView.reloadRowsAtIndexPaths([myIndexPath], withRowAnimation: .None)
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
}