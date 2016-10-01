//
//  ImageBlur.swift
//  VBVMI
//
//  Created by Thomas Carey on 1/10/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation
import AlamofireImage

/// Blurs an image using a `CIGaussianBlur` filter with the specified blur radius.
public struct ImageBlurFilter: ImageFilter {
    /// The blur radius of the filter.
    let blurRadius: UInt
    
    /**
     Initializes the `BlurFilter` instance with the given blur radius.
     
     - parameter blurRadius: The blur radius.
     
     - returns: The new `BlurFilter` instance.
     */
    public init(blurRadius: UInt = 10) {
        self.blurRadius = blurRadius
    }
    
    /// The filter closure used to create the modified representation of the given image.
    public var filter: Image -> Image {
        return { image in
            
            let imageToBlur = CIImage(image: image)
            let blurfilter = CIFilter(name: "CIBoxBlur")!
            blurfilter.setValue(imageToBlur, forKey: "inputImage")
            let resultImage = blurfilter.outputImage!
            let blurredImage = UIImage(CIImage: resultImage)
            return blurredImage
//            self.blurImageView.image = blurredImage
//            
//            let parameters = ["inputRadius": self.blurRadius]
//            return image.af_imageWithAppliedCoreImageFilter("CIGaussianBlur", filterParameters: parameters) ?? image
        }
    }
}
