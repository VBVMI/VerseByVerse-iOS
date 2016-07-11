//
//  ChannelViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 11/07/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import AVFoundation

class ChannelViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var fetchedResultsController: NSFetchedResultsController!
    
    private let formatter = NSDateComponentsFormatter()
    private let videoCellIdentifier = "ChannelCell"
    var channel: Channel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: videoCellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        formatter.unitsStyle = .Positional
        setupFetchedResultsController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest(entityName: Video.entityName())
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        fetchRequest.entity = Video.entity(context)
        let indexSort = NSSortDescriptor(key: VideoAttributes.videoIndex.rawValue, ascending: true)
        
        fetchRequest.sortDescriptors = [indexSort]
        fetchRequest.predicate = NSPredicate(format: "channel.identifier == %@", channel.identifier!)
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
    
    override func viewDidLayoutSubviews() {
        let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }

}

// MARK: - UITableViewDelegate
extension ChannelViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let video = fetchedResultsController.objectAtIndexPath(indexPath) as! Video
        
        if let videoURLString = video.videoSource, url = NSURL(string: videoURLString) {
            if UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
}

// MARK: - UITableViewDataSource
extension ChannelViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(videoCellIdentifier, forIndexPath: indexPath) as! VideoTableViewCell
        let video = fetchedResultsController.objectAtIndexPath(indexPath) as! Video
        
        cell.titleLabel.text = video.title
        if let timeString = video.videoLength, dateComponents = TimeParser.getTime(timeString) {
            cell.timeLabel.text = formatter.stringFromDateComponents(dateComponents)
        } else {
            cell.timeLabel.text = nil
        }
        
        if let urlString = video.thumbnailSource, url = NSURL(string: urlString) {
            cell.thumbnailImageView?.af_setImageWithURL(url, placeholderImage: nil, imageTransition: UIImageView.ImageTransition.CrossDissolve(0.3))
        } else {
            cell.thumbnailImageView?.image = nil
        }
        
        cell.descriptionLabel.text = video.descriptionText
        
        return cell
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension ChannelViewController: NSFetchedResultsControllerDelegate {
    
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