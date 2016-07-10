//
//  DotView.swift
//  VBVMI
//
//  Created by Thomas Carey on 21/05/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import UIKit

@IBDesignable
class DotView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    private func configure() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    override func drawRect(rect: CGRect) {
        if self.bounds.size.width != 3 {
            print("Bounds: \(rect)")
        }
       StyleKit.drawDotView(frame: self.bounds)
    }
 
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 3, height: 3)
    }
}
