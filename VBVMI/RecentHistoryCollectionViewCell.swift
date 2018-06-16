//
//  RecentHistoryCollectionViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 6/06/18.
//  Copyright © 2018 Tom Carey. All rights reserved.
//

import UIKit
import AlamofireImage
import CoreData

protocol RecentHistoryCollectionViewCellDelegate : class {
    func recentHistoryDidSelect(study: Study, lesson: Lesson)
}

class RecentHistoryCollectionViewCell: UICollectionViewCell {

    weak var delegate: RecentHistoryCollectionViewCellDelegate?
    
    var recentHistory: [Study] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.backgroundColor = .darkBackground
        contentView.backgroundColor = .darkBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "RecentStudyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StudyCell")
        
    }

}

extension RecentHistoryCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let study = recentHistory[indexPath.item]
        
        let fetchRequest = NSFetchRequest<Lesson>(entityName: Lesson.entityName())
        fetchRequest.predicate = NSPredicate(format: "%K MATCHES %@ && %K != nil", LessonAttributes.studyIdentifier.rawValue, study.identifier, LessonAttributes.dateLastPlayed.rawValue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: LessonAttributes.dateLastPlayed.rawValue, ascending: false)];
        fetchRequest.fetchLimit = 1
        
        if let lessons = try? study.managedObjectContext?.fetch(fetchRequest), let lesson = lessons?.first {
            delegate?.recentHistoryDidSelect(study: study, lesson: lesson)
        }
    }
}

extension RecentHistoryCollectionViewCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentHistory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StudyCell", for: indexPath) as! RecentStudyCollectionViewCell
        let study = recentHistory[indexPath.item]
        
        cell.delegate = self
        // We need to fetch the lesson that was most recent
        let fetchRequest = NSFetchRequest<Lesson>(entityName: Lesson.entityName())
        fetchRequest.predicate = NSPredicate(format: "%K MATCHES %@ && %K != nil", LessonAttributes.studyIdentifier.rawValue, study.identifier, LessonAttributes.dateLastPlayed.rawValue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: LessonAttributes.dateLastPlayed.rawValue, ascending: false)];
        fetchRequest.fetchLimit = 1
        
        if let lessons = try? study.managedObjectContext?.fetch(fetchRequest), let lesson = lessons?.first {
            cell.titleLabel.text = lesson.lessonNumber
            
            // We need to fetch the next one :sigh:
            let nextFetchRequest = NSFetchRequest<Lesson>(entityName: Lesson.entityName())
            nextFetchRequest.predicate = NSPredicate(format: "%K MATCHES %@ && %K == %d", LessonAttributes.studyIdentifier.rawValue, study.identifier, LessonAttributes.lessonIndex.rawValue, lesson.lessonIndex + 1)
            nextFetchRequest.fetchLimit = 1
            
            if let lessons = try? study.managedObjectContext?.fetch(nextFetchRequest), let _ = lessons?.first {
                cell.nextButton.isHidden = false
            } else {
                cell.nextButton.isHidden = true
            }
        }
        
        
        
        
        
        if let thumbnailSource = study.image300 {
            if let url = URL(string: thumbnailSource) {
                let width = 92
                let imageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSize(width: width, height: width), radius: 3, divideRadiusByImageScale: false)
                cell.imageView.af_setImage(withURL: url, placeholderImage: nil, filter: imageFilter, imageTransition: UIImageView.ImageTransition.crossDissolve(0.3), runImageTransitionIfCached: false, completion: nil)
            }
        }
        
        return cell
    }
    
    
    
}

extension RecentHistoryCollectionViewCell: RecentStudyCollectionViewCellDelegate {
    
    func didSelectNext(cell: RecentStudyCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let study = recentHistory[indexPath.item]
        
        let fetchRequest = NSFetchRequest<Lesson>(entityName: Lesson.entityName())
        fetchRequest.predicate = NSPredicate(format: "%K MATCHES %@ && %K != nil", LessonAttributes.studyIdentifier.rawValue, study.identifier, LessonAttributes.dateLastPlayed.rawValue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: LessonAttributes.dateLastPlayed.rawValue, ascending: false)];
        fetchRequest.fetchLimit = 1
        
        if let lessons = try? study.managedObjectContext?.fetch(fetchRequest), let lesson = lessons?.first {
            let lessonIndex = lesson.lessonIndex + 1
            let nextFetchRequest = NSFetchRequest<Lesson>(entityName: Lesson.entityName())
            nextFetchRequest.predicate = NSPredicate(format: "%K MATCHES %@ && %K == %d", LessonAttributes.studyIdentifier.rawValue, study.identifier, LessonAttributes.lessonIndex.rawValue, lessonIndex)
            nextFetchRequest.sortDescriptors = [NSSortDescriptor(key: LessonAttributes.dateLastPlayed.rawValue, ascending: false)];
            nextFetchRequest.fetchLimit = 1
            if let nextLessons = try? study.managedObjectContext?.fetch(nextFetchRequest), let nextLesson = nextLessons?.first {
                delegate?.recentHistoryDidSelect(study: study, lesson: nextLesson)
            }
        }
    }
    
    
}
