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


class StudiesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var fetchedResultsController: NSFetchedResultsController<Study>!
    private var aboutActionsController: AboutActionsController!
    
    private var header : StudiesHeaderReusableView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let headerView = UINib(nibName: Cell.NibName.StudiesHeader, bundle: nil).instantiate(withOwner: nil, options: nil).first as? StudiesHeaderReusableView {
            self.header = headerView
        }
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.register(UINib(nibName: Cell.NibName.Study, bundle: nil), forCellWithReuseIdentifier: Cell.Identifier.Study)

        collectionView.register(UINib(nibName: Cell.NibName.StudiesHeader, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Cell.Identifier.StudiesHeader)
        
        collectionView.register(UINib(nibName: Cell.NibName.RecentStudies, bundle: nil), forCellWithReuseIdentifier: Cell.Identifier.RecentStudies)
        
        let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let study = sender as? Study , segue.identifier == "showLessons" {
            if let studyViewController = segue.destination as? StudyViewController {
                studyViewController.study = study
            }
        }
    }

    func configureHeader(_ section: Int, header: StudiesHeaderReusableView) {
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch currentSections[indexPath.section] {
        case .study(_):
            return Cell.CellSize.Study
        default:
            return CGSize(width: collectionView.frame.size.width, height: 100)
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
            return 0
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
            
            cell.titleLabel.text = study.title
            cell.coverImageView.image = nil
            if let thumbnailSource = study.image300 {
                if let url = URL(string: thumbnailSource) {
                    let width = Cell.CellSize.Study.width - Cell.CellSize.StudyImageInset.left - Cell.CellSize.StudyImageInset.right
                    let imageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSize(width: width, height: width), radius: 3, divideRadiusByImageScale: false)
                    cell.coverImageView.af_setImage(withURL: url, placeholderImage: nil, filter: imageFilter, imageTransition: UIImageView.ImageTransition.crossDissolve(0.3), runImageTransitionIfCached: false, completion: nil)
                }
            }
            return cell
        case .recentHistory:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.Identifier.RecentStudies, for: indexPath)
            
            return cell
        case .latestLessons:
            fatalError()
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
            default:
                return UICollectionReusableView()
            }
        default:
            return UICollectionReusableView()
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        switch currentSections[section] {
        case .study(let sectionIndex):
            configureHeader(sectionIndex, header: header)
            header.snp.updateConstraints { (make) -> Void in
                make.width.equalTo(collectionView.bounds.size.width)
            }
            
            header.layoutIfNeeded()
            
            return header.bounds.size
        default:
            return .zero
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
