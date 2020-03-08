//
//  JSON.swift
//  TheMovieDbNG
//
//  Created by Brian Olsen on 22/02/2020.
//

import Foundation

public class ConfigurationJSON : Codable {
    let images : ConfigurationImagesJSON
}

public class ConfigurationImagesJSON : Codable {
    let base_url : String
    let secure_base_url : String
    let backdrop_sizes : [String]
    let logo_sizes : [String]
    let poster_sizes : [String]
    let profile_sizes : [String]
    let still_sizes : [String]
}

class PagedResultsJSON<T> : Codable where T: Codable {
    let page : Int
    let total_pages : Int
    let total_results : Int
    let results: [T]
}

class ResultsJSON<T> : Codable where T: Codable {
    let results: [T]
}

class IdNameJSON : Codable {
    let id : Int64
    let name : String
}

class IdTitleJSON : Codable {
    let id : Int64
    let title : String
}

class SeasonJSON : Codable {
    let id : Int64
    let episode_count : Int
    let name : String
    let season_number : Int
    let poster_path : String?
}

class TVShowSearchJSON : Codable {
    let id : Int64
    let name : String
    let overview : String
    let first_air_date : String
}

class ImageJSON : Codable {
    let file_path : String
    let vote_average : Double
    let height : Int
    let width : Int
    let iso_639_1 : String?
}

class ImagesJSON : Codable {
    let backdrops : [ImageJSON]?
    let posters : [ImageJSON]
}

class CastJSON : Codable {
    let name : String
    let character : String
}

class CrewJSON : Codable {
    let name : String
    let department : String
}

class CreditsJSON : Codable {
    let cast : [CastJSON]
    let crew : [CrewJSON]
}

class RatingJSON : Codable {
    let iso_3166_1 : String
    let rating : String
}

class TVShowDetailsJSON : Codable {
    let id : Int64
    let name : String
    let overview : String
    let first_air_date : String
    let genres : [IdNameJSON]
    let networks : [IdNameJSON]
    let seasons : [SeasonJSON]
    let content_ratings : ResultsJSON<RatingJSON>?
    let credits : CreditsJSON?
    let images : ImagesJSON?
}

class EpisodeJSON : Codable {
    let id : Int64
    let air_date : String?
    let name : String
    let episode_number : Int
    let overview : String
    let production_code : String
    let crew : [CrewJSON]
    let credits : CreditsJSON?
    let images : ImagesJSON?
}

class SeasonDetailsJSON : Codable {
    let id : Int64
    let name : String
    let season_number : Int
    let poster_path : String?
    let overview : String
    let episodes : [EpisodeJSON]
    let credits : CreditsJSON?
    let images : ImagesJSON?
}

class MovieDetailsJSON : Codable {
    let id: Int64
    let title: String
    let original_title: String
    let original_language: String
    let tagline: String?
    let imdb_id: String?
    let release_date: String
    let overview : String?
    let genres : [IdNameJSON]
    let credits : CreditsJSON?
    let images : ImagesJSON?
}
