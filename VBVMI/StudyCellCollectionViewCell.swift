//
//  StudyCellCollectionViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 3/02/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

class StudyCellCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageRightInsetContraint: NSLayoutConstraint!
    @IBOutlet weak var imageTopInsetContraint: NSLayoutConstraint!
    @IBOutlet weak var imageLeftInsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var progressView: CenteredProgressView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageRightInsetContraint.constant = Cell.CellSize.StudyImageInset.right
        imageLeftInsetConstraint.constant = Cell.CellSize.StudyImageInset.left
        imageTopInsetContraint.constant = Cell.CellSize.StudyImageInset.top
        
        let highlightView = UIView()
        highlightView.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.3)
        highlightView.layer.cornerRadius = 7
        self.selectedBackgroundView = highlightView
    }
    
}
