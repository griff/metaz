//
//  MovieSearch.swift
//  TheMovieDbNG
//
//  Created by Brian Olsen on 26/02/2020.
//

import Foundation
import MetaZKit

@objc public class MovieSearch : Search {
    let title : String
    let year : Int?

    // MARK: -

    public init(title: String,
                delegate: SearchProviderDelegate,
                year: Int? = nil)
    {
        self.title = title
        self.year = year
        super.init(delegate: delegate)
    }

    // MARK: -

    func fetch(movies: String, year: Int? = nil) throws -> [Int64] {
        guard let name = movies.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            else { throw SearchError.PercentEncoding(movies) }
        var url_s = "\(Plugin.BasePath)/search/movie?api_key=\(Plugin.API_KEY)&query=\(name)"
        if let y = year {
            url_s += "&year=\(y)"
        }
        guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
        guard let response = try request(url, type: PagedResultsJSON<IdTitleJSON>.self)
            else { throw SearchError.URLSession(url) }
        return response.results.map { $0.id }
    }

    func fetch(movieInfo id: Int64) throws -> MovieDetailsJSON {
        let url_s = "\(Plugin.BasePath)/movie/\(id)?api_key=\(Plugin.API_KEY)&append_to_response=credits,images"
        guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
        guard let response = try request(url, type: MovieDetailsJSON.self)
            else { throw SearchError.URLSession(url) }
        return response
    }

    // MARK: -

    override public func do_search() throws {
        let movies = try fetch(movies: title, year: year)

        for id in movies {
            do {
                var values = [String: Any]()

                let info = try fetch(movieInfo: id)
                if info.title.normalize().isEmpty {
                    print("TheMovieDB movie \(id) has no title")
                    continue
                }
                values[MZVideoTypeTagIdent] =  NSNumber(value: MZMovieVideoType.rawValue)
                values[Plugin.TMDbMovieIdTagIdent] = info.id
                values[MZTitleTagIdent] = info.title
                values.setNormalized(value: info.imdb_id, forKey: MZIMDBTagIdent)
                values.setNormalized(value: info.tagline, forKey: MZShortDescriptionTagIdent)
                values.setNormalized(value: info.overview, forKey: MZLongDescriptionTagIdent)
                let genres = info.genres.map { $0.name }.join()
                values.setNormalized(value: genres, forKey: MZGenreTagIdent)

                if let credits = info.credits {
                    let cast = credits.cast.map { $0.name }.join()
                    values.setNormalized(value: cast, forKey: MZActorsTagIdent)
                    values.setNormalized(value: cast, forKey: MZArtistTagIdent)

                    let directors = credits.crew.filter { $0.department == "Directing" }.map{ $0.name }.join()
                    values.setNormalized(value: directors, forKey: MZDirectorTagIdent)
                    let screenwriters = credits.crew.filter { $0.department == "Writing" }.map{ $0.name }.join()
                    values.setNormalized(value: screenwriters, forKey: MZScreenwriterTagIdent)
                    let producers = credits.crew.filter { $0.department == "Production" }.map{ $0.name }.join()
                    values.setNormalized(value: producers, forKey: MZProducerTagIdent)
                }
                var posters : [RemoteData] = []
                if let images = info.images {
                    posters = try images.posters.map { try Plugin.remote(image: $0, sort: "B") }
                }
                if !posters.isEmpty {
                    values[MZPictureTagIdent] = posters
                }

                let actual = info.release_date
                var firstAired : Date?
                let f = DateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                firstAired = f.date(from: actual)
                if let date = firstAired {
                    values[MZDateTagIdent] = date
                } else {
                    NSLog("Unable to parse release date '%@'", actual);
                }
                self.delegate.reportSearch(results: [values])
            } catch SearchError.Canceled {
                throw SearchError.Canceled
            } catch {
                self.delegate.reportSearch(error: error)
            }
        }
    }
}
