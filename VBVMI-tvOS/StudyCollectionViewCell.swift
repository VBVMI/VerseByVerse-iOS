//
//  StudyCollectionViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 16/11/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

class StudyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mainImage: UIImageView!
    
    override func awakeFromNib() {
        mainImage.layer.minificationFilter = kCAFilterTrilinear
        mainImage.adjustsImageWhenAncestorFocused = true
    }
    
    override var canBecomeFocused: Bool {
        return true
    }
    
}
