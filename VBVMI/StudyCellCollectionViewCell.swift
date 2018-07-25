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
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var progressView: CenteredProgressView!
    @IBOutlet weak var imageClippingView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var title: String? {
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        imageClippingView.layer.cornerRadius = 5
        imageClippingView.layer.masksToBounds = true
        
        imageClippingView.backgroundColor = StyleKit.midGrey
        
        imageRightInsetContraint.constant = Cell.CellSize.StudyImageInset.right
        imageLeftInsetConstraint.constant = Cell.CellSize.StudyImageInset.left
        imageTopInsetContraint.constant = Cell.CellSize.StudyImageInset.top
        
        let highlightView = UIView()
        highlightView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        highlightView.layer.cornerRadius = 0
        self.selectedBackgroundView = highlightView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        title = nil
        coverImageView.image = nil
    }
}
