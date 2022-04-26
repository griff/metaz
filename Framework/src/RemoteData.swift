//
//  RemoteData.swift
//  MetaZKit
//
//  Created by Brian Olsen on 22/02/2020.
//

import Foundation

fileprivate class RemoteCaching {
    // Used a session that caches its results
    static let remoteLoadSession: URLSession = {
        // Create URL Session Configuration
        let configuration = URLSessionConfiguration.default.copy() as! URLSessionConfiguration

        // Set the in-memory cache to 128 MB
        let cache = URLCache()
        cache.memoryCapacity = 128 * 1024 * 1024
        configuration.urlCache = cache

        // Define Request Cache Policy
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.urlCache = cache

        return URLSession(configuration: configuration)
    }()
}

@objc public class RemoteData : NSObject {
    private static let queue = DispatchQueue(label: "io.metaz.RemoteDataQueue")
    
    public let url : URL
    public let expectedMimeType : String

    private var _data : Data?
    @objc public var data : Data? {
        get {
            return self._data
        }
        set {
            DispatchQueue.main.sync {
                self.willChangeValue(for: \.data)
                self._data = newValue
                self.didChangeValue(for: \.data)
            }
        }
    }
    private var _loaded : Bool
    @objc public var isLoaded : Bool {
        get {
            return self._loaded
        }
        set {
            DispatchQueue.main.sync {
                self.willChangeValue(for: \.isLoaded)
                self._loaded = newValue
                self.didChangeValue(for: \.isLoaded)
            }
        }
    }
    private var _error : NSError?
    @objc public var error : NSError? {
        get {
            return self._error
        }
        set {
            DispatchQueue.main.sync {
                self.willChangeValue(for: \.error)
                self._error = newValue
                self.didChangeValue(for: \.error)
            }
        }
    }
    @objc public var userInfo : String?;

    @objc public convenience init(url: URL) {
        self.init(url: url, expectedMimeType: "*")
    }
    
    @objc public convenience init(imageUrl url: URL) {
        self.init(url: url, expectedMimeType: "image/*")
    }
    
    @objc public init(url: URL, expectedMimeType mime: String) {
        self.url = url
        self.expectedMimeType = mime
        _loaded = false
    }
    
    func report(downloadData:Data?, responseError: NSError?) {
        self.data = downloadData
        self.error = responseError
        self.isLoaded = true
    }
    
    @objc public func loadData() {
        RemoteLoader(owner: self).load()
    }
    class RemoteLoader {
        weak var data: RemoteData?
        
        init(owner: RemoteData) {
            self.data = owner
        }
        
        func load() {
            if self.data == nil {
                return
            }

            let url = self.data!.url
            let expectedMimeType = self.data!.expectedMimeType
            RemoteData.queue.async {
                var downloadData : Data?, responseError : NSError?
                let signal = DispatchSemaphore(value: 0)
                if self.data == nil {
                    return;
                }
                RemoteCaching.remoteLoadSession.dataTask(with: url) { (d, resp, err) in
                    if let error = err {
                        let info = [NSLocalizedDescriptionKey: error.localizedDescription]
                        let statusCode = (resp as? HTTPURLResponse)?.statusCode ?? 0
                        
                        responseError = NSError(domain: NetworkRequestErrorDomain,
                                                code: statusCode,
                                                userInfo: info)
                    } else if let response = resp {
                        if response.mimeType?.matches(mimeTypePattern: expectedMimeType) ?? false {
                            downloadData = d
                        } else {
                            let info = [NSLocalizedDescriptionKey: String(format: "Unsupported Media Type '%@'", response.mimeType ?? "")]
                            responseError = NSError(domain: NetworkRequestErrorDomain,
                                                    code: 415,
                                                    userInfo: info)
                        }
                    } else {
                        let info = [NSLocalizedDescriptionKey: String(format: "Unknown error with URL '%@'", url.absoluteString)]
                        responseError = NSError(domain: NetworkRequestErrorDomain,
                                                code: 416,
                                                userInfo: info)
                    }
                    signal.signal()
                    }.resume()
                signal.wait()
                if let owner = self.data {
                    owner.report(downloadData: downloadData, responseError: responseError)
                }
            }
        }
    }
}
