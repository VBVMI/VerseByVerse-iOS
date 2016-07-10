//
//  TagLabel.swift
//  VBVMI
//
//  Created by Thomas Carey on 26/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation
import UIKit
import UIImage_Color

class TopicAttachment : NSTextAttachment {
    var topic: Topic?
}

class TopicButton: UIButton {
    
    override dynamic var tintColor: UIColor! {
        get {
            return super.tintColor
        }
        set {
            super.tintColor = newValue
            configureColor()
        }
    }
    
    private func configureColor() {
        self.setTitleColor(tintColor, forState: .Normal)
        self.setTitleColor(StyleKit.white, forState: .Highlighted)
        self.setTitleColor(StyleKit.white, forState: .Selected)
        self.layer.borderColor = tintColor.CGColor
        let image = StyleKit.imageOfTopicLabelBackground.cl_changeColor(tintColor).resizableImageWithCapInsets(UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
        self.setBackgroundImage(image, forState: .Highlighted)
        self.setBackgroundImage(image, forState: .Selected)
    }
    
    var text: String? {
        didSet {
            self.setTitle(text, forState: .Normal)
            self.invalidateIntrinsicContentSize()
        }
    }
    
    var topic: Topic? {
        didSet {
            self.text = topic?.name
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
        self.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
        self.layer.cornerRadius = 2
//        self.layer.masksToBounds = true
        self.contentEdgeInsets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}