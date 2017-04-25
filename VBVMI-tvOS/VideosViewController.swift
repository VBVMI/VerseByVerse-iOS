//
//  SecondViewController.swift
//  VBVMI-tvOS
//
//  Created by Thomas Carey on 17/10/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import CoreData
import SnapKit
import AlamofireImage

class VideosDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let fetchedResultsController: NSFetchedResultsController<Video>
    private let realSection : Int
    private weak var viewController: UIViewController?
    
    init(fetchedResultsController: NSFetchedResultsController<Video>, section: Int, viewController: UIViewController) {
        self.fetchedResultsController = fetchedResultsController
        self.realSection = section
        self.viewController = viewController
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionInfo = fetchedResultsController.sections?[realSection] else { return 0 }
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let realIndexPath = IndexPath(item: indexPath.item, section: realSection)
        let video = fetchedResultsController.object(at: realIndexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudyCell", for: indexPath) as! StudyCollectionViewCell
        
        cell.mainTitle.text = video.title
        
        if let thumbnailSource = video.thumbnailSource {
            if let url = URL(string: thumbnailSource) {
                let width = 300
                let imageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSize(width: width, height: width), radius: 10, divideRadiusByImageScale: false)
                cell.mainImage.af_setImage(withURL: url, placeholderImage: nil, filter: imageFilter, imageTransition: UIImageView.ImageTransition.crossDissolve(0.3), runImageTransitionIfCached: false, completion: nil)
                //                cell.coverImageView.af_setImage(withURL: url)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let realIndexPath = IndexPath(item: indexPath.item, section: realSection)
        let study = fetchedResultsController.object(at: realIndexPath)
        viewController?.performSegue(withIdentifier: "showStudy", sender: study)
    }
    
    var title: String? {
        get {
            return fetchedResultsController.sections?[realSection].name
        }
    }
    
    var numberOfStudies: Int? {
        get {
            return fetchedResultsController.sections?[realSection].numberOfObjects
        }
    }
    
}

class VideosViewController: UIViewController {

    
    var fetchedResultsController: NSFetchedResultsController<Video>!
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate func configureFetchRequest(_ fetchRequest: NSFetchRequest<Video>) {
        
        let identifierSort = NSSortDescriptor(key: VideoAttributes.videoIndex.rawValue, ascending: true)
//        let bibleStudySort = NSSortDescriptor(key: StudyAttributes.bibleIndex.rawValue, ascending: true)
        
        var sortDescriptors : [NSSortDescriptor] = []
        
        sortDescriptors.append(contentsOf: [identifierSort])
        
        fetchRequest.sortDescriptors = sortDescriptors
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<Video>(entityName: Video.entityName())
        let context: NSManagedObjectContext = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Video.entity(managedObjectContext: context)
        
        configureFetchRequest(fetchRequest)
        
        fetchRequest.shouldRefreshRefetchedObjects = true
        fetchedResultsController = NSFetchedResultsController<Video>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "channel.title", cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            DispatchQueue.main.async { () -> Void in
                self.reloadData()
            }
        } catch let error {
            logger.error("Error fetching: \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFetchedResultsController()
        
        tableView.register(UINib(nibName: "StudiesTableViewCell", bundle: nil), forCellReuseIdentifier: "StudiesCell")
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadData() {
        tableView.reloadData()
    }
    
    
    
}

extension VideosViewController : NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("did change videos")
    }
    
}
