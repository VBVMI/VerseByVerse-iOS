//
//  HideView.swift
//  VBVMI
//
//  Created by Thomas Carey on 6/02/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

@IBDesignable
class HideView: UIView {

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        StyleKit.drawHideBackground(frame: self.bounds)
    }


}
