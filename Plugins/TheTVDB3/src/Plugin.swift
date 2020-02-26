//
//  Plugin.swift
//  TheTVDB_NG
//
//  Created by Brian Olsen on 19/02/2020.
//

import Foundation
import MetaZKit


@objc(TheTVDB3Plugin) public class Plugin : MZSearchProviderPlugin {
    public static let TVDBSeriesIdTagIdent = "tvdbSeriesId"
    public static let TVDBSeriesSlugTagIdent = "tvdbSeriesSlug"
    public static let TVDBSeasonIdTagIdent  = "tvdbSeasonId"
    public static let TVDBEpisodeIdTagIdent = "tvdbEpisodeId"

    private var menu : NSMenu

    @objc public override init(bundle: Bundle) {
        menu = NSMenu(title: "TheTVDB")
        super.init(bundle: bundle)
    }

    @objc public override init() {
        menu = NSMenu(title: "TheTVDB")
        super.init()
        var item = menu.addItem(withTitle: "View episode in Browser",
                                 action: #selector(Plugin.view),
                                 keyEquivalent: "")
        item.target = self
        item = menu.addItem(withTitle: "View season in Browser",
                             action: #selector(Plugin.viewSeason(_:)),
                             keyEquivalent: "")
        item.target = self
        item = menu.addItem(withTitle: "View series in Browser",
                             action: #selector(Plugin.viewSeries(_:)),
                             keyEquivalent: "")
        item.target = self
    }
        
    override public func didLoad() {
        MZTag.register(MZStringTag(identifier: Plugin.TVDBSeriesSlugTagIdent))
        MZTag.register(MZIntegerTag(identifier: Plugin.TVDBSeriesIdTagIdent))
        //MZTag.register(MZIntegerTag(identifier: Plugin.TVDBSeasonIdTagIdent))
        MZTag.register(MZIntegerTag(identifier: Plugin.TVDBEpisodeIdTagIdent))
        super.didLoad()

    }
    
    override public func isBuiltIn() -> Bool {
        return true
    }
    
    override public func supportedSearchTags() -> [MZTag] {
        return [
            MZTag.lookup(withIdentifier: MZVideoTypeTagIdent)!,
            MZTag.lookup(withIdentifier: MZVideoTypeTagIdent)!,
            MZTag.lookup(withIdentifier: MZTVShowTagIdent)!,
            MZTag.lookup(withIdentifier: MZTVSeasonTagIdent)!,
            MZTag.lookup(withIdentifier: MZTVEpisodeTagIdent)!
        ]
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
        guard let slug = (result.value(forKey: Plugin.TVDBSeriesSlugTagIdent) as? String)?
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            else { return }
        guard let episodeId = (result.value(forKey: Plugin.TVDBEpisodeIdTagIdent) as? NSNumber)?.intValue
            else { return }
        
        let str = String(format:"https://thetvdb.com/series/%@/episodes/%d",
                        slug,
                        episodeId)
        guard let url = URL(string: str) else { return }
        NSWorkspace.shared.open(url)
    }

    @objc public func viewSeason(_ sender: NSMenuItem!) {
        guard let result : MZSearchResult = sender.representedObject as? MZSearchResult
            else { return }
        guard let slug = (result.value(forKey: Plugin.TVDBSeriesSlugTagIdent) as? String)?
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            else { return }
        guard let season = (result.value(forKey: MZTVSeasonTagIdent) as? NSNumber)?.intValue
            else { return }
        let str = String(format:"https://thetvdb.com/series/%@/seasons/official/%d",
                         slug,
                         season)
        guard let url = URL(string: str) else { return }
        NSWorkspace.shared.open(url)
    }

    @objc public func viewSeries(_ sender: NSMenuItem!) {
        guard let result : MZSearchResult = sender.representedObject as? MZSearchResult
            else { return }
        guard let slug = (result.value(forKey: Plugin.TVDBSeriesSlugTagIdent) as? String)?
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
            else { return }
        let str = String(format:"https://thetvdb.com/series/%@",
                         slug)
        guard let url = URL(string: str) else { return }
        NSWorkspace.shared.open(url)
    }
    
    override public func search(withData data: [String : Any]!,
                                delegate: MZSearchProviderDelegate!,
                                queue: OperationQueue!) -> Bool
    {
        self.cancelSearch()
        
        guard let videoType = data[MZVideoTypeTagIdent] as? NSNumber
            else { return false }
        if videoType.intValue != MZTVShowVideoType.rawValue {
            return false
        }
        guard let show = data[MZTVShowTagIdent] as? String else { return false }
        guard let season = data[MZTVSeasonTagIdent] as? Int? else { return false }
        guard let episode = data[MZTVEpisodeTagIdent] as? Int? else { return false }
        
        let actual = DefaultSearchDelegate(owner: self, delegate: delegate)
        let search = Search(show: show, delegate: actual, season: season, episode: episode)
        actual.search = search
        self.startSearch(search)
        search.search()
        //MZLoggerDebug("Sent request to TheTVDB");
        
        return true
    }
}
