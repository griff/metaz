//
//  Configuration.swift
//  TheMovieDbNG
//
//  Created by Brian Olsen on 22/02/2020.
//

import Foundation

public class Configuration {
    private var current : ConfigurationJSON?
    let queue : DispatchQueue = DispatchQueue(label: "io.metaz.TheMovieDbConfigurationQueue")

    public var value: ConfigurationJSON? {
        get {
            return queue.sync {
                if let result = current {
                    return result
                } else if let result = load() {
                    current = result
                    return result
                } else {
                    return nil
                }
            }
        }
    }

    public var secure_base_url : String {
        get {
            return self.value?.images.secure_base_url ?? "https://image.tmdb.org/t/p/"
        }
    }

    private func load() -> ConfigurationJSON? {
        guard let url = URL(string: "\(Plugin.BasePath)/configuration?api_key=\(Plugin.API_KEY)")
            else { return nil }
        guard let data_o = try? URLSession.dataSync(url: url)
            else { return nil }
        guard let data = data_o else { return nil }
        return try? JSONDecoder().decode(ConfigurationJSON.self, from: data)
    }
}
