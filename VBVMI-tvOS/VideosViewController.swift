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
    
    private let videos: [Video]
    private weak var viewController: UIViewController?
    private weak var collectionView: UICollectionView?
    private let title: String
    
    init(videos: [Video], viewController: UIViewController, collectionView: UICollectionView, title: String) {
        self.videos = videos
        self.viewController = viewController
        self.collectionView = collectionView
        self.title = title
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let video = videos[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCollectionViewCell
        
        cell.titleLabel.text = video.title?.strippingHTMLTags.stringByDecodingHTMLEntities
        cell.descriptionTextView.text = video.descriptionText?.strippingHTMLTags.stringByDecodingHTMLEntities
        cell.delegate = self
        cell.videoThumbnailImageView.image = nil
        
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
        let video = videos[indexPath.item]
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
                case .success(let vimeoMode):
                    switch vimeoMode {
                    case .url(let vimeoUrl):
                        let player = AVPlayer(url: vimeoUrl)
                        movieController.player = player
                    }
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
        
        let video = videos[indexPath.item]
        
        
        let videoDetailController = VideoDetailViewController(nibName: "VideoDetailViewController", bundle: nil)
        videoDetailController.video = video
        
        viewController?.present(videoDetailController, animated: true, completion: nil)
    }
        
    var numberOfStudies: Int? {
        get {
            return videos.count
        }
    }
}

class VideosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private enum Section: CaseIterable {
        case curriculum
        case channel
    }
    
    private let sections = Section.allCases
    
    private lazy var fetchedChannelResultsController: NSFetchedResultsController<Channel> = {
        let fetchRequest = NSFetchRequest<Channel>(entityName: Channel.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Channel.entity(managedObjectContext: context)
        
        let sort = NSSortDescriptor(key: ChannelAttributes.postedDate.rawValue, ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.shouldRefreshRefetchedObjects = true
        let frc = NSFetchedResultsController<Channel>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "title", cacheName: nil)
        frc.delegate = self
        try? frc.performFetch()
        DispatchQueue.main.async { () -> Void in
            self.reloadData()
        }
        
        return frc
    }()
    
    private lazy var fetchedCurriculumResultsController: NSFetchedResultsController<Curriculum> = {
        let fetchRequest = NSFetchRequest<Curriculum>(entityName: Curriculum.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Curriculum.entity(managedObjectContext: context)
        
        let sort = NSSortDescriptor(key: CurriculumAttributes.postedDate.rawValue, ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.shouldRefreshRefetchedObjects = true
        let frc = NSFetchedResultsController<Curriculum>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "title", cacheName: nil)
        frc.delegate = self
        try? frc.performFetch()
        DispatchQueue.main.async { () -> Void in
            self.reloadData()
        }
        
        return frc
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate func configureFetchRequest(_ fetchRequest: NSFetchRequest<Video>) {
        

        let channelTitleSort = NSSortDescriptor(key: "channel.title", ascending: true)
        let identifierSort = NSSortDescriptor(key: VideoAttributes.videoIndex.rawValue, ascending: true)
        
        var sortDescriptors : [NSSortDescriptor] = []
        
        sortDescriptors.append(contentsOf: [channelTitleSort, identifierSort])
        
        fetchRequest.sortDescriptors = sortDescriptors
    }
    
    fileprivate func setupFetchedResultsController() {
//        let fetchRequest = NSFetchRequest<Video>(entityName: Video.entityName())
//        let context: NSManagedObjectContext = ContextCoordinator.sharedInstance.managedObjectContext!
//        fetchRequest.entity = Video.entity(managedObjectContext: context)
//
//        configureFetchRequest(fetchRequest)
//        fetchRequest.predicate = NSPredicate(format: "%K MATCHES %@", VideoAttributes.service.rawValue, "vimeo")
//        fetchRequest.shouldRefreshRefetchedObjects = true
//        fetchedResultsController = NSFetchedResultsController<Video>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "channel.title", cacheName: nil)
//
//        fetchedResultsController.delegate = self
//
//        do {
//            try fetchedResultsController.performFetch()
//            DispatchQueue.main.async { () -> Void in
//                self.reloadData()
//            }
//        } catch let error {
//            logger.error("Error fetching: \(error)")
//        }
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
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .channel:
            return fetchedChannelResultsController.sections?.count ?? 0
        case .curriculum:
            return fetchedCurriculumResultsController.sections?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideosCell", for: indexPath) as! VideosTableViewCell
        
        let videos: Set<Video>
        let title: String
        switch sections[indexPath.section] {
        case .channel:
            let channel = fetchedChannelResultsController.object(at: IndexPath(row: 0, section: indexPath.row))
            videos = channel.videos
            title = channel.title ?? ""
        case .curriculum:
            let curriculum = fetchedCurriculumResultsController.object(at: IndexPath(row: 0, section: indexPath.row))
            videos = curriculum.videos
            title = curriculum.title
        }
        
        let sortedVideos = videos.sorted { (v0, v1) -> Bool in
            return v0.videoIndex < v1.videoIndex
        }
        
        let source = VideosDataSource(videos: sortedVideos, viewController: self, collectionView: cell.collectionView, title: title)
        cell.collectionViewDelegate = source
        cell.collectionViewDatasource = source
        
        cell.channelTitleLabel.text = title
        cell.videosCountLabel.text = "\(sortedVideos.count) Video\(sortedVideos.count > 1 ? "s" : "")"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 431
    }
}

extension VideosViewController : NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        switch controller {
        case fetchedCurriculumResultsController:
            print("Curriculum did change content")
        case fetchedChannelResultsController:
            print("Channel did change content")
        default:
            print("Got an unexpected response from an unknown fetched results controller")
        }
    }
    
}

