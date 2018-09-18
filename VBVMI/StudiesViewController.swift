//
//  ViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 31/01/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage
import FirebaseAnalytics

class StudiesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var fetchedResultsController: NSFetchedResultsController<Study>!
    private var aboutActionsController: AboutActionsController!
    
    private var header : StudiesHeaderReusableView!
    private var lastTappedLesson: Lesson?
    
    private enum Section {
        case recentHistory
        case latestLessons
        case study(sectionIndex: Int)
    }
    
    private var currentSections : [Section] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private func reloadSections() {
        var sections = [Section]()
        if (recentHistoryFetchedResultsController.fetchedObjects?.count ?? 0) > 0 {
            sections.append(.recentHistory)
        }
        if (latestLessonsFetchedResultsController.fetchedObjects?.count ?? 0) > 0 {
            sections.append(.latestLessons)
        }
        fetchedResultsController?.sections?.enumerated().forEach({ (index, section) in
            sections.append(.study(sectionIndex: index))
        })
        currentSections = sections
    }
    
    private func configureFetchRequest(_ fetchRequest: NSFetchRequest<Study>) {
        
        let identifierSort = NSSortDescriptor(key: StudyAttributes.studyIndex.rawValue, ascending: true)
        let bibleStudySort = NSSortDescriptor(key: StudyAttributes.bibleIndex.rawValue, ascending: true)
        
        var sortDescriptors : [NSSortDescriptor] = [NSSortDescriptor(key: "studyCategory.order", ascending: true)]
        
        switch StudySortOption.currentSortOption {
        case .bibleBookIndex:
            sortDescriptors.append(contentsOf: [bibleStudySort, identifierSort])
        case .releaseDate:
            sortDescriptors.append(contentsOf: [identifierSort])
        }

        fetchRequest.sortDescriptors = sortDescriptors
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<Study>(entityName: Study.entityName())
        let context: NSManagedObjectContext = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Study.entity(managedObjectContext: context)
        fetchRequest.predicate = NSPredicate(format: "%K != NULL", StudyRelationships.studyCategory.rawValue)
        configureFetchRequest(fetchRequest)
        
        fetchRequest.shouldRefreshRefetchedObjects = true
        fetchedResultsController = NSFetchedResultsController<Study>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "studyCategory.order", cacheName: nil)
        
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            DispatchQueue.main.async { () -> Void in
                self.reloadSections()
            }
        } catch let error {
            logger.error("Error fetching: \(error)")
        }
    }
    
    private lazy var recentHistoryFetchedResultsController: NSFetchedResultsController<Study> = {
        let fetchRequest = NSFetchRequest<Study>(entityName: Study.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Study.entity(managedObjectContext: context)
        
        let dateSort = NSSortDescriptor(key: StudyAttributes.dateLastPlayed.rawValue, ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        fetchRequest.predicate = NSPredicate(format: "%K != nil", StudyAttributes.dateLastPlayed.rawValue)
        
        let fetchedResultsController = NSFetchedResultsController<Study>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            logger.error("Error fetching recent: \(error)")
        }
        return fetchedResultsController
    }()
    
    private lazy var latestLessonsFetchedResultsController: NSFetchedResultsController<Lesson> = {
        let fetchRequest = NSFetchRequest<Lesson>(entityName: Lesson.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Lesson.entity(managedObjectContext: context)
        
        let dateSort = NSSortDescriptor(key: LessonAttributes.postedDate.rawValue, ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        
        fetchRequest.fetchLimit = 10
        
        let fetchedResultsController = NSFetchedResultsController<Lesson>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            logger.error("Error fetching recent: \(error)")
        }
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let headerView = UINib(nibName: Cell.NibName.StudiesHeader, bundle: nil).instantiate(withOwner: nil, options: nil).first as? StudiesHeaderReusableView {
            self.header = headerView
        }
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.register(UINib(nibName: Cell.NibName.Study, bundle: nil), forCellWithReuseIdentifier: Cell.Identifier.Study)

        collectionView.register(UINib(nibName: Cell.NibName.StudiesHeader, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Cell.Identifier.StudiesHeader)
        
        collectionView.register(UINib(nibName: Cell.NibName.RecentStudies, bundle: nil), forCellWithReuseIdentifier: Cell.Identifier.RecentStudies)
        
        collectionView.register(UINib(nibName: Cell.NibName.LatestLessons, bundle: nil), forCellWithReuseIdentifier: Cell.Identifier.LatestLessons)
        
        setupFetchedResultsController()
        
        // Setup about Menu
        self.aboutActionsController = AboutActionsController(presentingController: self)
        self.navigationItem.leftBarButtonItem = self.aboutActionsController.barButtonItem
        
        let optionsButton = UIBarButtonItem(image: UIImage.fontAwesomeIcon(name: .sliders, textColor: StyleKit.darkGrey, size: CGSize(width: 30, height: 30)), style: UIBarButtonItemStyle.plain, target: self, action: #selector(openOptions))
        self.navigationItem.rightBarButtonItem = optionsButton
        
        UserDefaults.standard.addObserver(self, forKeyPath: "StudySortOption", options: [.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "StudySortOption" {
            if let fetchedResultsController = fetchedResultsController {
                configureFetchRequest(fetchedResultsController.fetchRequest)
                do {
                    try fetchedResultsController.performFetch()
                    DispatchQueue.main.async { () -> Void in
                        self.collectionView.reloadData()
                    }
                } catch let error {
                    logger.error("Error fetching: \(error)")
                }
            }
        }
    }
    
    @objc func openOptions() {
        
        let optionsController = UIStoryboard(name: "StudiesOptions", bundle: nil).instantiateInitialViewController()!
        
        present(optionsController, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if #available(iOS 11.0, *) {
            collectionView.contentInset = UIEdgeInsetsMake(0, 0, 8, 0)
        } else {
            // Fallback on earlier versions
            let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
            collectionView.contentInset = insets
            collectionView.scrollIndicatorInsets = insets
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.setScreenName("All Studies", screenClass: "StudiesViewController")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    enum TransitionData {
        case gotoLesson(study: Study, lesson: Lesson)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let study = sender as? Study , segue.identifier == "showLessons" {
            if let studyViewController = segue.destination as? StudyViewController {
                studyViewController.study = study
            }
        } else if let transitionData = sender as? TransitionData, segue.identifier == "showLessons" {
            if let studyViewController = segue.destination as? StudyViewController {
                switch transitionData {
                case .gotoLesson(let study, let lesson):
                    studyViewController.study = study
                    studyViewController.focusLesson = lesson
                }
            }
        }
    }

    func configureHeader(_ section: Int, header: StudiesHeaderReusableView) {
        header.mainTitleLabel.textColor = .black
        header.backgroundColor = .white
        if let numberOfItems = self.fetchedResultsController.sections?[section].numberOfObjects , numberOfItems > 0 {
            if numberOfItems == 1 {
                header.subtitleLabel.text = "\(numberOfItems) Study"
            } else {
                header.subtitleLabel.text = "\(numberOfItems) Studies"
            }
            header.subtitleLabel.isHidden = false
            
            let indexPath = IndexPath(row: 0, section: section)
            let item = fetchedResultsController.object(at: indexPath)
            header.mainTitleLabel.text = item.studyCategory?.name
            header.mainTitleLabel.isHidden = false
        } else {
            header.subtitleLabel.isHidden = true
            header.mainTitleLabel.isHidden = true
        }
    }

}



extension StudiesViewController : UICollectionViewDelegateFlowLayout {
    
    func cellWidth(for layout: UICollectionViewFlowLayout) -> CGFloat {
        var width = self.view.bounds.size.width
        let sectionInset = layout.sectionInset
        if #available(iOS 11.0, *) {
            width -= max(self.view.safeAreaInsets.left, sectionInset.left) + max(self.view.safeAreaInsets.right, sectionInset.right)
        } else {
            width -= sectionInset.left + sectionInset.right
        }
        let spacing = layout.minimumInteritemSpacing
        width += spacing
        
        let minimumAcross: CGFloat = 3
        let maxWidth: CGFloat = 150
        let maxItems = floor(width / (maxWidth + spacing))
        let maxItemWidth = (width / maxItems) - spacing
        
        if maxItems > minimumAcross {
            return maxItemWidth
        }
        
        let minimumCellWidth = (width / minimumAcross) - spacing
        
        return minimumCellWidth
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch currentSections[indexPath.section] {
        case .study(_):
            let finalWidth = cellWidth(for: collectionViewLayout as! UICollectionViewFlowLayout)
            return CGSize(width: finalWidth, height: finalWidth)
        case .latestLessons, .recentHistory:
            return CGSize(width: collectionView.frame.size.width, height: 116)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch currentSections[section] {
        case .study(_):
            let sectionInset = (collectionViewLayout as! UICollectionViewFlowLayout).sectionInset
            
            if #available(iOS 11.0, *) {
                return UIEdgeInsets(top: 0, left: max(self.view.safeAreaInsets.left, sectionInset.left), bottom: 0, right: max(self.view.safeAreaInsets.right, sectionInset.right))
            } else {
                return sectionInset
            }
        default:
            return UIEdgeInsets.zero
        }
    }
}

extension StudiesViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        switch currentSections[indexPath.section] {
        case .study(_):
            return true
        default:
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch currentSections[indexPath.section] {
        case .study(let sectionIndex):
            let studyIndexPath = IndexPath(item: indexPath.item, section: sectionIndex)
            if let _ = collectionView.cellForItem(at: indexPath) as? StudyCellCollectionViewCell {
                let study = fetchedResultsController.object(at: studyIndexPath)
                collectionView.deselectItem(at: indexPath, animated: true)
                self.performSegue(withIdentifier: "showLessons", sender: study)
            }
        default:
            break
        }
    }
}

extension StudiesViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return currentSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch currentSections[section] {
        case .study(let index):
            guard let sections = fetchedResultsController.sections else {
                return 0
            }
            if sections.count <= index {
                return 0
            }
            let sectionInfo = sections[index]
            return sectionInfo.numberOfObjects
        case .latestLessons:
            return 1
        case .recentHistory:
            return 1
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch currentSections[indexPath.section] {
        case .study(let sectionIndex):
            let studyIndexPath = IndexPath(item: indexPath.item, section: sectionIndex)
            let study = fetchedResultsController.object(at: studyIndexPath)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.Identifier.Study, for: indexPath) as! StudyCellCollectionViewCell
            
            cell.isAccessibilityElement = true
            
            cell.accessibilityHint = "\(study.title)"
            
            let totalLessons = CGFloat(max(study.lessonsCompleted, study.lessonCount))
            if totalLessons > 0 {
                let progress = CGFloat(study.lessonsCompleted) / totalLessons
                cell.progressView.progress = progress
            } else {
                cell.progressView.progress = 1
            }
            
            let calculatedCellWidth = cellWidth(for: collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
            cell.title = study.title
            
            if let thumbnailSource = study.image600 {
                if let url = URL(string: thumbnailSource) {
                    
                    let width = calculatedCellWidth - Cell.CellSize.StudyImageInset.left - Cell.CellSize.StudyImageInset.right
                    let scale: CGFloat = 1.3

                    let imageFilter = ScaledToSizeFilter(size: CGSize(width: width * scale, height: width * scale)) //ScaledToSizeWithRoundedCornersFilter(size: CGSize(width: width * scale, height: width * scale), radius: 3, divideRadiusByImageScale: false)
                    cell.coverImageView.af_setImage(withURL: url, placeholderImage: nil, filter: imageFilter, imageTransition: UIImageView.ImageTransition.crossDissolve(0.3), runImageTransitionIfCached: false, completion: nil)
                }
            }
            return cell
        case .recentHistory:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.Identifier.RecentStudies, for: indexPath) as! RecentHistoryCollectionViewCell
            cell.recentHistory = recentHistoryFetchedResultsController.fetchedObjects ?? []
            cell.delegate = self
            return cell
        case .latestLessons:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.Identifier.LatestLessons, for: indexPath) as! LatestLessonsCollectionViewCell
            cell.latestLessons = latestLessonsFetchedResultsController.fetchedObjects ?? []
            cell.delegate = self
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            switch currentSections[indexPath.section] {
            case .study(let sectionIndex):
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Cell.Identifier.StudiesHeader, for: indexPath) as! StudiesHeaderReusableView
                configureHeader(sectionIndex, header: header)
                return header
            case .recentHistory:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Cell.Identifier.StudiesHeader, for: indexPath) as! StudiesHeaderReusableView
                header.mainTitleLabel.text = "Recent History"
                header.subtitleLabel.text = nil
                header.backgroundColor = .darkBackground
                header.mainTitleLabel.textColor = .white
                return header
            case .latestLessons:
                let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Cell.Identifier.StudiesHeader, for: indexPath) as! StudiesHeaderReusableView
                header.mainTitleLabel.text = "Latest Lessons"
                header.subtitleLabel.text = nil
                header.backgroundColor = .darkBackground
                header.mainTitleLabel.textColor = .white
                return header
            }
        default:
            return UICollectionReusableView()
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        switch currentSections[section] {
        case .study(let sectionIndex):
            configureHeader(sectionIndex, header: header)
            return header.systemLayoutSizeFitting(CGSize(width: self.view.bounds.width, height: 400), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority(10))
        case .recentHistory:
            header.mainTitleLabel.text = "Recent History"
            header.subtitleLabel.text = nil
            return header.systemLayoutSizeFitting(CGSize(width: self.view.bounds.width, height: 400), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority(10))

        case .latestLessons:
            header.mainTitleLabel.text = "Latest Lessons"
            header.subtitleLabel.text = nil
            return header.systemLayoutSizeFitting(CGSize(width: self.view.bounds.width, height: 400), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority(10))
        }
        
    }
}

