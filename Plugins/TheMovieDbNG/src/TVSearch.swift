//
//  Search.swift
//  TheMovieDbNG
//
//  Created by Brian Olsen on 22/02/2020.
//

import Foundation
import MetaZKit

@objc public class TVSearch : Search {
    let tvShow : String
    let season : Int?
    let episode : Int?

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

    func fetch(series: String) throws -> [Int64] {
        guard let name = series.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else { throw SearchError.PercentEncoding(series) }
        let url_s = "\(Plugin.BasePath)/search/tv?api_key=\(Plugin.API_KEY)&query=\(name)"
        guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
        guard let response = try request(url, type: PagedResultsJSON<IdNameJSON>.self)
            else { throw SearchError.URLSession(url) }
        return response.results.map { $0.id }
    }

    func fetch(seriesInfo id: Int64) throws -> TVShowDetailsJSON {
        let url_s = "\(Plugin.BasePath)/tv/\(id)?api_key=\(Plugin.API_KEY)&append_to_response=content_ratings,credits,images"
        guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
        guard let response = try request(url, type: TVShowDetailsJSON.self)
            else { throw SearchError.URLSession(url) }
        return response
    }

    func fetch(series id: Int64, season: Int) throws -> SeasonDetailsJSON {
        let url_s = "\(Plugin.BasePath)/tv/\(id)/season/\(season)?api_key=\(Plugin.API_KEY)&append_to_response=credits,images"
        guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
        guard let response = try request(url, type: SeasonDetailsJSON.self)
            else { throw SearchError.URLSession(url) }
        return response
    }

    func fetch(series id: Int64, season: Int, episode: Int) throws -> EpisodeJSON {
        let url_s = "\(Plugin.BasePath)/tv/\(id)/season/\(season)/episode/\(episode)?api_key=\(Plugin.API_KEY)&append_to_response=credits,images"
        guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
        guard let response = try request(url, type: EpisodeJSON.self)
            else { throw SearchError.URLSession(url) }
        return response
    }

    // MARK: -

    func merge(episodes: [EpisodeJSON],
               with values: [String: Any],
               posters: [RemoteData],
               seasonBanners: [RemoteData]) -> [[String: Any]]
    {
        return episodes.map {(episode) in
            var result = values
            result[MZTVEpisodeTagIdent] = episode.episode_number
            result.setNormalized(value: episode.name, forKey: MZTitleTagIdent)
            //result[MZIMDBTagIdent] = episode.imdbId
            result.setNormalized(value: episode.overview, forKey: MZShortDescriptionTagIdent)
            result.setNormalized(value: episode.overview, forKey: MZLongDescriptionTagIdent)

            let director = episode.crew.filter { $0.department == "Directing" }.map{ $0.name }.join()
            result.setNormalized(value: director, forKey: MZDirectorTagIdent)

            let screenwriter = episode.crew.filter { $0.department == "Writing" }.map{ $0.name }.join()
            result.setNormalized(value: screenwriter, forKey: MZScreenwriterTagIdent)
            let producers = episode.crew.filter { $0.department == "Production" }.map{ $0.name }.join()
            result.setNormalized(value: producers, forKey: MZProducerTagIdent)
            result.setNormalized(value: episode.production_code, forKey: MZTVEpisodeIDTagIdent)

            if let actual = episode.air_date {
                var firstAired : Date?
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                firstAired = f.date(from: actual)
                if let date = firstAired {
                    result[MZDateTagIdent] = date
                } else {
                    NSLog("Unable to parse release date '%@'", actual);
                }
            }
            var images : [RemoteData] = seasonBanners
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
                if info.name.normalize().isEmpty {
                    print("TheMovieDB TV Show has \(id) no name")
                    continue
                }
                values[MZVideoTypeTagIdent] = NSNumber(value: MZTVShowVideoType.rawValue) 
                values[Plugin.TMDbTVIdTagIdent] = info.id
                values[MZTVShowTagIdent] = info.name
                values[MZArtistTagIdent] = info.name
                //values[MZIMDBTagIdent] = info.imdbId
                let networks = info.networks.map { $0.name }.join()
                values.setNormalized(value: networks, forKey: MZTVNetworkTagIdent)
                values.setNormalized(value: info.overview, forKey: MZShortDescriptionTagIdent)
                values.setNormalized(value: info.overview, forKey: MZLongDescriptionTagIdent)
                let genres = info.genres.map { $0.name }.join()
                values.setNormalized(value: genres, forKey: MZGenreTagIdent)

                let ratingTag = MZTag.lookup(withIdentifier: MZRatingTagIdent)!
                if let content_ratings = info.content_ratings {
                    for rating in content_ratings.results {
                        let ratingNr : NSNumber? = ratingTag.object(from: rating.rating) as? NSNumber? ?? nil
                        if let rating = ratingNr {
                            if rating.intValue != MZNoRating.rawValue {
                                values[MZRatingTagIdent] = ratingNr
                                break
                            }
                        }
                    }
                }

                if let credits = info.credits {
                    let actors = credits.cast.map { $0.name }.join()
                    values.setNormalized(value: actors, forKey: MZActorsTagIdent)
                }
                var posters : [RemoteData] = []
                if let images = info.images {
                    posters = try images.posters.map { try Plugin.remote(image: $0, sort: "B") }
                }

                var seasons : [Int] = []
                if let season = self.season {
                    seasons = [season]
                } else {
                    seasons = info.seasons.map { $0.season_number }
                }
                for season in seasons {
                    let seasonInfo = try fetch(series: id, season: season)
                    var seasonBanners : [RemoteData] = []
                    if let banners = seasonInfo.images {
                        seasonBanners = try banners.posters.map { try Plugin.remote(image: $0) }
                    }
                    values[MZTVSeasonTagIdent] = season
                    if let credits = seasonInfo.credits {
                        let directors = credits.crew.filter { $0.department == "Directing" }.map{ $0.name }.join()
                        values.setNormalized(value: directors, forKey: MZDirectorTagIdent)
                        let screenwriters = credits.crew.filter { $0.department == "Writing" }.map{ $0.name }.join()
                        values.setNormalized(value: screenwriters, forKey: MZScreenwriterTagIdent)
                        let producers = credits.crew.filter { $0.department == "Production" }.map{ $0.name }.join()
                        values.setNormalized(value: producers, forKey: MZProducerTagIdent)
                    }

                    var episodes = seasonInfo.episodes
                    if let episode = self.episode {
                        episodes = episodes.filter { $0.episode_number == episode }
                    }
                    let results = merge(episodes: episodes,
                                       with: values,
                                       posters: posters,
                                       seasonBanners: seasonBanners)
                    self.delegate.reportSearch(results: results)
                }
            } catch SearchError.Canceled {
                throw SearchError.Canceled
            } catch {
                self.delegate.reportSearch(error: error)
            }
        }
    }
}
