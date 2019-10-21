//
//  LatestLessonsCollectionViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 18/06/18.
//  Copyright © 2018 Tom Carey. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

protocol LatestLessonCollectionViewCellDelegate : class {
    func latestLessonsDidSelect(study: Study, lesson: Lesson)
    func latestLessonsDidPlay(study: Study, lesson: Lesson)
}

class LatestLessonsCollectionViewCell: UICollectionViewCell {

    weak var delegate: LatestLessonCollectionViewCellDelegate?
    
    var latestLessons: [Lesson] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = .darkBackground
        
        collectionView.backgroundColor = .darkBackground
        contentView.backgroundColor = .darkBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "RecentStudyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StudyCell")
    }

}

extension LatestLessonsCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let lesson = latestLessons[indexPath.item]
        
        let fetchRequest = NSFetchRequest<Study>(entityName: Study.entityName())
        fetchRequest.predicate = NSPredicate(format: "%K MATCHES %@", StudyAttributes.identifier.rawValue, lesson.studyIdentifier)
        fetchRequest.fetchLimit = 1
        
        if let studies = ((try? lesson.managedObjectContext?.fetch(fetchRequest)) as [Study]??), let study = studies?.first {
            delegate?.latestLessonsDidSelect(study: study, lesson: lesson)
        }
    }
}

extension LatestLessonsCollectionViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(latestLessons.count, 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudyCell", for: indexPath) as! RecentStudyCollectionViewCell
        let lesson = latestLessons[indexPath.item]
        
        cell.delegate = self
        // We need to fetch the study that goes with it
        let fetchRequest = NSFetchRequest<Study>(entityName: Study.entityName())
        fetchRequest.predicate = NSPredicate(format: "%K MATCHES %@", StudyAttributes.identifier.rawValue, lesson.studyIdentifier)
        fetchRequest.fetchLimit = 1
        
        cell.titleLabel.text = lesson.lessonNumber
        cell.nextButton.isHidden = false
        cell.nextButton.setTitle("Play", for: .normal)
        
        if let date = lesson.postedDate {
            cell.dateLabelText = DateFormatters.dayMonthDateFormatter.string(from: date)
        }
        
        
        if let studies = ((try? lesson.managedObjectContext?.fetch(fetchRequest)) as [Study]??), let study = studies?.first {
            
            if let thumbnailSource = study.image300 {
                if let url = URL(string: thumbnailSource) {
                    let width = 92
                    let imageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSize(width: width, height: width), radius: 3, divideRadiusByImageScale: false)
                    cell.imageView.af_setImage(withURL: url, placeholderImage: nil, filter: imageFilter, imageTransition: UIImageView.ImageTransition.crossDissolve(0.3), runImageTransitionIfCached: false, completion: nil)
                }
            }
        }
        
        return cell
    }
    
    
    
}

extension LatestLessonsCollectionViewCell: RecentStudyCollectionViewCellDelegate {
    
    func didSelectNext(cell: RecentStudyCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let lesson = latestLessons[indexPath.item]
        
        let fetchRequest = NSFetchRequest<Study>(entityName: Study.entityName())
        fetchRequest.predicate = NSPredicate(format: "%K MATCHES %@", StudyAttributes.identifier.rawValue, lesson.studyIdentifier)
        fetchRequest.fetchLimit = 1
        
        if let studies = ((try? lesson.managedObjectContext?.fetch(fetchRequest)) as [Study]??), let study = studies?.first {
            cell.isLoading = true
            delegate?.latestLessonsDidPlay(study: study, lesson: lesson)
        }
    }
    
    
}