extension StudiesViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        logger.debug("Controller didChangeContent")
        self.reloadSections()
    }
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        logger.debug("Will change content")
    }
    
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        logger.debug("Controller didChangeSection")
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        logger.debug("Controller didChangeObject")
//    }
//    
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        logger.debug("Controller will change content")
//    }
}

extension StudiesViewController : RecentHistoryCollectionViewCellDelegate {
    
    func recentHistoryDidSelect(study: Study, lesson: Lesson) {
        self.performSegue(withIdentifier: "showLessons", sender: TransitionData.gotoLesson(study: study, lesson: lesson))
    }
    
}

extension StudiesViewController : LatestLessonCollectionViewCellDelegate {
    
    func latestLessonsDidSelect(study: Study, lesson: Lesson) {
        self.performSegue(withIdentifier: "showLessons", sender: TransitionData.gotoLesson(study: study, lesson: lesson))
    }
    
    func latestLessonsDidPlay(study: Study, lesson: Lesson) {
        lastTappedLesson = lesson
        ResourceManager.sharedInstance.startDownloading(lesson, resource: ResourceManager.LessonType.audio, completion: { [weak self] (result) in
            guard let this = self else {
                return
            }
            
            switch result {
            case .error(let error):
                //Lame... we got an error..
                logger.error("\(error)")
            case .success(let lesson, _, let url):
                //Epic, we have the URL so lets go do a thing
                
                guard lesson == this.lastTappedLesson else {
                    return
                }
                study.dateLastPlayed = Date()
                lesson.dateLastPlayed = Date()
                try? lesson.managedObjectContext?.save()
                
                if let audioPlayerController = this.tabBarController?.popupContent as? AudioPlayerViewController {
                    audioPlayerController.configure(url, name: lesson.title , subTitle: lesson.descriptionText ?? "", lesson: lesson, study: study)
                    if this.tabBarController?.popupPresentationState == .closed {
                        this.tabBarController?.openPopup(animated: true, completion: nil)
                    }
                } else {
                    let demoVC = AudioPlayerViewController()
                    demoVC.configure(url, name: lesson.title, subTitle: lesson.descriptionText ?? "", lesson: lesson, study: study)
                    this.tabBarController?.presentPopupBar(withContentViewController: demoVC, openPopup: true, animated: true, completion: { () -> Void in
                        
                    })
                }
            }
        })
    }
    
}

