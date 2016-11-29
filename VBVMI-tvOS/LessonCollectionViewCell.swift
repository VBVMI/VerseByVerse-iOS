//
//  LessonCollectionViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 29/11/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

class LessonCollectionViewCell: UICollectionViewCell {
    
    enum LessonState {
        case focused
        case normal
        
        var backgroundColor: UIColor {
            switch self {
            case .focused:
                return StyleKit.darkGrey
            default:
                return StyleKit.white
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .focused:
                return StyleKit.white
            default:
                return StyleKit.darkGrey
            }
        }
    }
    
    var currentLessonState : LessonState {
        return isFocused ? .focused : .normal
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 10
        self.contentView.backgroundColor = currentLessonState.backgroundColor
    }
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override var canBecomeFocused: Bool {
        return true
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        coordinator.addCoordinatedAnimations({
            let state: LessonState = self.isFocused ? LessonState.focused : LessonState.normal
            self.contentView.backgroundColor = state.backgroundColor
            self.numberLabel.textColor = state.textColor
            self.descriptionLabel.textColor = state.textColor
            if self.isFocused {
                let scale: CGFloat = self.isHighlighted ? 1.05 : 1.05
                self.contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
            } else {
                self.contentView.transform = CGAffineTransform.identity
            }
        }, completion: {
        })
    }
}
