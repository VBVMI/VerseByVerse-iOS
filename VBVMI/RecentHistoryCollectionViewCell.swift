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

class RecentHistoryCollectionViewCell: UICollectionViewCell {

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
        
        // We need to fetch the lesson that was most recent
        let fetchRequest = NSFetchRequest<Lesson>(entityName: Lesson.entityName())
        fetchRequest.predicate = NSPredicate(format: "%K MATCHES %@ && %K != nil", LessonAttributes.studyIdentifier.rawValue, study.identifier, LessonAttributes.dateLastPlayed.rawValue)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: LessonAttributes.dateLastPlayed.rawValue, ascending: false)];
        fetchRequest.fetchLimit = 1
        
        if let lessons = try? study.managedObjectContext?.fetch(fetchRequest), let lesson = lessons?.first {
            cell.titleLabel.text = lesson.lessonNumber
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
