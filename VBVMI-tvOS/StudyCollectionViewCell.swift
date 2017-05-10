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
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    override func awakeFromNib() {
        mainImage.layer.minificationFilter = kCAFilterTrilinear
        mainImage.adjustsImageWhenAncestorFocused = true
        
        backgroundImage.layer.minificationFilter = kCAFilterTrilinear
        backgroundImage.adjustsImageWhenAncestorFocused = true
        
        backgroundImage.image = StyleKit.imageOfBlankBackgroundImage
        backgroundImage.layer.cornerRadius = 10
        backgroundImage.layer.masksToBounds = true
    }
    
    override var canBecomeFocused: Bool {
        return true
    }
    
    override func prepareForReuse() {
        mainTitle.text = nil
        mainImage.image = nil
        backgroundImage.isHidden = false
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        coordinator.addCoordinatedAnimations({
            
            if self.isFocused {
                let scale: CGFloat = self.isHighlighted ? 1.17 : 1.17
                self.mainTitle.transform = CGAffineTransform(scaleX: scale, y: scale)
            } else {
                self.mainTitle.transform = CGAffineTransform.identity
            }
        }, completion: {
        })
    }
    
}
