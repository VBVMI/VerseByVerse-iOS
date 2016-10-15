//
//  DepletionProgressView.swift
//  VBVMI
//
//  Created by Thomas Carey on 1/10/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation

class DepletionProgressView : UIView {
    
    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        StyleKit.drawPieProgressDeplete(frame: self.bounds, progress: progress)
    }
}
