//
//  ChannelsViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 10/07/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

class ChannelsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    fileprivate var channelFetchedResultsController: NSFetchedResultsController<Channel>!
    fileprivate var aboutActionsController: AboutActionsController!
    
    fileprivate let dateFormatter = DateFormatter()
    private let channelCellIdentifier = "ChannelCell"
    private let curriculumCellIdentifier = "CurriculumCell"
    
    enum Section {
        case channel
        case curriculum
    }
    
    let sections: [Section] = [.curriculum, .channel]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ChannelTableViewCell", bundle: nil), forCellReuseIdentifier: channelCellIdentifier)
        tableView.register(UINib(nibName: "CurriculumTableViewCell", bundle: nil), forCellReuseIdentifier: curriculumCellIdentifier)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        dateFormatter.dateStyle = .short
        
        // Setup about Menu
        self.aboutActionsController = AboutActionsController(presentingController: self)
        self.navigationItem.leftBarButtonItem = self.aboutActionsController.barButtonItem

        setupFetchedResultsController()
        let _ = curriculumFetchedResultsController
    }

    fileprivate func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<Channel>(entityName: Channel.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Channel.entity(managedObjectContext: context)
        let indexSort = NSSortDescriptor(key: ChannelAttributes.channelIndex.rawValue, ascending: false)
        
        fetchRequest.sortDescriptors = [indexSort]
        
        fetchRequest.shouldRefreshRefetchedObjects = true
        channelFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        channelFetchedResultsController.delegate = self
        
        do {
            try channelFetchedResultsController.performFetch()
            DispatchQueue.main.async { () -> Void in
                self.tableView.reloadData()
            }
        } catch let error {
            logger.error("Error fetching: \(error)")
        }
    }
    
    private lazy var curriculumFetchedResultsController: NSFetchedResultsController<Curriculum> = {
        let fetchRequest = NSFetchRequest<Curriculum>(entityName: Curriculum.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Curriculum.entity(managedObjectContext: context)
        let postedDateSort = NSSortDescriptor(keyPath: \Curriculum.postedDate, ascending: true)
        fetchRequest.sortDescriptors = [postedDateSort]
        fetchRequest.shouldRefreshRefetchedObjects = true
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            DispatchQueue.main.async { () -> Void in
                self.tableView.reloadData()
            }
        } catch let error {
            logger.error("Error fetching: \(error)")
        }
        
        return fetchedResultsController
    }()
    
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
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .channel:
            return channelFetchedResultsController.fetchedObjects?.count ?? 0
        case .curriculum:
            return curriculumFetchedResultsController.fetchedObjects?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .channel:
            let cell = tableView.dequeueReusableCell(withIdentifier: channelCellIdentifier, for: indexPath) as! ChannelTableViewCell
            let channel = channelFetchedResultsController.object(at: IndexPath(row: indexPath.row, section: 0))
            
            cell.titleLabel.text = channel.title
            let plural = channel.videos.count == 1 ? "" : "s"
            cell.countLabel.text = "\(channel.videos.count) video\(plural)"
            if let date = channel.postedDate {
                cell.dateLabel.text = dateFormatter.string(from: date)
            } else {
                cell.dateLabel.text = nil
            }
            
            return cell
        case .curriculum:
            let cell = tableView.dequeueReusableCell(withIdentifier: curriculumCellIdentifier, for: indexPath) as! CurriculumTableViewCell
            let curriculum = curriculumFetchedResultsController.object(at: IndexPath(row: indexPath.row, section: 0))
            
            cell.titleLabel.text = curriculum.title
            let plural = curriculum.videos.count == 1 ? "" : "s"
            cell.countLabel.text = "\(curriculum.videos.count) video\(plural)"
            cell.dateLabel.text = dateFormatter.string(from: curriculum.postedDate)
            
            if let imageString = curriculum.coverImage, let url = URL(string: imageString) {
                
                let scaleFilter = AspectScaledToFillSizeCircleFilter(size: CGSize(width: 40, height: 40))
                
                cell.thumbnailImageView?.af_setImage(withURL: url, placeholderImage: nil, filter: scaleFilter, progress: nil, progressQueue: .main, imageTransition: UIImageView.ImageTransition.crossDissolve(0.25), runImageTransitionIfCached: false, completion: { (dataResponse) in
                })
            }
            return cell
        }
        
    }
}

// MARK: - UITableViewDelegate
extension ChannelsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section] {
        case .channel:
            let channel = channelFetchedResultsController.object(at: IndexPath(row: indexPath.row, section: 0))
            self.performSegue(withIdentifier: "showChannel", sender: channel)
        case .curriculum:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch sections[section] {
        case .channel:
            return "Video Series"
        case .curriculum:
            return "Small Group Curriculum"
        }
    }
}


// MARK: - NSFetchedResultsControllerDelegate
extension ChannelsViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
