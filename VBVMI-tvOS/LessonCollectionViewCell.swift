//
//  LessonCollectionViewCell.swift
//  VBVMI
//
//  Created by Thomas Carey on 29/11/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit
import ParallaxView

class LessonCollectionViewCell: ParallaxCollectionViewCell {
    
    enum LessonState {
        case focused
        case normal
        
        func backgroundColor(traitCollection: UITraitCollection) -> UIColor {
            switch self {
            case .focused:
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return StyleKit.white.withAlpha(0.1)
                default:
                    return StyleKit.darkGrey.withAlpha(0.1)
                }
            default:
                return UIColor.clear
            }
        }
        
        func textColor(traitCollection: UITraitCollection) -> UIColor {
            switch self {
            default:
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return StyleKit.white
                default:
                    return StyleKit.darkGrey
                }
            }
        }
    }
    
    var currentLessonState : LessonState {
        return isFocused ? .focused : .normal
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 10
        self.contentView.backgroundColor = currentLessonState.backgroundColor(traitCollection: self.traitCollection)
    }
    
    @IBOutlet weak var numberLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel?
    
    override var canBecomeFocused: Bool {
        return true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        numberLabel?.text = nil
        descriptionLabel?.text = nil
        
        numberLabel?.textColor = currentLessonState.textColor(traitCollection: traitCollection)
        descriptionLabel?.textColor = currentLessonState.textColor(traitCollection: traitCollection)
    }
    
    override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        super.didUpdateFocus(in: context, with: coordinator)
        
        coordinator.addCoordinatedAnimations({
            let state: LessonState = self.isFocused ? LessonState.focused : LessonState.normal
            self.contentView.backgroundColor = state.backgroundColor(traitCollection: self.traitCollection)
        }, completion: {
        })
    }
}
