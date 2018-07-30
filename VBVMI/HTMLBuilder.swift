//
//  HTMLBuilder.swift
//  VBVMI
//
//  Created by Thomas Carey on 30/07/18.
//  Copyright © 2018 Tom Carey. All rights reserved.
//

import Foundation

class HTMLBuilder {
    static let header = try! String(contentsOf: Bundle.main.url(forResource: "Header", withExtension: "html")!, encoding: .utf8)
    
    static func attributedHeader(content: String?) -> NSAttributedString? {
        guard let content = content else { return nil }
        let html = header.replacingOccurrences(of: "BODY_CONTENT", with: content)
        
        let data = Data(html.utf8)
        do {
            let options : [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                ]
            let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            return attributedString.attributedStringByTrimmingCharactersInSet(set: .whitespacesAndNewlines)
        } catch {
            return nil
        }
    }
}


extension NSAttributedString {
    public func attributedStringByTrimmingCharactersInSet(set: CharacterSet) -> NSAttributedString {
        let invertedSet = set.inverted
        let rangeFromStart = string.rangeOfCharacter(from: invertedSet)
        let rangeFromEnd = string.rangeOfCharacter(from: invertedSet, options: .backwards)
        if let startLocation = rangeFromStart?.upperBound, let endLocation = rangeFromEnd?.lowerBound {
            let location = string.distance(from: string.startIndex, to: startLocation) - 1
            let length = string.distance(from: startLocation, to: endLocation) + 2
            let newRange = NSRange(location: location, length: length)
            return self.attributedSubstring(from: newRange)
        } else {
            return NSAttributedString()
        }
    }
}
