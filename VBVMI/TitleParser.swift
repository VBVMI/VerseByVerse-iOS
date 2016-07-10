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
//    print("ohai \(subject)")
//}

struct TitleParser {
    
    //Typical Title = "Galatians - Lesson 16B"
    static let title = Regex("^([^-]+)(\\s*-\\s*(\\w*)\\s*(\\w*[-\\/\\s]*\\w*))?$")
    
    static func match(string: String) -> [String?]? {
        return title.match(string)?.captures
    }
    
    static func components(string: String) -> (String?, String?) {
        guard let matches = match(string) else {
            return (nil, nil)
        }
        log.warning("Matches: \(matches)")
        if matches.count == 4 {
            return (matches[0]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()), matches[3]?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        }
        return (nil, nil)
    }
    
}

