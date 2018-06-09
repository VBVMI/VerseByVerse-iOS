//
//  RecentStudyCollectionViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 9/06/18.
//  Copyright © 2018 Tom Carey. All rights reserved.
//

import UIKit

class RecentStudyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        titleLabel.text = nil
    }
}
