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
    
    private let image: UIImage
    
    init(image: UIImage) {
        self.image = image
    }
    
    override func drawStatusNone() {
        let contextRect = self.bounds
        
        let context = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.setAllowsAntialiasing(true);
        context.setShouldAntialias(true);
        context.setShouldSmoothFonts(true);
        context.setFillColor(strokeColor.cgColor)
        context.setStrokeColor(strokeColor.cgColor)
        image.draw(in: contextRect)
        context.restoreGState()
    }
    
}

