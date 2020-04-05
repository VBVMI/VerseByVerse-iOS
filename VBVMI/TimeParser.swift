//
//  TimeParser.swift
//  VBVMI
//
//  Created by Thomas Carey on 11/07/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation
import Regex

extension TimeInterval {
    
    var timeString: String {
        let totalSeconds = abs(Int(self))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds - (hours * 3600)) / 60
        let seconds = totalSeconds - (hours * 3600) - (minutes * 60)
        
        var str = self < 0 ? "-" : ""
        if hours > 0 {
            str += "\(hours):"
            str += minutes < 10 ? "0\(minutes):" : "\(minutes):"
            str += seconds < 10 ? "0\(seconds)" : "\(seconds)"
        } else {
            str += "\(minutes):"
            str += seconds < 10 ? "0\(seconds)" : "\(seconds)"
        }
        return str
    }
    
}

enum TimeParser {
    
    //Typical Title = "Galatians - Lesson 16B"
    fileprivate static let title = Regex("^(\\d*\\.?\\d*)")
    
    static func match(_ string: String) -> [String?]? {
        return title.firstMatch(in: string)?.captures
    }
    
    static func getTime(_ string: String) -> (DateComponents?) {
        guard let matches = match(string) else {
            return nil
        }
        //logger.warning("Matches: \(matches)")
        if matches.count == 1 {
            if let time = Double(matches[0]!) {
                let totalSeconds = time * 60
                let hours = floor(totalSeconds / 3600)
                let minutes = floor((totalSeconds - (hours * 3600)) / 60)
                let seconds = totalSeconds - (hours * 3600) - (minutes * 60)
                
                var dateComponents = DateComponents()
                dateComponents.hour = Int(hours)
                dateComponents.minute = Int(minutes)
                dateComponents.second = Int(seconds)
                
                return dateComponents
            }
        }
        return nil
    }
    
    
    
}
