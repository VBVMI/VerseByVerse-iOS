//
//  TimeParser.swift
//  VBVMI
//
//  Created by Thomas Carey on 11/07/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation
import Regex

enum TimeParser {
    
    //Typical Title = "Galatians - Lesson 16B"
    private static let title = Regex("^(\\d*\\.?\\d*)")
    
    static func match(string: String) -> [String?]? {
        return title.match(string)?.captures
    }
    
    static func getTime(string: String) -> (NSDateComponents?) {
        guard let matches = match(string) else {
            return nil
        }
        //log.warning("Matches: \(matches)")
        if matches.count == 1 {
            if let time = Double(matches[0]!) {
                let totalSeconds = time * 60
                let hours = floor(totalSeconds / 3600)
                let minutes = floor((totalSeconds - (hours * 3600)) / 60)
                let seconds = totalSeconds - (hours * 3600) - (minutes * 60)
                
                let dateComponents = NSDateComponents()
                dateComponents.hour = Int(hours)
                dateComponents.minute = Int(minutes)
                dateComponents.second = Int(seconds)
                
                return dateComponents
            }
        }
        return nil
    }
    
}