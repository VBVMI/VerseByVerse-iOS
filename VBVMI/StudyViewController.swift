//
//  StudyViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 5/02/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

import SnapKit
import AlamofireImage
import CoreData
import ACPDownload
import LNPopupController
import AVKit
import AVFoundation

class StudyViewController: UITableViewController {

    fileprivate let lessonCellReuseIdentifier = "LessonCellReuseIdentifier"
    fileprivate let lessonSectionHeaderReuseIdentifier = "LessonSectionReuseIdentifier"

    @IBOutlet var headerBackingView: UIView!
    @IBOutlet var blurredImageView: UIImageView!
    @IBOutlet var headerImageView: UIImageView!
    private let activity = NSUserActivity(activityType: "org.versebyverseministry.www")
    
    fileprivate let barButtonItem: UIBarButtonItem = UIBarButtonItem(title: String.fontAwesomeIconWithName(.EllipsisH), style: .plain, target: nil, action: #selector(tappedMenu))
    
    fileprivate class ButtonSender {
        let url: URL
        let lessonType: ResourceManager.LessonType
        init(url: URL, lessonType: ResourceManager.LessonType) {
            self.url = url
            self.lessonType = lessonType
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController<Lesson>!
    
    var testDescriptionLabel = UILabel()
    
    var isDescriptionOpen = false {
        didSet {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? StudyDescriptionCell {
                cell.hideView.alpha = isDescriptionOpen ? 0 : 1
                cell.moreLabel.text = isDescriptionOpen ? "Less..." : "More..."
                if isDescriptionOpen {
                    NSLayoutConstraint.activate([cell.bottomConstraint])
                } else {
                    NSLayoutConstraint.deactivate([cell.bottomConstraint])
                }
            }
        }
    }
    
    var study: Study! {
        didSet {
            
            self.navigationItem.title = study.title
            
            if let identifier = study?.identifier {
                APIDataManager.lessons(identifier)
            }
            
            if let urlString = study.url, let url = URL(string: urlString) {
                activity.title = study?.title
                activity.webpageURL = url
                activity.becomeCurrent()
            }
            
        }
    }
    fileprivate let kTableHeaderHeight: CGFloat = 300.0
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(study.identifier, forKey: "studyIdentifier")
        super.encodeRestorableState(with: coder)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        guard let identifier = coder.decodeObject(forKey: "studyIdentifier") as? String else {
            fatalError()
        }
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        guard let study: Study = Study.findFirstWithPredicate(NSPredicate(format: "%K == %@", StudyAttributes.identifier.rawValue, identifier), context: context) else {
            fatalError()
        }
        self.study = study
    
        super.decodeRestorableState(with: coder)
        configureViewsForSudy()
        configureFetchController()
    }
    
    fileprivate func configureFetchController() {
        let fetchRequest = NSFetchRequest<Lesson>(entityName: Lesson.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Lesson.entity(managedObjectContext: context)
        
        let sectionSort = NSSortDescriptor(key: LessonAttributes.completed.rawValue, ascending: true, selector: #selector(NSNumber.compare(_:)))
        let indexSort = NSSortDescriptor(key: LessonAttributes.lessonIndex.rawValue, ascending: true, selector: #selector(NSNumber.compare(_:)))
        
        fetchRequest.sortDescriptors = [sectionSort, indexSort]
        fetchRequest.predicate = NSPredicate(format: "%K == %@", LessonAttributes.studyIdentifier.rawValue, study.identifier)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "completed", cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        try! fetchedResultsController.performFetch()
    }
    
    fileprivate func configureViewsForSudy() {
        testDescriptionLabel.text = study.descriptionText
        
        if let thumbnailSource = study.thumbnailSource {
            if let url = URL(string: thumbnailSource) {
                blurredImageView.af_setImage(withURL: url, placeholderImage: nil, filter: nil, imageTransition: UIImageView.ImageTransition.crossDissolve(0.3), runImageTransitionIfCached: true, completion: nil)
                
                let width = self.headerImageView.frame.size.width
                let headerImageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSize(width: width, height: width), radius: 3, divideRadiusByImageScale: false)
                headerImageView.af_setImage(withURL: url, placeholderImage: nil, filter: headerImageFilter, imageTransition: UIImageView.ImageTransition.crossDissolve(0.3))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurredImageView.clipsToBounds = true
        headerBackingView.clipsToBounds = false
        
        tableView.register(UINib(nibName: "LessonTableViewCell", bundle: nil), forCellReuseIdentifier: lessonCellReuseIdentifier)
        tableView.register(LessonsHeader.self, forHeaderFooterViewReuseIdentifier: lessonSectionHeaderReuseIdentifier)
        testDescriptionLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        testDescriptionLabel.numberOfLines = 0
        
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        if let _ = study {
            configureViewsForSudy()
            configureFetchController()
        }

        barButtonItem.target = self
        barButtonItem.setTitleTextAttributes([NSFontAttributeName: UIFont.fontAwesomeOfSize(20)], for: .normal)
        
        var buttons = [barButtonItem]
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAction(_:)))
        buttons.append(shareButton)
        
        navigationItem.rightBarButtonItems = buttons
    }
    
    func shareAction(_ button: Any) {
        guard let urlString = study?.url, let url = URL(string: urlString) else { return }
        
        let actionSheet = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(actionSheet, animated: true, completion: nil)
    }
    
    var resizeImageOnce = true
    override func viewDidLayoutSubviews() {
        let contentOffset = self.tableView.contentOffset
        let totalOffTop = self.tableView.contentInset.top + contentOffset.y
        
        let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        if totalOffTop <= 0 {
            resizeBlurImage()
        }
    }
    
    fileprivate func resizeBlurImage() {

        let layer = blurredImageView.layer
        let contentOffset = self.tableView.contentOffset
        let totalOffTop = self.tableView.contentInset.top + contentOffset.y
        
        var frame = self.headerBackingView.bounds
        frame.size.height -= totalOffTop
        
        frame.origin.y = totalOffTop
        let imageFrame = self.view.convert(frame, to: headerBackingView)
        layer.frame = imageFrame
        blurredImageView.setNeedsLayout()
        blurredImageView.layoutIfNeeded()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return 1
        case 1, 2:
            guard let sections = fetchedResultsController.sections else {
                return 0
            }
            let relativeSection = section - 1
            if sections.count <= relativeSection {
                return 0
            }
            let sectionInfo = sections[relativeSection]
            return sectionInfo.numberOfObjects
        default:
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let count = fetchedResultsController.sections?.count ?? 0
        return 1 + count
    }
    
    fileprivate var lastTappedLesson: Lesson?
    fileprivate var lastTappedResource: ResourceManager.LessonType?
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell", for: indexPath) as! StudyDescriptionCell
            cell.descriptionLabel.text = study.descriptionText
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: lessonCellReuseIdentifier, for: indexPath) as! LessonTableViewCell
            let lesson = fetchedResultsController.object(at: IndexPath(row: indexPath.row, section: indexPath.section - 1))
            
            LessonCellViewModel.configure(cell, lesson: lesson)
                
            cell.urlButtonCallback = { [weak self, weak cell] (button, status, lessonType) in
                //It is important to ask the table view for the indexPath otherwise we run the risk of using an out of date index path in this block
                guard let this = self,
                      let cell = cell,
                      let tableIndexPath = this.tableView.indexPath(for: cell) else {
                    return
                }
                
                let lessonIndexPath = IndexPath(row: (tableIndexPath as NSIndexPath).row, section: (tableIndexPath as NSIndexPath).section - 1)
                let lesson = this.fetchedResultsController.object(at: lessonIndexPath)
                
                this.lastTappedLesson = lesson
                this.lastTappedResource = lessonType
                
                switch status {
                case .none, .completed:
                    ResourceManager.sharedInstance.startDownloading(lesson, resource: lessonType, completion: { (result) in
                        guard let this = self else {
                            return
                        }
                        
                        switch result {
                        case .error(let error):
                            //Lame... we got an error..
                            logger.error("\(error)")
                        case .success(let lesson, let resource, let url):
                            //Epic, we have the URL so lets go do a thing
                            
                            guard lesson == this.lastTappedLesson && resource == this.lastTappedResource else {
                                return
                            }
                            
                            switch lessonType.fileType() {
                            case .pdf:
                                this.performSegue(withIdentifier: "showPDF", sender: ButtonSender(url: url, lessonType: resource))
                            case .audio:
                                if let audioPlayerController = this.tabBarController?.popupContent as? AudioPlayerViewController {
                                    audioPlayerController.configure(url, name: lesson.title , subTitle: lesson.descriptionText ?? "", lesson: lesson, study: this.study)
                                    if this.tabBarController?.popupPresentationState == .closed {
                                        this.tabBarController?.openPopup(animated: true, completion: nil)
                                    }
                                } else {
                                    let demoVC = AudioPlayerViewController()
                                    demoVC.configure(url, name: lesson.title, subTitle: lesson.descriptionText ?? "", lesson: lesson, study: this.study)
                                    
                                    this.tabBarController?.presentPopupBar(withContentViewController: demoVC, openPopup: true, animated: true, completion: { () -> Void in
                                        
                                    })
                                }
                            case .video:
                                if url.absoluteString.contains("vimeo.com") {
                                    let movieController = AVPlayerViewController()
                                    let player = AVPlayer(url: url)
                                    movieController.player = player
                                    
                                    this.present(movieController, animated: true, completion: {
                                        player.play()
                                    })
                                } else {
                                    UIApplication.shared.openURL(url)
                                }
                                
                                
                            }
                            
                        }
                    })
                case .running, .indeterminate:
                    ResourceManager.sharedInstance.cancelDownload(lesson, resource: lessonType)
                }
            }
            
            return cell
        }
    }
    
    fileprivate func downloadedFileUrls(_ lesson: Lesson) -> [URL] {
        let urls = ResourceManager.LessonType.all.flatMap({ $0.urlString(lesson) }).flatMap({ APIDataManager.fileExists(lesson, urlString: $0) })
        return urls
    }
    
    fileprivate func configureHeader(_ lessonHeader: LessonsHeader, section: Int) {
        switch section {
        case 1,2:
            if fetchedResultsController.sectionIndexTitles[section - 1] == "0" {
                lessonHeader.titleLabel.text = "Lessons"
                lessonHeader.countLabel.text = "\(fetchedResultsController.sections![section - 1].numberOfObjects)"
            } else {
                lessonHeader.titleLabel.text = "Completed lessons"
                lessonHeader.countLabel.text = "\(fetchedResultsController.sections![section - 1].numberOfObjects)"
            }
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1,2:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: lessonSectionHeaderReuseIdentifier) as! LessonsHeader
            configureHeader(header, section: section)
            return header
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1,2:
            return 36.5
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch (indexPath as NSIndexPath).section {
        case 1,2:
            let logicalIndex = IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section - 1)
            let lesson = fetchedResultsController.object(at: logicalIndex)
            if lesson.isPlaceholder {
                return false
            }
            return true
        default:
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        switch (indexPath as NSIndexPath).section {
        case 1,2:
            var actions = [UITableViewRowAction]()
            let logicalIndex = IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section - 1)
            let lessons = fetchedResultsController.fetchedObjects ?? []
            let lesson = fetchedResultsController.object(at: logicalIndex)
            let study = self.study
            let markCompleteAction : UITableViewRowAction
            if lesson.completed == true {
                markCompleteAction = UITableViewRowAction(style: .normal, title: "Mark as incomplete", handler: { (action, indexPath) in
                    lesson.completed = false
                    tableView.isEditing = false
                    
                    let lessonsCompleted = lessons.reduce(0, { (value, lesson) -> Int in
                        return lesson.completed ? value + 1 : value
                    })
                    study?.lessonsCompleted = Int32(lessonsCompleted)
                    
                    do {
                        try lesson.managedObjectContext?.save()
                    } catch {}
                })
            } else {
                markCompleteAction = UITableViewRowAction(style: .normal, title: "Mark as complete", handler: { (action, indexPath) in
                    lesson.completed = true
                    lesson.audioProgress = 0
                    tableView.isEditing = false
                    
                    let lessonsCompleted = lessons.reduce(0, { (value, lesson) -> Int in
                        return lesson.completed ? value + 1 : value
                    })
                    study?.lessonsCompleted = Int32(lessonsCompleted)
                    
                    do {
                        try lesson.managedObjectContext?.save()
                    } catch {}
                    
                })
            }
            
            markCompleteAction.backgroundColor = UIColor ( red: 0.2086, green: 0.4158, blue: 0.9483, alpha: 1.0 )
            markCompleteAction.backgroundEffect = UIBlurEffect(style: .dark)
            actions.append(markCompleteAction)
            let downloadedFileURLs = downloadedFileUrls(lesson)
            if downloadedFileURLs.count > 0 {
                let deleteAction = UITableViewRowAction(style: .default, title: "Delete files", handler: { (action, indexPath) in
                    downloadedFileURLs.forEach({ let _ = try? FileManager.default.removeItem(at: $0) })
                    //
                    tableView.isEditing = false
                    tableView.reloadRows(at: [indexPath], with: .none)
                })
                actions.append(deleteAction)
            }
            
            
            return actions
        default:
            return []
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? PDFViewController, let buttonSender = sender as? ButtonSender {
            viewController.urlToLoad = buttonSender.url
            viewController.title = buttonSender.lessonType.title
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ResourceManager.sharedInstance.addDownloadObserver(self)
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ResourceManager.sharedInstance.removeDownloadObserver(self)
        activity.invalidate()
    }
    
    var calculatedDescriptionHeight : CGFloat? = nil
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).section {
        case 0:
            if isDescriptionOpen {
                return 85
            } else {
                if let calculatedDescriptionHeight = calculatedDescriptionHeight {
                    return calculatedDescriptionHeight
                }
                let size = testDescriptionLabel.sizeThatFits(CGSize(width: self.view.frame.size.width - 16, height: CGFloat.greatestFiniteMagnitude))
                calculatedDescriptionHeight = size.height + 32
                return size.height + 32
            }
        case 1, 2:
            return 91
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch ((indexPath as NSIndexPath).section) {
        case 0:
            switch (indexPath as NSIndexPath).row {
            case 0:
                isDescriptionOpen = !isDescriptionOpen
                self.tableView.setNeedsLayout()
                tableView.beginUpdates()
                tableView.endUpdates()
            default:
                return
            }
        default:
            return
        }
    }
    
    func tappedMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let downloadAll = UIAlertAction(title: "Download all", style: .default) { [weak self] (action) in
            if let study = self?.study {
                ResourceManager.sharedInstance.downloadAllResources(study, completion: { 
                    logger.info("🍕Downloaded all Resources!!!")
                })
            }
        }
        
        let deleteAll = UIAlertAction(title: "Delete all files", style: .destructive) { [weak self] (action) in
            logger.info("🍕Trying to delete everything")
            guard let this = self else {
                return
            }
            
            if let lessons = this.fetchedResultsController?.fetchedObjects {
                lessons.forEach({ (lesson) in
                    let downloadedFileURLs = this.downloadedFileUrls(lesson)
                    downloadedFileURLs.forEach({ let _ = try? FileManager.default.removeItem(at: $0) })
                })
            }
            
            if let rows = this.tableView.indexPathsForVisibleRows {
                this.tableView.reloadRows(at: rows, with: .none)
            } else {
                this.tableView.reloadData()
            }
        }
        
        let markAllComplete = UIAlertAction(title: "Mark all complete", style: .default) { [weak self] action in
            guard let this = self else { return }
            if let lessons = this.fetchedResultsController.fetchedObjects {
                lessons.forEach({ (lesson) in
                    if !lesson.isPlaceholder {
                        lesson.completed = true
                        lesson.audioProgress = 0
                    }
                })
                
                let lessonsCompleted = lessons.reduce(0, { (value, lesson) -> Int in
                    return lesson.completed ? value + 1 : value
                })
                this.study.lessonsCompleted = Int32(lessonsCompleted)
                
                let context = ContextCoordinator.sharedInstance.managedObjectContext!
                let _ = try? context.save()
            }
        }
        
        let markAllIncomplete = UIAlertAction(title: "Mark all incomplete", style: .default) { [weak self] action in
            guard let this = self else { return }
            if let lessons = this.fetchedResultsController.fetchedObjects {
                lessons.forEach({ (lesson) in
                    lesson.completed = false
                    lesson.audioProgress = 0
                })
                
                let lessonsCompleted = lessons.reduce(0, { (value, lesson) -> Int in
                    return lesson.completed ? value + 1 : value
                })
                this.study.lessonsCompleted = Int32(lessonsCompleted)
                
                let context = ContextCoordinator.sharedInstance.managedObjectContext!
                let _ = try? context.save()
            }
        }
        
        let cancel = UIAlertAction(title: "Close", style: .cancel) { [weak self] (action) in
            self?.dismiss(animated: true, completion: nil)
        }
        
        let lessons = fetchedResultsController.fetchedObjects!
        let lessonsCompleted = lessons.reduce(0, { (value, lesson) -> Int in
            return lesson.completed ? value + 1 : value
        })
        
        if lessonsCompleted != lessons.count {
            alert.addAction(markAllComplete)
        }
        
        if lessonsCompleted != 0 {
            alert.addAction(markAllIncomplete)
        }
        
        alert.addAction(downloadAll)
        alert.addAction(deleteAll)
        alert.addAction(cancel)
        
        alert.popoverPresentationController?.barButtonItem = barButtonItem
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension StudyViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        (0..<tableView.numberOfSections).forEach({
            if let header = tableView.headerView(forSection: $0) as? LessonsHeader {
                configureHeader(header, section: $0)
            }
        })
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex + 1), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex + 1), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            let myNewIndexPath = IndexPath(row: (newIndexPath as NSIndexPath).row, section: (newIndexPath as NSIndexPath).section + 1)
            tableView.insertRows(at: [myNewIndexPath], with: .fade)
        case .delete:
            guard let indexPath = indexPath else { return }
            let myIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1)
            tableView.deleteRows(at: [myIndexPath], with: .fade)
        case .move, .update:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            let myNewIndexPath = IndexPath(row: (newIndexPath as NSIndexPath).row, section: (newIndexPath as NSIndexPath).section + 1)
            let myIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1)
            
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
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
}

