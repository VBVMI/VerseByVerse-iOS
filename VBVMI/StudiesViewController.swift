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
    private var fetchedResultsController: NSFetchedResultsController!
    private var aboutActionsController: AboutActionsController!
    
    private var header : StudiesHeaderReusableView!
    
    private func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest(entityName: Study.entityName())
        let context = ContextCoordinator.sharedInstance.managedObjectContext
        fetchRequest.entity = Study.entity(context)
        let identifierSort = NSSortDescriptor(key: StudyAttributes.studyIndex.rawValue, ascending: true)
        let bibleStudySort = NSSortDescriptor(key: StudyAttributes.bibleIndex.rawValue, ascending: true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: StudyAttributes.studyType.rawValue, ascending: true), bibleStudySort, identifierSort]
        fetchRequest.shouldRefreshRefetchedObjects = true
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: StudyAttributes.studyType.rawValue, cacheName: nil)
        
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.collectionView.reloadData()
            }
        } catch let error {
            log.error("Error fetching: \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let headerView = UINib(nibName: Cell.NibName.StudiesHeader, bundle: nil).instantiateWithOwner(nil, options: nil).first as? StudiesHeaderReusableView {
            self.header = headerView
        }
        // Do any additional setup after loading the view, typically from a nib.
        collectionView.registerNib(UINib(nibName: Cell.NibName.Study, bundle: nil), forCellWithReuseIdentifier: Cell.Identifier.Study)

        collectionView.registerNib(UINib(nibName: Cell.NibName.StudiesHeader, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Cell.Identifier.StudiesHeader)
        
        let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        
        setupFetchedResultsController()
        
        // Setup about Menu
        self.aboutActionsController = AboutActionsController(presentingController: self)
        self.navigationItem.leftBarButtonItem = self.aboutActionsController.barButtonItem
    }
    
    override func viewDidLayoutSubviews() {
        let insets = UIEdgeInsetsMake(topLayoutGuide.length, 0, bottomLayoutGuide.length, 0)
        collectionView.contentInset = insets
        collectionView.scrollIndicatorInsets = insets
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let study = sender as? Study where segue.identifier == "showLessons" {
            if let studyViewController = segue.destinationViewController as? StudyViewController {
                studyViewController.study = study
            }
        }
    }

    func configureHeader(section: Int, header: StudiesHeaderReusableView) {
        if let numberOfItems = self.fetchedResultsController.sections?[section].numberOfObjects where numberOfItems > 0 {
            if numberOfItems == 1 {
                header.subtitleLabel.text = "\(numberOfItems) Study"
            } else {
                header.subtitleLabel.text = "\(numberOfItems) Studies"
            }
            header.subtitleLabel.hidden = false
            
            let indexPath = NSIndexPath(forRow: 0, inSection: section)
            if let item = fetchedResultsController.objectAtIndexPath(indexPath) as? Study {
                header.mainTitleLabel.text = item.studyType
                header.mainTitleLabel.hidden = false
            } else {
                header.mainTitleLabel.hidden = true
            }
            
            
        } else {
            header.subtitleLabel.hidden = true
            header.mainTitleLabel.hidden = true
        }
    }

}

extension StudiesViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return Cell.CellSize.Study
    }
}

extension StudiesViewController : UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let _ = collectionView.cellForItemAtIndexPath(indexPath) as? StudyCellCollectionViewCell {
            let study = fetchedResultsController.objectAtIndexPath(indexPath)
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
            self.performSegueWithIdentifier("showLessons", sender: study)
        }
        
    }
    
    
}

extension StudiesViewController : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        if sections.count <= section {
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let study = fetchedResultsController.objectAtIndexPath(indexPath) as? Study else {
            return UICollectionViewCell()
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Cell.Identifier.Study, forIndexPath: indexPath) as! StudyCellCollectionViewCell
        
        cell.isAccessibilityElement = true
        
        cell.accessibilityHint = "\(study.title)"
        
        cell.titleLabel.text = study.title
        cell.coverImageView.image = nil
        if let thumbnailSource = study.thumbnailSource {
            if let url = NSURL(string: thumbnailSource) {
                let width = Cell.CellSize.Study.width - Cell.CellSize.StudyImageInset.left - Cell.CellSize.StudyImageInset.right
                let imageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSizeMake(width, width), radius: 3, divideRadiusByImageScale: false)
                cell.coverImageView.af_setImageWithURL(url, placeholderImage: nil, filter: imageFilter, imageTransition: UIImageView.ImageTransition.CrossDissolve(0.3), runImageTransitionIfCached: false, completion: nil)
//                cell.coverImageView.af_setImageWithURL(url)
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Cell.Identifier.StudiesHeader, forIndexPath: indexPath) as! StudiesHeaderReusableView
            configureHeader(indexPath.section, header: header)
            return header
        default:
            return UICollectionReusableView()
        }
       
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        configureHeader(section, header: header)
        header.snp_updateConstraints { (make) -> Void in
            make.width.equalTo(collectionView.bounds.size.width)
        }
        
        header.layoutIfNeeded()
        
        
        return header.bounds.size
    }
}

extension StudiesViewController : NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        log.debug("Controller didChangeContent")
        self.collectionView.reloadData()
    }
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        log.debug("Will change content")
    }
    
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        log.debug("Controller didChangeSection")
//    }
//    
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        log.debug("Controller didChangeObject")
//    }
//    
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        log.debug("Controller will change content")
//    }
}
