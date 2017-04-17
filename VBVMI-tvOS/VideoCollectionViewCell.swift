//
//  VideoCollectionViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 15/04/17.
//  Copyright © 2017 Tom Carey. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoThumbnailImageView: UIImageView!
    @IBOutlet weak var titleBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    override func prepareForReuse() {
        descriptionTextView.text = nil
        titleLabel.text = nil
        descriptionTextView.alpha = 0
        
    }
    
}
