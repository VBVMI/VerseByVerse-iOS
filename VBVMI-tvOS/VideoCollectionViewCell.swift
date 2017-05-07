//
//  VideoCollectionViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 15/04/17.
//  Copyright © 2017 Tom Carey. All rights reserved.
//

import UIKit
import ParallaxView

protocol VideoCollectionViewCellDelegate: NSObjectProtocol {
    func videoCollectionViewCellDidLongPress(cell: VideoCollectionViewCell)
}

class VideoCollectionViewCell: ParallaxCollectionViewCell {
    
    @IBOutlet weak var videoThumbnailImageView: UIImageView!
    @IBOutlet weak var titleBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    weak var delegate : VideoCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        self.addGestureRecognizer(longPress)
    
    }
    
    func longPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            delegate?.videoCollectionViewCellDidLongPress(cell: self)
        }
    }
    
    override func prepareForReuse() {
        videoThumbnailImageView.image = nil
        descriptionTextView.text = nil
        titleLabel.text = nil
        descriptionTextView.alpha = 0
        delegate = nil
    }
 
    override var canBecomeFocused: Bool {
        return true
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        coordinator.addCoordinatedAnimations({
            if self.isFocused {
                self.descriptionTextView.alpha = 1
            } else {
                self.descriptionTextView.alpha = 0
            }
        }, completion: {
        })
    }
}
