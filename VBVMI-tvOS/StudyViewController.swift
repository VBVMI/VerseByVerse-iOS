//
//  StudyViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 26/11/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import CoreData

enum LessonSection : Int {
    case completed = 0
    case incomplete = 1
}

class StudyViewController: UIViewController {

    fileprivate let lessonCellReuseIdentifier = "LessonCell"
    fileprivate let filterHeaderReuseIdentifier = "FilterHeader"
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<Lesson>!
    
    var study: Study! {
        didSet {
            
            self.navigationItem.title = study.title
            
            if let identifier = study?.identifier {
                APIDataManager.lessons(identifier)
            }
        }
    }
    
    let sections: [LessonSection] = [.incomplete, .completed]
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFetchController()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    

}

extension StudyViewController : UICollectionViewDelegate {
    
}

extension StudyViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let fetchedSection = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return fetchedSection.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let lesson = fetchedResultsController.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: lessonCellReuseIdentifier, for: indexPath) as! LessonCollectionViewCell
        cell.numberLabel.text = lesson.lessonNumber
        cell.descriptionLabel.text = lesson.descriptionText
        
        return cell
    }
}

extension StudyViewController : NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
}
