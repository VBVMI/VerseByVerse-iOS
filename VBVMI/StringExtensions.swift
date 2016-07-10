//
//  StringExtensions.swift
//  VBVMI
//
//  Created by Thomas Carey on 20/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func color() -> UIColor {
        let hash = CGFloat(self.hash % 100) / CGFloat(100)
        return UIColor(hue: hash, saturation: 0.9, brightness: 0.7, alpha: 1.0)
    }
}
