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
import VimeoNetworking

class ChannelViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var fetchedResultsController: NSFetchedResultsController<Video>!
    private let activity = NSUserActivity(activityType: "org.versebyverseministry.www")
    fileprivate let formatter = DateComponentsFormatter()
    fileprivate let videoCellIdentifier = "ChannelCell"
    var channel: Channel! {
        didSet {
            if let channel = channel {
                navigationItem.title = channel.title
                if let urlString = channel.url, let url = URL(string: urlString) {
                    activity.title = channel.title
                    activity.webpageURL = url
                    activity.becomeCurrent()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: videoCellIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        formatter.unitsStyle = .positional
        setupFetchedResultsController()
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction(_:)))
        self.navigationItem.rightBarButtonItem = shareButton
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        activity.invalidate()
    }
    
    @objc func shareAction(_ button: Any) {
        guard let urlString = channel?.url, let url = URL(string: urlString) else { return }
        
        let actionSheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(actionSheet, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<Video>(entityName: Video.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Video.entity(managedObjectContext: context)
        let indexSort = NSSortDescriptor(key: VideoAttributes.videoIndex.rawValue, ascending: true)
        
        fetchRequest.sortDescriptors = [indexSort]
        fetchRequest.predicate = NSPredicate(format: "channel.identifier == %@", channel.identifier)
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
    
    override func viewDidLayoutSubviews() {
        if #available(iOS 11.0, *) {
            
        } else {
            // Fallback on earlier versions
            let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
        }
        
    }

}

// MARK: - UITableViewDelegate
extension ChannelViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let video = fetchedResultsController.object(at: indexPath)
        
        if let videoURLString = video.videoSource, let url = URL(string: videoURLString) {
            
            if let service = video.service, service == "vimeo", let serviceID = video.serviceVideoIdentifier {
                let movieController = AVPlayerViewController()
                let dispatchGroup = DispatchGroup()
                dispatchGroup.enter()
                self.present(movieController, animated: true, completion: {
                    dispatchGroup.leave()
                })
                dispatchGroup.enter()
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                VimeoManager.shared.getVimeoURL(vimeoVideoID: serviceID, callback: { (result) in
                    switch result {
                    case .failure(let error):
                        logger.error("Error loading video files: \(error)")
                    case .success(let vimeoURL):
                        let player = AVPlayer(url: vimeoURL)
                        movieController.player = player
                        
                    }
                    dispatchGroup.leave()
                })
                dispatchGroup.notify(queue: DispatchQueue.main, execute: { [weak movieController] in
                    do {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                    }
                    catch {
                        // report for an error
                    }
                    
                    movieController?.player?.play()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
}

// MARK: - UITableViewDataSource
extension ChannelViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: videoCellIdentifier, for: indexPath) as! VideoTableViewCell
        let video = fetchedResultsController.object(at: indexPath)
        
        cell.titleLabel.text = video.title
        if let timeString = video.videoLength, let dateComponents = TimeParser.getTime(timeString) {
            cell.timeLabel.text = formatter.string(from: dateComponents)
        } else {
            cell.timeLabel.text = nil
        }
        
        if let urlString = video.thumbnailSource, let url = URL(string: urlString) {
            cell.thumbnailImageView.af_setImage(withURL: url, placeholderImage: nil, imageTransition: UIImageView.ImageTransition.crossDissolve(0.3))
        } else {
            cell.thumbnailImageView?.image = nil
        }
        
        cell.descriptionLabel.text = video.descriptionText
        
        return cell
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate
extension ChannelViewController: NSFetchedResultsControllerDelegate {
    
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
            let myNewIndexPath = IndexPath(row: (newIndexPath as NSIndexPath).row, section: (newIndexPath as NSIndexPath).section)
            tableView.insertRows(at: [myNewIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            let myIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section)
            tableView.deleteRows(at: [myIndexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            let myNewIndexPath = IndexPath(row: (newIndexPath as NSIndexPath).row, section: (newIndexPath as NSIndexPath).section)
            let myIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section)
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
            let myIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section)
            tableView.reloadRows(at: [myIndexPath], with: .none)
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
}
