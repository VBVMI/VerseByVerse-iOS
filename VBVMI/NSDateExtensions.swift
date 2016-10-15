//
//  NSDateExtensions.swift
//  VBVMI
//
//  Created by Thomas Carey on 17/03/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation

extension Date {
    static func dateFromTimeString(_ string: String) -> Date? {
        if let value = Double(string) {
            return Date(timeIntervalSince1970: value)
        }
        return nil
    }
}
