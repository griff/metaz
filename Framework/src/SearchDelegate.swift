//
//  SearchDelegate.swift
//  MetaZKit
//
//  Created by Brian Olsen on 21/02/2020.
//

import Foundation

public protocol SearchProviderDelegate {
    func reportSearch(results: [[String: Any]])
    func reportSearch(error: Error)
    func searchFinished()
}

public class DefaultSearchDelegate : SearchProviderDelegate {
    let owner : MZSearchProviderPlugin
    var timedOut : Bool = false
    var finished : Bool = false
    let actual : MZSearchProviderDelegate
    weak public var search : Search?
    
    public init(owner: MZSearchProviderPlugin, delegate: MZSearchProviderDelegate) {
        self.owner = owner
        self.actual = delegate
        DispatchQueue.main.asyncAfter(deadline: .now() + 30.0) {
            self.timeout()
        }
    }
    
    func timeout() {
        if !self.finished {
            self.timedOut = true
            self.finished = true
            if self.actual.responds(to: #selector(MZSearchProviderDelegate.searchFinished) ) {
                self.actual.searchFinished?()
            }
            self.search?.cancel()
        }
    }
    
    public func reportSearch(results: [[String : Any]]) {
        DispatchQueue.main.sync {
            let r = results.map { MZSearchResult(owner: self.owner, dictionary: $0)! }
            if !self.timedOut && !finished {
                self.actual.searchProvider(self.owner, result: r)
            }
        }
    }
    
    public func reportSearch(error: Error ) {
        if let loc_error = error as? LocalizedError {
            print("Unexpected error: \(loc_error) \(loc_error.errorDescription ?? loc_error.localizedDescription).")
        } else {
            print("Unexpected error: \(error) \(error.localizedDescription).")
        }
    }

    public func searchFinished() {
        DispatchQueue.main.sync {
            self.finished = true
            if !self.timedOut {
                if self.actual.responds(to: #selector(MZSearchProviderDelegate.searchFinished) ) {
                    self.actual.searchFinished?()
                }
            }
        }
    }
}
