//
//  LivestreamsViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 4/04/20.
//  Copyright © 2020 Tom Carey. All rights reserved.
//

import Foundation
import CoreData
import AVKit
import AVFoundation
import SafariServices

extension String {
    fileprivate static let videoCell = "VideoTableViewCell"
    fileprivate static let largeHeader = "LargeHeader"
}

class LivestreamsViewController: UIViewController {
    
    private static let postedDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter
    }()
    
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl(frame: .zero)
    
    private lazy var previousStreamsResultsController: NSFetchedResultsController<Livestream> = {
        let fetchRequest = NSFetchRequest<Livestream>(entityName: Livestream.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Livestream.entity(managedObjectContext: context)
        fetchRequest.predicate = NSPredicate(format: "\(LivestreamAttributes.expirationDate) < %@", NSDate())
        let dateSort = NSSortDescriptor(key: LivestreamAttributes.postedDate.rawValue, ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        fetchRequest.shouldRefreshRefetchedObjects = true
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    private lazy var livestreamResultsController: NSFetchedResultsController<Livestream> = {
        let fetchRequest = NSFetchRequest<Livestream>(entityName: Livestream.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Livestream.entity(managedObjectContext: context)
        fetchRequest.predicate = NSPredicate(format: "\(LivestreamAttributes.expirationDate) > %@", NSDate())
        let dateSort = NSSortDescriptor(key: LivestreamAttributes.postedDate.rawValue, ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        fetchRequest.fetchLimit = 1
        fetchRequest.shouldRefreshRefetchedObjects = true
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    private enum Section {
        case live
        case previous
    }
    
    private let sections: [Section] = [.live, .previous]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: .videoCell, bundle: .main), forCellReuseIdentifier: .videoCell)
        tableView.register(LargeTitleHeader.self, forHeaderFooterViewReuseIdentifier: .largeHeader)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedSectionHeaderHeight = 30
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = .leastNormalMagnitude
        refetchData()
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
    }
    
    @objc private func refresh() {
        DispatchQueue.global(qos: .background).async {
            APIDataManager.allTheLivestreams() { [weak self] in
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
            }
        }
        
    }
    
    private func refetchData() {
        do {
            try previousStreamsResultsController.performFetch()
        } catch let error {
            logger.error("🍕 error fetching previous streams: \(error)")
        }
        
        do {
            try livestreamResultsController.performFetch()
        } catch let error {
            logger.error("🍕 error fetching live stream: \(error)")
        }
    }
    
    private func playVimeo(vimeoId: String) {
        let movieController = AVPlayerViewController()
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        self.present(movieController, animated: true, completion: {
            dispatchGroup.leave()
        })
        dispatchGroup.enter()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        VimeoManager.shared.getVimeoURL(vimeoVideoID: vimeoId, callback: { (result) in
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
    }
    
}

extension LivestreamsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .live:
            let web = SFSafariViewController(url: URL(string: "https://versebyverseministry.org/livestream")!)
            present(web, animated: true, completion: nil)
        case .previous:
            let livestream = previousStreamsResultsController.object(at: IndexPath(row: indexPath.row, section: 0))
            if let id = livestream.videoId {
                playVimeo(vimeoId: id)
            }
        }
    }
}


extension LivestreamsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .live: return livestreamResultsController.fetchedObjects?.count ?? 0
        case .previous: return previousStreamsResultsController.fetchedObjects?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .live:
            let cell = tableView.dequeueReusableCell(withIdentifier: .videoCell, for: indexPath) as! VideoTableViewCell
            let livestream = livestreamResultsController.object(at: IndexPath(row: indexPath.row, section: 0))
            
            cell.title = livestream.title
            cell.vimeoId = livestream.videoId
            
            return cell
        case .previous:
            let cell = tableView.dequeueReusableCell(withIdentifier: .videoCell, for: indexPath) as! VideoTableViewCell
            let livestream = previousStreamsResultsController.object(at: IndexPath(row: indexPath.row, section: 0))
            
            cell.title = livestream.title
            cell.vimeoId = livestream.videoId
            if let date = livestream.postedDate {
                cell.videoDescription = LivestreamsViewController.postedDateFormatter.string(from: date)
            } else {
                cell.videoDescription = ""
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch sections[section] {
        case .live:
            return nil
        case .previous:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: .largeHeader) as! LargeTitleHeader
            header.title = "Previous Livestreams"
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section] {
        case .live:
            return .leastNormalMagnitude
        case .previous:
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section] {
        case .live:
            return .leastNormalMagnitude
        case .previous:
            return UITableView.automaticDimension
        }
    }
    
}

extension LivestreamsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        switch controller {
        case livestreamResultsController: tableView.reloadData()
        case previousStreamsResultsController: tableView.reloadData()
        default: break
        }
    }
    
}
