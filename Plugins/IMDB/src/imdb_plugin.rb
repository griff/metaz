require 'osx/cocoa'

require 'rubygems'
require 'hpricot'

include OSX

class String
    def imdb_strip_tags
        gsub(/<\/?[^>]*>/, "")
    end
end

class IMDBScraper < NSObject

    objc_method "parseData:withQueue:delegate:", "v@:@@@" do |data,queue,delegate|
        NSLog("Testy tester")
        document = Hpricot(data.to_ruby)
        
        if !document.at("//h3[text()^='Overview']/..").nil?
            parseMovie_delegate(data,delegate)
        else
            elems = document.search('a[@href^="/title/tt"]').reject do |element|
                element.innerHTML.imdb_strip_tags.empty? ||
                element.parent.innerHTML =~ /media from/i
            end
            elems = elems.map do |element|
                id = element['href'][/\d+/]
        
                data = element.parent.innerHTML.split("<br />")
                if !data[0].nil? && !data[1].nil? && data[0] =~ /img/
                    title = data[1]
                else
                    title = data[0]
                end
        
                title = title.imdb_strip_tags
                title.gsub!(/\s+\(\d\d\d\d\)$/, '')
                
                IMDBSearchItem.new.initWithIdentifier_title_scraper_delegate_(id, title, scraper, delegate)
        
                [id, title]
            end
        end
	end
    
    objc_method "parseMovie:delegate:" do |data,delegate|
        document = Hpricot(data.to_ruby)
        
    end
end