//MARK: - ResourceManagerObserver
extension StudyViewController : ResourceManagerObserver {
    
    func downloadStateChanged(_ lesson: Lesson, lessonType: ResourceManager.LessonType, downloadState: ResourceManager.DownloadState) {
        if let indexPath = fetchedResultsController?.indexPath(forObject: lesson) {
            //Then we have a lesson in our table that needs an update.. lets see first if the cell is available
            let tableIndexPath = IndexPath(row: (indexPath as NSIndexPath).row, section: (indexPath as NSIndexPath).section + 1)
            if let cell = tableView?.cellForRow(at: tableIndexPath) as? LessonTableViewCell {
                //Nice one, now we have a cell that we can update.. All other download notifications we can ignore because they are for someone else
                let button = lessonType.button(cell)
                if button.currentStatus != downloadState.acpStatus {
                    button.setIndicatorStatus(downloadState.acpStatus)
                }
                
                switch downloadState {
                case .downloading(let percent):
                    button.setProgress(Float(percent), animated: false)
                case .downloaded:
                    let view = lessonType.view(cell)
                    view.dotView.isHidden = false
                default:
                    break
                }
            }
        }
    }
    
}

extension ResourceManager.DownloadState {
    
    var acpStatus : ACPDownloadStatus {
        get {
            switch self {
            case .nothing:
                return ACPDownloadStatus.none
            case .downloaded:
                return ACPDownloadStatus.none
            case .pending:
                return ACPDownloadStatus.indeterminate
            case .downloading:
                return ACPDownloadStatus.running
            }
        }
    }
    
}
