//
//  NSDateExtensions.swift
//  VBVMI
//
//  Created by Thomas Carey on 17/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation

extension NSDate {
    static func dateFromTimeString(string: String) -> NSDate? {
        if let value = Double(string) {
            return NSDate(timeIntervalSince1970: value)
        }
        return nil
    }
}