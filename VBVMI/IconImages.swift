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
    
    private static let buttonFont = UIFont.fontAwesomeOfSize(20)
    
    let string: String
    let paragraphStyle = NSMutableParagraphStyle()
    let attrs : [String: AnyObject]
    let size : CGSize
    
    init(string: String) {
        self.string = string
        paragraphStyle.alignment = .Center
        attrs = [NSFontAttributeName: IconImages.buttonFont, NSParagraphStyleAttributeName: paragraphStyle]
        
        size = string.sizeWithAttributes(attrs)
    }
    
    override func drawStatusNone() {
        let contextRect = self.bounds
        let width = floor((contextRect.size.width - size.width) / CGFloat(2))
        let height = floor((contextRect.size.height - size.height) / CGFloat(2)) - 1
        let textRect = CGRectMake(contextRect.origin.x + width,
            contextRect.origin.y + height,
            size.width,
            size.height)
        var myAttrs = attrs
        let context = UIGraphicsGetCurrentContext()!
        CGContextSaveGState(context)
        CGContextSetAllowsAntialiasing(context, true);
        CGContextSetShouldAntialias(context, true);
        CGContextSetShouldSmoothFonts(context, true);
        
        myAttrs[NSForegroundColorAttributeName] = strokeColor
        string.drawWithRect(textRect, options: .UsesLineFragmentOrigin, attributes: myAttrs, context: nil)
        CGContextRestoreGState(context)
//        label.textColor = strokeColor
//        label.textAlignment = .Center
//        label.frame = bounds
//        label.drawTextInRect(bounds)
    }
    
}

