//
//  IconLayer.swift
//  VBVMI
//
//  Created by Thomas Carey on 29/02/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation
import ACPDownload

class IconImages : ACPStaticImages {
    
    fileprivate static let buttonFont = UIFont.fontAwesomeOfSize(20)
    
    let string: String
    let paragraphStyle = NSMutableParagraphStyle()
    let attrs : [String: AnyObject]
    let size : CGSize
    
    init(string: String) {
        self.string = string
        paragraphStyle.alignment = .center
        attrs = [NSFontAttributeName: IconImages.buttonFont, NSParagraphStyleAttributeName: paragraphStyle]
        
        size = string.size(attributes: attrs)
    }
    
    override func drawStatusNone() {
        let contextRect = self.bounds
        let width = floor((contextRect.size.width - size.width) / CGFloat(2))
        let height = floor((contextRect.size.height - size.height) / CGFloat(2)) - 1
        let textRect = CGRect(x: contextRect.origin.x + width,
            y: contextRect.origin.y + height,
            width: size.width,
            height: size.height)
        var myAttrs = attrs
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.setAllowsAntialiasing(true);
        context.setShouldAntialias(true);
        context.setShouldSmoothFonts(true);
        
        myAttrs[NSForegroundColorAttributeName] = strokeColor
        string.draw(with: textRect, options: .usesLineFragmentOrigin, attributes: myAttrs, context: nil)
        context.restoreGState()
//        label.textColor = strokeColor
//        label.textAlignment = .Center
//        label.frame = bounds
//        label.drawTextInRect(bounds)
    }
    
}

