//
//  StudiesTableViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 27/02/17.
//  Copyright © 2017 Tom Carey. All rights reserved.
//

import UIKit

class StudiesTableViewCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var studyCountLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var collectionViewDelegate : UICollectionViewDelegate? {
        didSet {
            self.collectionView.delegate = collectionViewDelegate
        }
    }
    var collectionViewDatasource : UICollectionViewDataSource? {
        didSet {
            self.collectionView.dataSource = collectionViewDatasource
        }
    }
    
    var header: String? {
        get {
            return headerLabel.text
        }
        set {
            headerLabel.text = newValue
        }
    }
    
    var studyCount: String? {
        get {
            return studyCountLabel.text
        }
        set {
            studyCountLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(UINib(nibName: "StudyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StudyCell")
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: 300, height: 300)
        flowLayout.minimumInteritemSpacing = 100
        flowLayout.minimumLineSpacing = 60
        flowLayout.scrollDirection = .horizontal
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        collectionView.contentOffset = CGPoint(x: -60, y: 0)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override var canBecomeFocused: Bool {
        return false
    }
}
