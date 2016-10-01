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

class StudyViewController: UITableViewController {

    private let lessonCellReuseIdentifier = "LessonCellReuseIdentifier"
    private let lessonSectionHeaderReuseIdentifier = "LessonSectionReuseIdentifier"

    @IBOutlet var headerBackingView: UIView!
    @IBOutlet var blurredImageView: UIImageView!
    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet weak var headerBlurView: UIVisualEffectView!
    
    private let barButtonItem: UIBarButtonItem = UIBarButtonItem(title: String.fontAwesomeIconWithName(.EllipsisH), style: .Plain, target: nil, action: #selector(tappedMenu))
    
    private class ButtonSender {
        let url: NSURL
        let lessonType: ResourceManager.LessonType
        init(url: NSURL, lessonType: ResourceManager.LessonType) {
            self.url = url
            self.lessonType = lessonType
        }
    }
    
    var fetchedResultsController: NSFetchedResultsController!
    
    var testDescriptionLabel = UILabel()
    
    var isDescriptionOpen = false {
        didSet {
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? StudyDescriptionCell {
                cell.hideView.alpha = isDescriptionOpen ? 0 : 1
                cell.moreLabel.text = isDescriptionOpen ? "Less..." : "More..."
                if isDescriptionOpen {
                    NSLayoutConstraint.activateConstraints([cell.bottomConstraint])
                } else {
                    NSLayoutConstraint.deactivateConstraints([cell.bottomConstraint])
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
        }
    }
    private let kTableHeaderHeight: CGFloat = 300.0
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        coder.encodeObject(study.identifier, forKey: "studyIdentifier")
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        guard let identifier = coder.decodeObjectForKey("studyIdentifier") as? String else {
            fatalError()
        }
        let context = ContextCoordinator.sharedInstance.managedObjectContext
        guard let study: Study = Study.findFirstWithPredicate(NSPredicate(format: "%K == %@", StudyAttributes.identifier.rawValue, identifier), context: context) else {
            fatalError()
        }
        self.study = study
    
        super.decodeRestorableStateWithCoder(coder)
        configureViewsForSudy()
        configureFetchController()
    }
    
    private func configureFetchController() {
        let fetchRequest = NSFetchRequest(entityName: Lesson.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext
        fetchRequest.entity = Lesson.entity(context)
        
        let sectionSort = NSSortDescriptor(key: LessonAttributes.completed.rawValue, ascending: true, selector: #selector(NSNumber.compare(_:)))
        let indexSort = NSSortDescriptor(key: LessonAttributes.lessonIndex.rawValue, ascending: true, selector: #selector(NSNumber.compare(_:)))
        
        fetchRequest.sortDescriptors = [sectionSort, indexSort]
        fetchRequest.predicate = NSPredicate(format: "%K == %@", LessonAttributes.studyIdentifier.rawValue, study.identifier)
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "completed", cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        try! fetchedResultsController.performFetch()
    }
    
    private func configureViewsForSudy() {
        testDescriptionLabel.text = study.descriptionText
        
        if let thumbnailSource = study.thumbnailSource {
            if let url = NSURL(string: thumbnailSource) {
                blurredImageView.af_setImageWithURL(url, placeholderImage: nil, filter: nil, imageTransition: UIImageView.ImageTransition.CrossDissolve(0.3), runImageTransitionIfCached: false, completion: nil)
                
                let width = self.headerImageView.frame.size.width
                let headerImageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSizeMake(width, width), radius: 3, divideRadiusByImageScale: false)
                headerImageView.af_setImageWithURL(url, placeholderImage: nil, filter: headerImageFilter, imageTransition: UIImageView.ImageTransition.CrossDissolve(0.3))
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurredImageView.clipsToBounds = true
        headerBackingView.clipsToBounds = false
        
        tableView.registerNib(UINib(nibName: "LessonTableViewCell", bundle: nil), forCellReuseIdentifier: lessonCellReuseIdentifier)
        tableView.registerClass(LessonsHeader.self, forHeaderFooterViewReuseIdentifier: lessonSectionHeaderReuseIdentifier)
        testDescriptionLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        testDescriptionLabel.numberOfLines = 0
        
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        if let _ = study {
            configureViewsForSudy()
            configureFetchController()
        }
        blurredImageView.addSubview(headerBlurView)
        headerBlurView.snp_makeConstraints { (make) in
            make.edges.equalTo(0)
        }
        
        barButtonItem.target = self
        barButtonItem.setTitleTextAttributes([NSFontAttributeName: UIFont.fontAwesomeOfSize(20)], forState: .Normal)
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    var resizeImageOnce = true
    override func viewDidLayoutSubviews() {
        let contentOffset = self.tableView.contentOffset
        let totalOffTop = self.tableView.contentInset.top + contentOffset.y
        if totalOffTop <= 0 {
            resizeBlurImage()
        }
        
        let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
    }
    
    private func resizeBlurImage() {
        let layer = blurredImageView.layer
        let contentOffset = self.tableView.contentOffset
        let totalOffTop = self.tableView.contentInset.top + contentOffset.y
        
        var frame = self.headerBackingView.bounds
        frame.size.height -= totalOffTop
        frame.size.height += self.tableView.contentInset.top
        
        frame.origin.y = totalOffTop - self.tableView.contentInset.top
        let imageFrame = self.view.convertRect(frame, toView: headerBackingView)
        layer.frame = imageFrame
        headerBlurView.frame = layer.bounds
//        headerBlurView.layer.frame = imageFrame
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let count = fetchedResultsController.sections?.count ?? 0
        return 1 + count
    }
    
    private var lastTappedLesson: Lesson?
    private var lastTappedResource: ResourceManager.LessonType?
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("DescriptionCell", forIndexPath: indexPath) as! StudyDescriptionCell
            cell.descriptionLabel.text = study.descriptionText
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(lessonCellReuseIdentifier, forIndexPath: indexPath) as! LessonTableViewCell
            if let lesson = fetchedResultsController.objectAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: indexPath.section - 1)) as? Lesson {
                LessonCellViewModel.configure(cell, lesson: lesson)
                
                cell.urlButtonCallback = { [weak self, weak cell] (button, status, lessonType) in
                    //It is important to ask the table view for the indexPath otherwise we run the risk of using an out of date index path in this block
                    guard let this = self,
                          let cell = cell,
                          let tableIndexPath = this.tableView.indexPathForCell(cell) else {
                        return
                    }
                    
                    let lessonIndexPath = NSIndexPath(forRow: tableIndexPath.row, inSection: tableIndexPath.section - 1)
                    let lesson = this.fetchedResultsController.objectAtIndexPath(lessonIndexPath) as! Lesson
                    
                    this.lastTappedLesson = lesson
                    this.lastTappedResource = lessonType
                    
                    switch status {
                    case .None, .Completed:
                        ResourceManager.sharedInstance.startDownloading(lesson, resource: lessonType, completion: { (result) in
                            guard let this = self else {
                                return
                            }
                            
                            switch result {
                            case .error(let error):
                                //Lame... we got an error..
                                log.error("\(error)")
                            case .success(let lesson, let resource, let url):
                                //Epic, we have the URL so lets go do a thing
                                
                                guard lesson == this.lastTappedLesson && resource == this.lastTappedResource else {
                                    return
                                }
                                
                                switch lessonType.fileType() {
                                case .PDF:
                                    this.performSegueWithIdentifier("showPDF", sender: ButtonSender(url: url, lessonType: resource))
                                case .Audio:
                                    if let audioPlayerController = this.tabBarController?.popupContentViewController as? AudioPlayerViewController {
                                        audioPlayerController.configure(url, name: lesson.title ?? "", subTitle: lesson.descriptionText ?? "", lesson: lesson, study: this.study)
                                        if this.tabBarController?.popupPresentationState == .Closed {
                                            this.tabBarController?.openPopupAnimated(true, completion: nil)
                                        }
                                    } else {
                                        let demoVC = AudioPlayerViewController()
                                        demoVC.configure(url, name: lesson.title ?? "", subTitle: lesson.descriptionText ?? "", lesson: lesson, study: this.study)
                                        
                                        this.tabBarController?.presentPopupBarWithContentViewController(demoVC, openPopup: true, animated: true, completion: { () -> Void in
                                            
                                        })
                                    }
                                case .Video:
                                    UIApplication.sharedApplication().openURL(url)
                                }
                                
                            }
                        })
                    case .Running, .Indeterminate:
                        ResourceManager.sharedInstance.cancelDownload(lesson, resource: lessonType)
                    }
                }
            }
            return cell
        }
    }
    
    private func downloadedFileUrls(lesson: Lesson) -> [NSURL] {
        let urls = ResourceManager.LessonType.all.flatMap({ $0.urlString(lesson) }).flatMap({ APIDataManager.fileExists(lesson, urlString: $0) })
        return urls
    }
    
    private func configureHeader(lessonHeader: LessonsHeader, section: Int) {
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
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1,2:
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(lessonSectionHeaderReuseIdentifier) as! LessonsHeader
            configureHeader(header, section: section)
            return header
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1,2:
            return 36.5
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch indexPath.section {
        case 1,2:
            let logicalIndex = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section - 1)
            let lesson = fetchedResultsController.objectAtIndexPath(logicalIndex) as! Lesson
            if lesson.isPlaceholder {
                return false
            }
            return true
        default:
            return false
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        switch indexPath.section {
        case 1,2:
            var actions = [UITableViewRowAction]()
            let logicalIndex = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section - 1)
            let lesson = fetchedResultsController.objectAtIndexPath(logicalIndex) as! Lesson
            let markCompleteAction : UITableViewRowAction
            if lesson.completed == true {
                markCompleteAction = UITableViewRowAction(style: .Normal, title: "Mark as incomplete", handler: { (action, indexPath) in
                    lesson.completed = false
                    tableView.editing = false
                    do {
                        try lesson.managedObjectContext?.save()
                    } catch {}
                })
            } else {
                markCompleteAction = UITableViewRowAction(style: .Normal, title: "Mark as complete", handler: { (action, indexPath) in
                    lesson.completed = true
                    lesson.audioProgress = 0
                    tableView.editing = false
                    do {
                        try lesson.managedObjectContext?.save()
                    } catch {}
                    
                })
            }
            
            markCompleteAction.backgroundColor = UIColor ( red: 0.2086, green: 0.4158, blue: 0.9483, alpha: 1.0 )
            markCompleteAction.backgroundEffect = UIBlurEffect(style: .Dark)
            actions.append(markCompleteAction)
            let downloadedFileURLs = downloadedFileUrls(lesson)
            if downloadedFileURLs.count > 0 {
                let deleteAction = UITableViewRowAction(style: .Default, title: "Delete files", handler: { (action, indexPath) in
                    downloadedFileURLs.forEach({ let _ = try? NSFileManager.defaultManager().removeItemAtURL($0) })
                    //
                    tableView.editing = false
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                })
                actions.append(deleteAction)
            }
            
            
            return actions
        default:
            return []
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? PDFViewController, buttonSender = sender as? ButtonSender {
            viewController.urlToLoad = buttonSender.url
            viewController.title = buttonSender.lessonType.title
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ResourceManager.sharedInstance.addDownloadObserver(self)
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        ResourceManager.sharedInstance.removeDownloadObserver(self)
    }
    
    var calculatedDescriptionHeight : CGFloat? = nil
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if isDescriptionOpen {
                return 85
            } else {
                if let calculatedDescriptionHeight = calculatedDescriptionHeight {
                    return calculatedDescriptionHeight
                }
                let size = testDescriptionLabel.sizeThatFits(CGSize(width: self.view.frame.size.width - 16, height: CGFloat.max))
                calculatedDescriptionHeight = size.height + 32
                return size.height + 32
            }
        case 1, 2:
            return 91
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section) {
        case 0:
            switch indexPath.row {
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
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let downloadAll = UIAlertAction(title: "Download all", style: .Default) { [weak self] (action) in
            if let study = self?.study {
                ResourceManager.sharedInstance.downloadAllResources(study, completion: { 
                    log.info("Downloaded all Resources!!!")
                })
            }
        }
        
        let deleteAll = UIAlertAction(title: "Delete all files", style: .Destructive) { [weak self] (action) in
            log.info("Trying to delete everything")
            guard let this = self else {
                return
            }
            
            if let lessons = this.fetchedResultsController?.fetchedObjects as? [Lesson] {
                lessons.forEach({ (lesson) in
                    let downloadedFileURLs = this.downloadedFileUrls(lesson)
                    downloadedFileURLs.forEach({ let _ = try? NSFileManager.defaultManager().removeItemAtURL($0) })
                })
            }
            
            if let rows = this.tableView.indexPathsForVisibleRows {
                this.tableView.reloadRowsAtIndexPaths(rows, withRowAnimation: .None)
            } else {
                this.tableView.reloadData()
            }
        }
        
        let markAllComplete = UIAlertAction(title: "Mark all complete", style: .Default) { [weak self] action in
            guard let this = self else { return }
            if let lessons = this.fetchedResultsController.fetchedObjects as? [Lesson] {
                lessons.forEach({ (lesson) in
                    if !lesson.isPlaceholder {
                        lesson.completed = true
                        lesson.audioProgress = 0
                    }
                })
                
                let context = ContextCoordinator.sharedInstance.managedObjectContext
                let _ = try? context.save()
            }
        }
        
        let markAllIncomplete = UIAlertAction(title: "Mark all incomplete", style: .Default) { [weak self] action in
            guard let this = self else { return }
            if let lessons = this.fetchedResultsController.fetchedObjects as? [Lesson] {
                lessons.forEach({ (lesson) in
                    lesson.completed = false
                    lesson.audioProgress = 0
                })
                
                let context = ContextCoordinator.sharedInstance.managedObjectContext
                let _ = try? context.save()
            }
        }
        
        let cancel = UIAlertAction(title: "Close", style: .Cancel) { [weak self] (action) in
            self?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(markAllComplete)
        alert.addAction(markAllIncomplete)
        alert.addAction(downloadAll)
        alert.addAction(deleteAll)
        alert.addAction(cancel)
        
        alert.popoverPresentationController?.barButtonItem = barButtonItem
        presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension StudyViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
        (0..<tableView.numberOfSections).forEach({
            if let header = tableView.headerViewForSection($0) as? LessonsHeader {
                configureHeader(header, section: $0)
            }
        })
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex + 1), withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex + 1), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
        case .Insert:
            guard let newIndexPath = newIndexPath else { return }
            let myNewIndexPath = NSIndexPath(forRow: newIndexPath.row, inSection: newIndexPath.section + 1)
            tableView.insertRowsAtIndexPaths([myNewIndexPath], withRowAnimation: .Fade)
        case .Delete:
            guard let indexPath = indexPath else { return }
            let myIndexPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + 1)
            tableView.deleteRowsAtIndexPaths([myIndexPath], withRowAnimation: .Fade)
        case .Move, .Update:
            guard let indexPath = indexPath, newIndexPath = newIndexPath else { return }
            let myNewIndexPath = NSIndexPath(forRow: newIndexPath.row, inSection: newIndexPath.section + 1)
            let myIndexPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + 1)
            
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
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
}

//MARK: - ResourceManagerObserver
extension StudyViewController : ResourceManagerObserver {
    
    func downloadStateChanged(lesson: Lesson, lessonType: ResourceManager.LessonType, downloadState: ResourceManager.DownloadState) {
        if let indexPath = fetchedResultsController?.indexPathForObject(lesson) {
            //Then we have a lesson in our table that needs an update.. lets see first if the cell is available
            let tableIndexPath = NSIndexPath(forRow: indexPath.row, inSection: indexPath.section + 1)
            if let cell = tableView?.cellForRowAtIndexPath(tableIndexPath) as? LessonTableViewCell {
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
                    view.dotView.hidden = false
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
                return ACPDownloadStatus.None
            case .downloaded:
                return ACPDownloadStatus.None
            case .pending:
                return ACPDownloadStatus.Indeterminate
            case .downloading:
                return ACPDownloadStatus.Running
            }
        }
    }
    
}
