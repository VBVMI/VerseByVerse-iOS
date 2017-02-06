//
//  TitleParser.swift
//  VBVMI
//
//  Created by Thomas Carey on 27/02/16.
//  Copyright © 2016 Tom Carey. All rights reserved.
//

import Foundation
import Regex

//let greeting = Regex("hello (world|universe|swift)")
//
//if let subject = greeting.match("hello swift")?.captures[0] {
//    logger.info("🍕ohai \(subject)")
//}

struct TitleParser {
    
    //Typical Title = "Galatians - Lesson 16B"
    fileprivate static let title = Regex("^([^-]+)(\\s*-\\s*(\\w*)\\s*(\\w*[-\\/\\s]*\\w*))?$")
    
    static func match(_ string: String) -> [String?]? {
        return title.match(string)?.captures
    }
    
    static func components(_ string: String) -> (String?, String?) {
        guard let matches = match(string) else {
            return (nil, nil)
        }
        //logger.warning("Matches: \(matches)")
        if matches.count == 4 {
            return (matches[0]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), matches[3]?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        }
        return (nil, nil)
    }
    
}

