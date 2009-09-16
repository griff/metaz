#
#  AtomicParsleyWrapper.rb
#  MetaZ
#
#  Created by Brian Olsen on 26/08/09.
#  Copyright (c) 2009 Maven-Group. All rights reserved.
#

require 'osx/cocoa'

include OSX
ns_import :MetaLoaded

class AtomicParsleyWrapper < NSObject
    def types
        NSArray.arrayWithArray ['video/mpeg4']
    end
    
    def extensions
        NSArray.arrayWithArray ['mp4', 'm4v', 'm4a']
    end
    
    def providedKeys
        keys = %w{fileName picture title artist date rating genre album albumArtist purchaseDate
                shortDescription longDescription videoType actors director producer screenwriter
                tvShow tvEpisodeID tvSeason tvEpisode tvNetwork
                sortTitle sortArtist sortAlbumArtist sortAlbum sortTvShow}
        NSArray.arrayWithArray keys
    end
    
	objc_method("loadFromFile:", [:id, :id]) do |file|
        bundle = BundleSupport.bundle_for_class(self.class)
        puts bundle
        dict = NSMutableDictionary.dictionary
        providedKeys.each{|e| dict.setObject_forKey_(NSNull.null, e) }
        dict.setObject_forKey_(File.basename(file), "fileName");
        dict.setObject_forKey_("Burn Notice", "tvShow");
        MetaLoaded.alloc.initWithFilename_dictionary_(file, dict);
    end

	objc_method("saveChanges:", [:void, :id]) do |data|
        
    end
end
