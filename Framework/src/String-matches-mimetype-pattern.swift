//
//  String-matches-mimetype-pattern.swift
//  MetaZKit
//
//  Created by Brian Olsen on 22/02/2020.
//

import Foundation

extension String {
    public func matches(mimeTypePattern pattern: String) -> Bool {
        if pattern == "*" {
            return true
        }
        var pattern = pattern
        
        var range : Range<String.Index> = self.startIndex ..< self.endIndex
        var length = pattern.endIndex
        if pattern.hasSuffix("/*") {
            length = pattern.index(before: length)
            pattern = String(pattern.prefix(upTo: length))
            if length < range.upperBound {
                range = self.startIndex ..< length
            }
        } else if range.upperBound != length {
            return false
        }
        return self.compare(pattern,
                            options: [.caseInsensitive, .literal],
                            range: range,
                            locale: nil) == .orderedSame
    }
}
