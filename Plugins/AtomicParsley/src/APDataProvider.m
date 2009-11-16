//
//  APMetaProvider.m
//  MetaZ
//
//  Created by Brian Olsen on 23/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "APDataProvider.h"
#import "APWriteManager.h"

@interface APDataProvider (Private)

+ (NSString *)launchPath;
+ (NSString *)launchChapsPath;
- (NSString *)launchPath;
- (NSString *)launchChapsPath;

@end

@implementation APDataProvider

+ (void)removeChaptersFromFile:(NSString *)filePath
{
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:[self launchChapsPath]];
    [task setArguments:[NSArray arrayWithObjects:@"-r", filePath, nil]];
    [task launch];
    [task waitUntilExit];
    [task release];
}

+ (void)importChaptersFromFile:(NSString *)chaptersFile toFile:(NSString *)filePath
{
    
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:[self launchChapsPath]];
    [task setArguments:[NSArray arrayWithObjects:@"--import", chaptersFile, filePath, nil]];
    [task launch];
    [task waitUntilExit];
    [task release];
}

+ (NSString *)launchPath
{
    NSBundle* myBundle = [NSBundle bundleForClass:[self class]];
    return [myBundle pathForResource:@"AtomicParsley32" ofType:nil];
}

+ (NSString *)launchChapsPath
{
    NSBundle* myBundle = [NSBundle bundleForClass:[self class]];
    return [myBundle pathForResource:@"mp4chaps" ofType:nil];
}


