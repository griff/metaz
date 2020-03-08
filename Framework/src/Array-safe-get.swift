//
//  File.swift
//  MetaZKit
//
//  Created by Brian Olsen on 22/02/2020.
//

import Foundation

extension Array {
    // Safely lookup an index that might be out of bounds,
    // returning nil if it does not exist
    public func safeGet(index: Int) -> Element? {
        if 0 <= index && index < count {
            return self[index]
        } else {
            return nil
        }
    }
}

extension Array where Element: CustomStringConvertible {
    public func join(sep: String = ", ") -> String {
        return self.reduce("", { $0 + ($0.isEmpty ? "" : sep) + String(describing:$1) })
    }
}
