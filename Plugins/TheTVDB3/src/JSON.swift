//
//  JSON.swift
//  TheTVDB_NG
//
//  Created by Brian Olsen on 21/02/2020.
//

import Foundation


class DataJSON<T> : Codable where T: Codable {
    let data: T
}

class LinksJSON : Codable {
    let first : Int64
    let last : Int64
    let next : Int64?
    let prev : Int64?
}

class PagedDataJSON<T> : Codable where T: Codable {
    let data: T
    let links: LinksJSON
}

class SearchResultJSON : Codable {
    let id: Int64
}

class SeriesJSON : Codable {
    let id: Int64
    let seriesName : String?
    let imdbId : String
    let season : String
    let network : String
    let genre : [String]
    let rating : String?
    let overview : String?
    let slug : String
}

class EpisodeJSON : Codable {
    let id: Int64
    let airedSeason : Int
    let airedEpisodeNumber : Int
    let dvdSeason : Int?
    let dvdEpisodeNumber : Int?
    let episodeName : String?
    let firstAired : String
    let directors : [String]
    let writers : [String]
    let overview : String?
    let imdbId : String
    let contentRating : String?
    let productionCode : String
}

class ActorJSON : Codable {
    let id : Int64
    let name : String
    let role : String
    let image : String
    let sortOrder : Int
}

class RatingsInfoJSON : Codable {
    let average: Int
    let count: Int
}

class ImageJSON : Codable {
    let subKey : String
    let fileName : String
    let ratingsInfo : RatingsInfoJSON
}

enum TheTVDBError: Error {
    case MissingToken
}
