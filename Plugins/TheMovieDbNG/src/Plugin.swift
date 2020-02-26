//
//  Plugin.swift
//  TheMovieDbNG
//
//  Created by Brian Olsen on 22/02/2020.
//

import Foundation
import MetaZKit


@objc(TheMovieDbNGPlugin) public class Plugin : MZSearchProviderPlugin, NSUserInterfaceValidations {
    public static let API_KEY = "a2d6b9d31ed78237618c953eb2df504d"
    public static let BasePath = "https://api.themoviedb.org/3";

    public static let TMDbMovieIdTagIdent = "tmdbMovieId"
    public static let TMDbTVIdTagIdent = "tmdbTVId"
    public static let TMDbURLTagIdent = "tmdbURL"
    
    public static let configuration = Configuration()
    
    static func remote(image: ImageJSON, sort: String = "A") throws -> RemoteData {
        let url_s = "\(Plugin.configuration.secure_base_url)original\(image.file_path)"
        guard let url = URL(string: url_s) else { throw SearchError.URL(url_s) }
        let d = RemoteData(imageUrl: url)
        d.userInfo = String(format: "%@-%5.10f", sort, image.vote_average)
        d.loadData()
        return d
    }

    private let menu : NSMenu
    
    @objc public override init(bundle: Bundle) {
        menu = NSMenu(title: "TheMovieDb")
        super.init(bundle: bundle)
    }

    @objc public override init() {
        menu = NSMenu(title: "TheMovieDb")
        super.init()
        
        var item = menu.addItem(withTitle: "View in Browser",
                                action: #selector(Plugin.view),
                                keyEquivalent: "")
        item.tag = 0
        item.target = self
        
        item = menu.addItem(withTitle: "View season in Browser",
                            action: #selector(Plugin.viewSeason(_:)),
                            keyEquivalent: "")
        item.tag = 1
        item.target = self
        
        item = menu.addItem(withTitle: "View series in Browser",
                            action: #selector(Plugin.viewSeries(_:)),
                            keyEquivalent: "")
        item.tag = 2
        item.target = self
    }
    
    override public func didLoad() {
        MZTag.register(MZIntegerTag(identifier: Plugin.TMDbMovieIdTagIdent))
        MZTag.register(MZIntegerTag(identifier: Plugin.TMDbTVIdTagIdent))
        MZTag.register(MZStringTag(identifier: Plugin.TMDbURLTagIdent))
        super.didLoad()
        
    }
    
    override public func isBuiltIn() -> Bool {
        return true
    }
    
    override public func supportedSearchTags() -> [MZTag] {
        return [
            MZTag.lookup(withIdentifier: MZVideoTypeTagIdent)!,
            MZTag.lookup(withIdentifier: MZTitleTagIdent)!,
            MZTag.lookup(withIdentifier: MZTVShowTagIdent)!,
            MZTag.lookup(withIdentifier: MZTVSeasonTagIdent)!,
            MZTag.lookup(withIdentifier: MZTVEpisodeTagIdent)!,
            MZTag.lookup(withIdentifier: MZDateTagIdent)!
        ]
    }
    
    public func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        guard let menuItem = item as? NSMenuItem else { return false }
        guard let result : MZSearchResult = menuItem.representedObject as? MZSearchResult
            else { return false }
        guard let videoType = (result.value(forKey: MZVideoTypeTagIdent) as? NSNumber)?.intValue
            else { return false }

