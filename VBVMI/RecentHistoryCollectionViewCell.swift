//
//  RecentHistoryCollectionViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 6/06/18.
//  Copyright © 2018 Tom Carey. All rights reserved.
//

import UIKit

class RecentHistoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.backgroundColor = .red
    }

}
