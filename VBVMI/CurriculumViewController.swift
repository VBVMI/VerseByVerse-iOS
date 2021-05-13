//
//  CurriculumViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 26/08/18.
//  Copyright © 2018 Tom Carey. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import AVFoundation
import VimeoNetworking
import FirebaseAnalytics

class CurriculumViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, CurriculumPDFTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let activity = NSUserActivity(activityType: "org.versebyverseministry.www")
    fileprivate let formatter = DateComponentsFormatter()
    fileprivate let videoCellIdentifier = "ChannelCell"
    fileprivate let pdfCellIdentifier = "PDFCell"
    private lazy var shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction(_:)))
    
    var curriculum: Curriculum! {
        didSet {
            if let curriculum = curriculum {
                navigationItem.title = curriculum.title
                if let urlString = curriculum.url, let url = URL(string: urlString) {
                    activity.title = curriculum.title
                    activity.webpageURL = url
                    activity.becomeCurrent()
                }
            }
        }
    }
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Video> = {
        let fetchRequest = NSFetchRequest<Video>(entityName: Video.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Video.entity(managedObjectContext: context)
        let indexSort = NSSortDescriptor(key: VideoAttributes.videoIndex.rawValue, ascending: true)
        
        fetchRequest.sortDescriptors = [indexSort]
        fetchRequest.predicate = NSPredicate(format: "curriculum.identifier == %@", curriculum.identifier)
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
    
    enum Section {
        case studyGuide
        case videos
    }
    
    let sections: [Section] = [.studyGuide, .videos]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: videoCellIdentifier)
        tableView.register(UINib(nibName: "CurriculumPDFTableViewCell", bundle: nil), forCellReuseIdentifier: pdfCellIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        formatter.unitsStyle = .positional
        let _ = fetchedResultsController
        
        if let _ = curriculum?.url {
            
            self.navigationItem.rightBarButtonItem = shareButton
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Analytics.setScreenName("\(curriculum?.title ?? "Curriculum")", screenClass: "CurriculumView")
    }
    
    @objc func shareAction(_ button: Any) {
        guard let urlString = curriculum?.url, let url = URL(string: urlString) else { return }
        
        let actionSheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        actionSheet.popoverPresentationController?.barButtonItem = shareButton
        present(actionSheet, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        if #available(iOS 11.0, *) {
            
        } else {
            // Fallback on earlier versions
            let insets = UIEdgeInsets(top: topLayoutGuide.length, left: 0, bottom: bottomLayoutGuide.length, right: 0)
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
        }
        
    }
    
    func orderCopies(cell: CurriculumPDFTableViewCell) {
        if let purchaseURLString = curriculum.purchaseLink, let url = URL(string: purchaseURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .studyGuide:
            if let pdfURL = curriculum.pdfURL, let _ = URL(string: pdfURL) {
                return 1
            } else {
                return 0
            }
        case .videos:
            return fetchedResultsController.fetchedObjects?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .studyGuide:
            let cell = tableView.dequeueReusableCell(withIdentifier: pdfCellIdentifier, for: indexPath) as! CurriculumPDFTableViewCell
            
            if let urlString = curriculum.coverImage, let url = URL(string: urlString) {
                cell.pdfImageView.af_setImage(withURL: url) { (_) in
                }
            }
            if let purchaseURLString = curriculum.purchaseLink, let _ = URL(string: purchaseURLString) {
                cell.orderCopiesButton.isHidden = false
            } else {
                cell.orderCopiesButton.isHidden = true
            }
            cell.delegate = self
            
            return cell
        case .videos:
            let cell = tableView.dequeueReusableCell(withIdentifier: videoCellIdentifier, for: indexPath) as! VideoTableViewCell
            let video = fetchedResultsController.object(at: IndexPath(row: indexPath.row, section: 0))
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch sections[indexPath.section] {
        case .studyGuide:
            if let urlString = curriculum.pdfURL, let url = URL(string: urlString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case .videos:
            let video = fetchedResultsController.object(at: IndexPath(row: indexPath.row, section: 0))
            playVideo(video)
        }
        
    }
    
    private func playVideo(_ video: Video) {
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
                        switch vimeoURL {
                        case .url(let url):
                            let player = AVPlayer(url: url)
                            movieController.player = player
                        }
                    }
                    dispatchGroup.leave()
                })
                dispatchGroup.notify(queue: DispatchQueue.main, execute: { [weak movieController] in
                    do {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                    }
                    catch {
                        // report for an error
                    }
                    
                    movieController?.player?.play()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                })
            } else {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
}
