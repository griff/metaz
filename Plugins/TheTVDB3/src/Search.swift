//
//  TheTVDB_NGSearch.swift
//  TheTVDB_NG
//
//  Created by Brian Olsen on 17/02/2020.
//

import Foundation
import MetaZKit


@objc public class Search: MetaZKit.Search {
    public static let basePath = "https://api.thetvdb.com";
    public static let baseURL = URL(string: "https://api.thetvdb.com")!
    public static let imageBasePath = "https://artworks.thetvdb.com/banners/"
    
    let tvShow : String
    let season : Int?
    let episode : Int?


    class TokenData : Codable {
        public let exp: TimeInterval
    }
    

    private var token : Token? {
        get {
            return Token.shared.token
        }
    }
    
    // MARK: -
    
    public init(show: String,
                delegate: SearchProviderDelegate,
                season: Int? = nil,
                episode: Int? = nil)
    {
        self.tvShow = show
        self.season = season
        self.episode = episode
        super.init(delegate: delegate)
    }
    
    // MARK: -
    
    override public func request<T>(_ url: URL, type: T.Type) throws -> T? where T: Decodable {
        if self.isCanceled {
            throw SearchError.Canceled
        }
        guard let token = self.token else { throw TheTVDBError.MissingToken }
        let headers = ["Accept": "application/vnd.thetvdb.v3",
                       "Accept-Language": "en",
                       "Authorization": "Bearer \(token.value)"]
        guard let data = try URLSession.dataSync(url: url,
                                                 headers: headers)
            else { return nil }
        guard let data_s = String(bytes: data, encoding: .utf8)
            else { throw SearchError.UTF8Decoding(url) }
        guard let response = try? JSONDecoder().decode(type, from: data)
            else { throw SearchError.JSONDecoding(url, data_s) }
        return response
    }

    // MARK: -

    func fetch(series: String) throws -> [Int64] {
        guard let name = series.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else { throw SearchError.PercentEncoding(series) }
        let url_s = "\(Search.basePath)/search/series?name=\(name)"
        guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
        guard let response = try request(url, type: DataJSON<[SearchResultJSON]>.self)
            else { throw SearchError.URLSession(url) }
        return response.data.map { $0.id }
    }
    
    func fetch(seriesInfo id: Int64) throws -> SeriesJSON {
        let url_s = "\(Search.basePath)/series/\(id)"
        guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
        guard let response = try request(url, type: DataJSON<SeriesJSON>.self)
            else { throw SearchError.URLSession(url) }
        return response.data
    }

    func fetch(actors id: Int64) throws -> [ActorJSON] {
        let url_s = "\(Search.basePath)/series/\(id)/actors"
        guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
        guard let response = try request(url, type: DataJSON<[ActorJSON]>.self)
            else { return [] }
        return response.data
    }
    
    func fetch(episodes id: Int64, page: Int64 = 1) throws -> PagedDataJSON<[EpisodeJSON]>? {
        var url_s : String;
        if let season = self.season {
            url_s = "\(Search.basePath)/series/\(id)/episodes/query?page=\(page)&airedSeason=\(season)"
            if let episode = self.episode {
                url_s += "&airedEpisode=\(episode)"
            }
        } else {
            url_s = "\(Search.basePath)/series/\(id)/episodes?page=\(page)"
        }
        guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
        return try request(url, type: PagedDataJSON<[EpisodeJSON]>.self)
    }

    func fetch(posters id: Int64) throws -> [RemoteData] {
        let url_s = "\(Search.basePath)/series/\(id)/images/query?keyType=poster"
        guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
        guard let response = try request(url, type: DataJSON<[ImageJSON]>.self)
            else { return [] }
        
        return try response.data.map {(image) throws in
            let url_s = "\(Search.imageBasePath)\(image.fileName)"
            guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
            let data = RemoteData(url: url)
            data.userInfo = String(format: "B-%d", image.ratingsInfo.average);
            data.loadData()
            return data
        }
    }

    func fetch(seasonBanners id: Int64) throws -> [Int: [RemoteData]] {
        var url_s = "\(Search.basePath)/series/\(id)/images/query?keyType=season"
        if let season = self.season {
            url_s += "&subKey=\(season)"
        }
        guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
        guard let response = try request(url, type: DataJSON<[ImageJSON]>.self)
            else { return [:] }

        let values : [(String, RemoteData)] = try response.data.map {(image) throws in
            let url_s = "\(Search.imageBasePath)\(image.fileName)"
            guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
            let data = RemoteData(url: url)
            data.userInfo = String(format: "A-%@-%d", image.subKey, image.ratingsInfo.average)
            data.loadData()
            return (image.subKey, data)
        }
        if let season = self.season {
            return [season: values.map {
                let (_, image) = $0
                return image
            }]
        } else {
            var result = [Int: [RemoteData]]()
            for (key_s, image) in values {
                if let key = Int(key_s) {
                    let values = result[key]
                    if var arr = values {
                        arr.append(image)
                        result[key] = arr
                    } else {
                        result[key] = [image]
                    }
                }
            }
            return result
        }
    }

