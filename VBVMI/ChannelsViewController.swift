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
    fileprivate var fetchedResultsController: NSFetchedResultsController<Channel>!
    fileprivate var aboutActionsController: AboutActionsController!
    
    fileprivate let dateFormatter = DateFormatter()
    fileprivate let channelCellIdentifier = "ChannelCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ChannelTableViewCell", bundle: nil), forCellReuseIdentifier: channelCellIdentifier)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        dateFormatter.dateStyle = .short
        
        // Setup about Menu
        self.aboutActionsController = AboutActionsController(presentingController: self)
        self.navigationItem.leftBarButtonItem = self.aboutActionsController.barButtonItem
        
        
        
        setupFetchedResultsController()
    }

    fileprivate func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<Channel>(entityName: Channel.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Channel.entity(managedObjectContext: context)
        let indexSort = NSSortDescriptor(key: ChannelAttributes.channelIndex.rawValue, ascending: false)
        
        fetchRequest.sortDescriptors = [indexSort]
        
        fetchRequest.shouldRefreshRefetchedObjects = true
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            DispatchQueue.main.async { () -> Void in
                self.tableView.reloadData()
            }
        } catch let error {
            logger.error("Error fetching: \(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    override func viewDidLayoutSubviews() {
        if #available(iOS 11.0, *) {
            
        } else {
            // Fallback on earlier versions
            let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChannelViewController, let channel = sender as? Channel {
            destination.channel = channel
        }
    }
}

// MARK: - UITableViewDataSource
extension ChannelsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: channelCellIdentifier, for: indexPath) as! ChannelTableViewCell
        let channel = fetchedResultsController.object(at: indexPath)
        
        cell.titleLabel.text = channel.title
        let plural = channel.videos.count == 1 ? "" : "s"
        cell.countLabel.text = "\(channel.videos.count) video\(plural)"
        if let date = channel.postedDate {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = nil
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChannelsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let channel = fetchedResultsController.object(at: indexPath)
        self.performSegue(withIdentifier: "showChannel", sender: channel)
        
    }
}


// MARK: - NSFetchedResultsControllerDelegate
extension ChannelsViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            let myNewIndexPath = IndexPath(row: newIndexPath.row, section: newIndexPath.section)
            tableView.insertRows(at: [myNewIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            let myIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
            tableView.deleteRows(at: [myIndexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            let myNewIndexPath = IndexPath(row: newIndexPath.row, section: newIndexPath.section)
            let myIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
            if myIndexPath == myNewIndexPath {
                if let cell = tableView.cellForRow(at: myIndexPath) , cell.isEditing == false {
                    tableView.deleteRows(at: [myIndexPath], with: .none)
                    tableView.insertRows(at: [myNewIndexPath], with: .none)
                }
            } else {
                //Don't perform a move here because for some reason it doesn't work
                tableView.deleteRows(at: [myIndexPath], with: .automatic)
                tableView.insertRows(at: [myNewIndexPath], with: .automatic)
            }
        case .update:
            guard let indexPath = indexPath else { return }
            let myIndexPath = IndexPath(row: indexPath.row, section: indexPath.section)
            tableView.reloadRows(at: [myIndexPath], with: .none)
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}
