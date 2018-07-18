//
//  CenteredProgressView.swift
//  VBVMI
//
//  Created by Thomas Carey on 1/10/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

class CenteredProgressView: UIView {

    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        drawCenteredProgress(progress: progress, progressFrame: self.bounds)
    }
    
    func drawCenteredProgress(progress: CGFloat = 1, progressFrame: CGRect = CGRect(x: 0, y: 0, width: 80, height: 4)) {
        
        if  progress == 1 {
            return
        }
        //// Variable Declarations
        let progressWidth: CGFloat = (1 - progress) * (progressFrame.size.width - progressFrame.size.height) + progressFrame.size.height
        let progressOffset: CGFloat = (progressFrame.size.width - progressWidth)// / 2.0
        
        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: progressOffset, y: 0, width: progressWidth, height: progressFrame.size.height), cornerRadius: 0)//progressFrame.size.height / 2.0)
        
        StyleKit.orange.setFill()
        rectanglePath.fill()
    }


}
