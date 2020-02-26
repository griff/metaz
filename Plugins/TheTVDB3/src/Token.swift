//
//  Token.swift
//  TheTVDB_NG
//
//  Created by Brian Olsen on 21/02/2020.
//

import Foundation
import MetaZKit

class Token {
    public static let API_KEY = "EC3E583524604886"
    
    let value: String
    let exp : Date
    
    class TokenData : Codable {
        public let exp: TimeInterval
    }
    
    public class TokenProvider {
        private let tokenQueue : DispatchQueue
        private var currentToken : Token?
        
        init() {
            tokenQueue = DispatchQueue(label: "io.metaz.TheTVDB3TokenQueue")
            if let token = UserDefaults.standard.string(forKey: "TheTVDB3") {
                currentToken = Token(token)
            }
        }
        
        public var token: Token? {
            get {
                return tokenQueue.sync {
                    if let result = currentToken, result.valid() {
                        return result
                    } else if let result = login() {
                        UserDefaults.standard.set(result.value, forKey: "TheTVDB3")
                        currentToken = result
                        return result
                    } else {
                        return nil
                    }
                }
            }
        }
        
        private func login() -> Token? {
            struct LoginResponse : Codable {
                let token: String
            }
            struct Login : Codable {
                let apiKey: String
            }
            guard let key = try? JSONEncoder().encode(Login(apiKey: Token.API_KEY))
                else { return nil }
            guard let url = URL(string: "\(Search.basePath)/login") else { return nil }
            let headers = ["Content-Type": "application/json",
                           "Accept": "application/vnd.thetvdb.v3"]
            guard let data_o = try? URLSession.dataSync(url: url,
                                                        method: "POST",
                                                        body: key,
                                                        headers: headers)
                else { return nil }
            guard let data = data_o else { return nil }
            guard let token = try? JSONDecoder().decode(LoginResponse.self, from: data)
                else { return nil }
            return Token(token.token)
        }
        
    }
    
    public static let shared = TokenProvider()
    
    init(_ key: String) {
        value = key
        if let parsed = Token.parse(token: key) {
            exp = parsed
        } else {
            exp = Date.distantPast
        }
    }
    
    static func parse(token: String) -> Date? {
        guard let data = token.split(separator: ".").safeGet(index: 1) else { return nil }
        guard let jwt = Data(base64URLEncoded: String(data)) else { return nil }
        guard let td = try? JSONDecoder().decode(TokenData.self, from: jwt) else { return nil }
        return Date(timeIntervalSince1970: td.exp)
    }
    
    func valid() -> Bool {
        return Date() < self.exp
    }
}