- (id)init
{
    self = [super init];
    if(self)
    {
        writes = [[NSMutableArray alloc] init];
        types = [[NSArray alloc] initWithObjects:
            @"public.mpeg-4", @"com.apple.quicktime-movie",
            @"com.apple.protected-mpeg-4-video", nil];
        tags = [[MZTag allKnownTags] retain];
        NSArray* readmapkeys = [NSArray arrayWithObjects:
            @"©nam", @"©ART", @"©day",
            //@"com.apple.iTunes;iTunEXTC", @"©gen",
            @"©alb", @"aART", @"purd", @"desc",
            @"ldes",
            //@"stik",
            @"tvsh", @"tven",
            @"tvsn", @"tves", @"tvnn", @"purl",
            @"egid", @"catg", @"keyw", @"rtng",
            @"pcst", @"cprt", @"©grp", @"©too",
            @"©cmt", @"pgap", @"cpil", @"sonm",
            @"soar", @"soaa", @"soal",
            @"sosn", nil];
        NSArray* readmapvalues = [NSArray arrayWithObjects:
            MZTitleTagIdent, MZArtistTagIdent, MZDateTagIdent,
            //MZRatingTagIdent, MZGenreTagIdent,
            MZAlbumTagIdent, MZAlbumArtistTagIdent, MZPurchaseDateTagIdent, MZShortDescriptionTagIdent,
            MZLongDescriptionTagIdent,
            //MZVideoTypeTagIdent,
            MZTVShowTagIdent, MZTVEpisodeIDTagIdent,
            MZTVSeasonTagIdent, MZTVEpisodeTagIdent, MZTVNetworkTagIdent, MZFeedURLTagIdent,
            MZEpisodeURLTagIdent, MZCategoryTagIdent, MZKeywordTagIdent, MZAdvisoryTagIdent,
            MZPodcastTagIdent, MZCopyrightTagIdent, MZGroupingTagIdent, MZEncodingToolTagIdent,
            MZCommentTagIdent, MZGaplessTagIdent, MZCompilationTagIdent, MZSortTitleTagIdent,
            MZSortArtistTagIdent, MZSortAlbumArtistTagIdent, MZSortAlbumTagIdent,
            MZSortTVShowTagIdent,nil];
        read_mapping = [[NSDictionary alloc]
            initWithObjects:readmapvalues
                    forKeys:readmapkeys];


        NSArray* writemapkeys = [NSArray arrayWithObjects:
            MZTitleTagIdent, MZArtistTagIdent, MZDateTagIdent,
            //MZRatingTagIdent,
            MZGenreTagIdent,
            MZAlbumTagIdent, MZAlbumArtistTagIdent, MZPurchaseDateTagIdent, MZShortDescriptionTagIdent,
            MZLongDescriptionTagIdent,
            //MZVideoTypeTagIdent,
            MZTVShowTagIdent, MZTVEpisodeIDTagIdent,
            MZTVSeasonTagIdent, MZTVEpisodeTagIdent, MZTVNetworkTagIdent, MZFeedURLTagIdent,
            MZEpisodeURLTagIdent, MZCategoryTagIdent, MZKeywordTagIdent, MZAdvisoryTagIdent,
            MZPodcastTagIdent, MZCopyrightTagIdent, MZGroupingTagIdent, MZEncodingToolTagIdent,
            MZCommentTagIdent, MZGaplessTagIdent, MZCompilationTagIdent,
            nil];
            //MZSortTitleTagIdent, MZSortArtistTagIdent, MZSortAlbumArtistTagIdent,
            //MZSortAlbumTagIdent, MZSortTVShowTagIdent,nil];
        NSArray* writemapvalues = [NSArray arrayWithObjects:
            @"title", @"artist", @"year",
            //@"contentRating",
            @"genre",
            @"album", @"albumArtist", @"purchaseDate", @"description",
            @"longDescription",
            //@"stik",
            @"TVShowName", @"TVEpisode",
            @"TVSeasonNum", @"TVEpisodeNum", @"TVNetwork", @"podcastURL",
            @"podcastGUID",@"category", @"keyword", @"advisory",
            @"podcastFlag", @"copyright", @"grouping", @"encodingTool",
            @"comment", @"gapless", @"compilation",
            nil];
            //@"sonm", @"soar", @"soaa",
            //@"soal", @"sosn", nil];
        write_mapping = [[NSDictionary alloc]
            initWithObjects:writemapvalues
                    forKeys:writemapkeys];
                    
        NSArray* ratingkeys = [NSArray arrayWithObjects:
        // US
            [NSNumber numberWithInt:MZ_G_Rating],
            [NSNumber numberWithInt:MZ_PG_Rating],
            [NSNumber numberWithInt:MZ_PG13_Rating],
            [NSNumber numberWithInt:MZ_R_Rating],
            [NSNumber numberWithInt:MZ_NC17_Rating],
            [NSNumber numberWithInt:MZ_Unrated_Rating],
    
        //US-TV
            [NSNumber numberWithInt:MZ_TVY7_Rating],
            [NSNumber numberWithInt:MZ_TVY_Rating],
            [NSNumber numberWithInt:MZ_TVG_Rating],
            [NSNumber numberWithInt:MZ_TVPG_Rating],
            [NSNumber numberWithInt:MZ_TV14_Rating],
            [NSNumber numberWithInt:MZ_TVMA_Rating],
    
        // UK
            [NSNumber numberWithInt:MZ_U_Rating],
            [NSNumber numberWithInt:MZ_Uc_Rating],
            [NSNumber numberWithInt:MZ_PG_UK_Rating],
            [NSNumber numberWithInt:MZ_12_UK_Rating],
            [NSNumber numberWithInt:MZ_12A_Rating],
            [NSNumber numberWithInt:MZ_15_UK_Rating],
            [NSNumber numberWithInt:MZ_18_UK_Rating],
            [NSNumber numberWithInt:MZ_E_UK_Rating],
            [NSNumber numberWithInt:MZ_Unrated_UK_Rating],

        // DE
            [NSNumber numberWithInt:MZ_FSK0_Rating],
            [NSNumber numberWithInt:MZ_FSK6_Rating],
            [NSNumber numberWithInt:MZ_FSK12_Rating],
            [NSNumber numberWithInt:MZ_FSK16_Rating],
            [NSNumber numberWithInt:MZ_FSK18_Rating],
    
        // IE
            [NSNumber numberWithInt:MZ_G_IE_Rating],
            [NSNumber numberWithInt:MZ_PG_IE_Rating],
            [NSNumber numberWithInt:MZ_12_IE_Rating],
            [NSNumber numberWithInt:MZ_15_IE_Rating],
            [NSNumber numberWithInt:MZ_16_Rating],
            [NSNumber numberWithInt:MZ_18_IE_Rating],
            [NSNumber numberWithInt:MZ_Unrated_IE_Rating],
    
        // IE-TV
            [NSNumber numberWithInt:MZ_GA_Rating],
            [NSNumber numberWithInt:MZ_Ch_Rating],
            [NSNumber numberWithInt:MZ_YA_Rating],
            [NSNumber numberWithInt:MZ_PS_Rating],
            [NSNumber numberWithInt:MZ_MA_IETV_Rating],
            [NSNumber numberWithInt:MZ_Unrated_IETV_Rating],
    
        // CA
            [NSNumber numberWithInt:MZ_G_CA_Rating],
            [NSNumber numberWithInt:MZ_PG_CA_Rating],
            [NSNumber numberWithInt:MZ_14_Rating],
            [NSNumber numberWithInt:MZ_18_CA_Rating],
            [NSNumber numberWithInt:MZ_R_CA_Rating],
            [NSNumber numberWithInt:MZ_E_CA_Rating],
            [NSNumber numberWithInt:MZ_Unrated_CA_Rating],
    
        // CA-TV
            [NSNumber numberWithInt:MZ_C_CATV_Rating],
            [NSNumber numberWithInt:MZ_C8_Rating],
            [NSNumber numberWithInt:MZ_G_CATV_Rating],
            [NSNumber numberWithInt:MZ_PG_CATV_Rating],
            [NSNumber numberWithInt:MZ_14Plus_Rating],
            [NSNumber numberWithInt:MZ_18Plus_Rating],
            [NSNumber numberWithInt:MZ_Unrated_CATV_Rating],
    
        // AU
            [NSNumber numberWithInt:MZ_E_AU_Rating],
            [NSNumber numberWithInt:MZ_G_AU_Rating],
            [NSNumber numberWithInt:MZ_PG_AU_Rating],
            [NSNumber numberWithInt:MZ_M_AU_Rating],
            [NSNumber numberWithInt:MZ_MA15Plus_AU_Rating],
            [NSNumber numberWithInt:MZ_R18Plus_Rating],
            [NSNumber numberWithInt:MZ_Unrated_AU_Rating],
    
        // AU-TV
            [NSNumber numberWithInt:MZ_P_Rating],
            [NSNumber numberWithInt:MZ_C_AUTV_Rating],
            [NSNumber numberWithInt:MZ_G_AUTV_Rating],
            [NSNumber numberWithInt:MZ_PG_AUTV_Rating],
            [NSNumber numberWithInt:MZ_M_AUTV_Rating],
            [NSNumber numberWithInt:MZ_MA15Plus_AUTV_Rating],
            [NSNumber numberWithInt:MZ_AV15Plus_Rating],
            [NSNumber numberWithInt:MZ_Unrated_AUTV_Rating],
    
        // NZ
            [NSNumber numberWithInt:MZ_E_NZ_Rating],
            [NSNumber numberWithInt:MZ_G_NZ_Rating],
            [NSNumber numberWithInt:MZ_PG_NZ_Rating],
            [NSNumber numberWithInt:MZ_M_NZ_Rating],
            [NSNumber numberWithInt:MZ_R13_Rating],
            [NSNumber numberWithInt:MZ_R15_Rating],
            [NSNumber numberWithInt:MZ_R16_Rating],
            [NSNumber numberWithInt:MZ_R18_Rating],
            [NSNumber numberWithInt:MZ_R_NZ_Rating],
            [NSNumber numberWithInt:MZ_Unrated_NZ_Rating],
    
        // NZ-TV
            [NSNumber numberWithInt:MZ_G_NZTV_Rating],
            [NSNumber numberWithInt:MZ_PGR_Rating],
            [NSNumber numberWithInt:MZ_AO_Rating],
            [NSNumber numberWithInt:MZ_Unrated_NZTV_Rating],
            nil];
        NSArray* ratingvalues = [NSArray arrayWithObjects:
        // US
            @"mpaa|G|100|",
            @"mpaa|PG|200|",
            @"mpaa|PG-13|300|",
            @"mpaa|R|400|",
            @"mpaa|NC-17|500|",
            @"mpaa|UNRATED|600|",
            
        // US-TV
            @"us-tv|TV-Y7|100|",
            @"us-tv|TV-Y|200|",
            @"us-tv|TV-G|300|",
            @"us-tv|TV-PG|400|",
            @"us-tv|TV-14|500|",
            @"us-tv|TV-MA|600|",
            
        // UK
            @"uk-movie|U|100|",
            @"uk-movie|Uc|150|",
            @"uk-movie|PG|200|",
            @"uk-movie|12|300|",
            @"uk-movie|12A|325|",
            @"uk-movie|15|350|",
            @"uk-movie|18|400|",
            @"uk-movie|E|600|",
            @"uk-movie|UNRATED|900|",
            
        // DE
            @"de-movie|FSK 0|100|",
            @"de-movie|FSK 6|200|",
            @"de-movie|FSK 12|300|",
            @"de-movie|FSK 16|400|",
            @"de-movie|FSK 18|500|",
        
        // IE
            @"ie-movie|G|100|",
            @"ie-movie|PG|200|",
            @"ie-movie|12|300|",
            @"ie-movie|15|350|",
            @"ie-movie|16|375|",
            @"ie-movie|18|400|",
            @"ie-movie|UNRATED|900|",
            
        // IE-TV
            @"ie-tv|GA|100|",
            @"ie-tv|Ch|200|",
            @"ie-tv|YA|400|",
            @"ie-tv|PS|500|",
            @"ie-tv|MA|600|",
            @"ie-tv|UNRATED|900|",
            
        // CA
            @"ca-movie|G|100|",
            @"ca-movie|PG|200|",
            @"ca-movie|14|325|",
            @"ca-movie|18|400|",
            @"ca-movie|R|500|",
            @"ca-movie|E|600|",
            @"ca-movie|UNRATED|900|",
        
        // CA-TV
            @"ca-tv|C|100|",
            @"ca-tv|C8|200|",
            @"ca-tv|G|300|",
            @"ca-tv|PG|400|",
            @"ca-tv|14+|500|",
            @"ca-tv|18+|600|",
            @"ca-tv|UNRATED|900|",
            
        // AU
            @"au-movie|E|0|",
            @"au-movie|G|100|",
            @"au-movie|PG|200|",
            @"au-movie|M|350|",
            @"au-movie|MA 15+|375|",
            @"au-movie|R18+|400|",
            @"au-movie|UNRATED|900|",
            
        // AU-TV
            @"au-tv|P|100|",
            @"au-tv|C|200|",
            @"au-tv|G|300|",
            @"au-tv|PG|400|",
            @"au-tv|M|500|",
            @"au-tv|MA 15+|550|",
            @"au-tv|AV 15+|575|",
            @"au-tv|UNRATED|900|",
        
        // NZ
            @"nz-movie|E|0|",
            @"nz-movie|G|100|",
            @"nz-movie|PG|200|",
            @"nz-movie|M|300|",
            @"nz-movie|R13|325|",
            @"nz-movie|R15|350|",
            @"nz-movie|R16|375|",
            @"nz-movie|R18|400|",
            @"nz-movie|R|500",
            @"nz-movie|R|UNRATED|900",
        
        // NZ-TV
            @"nz-tv|G|200|",
            @"nz-tv|PGR|400|",
            @"nz-tv|AO|600|",
            @"nz-tv|UNRATED|900|",
            nil];
        rating_write = [[NSDictionary alloc]
            initWithObjects:ratingvalues
                    forKeys:ratingkeys];
        rating_read = [[NSDictionary alloc]
            initWithObjects:ratingkeys
                    forKeys:ratingvalues];

    }
    return self;
}

