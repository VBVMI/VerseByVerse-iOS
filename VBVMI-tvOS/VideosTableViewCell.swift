//
//  VideosTableViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 15/04/17.
//  Copyright © 2017 Tom Carey. All rights reserved.
//

import UIKit

class VideosTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var channelTitleLabel: UILabel!
    @IBOutlet weak var videosCountLabel: UILabel!
    
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
            return channelTitleLabel.text
        }
        set {
            channelTitleLabel.text = newValue
        }
    }
    
    var studyCount: String? {
        get {
            return videosCountLabel.text
        }
        set {
            videosCountLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        collectionView.register(UINib(nibName: "VideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideoCell")
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: 544, height: 306)
        flowLayout.minimumInteritemSpacing = 100
        flowLayout.minimumLineSpacing = 60
        flowLayout.scrollDirection = .horizontal
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = false
        contentView.clipsToBounds = false
        clipsToBounds = false
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override var canBecomeFocused: Bool {
        return false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        collectionView.contentOffset = CGPoint(x: -60, y: 0)
    }
}
