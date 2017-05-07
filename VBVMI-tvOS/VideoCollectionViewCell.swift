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
        videoThumbnailImageView.image = nil
        descriptionTextView.text = nil
        titleLabel.text = nil
        descriptionTextView.alpha = 0
        
    }
 
    override var canBecomeFocused: Bool {
        return true
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        coordinator.addCoordinatedAnimations({
            
            if self.isFocused {
                let scale: CGFloat = self.isHighlighted ? 1.17 : 1.17
                self.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
                self.descriptionTextView.alpha = 1
                //self.descriptionTextView.transform = CGAffineTransform(scaleX: scale, y: scale)
            } else {
                self.contentView.transform = CGAffineTransform.identity
                self.descriptionTextView.alpha = 0
                //self.descriptionTextView.transform = CGAffineTransform.identity
            }
        }, completion: {
        })
    }
}
