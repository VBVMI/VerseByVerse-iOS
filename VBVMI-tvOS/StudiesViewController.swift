//
//  FirstViewController.swift
//  VBVMI-tvOS
//
//  Created by Thomas Carey on 17/10/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import CoreData
import SnapKit
import AlamofireImage

struct StudiesCollectionManager {
    let newTestamentCollectionView : UICollectionView
    let oldTestamentCollectionView : UICollectionView
    let singleTeachingCollectionView : UICollectionView
    let topicalSeriesCollectionView : UICollectionView
    
    let allCollectionViews : [UICollectionView]
    
    init() {
        newTestamentCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        oldTestamentCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        singleTeachingCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        topicalSeriesCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        allCollectionViews = [newTestamentCollectionView, oldTestamentCollectionView, singleTeachingCollectionView, topicalSeriesCollectionView]
        allCollectionViews.forEach { (collectionView) in
            collectionView.register(UINib(nibName: "StudyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StudyCell")
            let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            flowLayout.itemSize = CGSize(width: 300, height: 300)
            flowLayout.minimumInteritemSpacing = 100
            flowLayout.minimumLineSpacing = 60
            flowLayout.scrollDirection = .horizontal
            collectionView.contentInset = UIEdgeInsets(top: 60, left: 60, bottom: 160 + 20, right: 60)
        }
    }
}

class StudiesViewController: UIViewController {

    var fetchedResultsController: NSFetchedResultsController<Study>!
    
    let collectionManager = StudiesCollectionManager()
    
    fileprivate func configureFetchRequest(_ fetchRequest: NSFetchRequest<Study>) {
        
        let identifierSort = NSSortDescriptor(key: StudyAttributes.studyIndex.rawValue, ascending: true)
        let bibleStudySort = NSSortDescriptor(key: StudyAttributes.bibleIndex.rawValue, ascending: true)
        
        var sortDescriptors : [NSSortDescriptor] = [NSSortDescriptor(key: StudyAttributes.studyType.rawValue, ascending: true)]
        
        sortDescriptors.append(contentsOf: [bibleStudySort, identifierSort])
        
        fetchRequest.sortDescriptors = sortDescriptors
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest = NSFetchRequest<Study>(entityName: Study.entityName())
        let context: NSManagedObjectContext = ContextCoordinator.sharedInstance.managedObjectContext!
        fetchRequest.entity = Study.entity(managedObjectContext: context)
        
        configureFetchRequest(fetchRequest)
        
        fetchRequest.shouldRefreshRefetchedObjects = true
        fetchedResultsController = NSFetchedResultsController<Study>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: StudyAttributes.studyType.rawValue, cacheName: nil)
        
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
        
        let scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        let contentView = UIView()
        
        let collectionHeight = 300 + 60 + 20
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.height.equalTo(collectionHeight * collectionManager.allCollectionViews.count + 60)
            make.width.equalTo(view)
        }
        
        
        collectionManager.allCollectionViews.enumerated().forEach { (offset, collectionView) in
            collectionView.delegate = self
            collectionView.dataSource = self
            
            contentView.addSubview(collectionView)
            
            collectionView.snp.makeConstraints({ (make) in
                make.top.equalTo(contentView).offset(collectionHeight * offset)
                make.left.right.equalTo(contentView)
                make.height.equalTo(collectionHeight + 160)
            })
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func reloadData() {
        collectionManager.allCollectionViews.forEach({ $0.reloadData() })
    }
}

extension StudiesViewController: UICollectionViewDelegate {
    
}

extension StudiesViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let realSection = collectionManager.allCollectionViews.index(of: collectionView) else {
            return 0
        }
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        if sections.count <= section {
            return 0
        }
        let sectionInfo = sections[realSection]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudyCell", for: indexPath) as! StudyCollectionViewCell
        let realSection = collectionManager.allCollectionViews.index(of: collectionView)!
        let realIndexPath = IndexPath(item: indexPath.item, section: realSection)
        let study = fetchedResultsController.object(at: realIndexPath)

        cell.mainImage.image = nil
        if let thumbnailSource = study.thumbnailSource {
            if let url = URL(string: thumbnailSource) {
                let width = 300
                let imageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSize(width: width, height: width), radius: 10, divideRadiusByImageScale: false)
                cell.mainImage.af_setImage(withURL: url, placeholderImage: nil, filter: imageFilter, imageTransition: UIImageView.ImageTransition.crossDissolve(0.3), runImageTransitionIfCached: false, completion: nil)
                //                cell.coverImageView.af_setImage(withURL: url)
            }
        }
        
        return cell
    }
    
}

extension StudiesViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reloadData()
    }
}
