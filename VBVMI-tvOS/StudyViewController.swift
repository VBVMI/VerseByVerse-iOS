//
//  StudyViewController.swift
//  VBVMI
//
//  Created by Thomas Carey on 26/11/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage
import AVFoundation
import AVKit
import MediaPlayer

enum LessonSection : Int {
    case completed = 0
    case incomplete = 1
}

class StudyViewController: UIViewController {

    fileprivate let lessonCellReuseIdentifier = "LessonCell"
    fileprivate let lessonDescriptionCellReuseIdentifier = "LessonDescriptionCell"
    fileprivate let filterHeaderReuseIdentifier = "FilterHeader"
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    var audioPlayer: AVPlayer?
    fileprivate var fetchedResultsController: NSFetchedResultsController<Lesson>!
    
    var study: Study! {
        didSet {
            
            self.navigationItem.title = study.title
            
            if let identifier = study?.identifier {
                APIDataManager.lessons(identifier)
            }
            
            reloadImageView()
        }
    }
    
    func reloadImageView() {
        if let thumbnailSource = study.thumbnailSource, let imageView = imageView {
            if let url = URL(string: thumbnailSource) {
                let width = 440
                let imageFilter = ScaledToSizeWithRoundedCornersFilter(size: CGSize(width: width, height: width), radius: 3, divideRadiusByImageScale: false)
                imageView.af_setImage(withURL: url, placeholderImage: nil, filter: imageFilter, imageTransition: UIImageView.ImageTransition.crossDissolve(0.3), runImageTransitionIfCached: false, completion: nil)
                //                cell.coverImageView.af_setImage(withURL: url)
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
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 90, bottom: 60, right: 0)
        reloadImageView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    fileprivate func makeMetadataItem(_ identifier: String,
                                  value: Any) -> AVMetadataItem {
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        item.extendedLanguageTag = "und"
        return item.copy() as! AVMetadataItem
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }

}

extension StudyViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let lesson = fetchedResultsController.object(at: indexPath)
        if let urlString = lesson.videoSourceURL, urlString.contains("vimeo.com"), let url = URL(string: urlString) {
            let player = AVPlayer(url: url)
            let controller = AVPlayerViewController()
            controller.delegate = self
            controller.player = player
            
            let titleItem = makeMetadataItem(AVMetadataCommonIdentifierTitle, value: lesson.title)
            
            var items = [titleItem]
            if let text = lesson.descriptionText {
                items.append(makeMetadataItem(AVMetadataCommonIdentifierDescription, value: text))
            }
            if let image = imageView.image {
                items.append(makeMetadataItem(AVMetadataCommonIdentifierArtwork, value: image))
            }
            
            player.currentItem?.externalMetadata = items
            UIApplication.shared.isIdleTimerDisabled = true
            present(controller, animated: true, completion: {
                player.play()
            })
        } else if let urlString = ResourceManager.LessonType.audio.urlString(lesson) {
            if let url = URL(string: urlString) {

                let audioPlayer = AVPlayer(url: url)
                self.audioPlayer = audioPlayer
                
                let controller = AVPlayerViewController()
                controller.delegate = self
                controller.player = audioPlayer
                
                let titleItem = makeMetadataItem(AVMetadataCommonIdentifierTitle, value: lesson.title)
                var items = [titleItem]
                if let text = lesson.descriptionText {
                    items.append(makeMetadataItem(AVMetadataCommonIdentifierDescription, value: text))
                }
                if let image = imageView.image {
                    items.append(makeMetadataItem(AVMetadataCommonIdentifierArtwork, value: image))
                }
                
                audioPlayer.currentItem?.externalMetadata = items
                
                let contentView = UIImageView()
                contentView.image = imageView.image
                contentView.contentMode = .scaleAspectFill
                let _ = controller.view
                controller.contentOverlayView?.addSubview(contentView)
                let contentImageView = UIImageView()
                contentImageView.image = imageView.image
                contentView.addSubview(contentImageView)
                contentView.alpha = 0
                
                let background = UIVisualEffectView(effect: UIBlurEffect(style: .extraDark))
                contentView.addSubview(background)
                background.snp.makeConstraints({ (make) in
                    make.edges.equalTo(contentView)
                })
                
                background.contentView.addSubview(contentImageView)
                contentImageView.snp.makeConstraints({ (make) in
                    make.centerX.equalTo(background)
                    make.top.equalTo(240)
                    make.width.height.equalTo(440)
                })
                
                contentView.snp.makeConstraints({ (make) in
                    make.edges.equalTo(0)
                })
                
                let label = UILabel()
                label.font = UIFont.preferredFont(forTextStyle: .title3)
                label.text = lesson.title
                background.contentView.addSubview(label)
                label.textAlignment = .center
                
                label.snp.makeConstraints({ (make) in
                    make.top.equalTo(contentImageView.snp.bottom).offset(40)
                    make.centerX.equalTo(contentImageView)
                    make.width.lessThanOrEqualTo(900)
                })
                label.numberOfLines = 0
                label.textColor = .white
                
                let descriptionLabel = UILabel()
                descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
                descriptionLabel.text = lesson.descriptionText
                background.contentView.addSubview(descriptionLabel)
                descriptionLabel.textAlignment = .center
                
                descriptionLabel.snp.makeConstraints({ (make) in
                    make.top.equalTo(label.snp.bottom).offset(20)
                    make.centerX.equalTo(contentImageView)
                    make.width.lessThanOrEqualTo(900)
                })
                descriptionLabel.numberOfLines = 0
                descriptionLabel.textColor = .white
                
                controller.contentOverlayView?.addSubview(contentView)
                UIApplication.shared.isIdleTimerDisabled = true
                present(controller, animated: true, completion: {
                    audioPlayer.play()
                    
                    UIView.animate(withDuration: 0.4, animations: {
                        contentView.alpha = 1
                    })
                })
                
            }
        }
    }
    
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
        
        let cell : LessonCollectionViewCell
        if let lessonNumber = lesson.lessonNumber, lessonNumber.characters.count > 0 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: lessonCellReuseIdentifier, for: indexPath) as! LessonCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: lessonDescriptionCellReuseIdentifier, for: indexPath) as! LessonCollectionViewCell
        }
        
        cell.numberLabel?.text = lesson.lessonNumber
        cell.descriptionLabel?.text = lesson.descriptionText
        
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

extension StudyViewController : AVPlayerViewControllerDelegate {
    
    
    func playerViewController(_ playerViewController: AVPlayerViewController, shouldPresent proposal: AVContentProposal) -> Bool {
        return true
    }
}
