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
import Regex
import AVFoundation
import AVKit
import MediaPlayer

private let regex = Regex("[0-9]+x[0-9]+")

class VideosDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate, VideoCollectionViewCellDelegate {
    
    private let fetchedResultsController: NSFetchedResultsController<Video>
    private let realSection : Int
    private weak var viewController: UIViewController?
    private weak var collectionView: UICollectionView?
    
    init(fetchedResultsController: NSFetchedResultsController<Video>, section: Int, viewController: UIViewController, collectionView: UICollectionView) {
        self.fetchedResultsController = fetchedResultsController
        self.realSection = section
        self.viewController = viewController
        self.collectionView = collectionView
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCollectionViewCell
        
        cell.titleLabel.text = video.title
        cell.descriptionTextView.text = video.descriptionText
        cell.delegate = self
        
        if var thumbnailSource = video.thumbnailSource {
            
            thumbnailSource.replaceAll(matching: regex, with: "544x306")
            
            if let url = URL(string: thumbnailSource) {
                
                let imageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSize(width: 544, height: 306), radius: 10, divideRadiusByImageScale: false)
                cell.videoThumbnailImageView.af_setImage(withURL: url, placeholderImage: nil, filter: imageFilter, imageTransition: UIImageView.ImageTransition.crossDissolve(0.3), runImageTransitionIfCached: false, completion: nil)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let realIndexPath = IndexPath(item: indexPath.item, section: realSection)
        let video = fetchedResultsController.object(at: realIndexPath)
        //viewController?.performSegue(withIdentifier: "showStudy", sender: study)
        
        if let service = video.service, service == "vimeo", let serviceID = video.serviceVideoIdentifier {
            let movieController = AVPlayerViewController()
            let dispatchGroup = DispatchGroup()
            dispatchGroup.enter()
            viewController?.present(movieController, animated: true, completion: {
                dispatchGroup.leave()
            })
            dispatchGroup.enter()
            //UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
                //UIApplication.shared.isNetworkActivityIndicatorVisible = false
            })
        }
    }
    
    func videoCollectionViewCellDidLongPress(cell: VideoCollectionViewCell) {
        guard let collectionView = collectionView, let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let realIndexPath = IndexPath(item: indexPath.item, section: realSection)
        let video = fetchedResultsController.object(at: realIndexPath)
        
        
        let videoDetailController = VideoDetailViewController(nibName: "VideoDetailViewController", bundle: nil)
        videoDetailController.video = video
        
        viewController?.present(videoDetailController, animated: true, completion: nil)
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

class VideosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    var fetchedResultsController: NSFetchedResultsController<Video>!
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate func configureFetchRequest(_ fetchRequest: NSFetchRequest<Video>) {
        
        let channelSort = NSSortDescriptor(key: "channel.title", ascending: true)
        let identifierSort = NSSortDescriptor(key: VideoAttributes.videoIndex.rawValue, ascending: true)
        
        var sortDescriptors : [NSSortDescriptor] = []
        
        sortDescriptors.append(contentsOf: [channelSort, identifierSort])
        
        fetchRequest.sortDescriptors = sortDescriptors
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<Video>(entityName: Video.entityName())
        let context: NSManagedObjectContext = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Video.entity(managedObjectContext: context)
        
        configureFetchRequest(fetchRequest)
        fetchRequest.predicate = NSPredicate(format: "%K MATCHES %@", VideoAttributes.service.rawValue, "vimeo")
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
        
        tableView.register(UINib(nibName: "VideosTableViewCell", bundle: nil), forCellReuseIdentifier: "VideosCell")
        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 60, right: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadData() {
        tableView.reloadData()
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideosCell", for: indexPath) as! VideosTableViewCell
        
        let dataSource = VideosDataSource(fetchedResultsController: self.fetchedResultsController, section: indexPath.row, viewController: self, collectionView: cell.collectionView)
        cell.collectionViewDelegate = dataSource
        cell.collectionViewDatasource = dataSource
        
        if let section = self.fetchedResultsController.sections?[indexPath.row] {
            cell.channelTitleLabel.text = section.name
            cell.videosCountLabel.text = "\(section.numberOfObjects) Video\(section.numberOfObjects > 1 ? "s" : "")"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 431
    }
}

extension VideosViewController : NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("did change videos")
    }
    
}

