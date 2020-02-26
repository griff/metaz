//
//  URLSession-dataSync.swift
//  MetaZKit
//
//  Created by Brian Olsen on 18/02/2020.
//

import Foundation

public class HTTPError : LocalizedError {
    public let url : URL
    public let statusCode : Int
    public let description : String
    
    public var errorDescription: String? {
        get {
            return "MetaZKit.HTTP(url:\(self.url.absoluteString), status: \(statusCode), \(description)"
        }
    }
    
    init(_ url: URL, _ statusCode: Int) {
        self.url = url
        self.statusCode = statusCode
        self.description = HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }
}

extension URLSession {
    public static func dataSync(url: URL,
                                method: String = "GET",
                                body: Data? = nil,
                                headers: [String: String] = [:],
                                cachePolicy: URLRequest.CachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy,
                                timeoutInterval: TimeInterval = 60.0) throws -> Data?
    {
        let semaphore = DispatchSemaphore(value: 0)
        var resultData : Data? = nil
        var resultError : Error? = nil
        URLSession.dataTask(url: url,
                            method: method,
                            body: body,
                            headers: headers,
                            cachePolicy: cachePolicy,
                            timeoutInterval: timeoutInterval) { (data, response, error) in
            resultData = data
            resultError = error
            semaphore.signal()
        }.resume()
        semaphore.wait()
        if let error = resultError as? HTTPError {
            if error.statusCode == 404 {
                return nil
            } else {
                throw error
            }
        }
        return resultData
    }
    
    public static func dataTask(url: URL,
                                method: String = "GET",
                                body: Data? = nil,
                                headers: [String: String] = [:],
                                cachePolicy: URLRequest.CachePolicy = NSURLRequest.CachePolicy.useProtocolCachePolicy,
                                timeoutInterval: TimeInterval = 60.0,
                                completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    {
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.httpMethod = method
        request.httpBody = body
        for (header, value) in headers {
            request.addValue(value, forHTTPHeaderField: header)
        }
        return URLSession.shared.dataTask(with:request) { (data, response, error) in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if let data = data {
                if statusCode == 200 {
                    completionHandler(data, response, error)
                } else if error == nil && statusCode > 0 {
                    completionHandler(nil, response, HTTPError(url, statusCode))
                } else {
                    completionHandler(nil, response, error)
                }
            } else if error == nil && statusCode > 0 {
                completionHandler(nil, response, HTTPError(url, statusCode))
            } else {
                completionHandler(nil, response, error)
            }
        }
    }
}
