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

class StudiesDataSource : NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let fetchedResultsController: NSFetchedResultsController<Study>
    private let realSection : Int
    private weak var viewController: UIViewController?
    
    init(fetchedResultsController: NSFetchedResultsController<Study>, section: Int, viewController: UIViewController) {
        self.fetchedResultsController = fetchedResultsController
        self.realSection = section
        self.viewController = viewController
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
        let study = fetchedResultsController.object(at: realIndexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudyCell", for: indexPath) as! StudyCollectionViewCell
        
        cell.mainTitle.text = study.title
        
        if let thumbnailSource = study.thumbnailSource {
            if let url = URL(string: thumbnailSource) {
                let width = 300
                let imageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSize(width: width, height: width), radius: 10, divideRadiusByImageScale: false)
                cell.mainImage.af_setImage(withURL: url, placeholderImage: nil, filter: imageFilter, imageTransition: UIImageView.ImageTransition.crossDissolve(0.3), runImageTransitionIfCached: false, completion: { _ in
                    cell.backgroundImage.isHidden = true
                })
                //                cell.coverImageView.af_setImage(withURL: url)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let realIndexPath = IndexPath(item: indexPath.item, section: realSection)
        let study = fetchedResultsController.object(at: realIndexPath)
        viewController?.performSegue(withIdentifier: "showStudy", sender: study)
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

class StudiesViewController: UIViewController {

    var fetchedResultsController: NSFetchedResultsController<Study>!
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        tableView.register(UINib(nibName: "StudiesTableViewCell", bundle: nil), forCellReuseIdentifier: "StudiesCell")
        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 60, right: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let study = sender as? Study , segue.identifier == "showStudy" {
            if let studyViewController = segue.destination as? StudyViewController {
                studyViewController.study = study
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reloadData() {
        tableView.reloadData()
    }
}

extension StudiesViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 430
    }
}

extension StudiesViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else { return 0 }
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataSource = StudiesDataSource(fetchedResultsController: fetchedResultsController, section: indexPath.row, viewController: self)
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudiesCell", for: indexPath) as! StudiesTableViewCell
        
        cell.collectionViewDatasource = dataSource
        cell.collectionViewDelegate = dataSource
        
        cell.header = dataSource.title
        if let count = dataSource.numberOfStudies {
            cell.studyCount = "\(count) Studies"
        } else {
            cell.studyCount = nil
        }
        
        return cell
    }
}


extension StudiesViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        reloadData()
    }
}
