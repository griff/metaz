//
//  Normalize.swift
//  MetaZKit
//
//  Created by Brian Olsen on 02/03/2020.
//

import Foundation

public protocol Normalize {
    var isEmpty : Bool { get }
    func normalize() -> Self
}

extension String: Normalize {
    public func normalize() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension Dictionary {
    public mutating func setNormalized<V>(value: V?, forKey key: Key) where V: Normalize {
        if let actual = value {
            let v = actual.normalize()
            if !v.isEmpty {
                self[key] = v as? Value
            }
        }
    }
}
