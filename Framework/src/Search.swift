//
//  Search.swift
//  MetaZKit
//
//  Created by Brian Olsen on 25/02/2020.
//

import Foundation

public enum SearchError: LocalizedError {
    case URL(String)
    case PercentEncoding(String)
    case URLSession(URL)
    case UTF8Decoding(URL)
    case JSONDecoding(URL, String)
    case JSONEncoding(URL)
    case Canceled
}

@objc open class Search : NSObject {
    public let delegate : SearchProviderDelegate
    
    private let queue : DispatchQueue
    private let cancelQueue : DispatchQueue
    
    private var _finished = false
    @objc public var isFinished : Bool {
        get {
            return self.cancelQueue.sync {
                return self._finished
            }
        }
        set {
            DispatchQueue.main.sync {
                self.willChangeValue(for: \.isFinished)
                self.cancelQueue.sync {
                    self._finished = newValue
                }
                self.didChangeValue(for: \.isFinished)
            }
        }
    }
    private var _canceled = false
    @objc public var isCanceled : Bool {
        get {
            return self.cancelQueue.sync {
                return self._canceled
            }
        }
        set {
            self.cancelQueue.sync {
                self._canceled = newValue
            }
        }
    }

    public init(delegate: SearchProviderDelegate)
    {
        self.delegate = delegate
        let t = type(of: self)
        let b = Bundle(for: t).bundleIdentifier ?? "io.metaz.MetaZKit"
        queue = DispatchQueue(label: "\(b)-\(t.className())-Queue")
        cancelQueue = DispatchQueue(label: "\(b)-\(t.className())-CancelQueue")
    }
    
    @objc public func cancel() {
        self.isCanceled = true
    }

    open func request<T>(_ url: URL, type: T.Type) throws -> T? where T: Decodable {
        if self.isCanceled {
            throw SearchError.Canceled
        }
        guard let data = try URLSession.dataSync(url: url)
            else { return nil }
        guard let data_s = String(bytes: data, encoding: .utf8)
            else { throw SearchError.UTF8Decoding(url) }
        guard let response = try? JSONDecoder().decode(type, from: data)
            else { throw SearchError.JSONDecoding(url, data_s) }
        return response
    }

    @objc public func search() {
        queue.async {
            self.sync_search()
        }
    }

    open func do_search() throws {
    }

    func sync_search() {
        do {
            try self.do_search()
        } catch SearchError.Canceled {
            NSLog("Canceled")
        } catch {
            self.delegate.reportSearch(error: error)
        }
        self.delegate.searchFinished()
        self.isFinished = true
    }
}