    // MARK: -

    func merge(episodes: [EpisodeJSON],
               with values: [String: Any],
               posters: [RemoteData],
               seasonBanners: [Int: [RemoteData]]) -> [[String: Any]]
    {
        return episodes.compactMap {(episode) in
            var result = values
            guard let episodeName = episode.episodeName
                else { return nil }
            if episodeName.normalize().isEmpty {
                return nil
            }
            result[Plugin.TVDBEpisodeIdTagIdent] = episode.id
            result[MZTVSeasonTagIdent] = episode.airedSeason
            result[MZTVEpisodeTagIdent] = episode.airedEpisodeNumber
            result[MZDVDSeasonTagIdent] = episode.dvdSeason
            result[MZDVDEpisodeTagIdent] = episode.dvdEpisodeNumber
            result[MZTitleTagIdent] = episodeName
            result.setNormalized(value: episode.imdbId, forKey: MZIMDBTagIdent)
            result.setNormalized(value: episode.overview, forKey: MZShortDescriptionTagIdent)
            result.setNormalized(value: episode.overview, forKey: MZLongDescriptionTagIdent)
            result.setNormalized(value: episode.directors.join(), forKey: MZDirectorTagIdent)
            result.setNormalized(value: episode.writers.join(), forKey: MZScreenwriterTagIdent)
            result.setNormalized(value: episode.productionCode, forKey: MZTVEpisodeIDTagIdent)

            if episode.firstAired != "" {
                var firstAired : Date?
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                firstAired = f.date(from: episode.firstAired)
                if let date = firstAired {
                    result[MZDateTagIdent] = date
                } else {
                    NSLog("Unable to parse release date '%@'", episode.firstAired);
                }
            }
            var images : [RemoteData] = []
            if let banners = seasonBanners[episode.airedSeason] {
                images = banners
            }
            images.append(contentsOf: posters)
            if !images.isEmpty {
                result[MZPictureTagIdent] = images
            }

            return result
        }
    }
    
    // MARK: -
    
    override public func do_search() throws {
        let series = try fetch(series: tvShow)
        
        for id in series {
            do {
                var values = [String: Any]()
                
                let info = try fetch(seriesInfo: id)
                values[MZVideoTypeTagIdent] =  NSNumber(value: MZTVShowVideoType.rawValue)
                values[Plugin.TVDBSeriesIdTagIdent] = info.id
                values[Plugin.TVDBSeriesSlugTagIdent] = info.slug
                guard let seriesName = info.seriesName else { continue }
                if seriesName.normalize().isEmpty {
                    continue
                }
                values[MZTVShowTagIdent] = seriesName
                values[MZArtistTagIdent] = seriesName
                values.setNormalized(value: info.imdbId, forKey: MZIMDBTagIdent)
                values.setNormalized(value: info.network, forKey: MZTVNetworkTagIdent)
                values.setNormalized(value: info.overview, forKey: MZShortDescriptionTagIdent)
                values.setNormalized(value: info.overview, forKey: MZLongDescriptionTagIdent)
                values.setNormalized(value: info.genre.join(), forKey: MZGenreTagIdent)

                let ratingTag = MZTag.lookup(withIdentifier: MZRatingTagIdent)!
                let ratingNr : NSNumber? = ratingTag.object(from: info.rating) as? NSNumber? ?? nil
                if let rating = ratingNr {
                    if rating.intValue != MZNoRating.rawValue {
                        values[MZRatingTagIdent] = ratingNr
                    }
                }

                let actors = try fetch(actors: id)
                let actor_names = actors.map { $0.name }.join()
                values.setNormalized(value: actor_names, forKey: MZActorsTagIdent)
                
                guard let episodes = try fetch(episodes: id) else { continue }
                let posters = try fetch(posters: id)
                let seasonBanners = try fetch(seasonBanners: id)

                let result = merge(episodes: episodes.data,
                                   with: values,
                                   posters: posters,
                                   seasonBanners: seasonBanners)
                self.delegate.reportSearch(results: result)
                if episodes.links.last > 1 {
                    for page in 2...episodes.links.last {
                        guard let episodes = try fetch(episodes: id, page: page)
                             else { continue }
                        let result = merge(episodes: episodes.data,
                                           with: values,
                                           posters: posters,
                                           seasonBanners: seasonBanners)
                        self.delegate.reportSearch(results: result)
                    }
                }
            } catch SearchError.Canceled {
                throw SearchError.Canceled
            } catch {
                self.delegate.reportSearch(error: error)
            }
        }
    }
}