- (void)dealloc
{
    [writes release];
    [types release];
    [tags release];
    [read_mapping release];
    [write_mapping release];
    [rating_read release];
    [rating_write release];
    [super dealloc];
}

- (NSString *)identifier
{
    return @"org.maven-group.MetaZ.AtomicParsleyPlugin";
}

-(NSArray *)types
{
    return types;
}

-(NSArray *)providedTags
{
    return tags;
}

- (MetaLoaded *)loadFromFile:(NSString *)fileName
{
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:[self launchPath]];
    [task setArguments:[NSArray arrayWithObjects:fileName, @"-t", nil]];
    NSPipe* out = [NSPipe pipe];
    [task setStandardOutput:out];
    [task launch];
    
    NSData* data = [[out fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    [task release];
    NSString* str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSArray* atoms = [str componentsSeparatedByString:@"Atom \""];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:[atoms count]];
    for(NSString* atom in atoms)
    {
        NSRange split = [atom rangeOfString:@"\" contains: "];
        if(split.location == NSNotFound)
            continue;
        NSString* type = [atom substringToIndex:split.location];
        NSString* content = [[atom substringFromIndex:split.location+split.length] 
                stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [dict setObject:content forKey:type];
    }
    
    NSMutableDictionary* retdict = [NSMutableDictionary dictionaryWithCapacity:[tags count]];
    // Initialize a null value for all known keys
    for(MZTag* tag in tags)
        [retdict setObject:[NSNull null] forKey:[tag identifier]];

    // Store real parsed values using a simple key -> key mapping
    for(NSString* map in [read_mapping allKeys])
    {
        NSString* tagId = [read_mapping objectForKey:map];
        MZTag* tag = [MZTag tagForIdentifier:tagId];
        NSString* value = [dict objectForKey:map];
        NSLog(@"%@ %@", tagId, value);
        if(value)
            [retdict setObject:[tag convertObjectForStorage:[tag objectFromString:value]] forKey:tagId];
    }
    
    // Special genre handling
    NSString* genre = [dict objectForKey:@"gnre"];
    if(!genre)
        genre = [dict objectForKey:@"©gen"]; 
    if(genre)
    {
        NSLog(@"Genre %@", genre);
        [retdict setObject:genre forKey:MZGenreTagIdent];
    }
    
    // Special rating handling
    NSString* rating = [dict objectForKey:@"com.apple.iTunes;iTunEXTC"];
    if(rating)
    {
        NSLog(@"Rating %@", rating);
        id rate = [rating_read objectForKey:rating];
        if(rate)
            [retdict setObject:rate forKey:MZRatingTagIdent];
    }
    
    // Special video type handling (stik)
    NSString* stik = [dict objectForKey:@"stik"];
    if(stik)
    {
        MZVideoType stikNo = MZUnsetVideoType;
        if([stik isEqualToString:@"Movie"])
            stikNo = MZMovieVideoType;
        else if([stik isEqualToString:@"Normal"])
            stikNo = MZNormalVideoType;
        else if([stik isEqualToString:@"Audiobook"])
            stikNo = MZAudiobookVideoType;
        else if([stik isEqualToString:@"Whacked Bookmark"])
            stikNo = MZWhackedBookmarkVideoType;
        else if([stik isEqualToString:@"Music Video"])
            stikNo = MZMusicVideoType;
        else if([stik isEqualToString:@"Short Film"])
            stikNo = MZShortFilmVideoType;
        else if([stik isEqualToString:@"TV Show"])
            stikNo = MZTVShowVideoType;
        else if([stik isEqualToString:@"Booklet"])
            stikNo = MZBookletVideoType;
        if(stikNo!=MZUnsetVideoType)
        {
            MZTag* tag = [MZTag tagForIdentifier:MZVideoTypeTagIdent];
            [retdict setObject:[tag nullConvertValueToObject:&stikNo]
                        forKey:MZVideoTypeTagIdent];
        }
    }
    
    // Special image handling
    NSString* covr = [dict objectForKey:@"covr"];
    if(covr)
    {
        task = [[NSTask alloc] init];
        [task setLaunchPath:[self launchPath]];
        NSString* file = NSTemporaryDirectory();
        if(!file)
            file = @"/tmp";
        
        file = [file stringByAppendingPathComponent:
            [NSString stringWithFormat:@"MetaZImage_%@",
                [[NSProcessInfo processInfo] globallyUniqueString]]];
        [task setArguments:[NSArray arrayWithObjects:fileName, @"-e", file, nil]];
        [task launch];
        [task waitUntilExit];
        [task release];
        
        file = [file stringByAppendingString:@"_artwork_1"];
        
        NSFileManager* mgr = [NSFileManager defaultManager];
        BOOL isDir;
        if([mgr fileExistsAtPath:[file stringByAppendingString:@".png"] isDirectory:&isDir] && !isDir)
        {
            NSData* data = [NSData dataWithContentsOfFile:[file stringByAppendingString:@".png"]];
            [retdict setObject:data forKey:MZPictureTagIdent];
            [mgr removeItemAtPath:[file stringByAppendingString:@".png"] error:NULL];
        }
        else if([mgr fileExistsAtPath:[file stringByAppendingString:@".jpg"] isDirectory:&isDir] && !isDir)
        {
            NSData* data = [NSData dataWithContentsOfFile:[file stringByAppendingString:@".jpg"]];
            [retdict setObject:data forKey:MZPictureTagIdent];
            [mgr removeItemAtPath:[file stringByAppendingString:@".jpg"] error:NULL];
        }
    }
    
    // Special handling for cast, directors, producers and screenwriters
    NSString* iTunMOVIStr = [dict objectForKey:@"com.apple.iTunes;iTunMOVI"];
    if(iTunMOVIStr)
    {
        NSDictionary* iTunMOVI = [iTunMOVIStr propertyList];
        NSArray* value = [iTunMOVI objectForKey:@"cast"];
        if(value)
        {
            value = [value arrayByPerformingSelector:@selector(objectForKey:) withObject:@"name"];
            [retdict setObject:[value componentsJoinedByString:@", "] forKey:MZActorsTagIdent];
        }

        value = [iTunMOVI objectForKey:@"directors"];
        if(value)
        {
            value = [value arrayByPerformingSelector:@selector(objectForKey:) withObject:@"name"];
            [retdict setObject:[value componentsJoinedByString:@", "] forKey:MZDirectorTagIdent];
        }

        value = [iTunMOVI objectForKey:@"producers"];
        if(value)
        {
            value = [value arrayByPerformingSelector:@selector(objectForKey:) withObject:@"name"];
            [retdict setObject:[value componentsJoinedByString:@", "] forKey:MZProducerTagIdent];
        }

        value = [iTunMOVI objectForKey:@"screenwriters"];
        if(value)
        {
            value = [value arrayByPerformingSelector:@selector(objectForKey:) withObject:@"name"];
            [retdict setObject:[value componentsJoinedByString:@", "] forKey:MZScreenwriterTagIdent];
        }
    }
    
    // Special handling of track
    NSString* trkn = [dict objectForKey:@"trkn"];
    if(trkn)
    {
        // TODO
    }
    
    // Special handling of disc num
    NSString* disk = [dict objectForKey:@"disk"];
    if(disk)
    {
        // TODO
    }
        
    [retdict setObject:[fileName lastPathComponent] forKey:MZFileNameTagIdent];
    id title = [retdict objectForKey:MZTitleTagIdent];
    if(![title isKindOfClass:[NSString class]])
    {
        NSString* basefile = [fileName lastPathComponent];
        NSString* newTitle = [basefile substringToIndex:[basefile length] - [[basefile pathExtension] length] - 1];
        [retdict setObject:newTitle forKey:MZTitleTagIdent];
    }
    
    // Chapter reading
    {
        task = [[NSTask alloc] init];
        [task setLaunchPath:[self launchChapsPath]];
        [task setArguments:[NSArray arrayWithObjects:@"-l", fileName, nil]];
        NSPipe* out = [NSPipe pipe];
        [task setStandardOutput:out];
        [task launch];

        NSData* data = [[out fileHandleForReading] readDataToEndOfFile];
        [task waitUntilExit];
        [task release];

        NSString* str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

        NSRange f = [str rangeOfString:@"Duration "];
        NSString* movieDurationStr = [str substringWithRange:NSMakeRange(f.location+f.length, 12)];
        //NSLog(@"Movie duration '%@'", movieDurationStr);
        MZTimeCode* movieDuration = [MZTimeCode timeCodeWithString:movieDurationStr];
        [retdict setObject:movieDuration forKey:MZDurationTagIdent];

        NSArray* lines = [str componentsSeparatedByString:@"\tChapter #"];
        if([lines count]>1)
        {
            NSMutableArray* chapters = [NSMutableArray array];
            int len = [lines count];
            for(int i=1; i<len; i++)
            {
                NSString* line = [[lines objectAtIndex:i]
                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                NSString* startStr = [line substringWithRange:NSMakeRange(6, 12)];
                NSString* durationStr = [line substringWithRange:NSMakeRange(21, 12)];
                NSString* name = [line substringWithRange:NSMakeRange(37, [line length]-38)];
                //NSLog(@"Found args: '%@' '%@' '%@'", start, duration, name);

                MZTimeCode* start = [MZTimeCode timeCodeWithString:startStr];
                MZTimeCode* duration = [MZTimeCode timeCodeWithString:durationStr];

                if(!start || !duration)
                    break;
                    
                MZTimedTextItem* item = [MZTimedTextItem textItemWithStart:start duration:duration text:name];
                [chapters addObject:item];
            }
            if([chapters count] == len-1)
                [retdict setObject:chapters forKey:MZChaptersTagIdent];
        }
    }
    
    return [MetaLoaded metaWithOwner:self filename:fileName dictionary:retdict];
}

void sortTags(NSMutableArray* args, NSDictionary* changes, NSString* tag, NSString* sortType)
{
    id value = [changes objectForKey:tag];
    if(value == [NSNull null])
        value = @"";
    if(value)
    {
        [args addObject:@"--sortOrder"];
        [args addObject:sortType];
        [args addObject:value];
    }
}


-(id<MZDataWriteController>)saveChanges:(MetaEdits *)data
          delegate:(id<MZDataWriteDelegate>)delegate;
{
    NSMutableArray* args = [NSMutableArray array];
    [args addObject:[data loadedFileName]];
    
    [args addObject:@"--output"];
    [args addObject:[data savedTempFileName]];
    
    NSDictionary* changes = [data changes];
    for(NSString* key in [changes allKeys])
    {
        MZTag* tag = [MZTag tagForIdentifier:key];
        id value = [changes objectForKey:key];
        if(value == [NSNull null])
            value = @"";
        NSString* map = [write_mapping objectForKey:key];
        if(map)
        {
            [args addObject:[@"--" stringByAppendingString:map]];
            [args addObject:[tag stringForObject:value]];
        }
    }
    
    // Special rating handling
    id rating = [changes objectForKey:MZRatingTagIdent];
    if(rating)
    {
        NSString* rate = [rating_write objectForKey:rating];
        if(rate)
        {
            [args addObject:@"--rDNSatom"];
            [args addObject:rate];
            [args addObject:@"name=iTunEXTC"];
            [args addObject:@"domain=com.apple.iTunes"];
        }
    }
    
    // Special video type handling
    id stikNo = [changes objectForKey:MZVideoTypeTagIdent];
    if(stikNo)
    {
        MZVideoType stik;
        MZTag* tag = [MZTag tagForIdentifier:MZVideoTypeTagIdent];
        [tag nullConvertObject:stikNo toValue:&stik];
        NSString* stikStr = nil;
        switch (stik) {
            case MZUnsetVideoType:
                stikStr = @"";
                break;
            case MZMovieVideoType:
                stikStr = @"Movie";
                break;
            case MZNormalVideoType:
                stikStr = @"Normal";
                break;
            case MZAudiobookVideoType:
                stikStr = @"Audiobook";
                break;
            case MZWhackedBookmarkVideoType:
                stikStr = @"Whacked Bookmark";
                break;
            case MZMusicVideoType:
                stikStr = @"Music Video";
                break;
            case MZShortFilmVideoType:
                stikStr = @"Short Film";
                break;
            case MZTVShowVideoType:
                stikStr = @"TV Show";
                break;
            case MZBookletVideoType:
                stikStr = @"Booklet";
                break;
        }
        if(stikStr)
        {
            [args addObject:@"--stik"];
            [args addObject:stikStr];
        }
    }
    
    // Sort tags
    sortTags(args, changes, MZSortTitleTagIdent, @"name");
    sortTags(args, changes, MZSortArtistTagIdent, @"artist");
    sortTags(args, changes, MZSortAlbumArtistTagIdent, @"albumartist");
    sortTags(args, changes, MZSortAlbumTagIdent, @"album");
    sortTags(args, changes, MZSortTVShowTagIdent, @"show");
    sortTags(args, changes, MZSortComposerTagIdent, @"composer");
    
    // Special image handling
    id pictureObj = [changes objectForKey:MZPictureTagIdent];
    NSString* pictureFile = nil;
    if(pictureObj == [NSNull null])
    {
        [args addObject:@"--artwork"];
        [args addObject:@"REMOVE_ALL"];
    }
    else if(pictureObj)
    {
        NSData* picture = pictureObj;
        pictureFile = NSTemporaryDirectory();
        if(!pictureFile)
            pictureFile = @"/tmp";
        
        pictureFile = [pictureFile stringByAppendingPathComponent:
            [NSString stringWithFormat:@"MetaZImage_%@.png",
                [[NSProcessInfo processInfo] globallyUniqueString]]];
                
        //NSData *imageData = [picture TIFFRepresentation];
        NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData:picture];
        picture = [imageRep representationUsingType:NSPNGFileType properties:[NSDictionary dictionary]];

        NSError* error = nil;
        if([picture writeToFile:pictureFile options:0 error:&error])
        {
            [args addObject:@"--artwork"];
            [args addObject:@"REMOVE_ALL"];
            [args addObject:@"--artwork"];
            [args addObject:pictureFile];
        }
        else
        {
            NSLog(@"Failed to write image to temp '%@' %@", pictureFile, [error localizedDescription]);
            pictureFile = nil;
        }
    }
    
    //Special handling for directors, producers, actors, screenwriters
    NSString* actors = [changes objectForKey:MZActorsTagIdent];
    NSString* directors = [changes objectForKey:MZDirectorTagIdent];
    NSString* producers = [changes objectForKey:MZProducerTagIdent];
    NSString* screenwriters = [changes objectForKey:MZScreenwriterTagIdent];
    if(actors || directors || producers || screenwriters)
    {
        if(!actors)
            actors = [data actors];
        if(!directors)
            directors = [data director];
        if(!producers)
            producers = [data producer];
        if(!screenwriters)
            screenwriters = [data screenwriter];
        if(actors == (NSString*)[NSNull null])
            actors = nil;
        if(directors == (NSString*)[NSNull null])
            directors = nil;
        if(producers == (NSString*)[NSNull null])
            producers = nil;
        if(screenwriters == (NSString*)[NSNull null])
            screenwriters = nil;

        [args addObject:@"--rDNSatom"];
        if(actors || directors || producers || screenwriters)
        {
            NSMutableDictionary* dict = [NSMutableDictionary dictionary];
            if(actors)
            {
                NSArray* arr = [actors componentsSeparatedByString:@","];
                NSMutableArray* arr2 = [NSMutableArray array];
                for(NSString* actor in arr)
                {
                    NSString* trimmed = [actor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if([trimmed length] > 0) {
                        NSDictionary* nameDict = [NSDictionary dictionaryWithObject:trimmed forKey:@"name"];
                        [arr2 addObject:nameDict];
                    }
                }
                [dict setObject:arr2 forKey:@"cast"];
            }
            if(directors)
            {
                NSArray* arr = [directors componentsSeparatedByString:@","];
                NSMutableArray* arr2 = [NSMutableArray array];
                for(NSString* actor in arr)
                {
                    NSString* trimmed = [actor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if([trimmed length] > 0) {
                        NSDictionary* nameDict = [NSDictionary dictionaryWithObject:trimmed forKey:@"name"];
                        [arr2 addObject:nameDict];
                    }
                }
                [dict setObject:arr2 forKey:@"directors"];
            }
            if(producers)
            {
                NSArray* arr = [producers componentsSeparatedByString:@","];
                NSMutableArray* arr2 = [NSMutableArray array];
                for(NSString* actor in arr)
                {
                    NSString* trimmed = [actor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if([trimmed length] > 0) {
                        NSDictionary* nameDict = [NSDictionary dictionaryWithObject:trimmed forKey:@"name"];
                        [arr2 addObject:nameDict];
                    }
                }
                [dict setObject:arr2 forKey:@"producers"];
            }
            if(screenwriters)
            {
                NSArray* arr = [screenwriters componentsSeparatedByString:@","];
                NSMutableArray* arr2 = [NSMutableArray array];
                for(NSString* actor in arr)
                {
                    NSString* trimmed = [actor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if([trimmed length] > 0) {
                        NSDictionary* nameDict = [NSDictionary dictionaryWithObject:trimmed forKey:@"name"];
                        [arr2 addObject:nameDict];
                    }
                }
                [dict setObject:arr2 forKey:@"screenwriters"];
            }
            
            NSData* xmlData = [NSPropertyListSerialization dataFromPropertyList:dict
                                       format:NSPropertyListXMLFormat_v1_0
                                       errorDescription:NULL];
            NSString* movi = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
            [args addObject:movi];
        }
        else {
            [args addObject:@""];
        }
        [args addObject:@"name=iTunMOVI"];
        [args addObject:@"domain=com.apple.iTunes"];
    }

    // Special chapters handling
    id chaptersObj = [changes objectForKey:MZChaptersTagIdent];
    NSString* chaptersFile = nil;
    if(chaptersObj == [NSNull null])
    {
        chaptersFile = @"";
    }
    else if(chaptersObj)
    {
        NSArray* chapters = chaptersObj;
        chaptersFile = NSTemporaryDirectory();
        if(!chaptersFile)
            chaptersFile = @"/tmp";
        
        chaptersFile = [chaptersFile stringByAppendingPathComponent:
            [NSString stringWithFormat:@"MetaZChapters_%@.txt",
                [[NSProcessInfo processInfo] globallyUniqueString]]];

        NSString* data = [[chapters arrayByPerformingSelector:@selector(description)]
            componentsJoinedByString:@"\n"];
                
        NSError* error = nil;
        if(![data writeToFile:chaptersFile atomically:NO encoding:NSUTF8StringEncoding error:&error])
        {
            NSLog(@"Failed to write chapters to temp '%@' %@", chaptersFile, [error localizedDescription]);
            chaptersFile = nil;
        }
    }


    NSTask* task = [[[NSTask alloc] init] autorelease];
    [task setLaunchPath:[self launchPath]];
    [task setArguments:args];
    
    APWriteManager* manager = [APWriteManager
            managerForProvider:self
                          task:task
                      delegate:delegate
                         edits:data
                   pictureFile:pictureFile
                  chaptersFile:chaptersFile];
    [manager start];
    [writes addObject:manager];
    
    return manager;
}

- (void)removeWriteManager:(id)writeManager
{
    [writes removeObject:writeManager];
}


- (NSString *)launchPath
{
    return [[self class] launchPath];
}

- (NSString *)launchChapsPath
{
    return [[self class] launchChapsPath];
}


@end