        return videoType != MZMovieVideoType.rawValue ||
            item.tag == 0
    }

    override public func menu(for result: MZSearchResult!) -> NSMenu! {
        for item in menu.items {
            item.representedObject = result
        }
        return menu;
    }
    
    @objc public func view(_ sender: NSMenuItem!) {
        guard let result : MZSearchResult = sender.representedObject as? MZSearchResult
            else { return }
        guard let videoType = (result.value(forKey: MZVideoTypeTagIdent) as? NSNumber)?.intValue
            else { return }
        if videoType == MZMovieVideoType.rawValue {
            guard let id = (result.value(forKey: Plugin.TMDbMovieIdTagIdent) as? NSNumber)?.intValue
                else { return }

            let str = String(format:"https://www.themoviedb.org/movie/%d", id)
            guard let url = URL(string: str) else { return }
            NSWorkspace.shared.open(url)
        } else {
            guard let id = (result.value(forKey: Plugin.TMDbTVIdTagIdent) as? NSNumber)?.intValue
                else { return }
            guard let season = (result.value(forKey: MZTVSeasonTagIdent) as? NSNumber)?.intValue
                else { return }
            guard let episode = (result.value(forKey: MZTVEpisodeTagIdent) as? NSNumber)?.intValue
                else { return }

            let str = String(format:"https://www.themoviedb.org/tv/%d/season/%d/episode/%d",
                             id, season, episode)
            guard let url = URL(string: str) else { return }
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc public func viewSeason(_ sender: NSMenuItem!) {
        guard let result : MZSearchResult = sender.representedObject as? MZSearchResult
            else { return }
        guard let videoType = (result.value(forKey: MZVideoTypeTagIdent) as? NSNumber)?.intValue
            else { return }
        if videoType == MZTVShowVideoType.rawValue {
            guard let id = (result.value(forKey: Plugin.TMDbTVIdTagIdent) as? NSNumber)?.intValue
                else { return }
            guard let season = (result.value(forKey: MZTVSeasonTagIdent) as? NSNumber)?.intValue
                else { return }
            let str = String(format:"https://www.themoviedb.org/tv/%d/season/%d",
                             id,
                             season)
            guard let url = URL(string: str) else { return }
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc public func viewSeries(_ sender: NSMenuItem!) {
        guard let result : MZSearchResult = sender.representedObject as? MZSearchResult
            else { return }
        guard let videoType = (result.value(forKey: MZVideoTypeTagIdent) as? NSNumber)?.intValue
            else { return }
        if videoType == MZTVShowVideoType.rawValue {
            guard let id = (result.value(forKey: Plugin.TMDbTVIdTagIdent) as? NSNumber)?.intValue
                else { return }
            
            let str = String(format:"https://www.themoviedb.org/tv/%d", id)
            guard let url = URL(string: str) else { return }
            NSWorkspace.shared.open(url)
        }
    }
    
    override public func search(withData data: [String : Any]!,
                                delegate: MZSearchProviderDelegate!,
                                queue: OperationQueue!) -> Bool
    {
        self.cancelSearch()
        
        guard let videoType = data[MZVideoTypeTagIdent] as? NSNumber
            else { return false }
        if videoType.intValue == MZTVShowVideoType.rawValue {
            guard let show = data[MZTVShowTagIdent] as? String else { return false }
            guard let season = data[MZTVSeasonTagIdent] as? Int? else { return false }
            guard let episode = data[MZTVEpisodeTagIdent] as? Int? else { return false }
            
            let actual = DefaultSearchDelegate(owner: self, delegate: delegate)
            let search = TVSearch(show: show, delegate: actual, season: season, episode: episode)
            actual.search = search
            self.startSearch(search)
            search.search()
            //MZLoggerDebug("Sent request to TheTVDB");
            return true
        }
        if videoType.intValue == MZMovieVideoType.rawValue {
            guard let title = data[MZTitleTagIdent] as? String else { return false }
            if let date = data[MZDateTagIdent] {
                print("Found date \(date)")
            }
            
            var year : Int? = nil
            if let date = data[MZDateTagIdent] as? Date {
                let c = Calendar(identifier: .gregorian)
                year = c.component(.year, from: date)
            }
            if let y = data[MZDateTagIdent] as? Int {
                year = y
            }

            let actual = DefaultSearchDelegate(owner: self, delegate: delegate)
            let search = MovieSearch(title: title, delegate: actual, year: year)
            actual.search = search
            self.startSearch(search)
            search.search()

            return true
        }

        return false
    }
}
