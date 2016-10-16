//
//  BlurImageView.swift
//  VBVMI
//
//  Created by Thomas Carey on 5/10/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

class BlurImageView: UIImageView {

    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(visualEffectView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(visualEffectView)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    
    override func layoutSubviews() {
        super.layoutSubviews()
        visualEffectView.frame = self.bounds
    }
    
}
