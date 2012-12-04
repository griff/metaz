//
//  AtomicParsleyPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 27/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "AtomicParsleyPlugin.h"
#import "APWriteManager.h"
#import "APReadDataTask.h"

@interface AtomicParsleyPlugin ()

+ (NSString *)launchPath;
+ (NSString *)launchChapsPath;
- (NSString *)launchPath;
- (NSString *)launchChapsPath;

@end


@implementation AtomicParsleyPlugin

+ (void)logFromProgram:(NSString *)program pipe:(NSPipe *)pipe
{
    NSData* data = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString* str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    if([str length] > 0)
        MZLoggerDebug(@"Read from %@: %@", program, str);
}

+ (int)testReadFile:(NSString *)filePath
{
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:[self launchChapsPath]];
    [task setArguments:[NSArray arrayWithObjects:@"-l", filePath, nil]];
    NSPipe* err = [NSPipe pipe];
    [task setStandardError:err];
    [task setStandardOutput:err];
    [task launch];
    [task waitUntilExit];
    [self logFromProgram:@"mp4chaps" pipe:err];
    int ret = [task terminationStatus];
    if(ret!=0)
        MZLoggerDebug(@"Encountered bad chapter write issue: %d", ret);
    [task release];
    return ret;
}

+ (int)removeChaptersFromFile:(NSString *)filePath
{
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:[self launchChapsPath]];
    [task setArguments:[NSArray arrayWithObjects:@"-r", filePath, nil]];
    NSPipe* err = [NSPipe pipe];
    [task setStandardError:err];
    [task setStandardOutput:err];
    [task launch];
    [task waitUntilExit];
    [self logFromProgram:@"mp4chaps" pipe:err];
    int ret = [task terminationStatus];
    [task release];
    return ret;
}

+ (int)importChaptersFromFile:(NSString *)chaptersFile toFile:(NSString *)filePath
{
    
    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:[self launchChapsPath]];
    [task setArguments:[NSArray arrayWithObjects:@"--import", chaptersFile, filePath, nil]];
    NSPipe* err = [NSPipe pipe];
    [task setStandardError:err];
    [task setStandardOutput:err];
    [task launch];
    [task waitUntilExit];
    [self logFromProgram:@"mp4chaps" pipe:err];
    int ret = [task terminationStatus];
    [task release];
    return ret;
}

+ (NSString *)launchPath
{
    CFBundleRef myBundle = CFBundleGetBundleWithIdentifier(CFSTR("org.maven-group.metaz.AtomicParsleyPlugin"));
    CFURLRef pathUrl = CFBundleCopyResourceURL(myBundle, CFSTR("AtomicParsley"), NULL, NULL);
    NSString* path = (NSString*)CFURLCopyFileSystemPath(pathUrl, kCFURLPOSIXPathStyle);
    CFRelease(pathUrl);
    return [path autorelease];
}

+ (NSString *)launchChapsPath
{
    CFBundleRef myBundle = CFBundleGetBundleWithIdentifier(CFSTR("org.maven-group.metaz.AtomicParsleyPlugin"));
    CFURLRef pathUrl = CFBundleCopyResourceURL(myBundle, CFSTR("mp4chaps"), NULL, NULL);
    NSString* path = (NSString*)CFURLCopyFileSystemPath(pathUrl, kCFURLPOSIXPathStyle);
    CFRelease(pathUrl);
    return [path autorelease];
}


- (id)init
{
    self = [super init];
    if(self)
    {
        writes = [[NSMutableArray alloc] init];
        types = [[NSArray alloc] initWithObjects:
            @"public.mpeg-4", @"com.apple.quicktime-movie",
            @"com.apple.m4v-video", @"com.apple.protected-mpeg-4-video", nil];
        tags = [[MZTag allKnownTags] retain];
        NSArray* readmapkeys = [NSArray arrayWithObjects:
            @"©nam", @"©ART", @"©day",
            //@"com.apple.iTunes;iTunEXTC", @"©gen",
            @"©alb", @"aART", @"purd", @"desc",
            @"ldes",
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
                    
        NSArray* typeNames = [[NSArray alloc] initWithObjects:
            @"", @"Movie", @"Normal", 
            @"Audiobook", @"Whacked Bookmark", @"Music Video",
            @"Short Film", @"TV Show", @"Booklet",
            @"Unknown value: 14", @"Unknown value: 21", @"Unknown value: 23",
            nil];

        MZEnumTag* videoTypeTag = [MZTag tagForIdentifier:MZVideoTypeTagIdent];
        NSAssert([typeNames count] == [[videoTypeTag values] count], @"Bad number of types");
        videotype_read = [[NSDictionary alloc]
            initWithObjects:[videoTypeTag values]
                    forKeys:typeNames];

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
    [videotype_read release];
    [super dealloc];
}

- (BOOL)isBuiltIn
{
    return YES;
}

-(NSArray *)types
{
    return types;
}

-(NSArray *)providedTags
{
    return tags;
}

- (id<MZDataController>)loadFromFile:(NSString *)fileName
                            delegate:(id<MZDataReadDelegate>)delegate
                               queue:(NSOperationQueue *)queue
                               extra:(NSDictionary *)extra
{
    MZReadOperationsController* op = [MZReadOperationsController
        controllerWithProvider:self
                  fromFileName:fileName
                      delegate:delegate
                         extra:extra];
        
    APReadDataTask* dataRead = [APReadDataTask taskWithProvider:self fromFileName:fileName dictionary:op.tagdict];
    [dataRead setLaunchPath:[self launchPath]];
    [dataRead setArguments:[NSArray arrayWithObjects:fileName, @"-t", nil]];
    [op addOperation:dataRead];

    APPictureReadDataTask* pictureRead = [APPictureReadDataTask taskWithDictionary:op.tagdict];
    [pictureRead setLaunchPath:[self launchPath]];
    [pictureRead setArguments:[NSArray arrayWithObjects:fileName, @"-e", pictureRead.file, nil]];
    [pictureRead addDependency:dataRead];
    [op addOperation:pictureRead];
        
    APChapterReadDataTask* chapterRead = [APChapterReadDataTask taskWithFileName:fileName dictionary:op.tagdict];
    [chapterRead setLaunchPath:[self launchChapsPath]];
    [chapterRead addDependency:pictureRead];
    [op addOperation:chapterRead];

    [op addOperationsToQueue:queue];

    return op;
}

- (void)parseData:(NSData *)data withFileName:(NSString *)fileName dict:(NSMutableDictionary *)tagdict
{
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
    
    // Initialize a null value for all known keys
    for(MZTag* tag in tags)
    {
        if(![tagdict objectForKey:[tag identifier]])
            [tagdict setObject:[NSNull null] forKey:[tag identifier]];
    }

    // Store real parsed values using a simple key -> key mapping
    for(NSString* map in [read_mapping allKeys])
    {
        NSString* tagId = [read_mapping objectForKey:map];
        MZTag* tag = [MZTag tagForIdentifier:tagId];
        NSString* value = [dict objectForKey:map];
        if(value)
            [tagdict setObject:[tag convertObjectForStorage:[tag objectFromString:value]] forKey:tagId];
    }
    
    // Special video type handling
    NSString* stik = [dict objectForKey:@"stik"];
    if(stik)
    {
        MZLoggerDebug(@"Stik '%@'", stik);
        MZTag* tag = [MZTag tagForIdentifier:MZVideoTypeTagIdent];
        id videotype = [videotype_read objectForKey:stik];
        if(videotype)
            [tagdict setObject:[tag convertObjectForStorage:videotype] forKey:MZVideoTypeTagIdent];
    }
    
    
    // Special genre handling
    NSString* genre = [dict objectForKey:@"gnre"];
    if(!genre)
        genre = [dict objectForKey:@"©gen"]; 
    if(genre)
    {
        MZLoggerDebug(@"Genre %@", genre);
        [tagdict setObject:genre forKey:MZGenreTagIdent];
    }
    
    // Special rating handling
    NSString* rating = [dict objectForKey:@"com.apple.iTunes;iTunEXTC"];
    if(rating)
    {
        MZLoggerDebug(@"Rating %@", rating);
        id rate = [rating_read objectForKey:rating];
        if(rate)
            [tagdict setObject:rate forKey:MZRatingTagIdent];
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
            [tagdict setObject:[value componentsJoinedByString:@", "] forKey:MZActorsTagIdent];
        }

        value = [iTunMOVI objectForKey:@"directors"];
        if(value)
        {
            value = [value arrayByPerformingSelector:@selector(objectForKey:) withObject:@"name"];
            [tagdict setObject:[value componentsJoinedByString:@", "] forKey:MZDirectorTagIdent];
        }

        value = [iTunMOVI objectForKey:@"producers"];
        if(value)
        {
            value = [value arrayByPerformingSelector:@selector(objectForKey:) withObject:@"name"];
            [tagdict setObject:[value componentsJoinedByString:@", "] forKey:MZProducerTagIdent];
        }

        value = [iTunMOVI objectForKey:@"screenwriters"];
        if(value)
        {
            value = [value arrayByPerformingSelector:@selector(objectForKey:) withObject:@"name"];
            [tagdict setObject:[value componentsJoinedByString:@", "] forKey:MZScreenwriterTagIdent];
        }
    }
    
    // Special handling of track
    NSString* trkn = [dict objectForKey:@"trkn"];
    if(trkn)
    {
        NSArray* trks = [trkn componentsSeparatedByString:@"/"];
        NSAssert([trks count] < 3, @"Only two tracks");

        MZTag* tag1 = [MZTag tagForIdentifier:MZTrackNumberTagIdent];
        NSNumber* num = [tag1 objectFromString:[trks objectAtIndex:0]];
        [tagdict setObject:num forKey:MZTrackNumberTagIdent];

        if([trks count] == 2)
        {
            MZTag* tag2 = [MZTag tagForIdentifier:MZTrackCountTagIdent];
            NSNumber* count = [tag2 objectFromString:[trks objectAtIndex:1]];
            [tagdict setObject:count forKey:MZTrackCountTagIdent];
        }
    }
    
    // Special handling of disc num
    NSString* disk = [dict objectForKey:@"disk"];
    if(disk)
    {
        NSArray* trks = [disk componentsSeparatedByString:@"/"];
        NSAssert([trks count] < 3, @"Only two disks");

        MZTag* tag1 = [MZTag tagForIdentifier:MZDiscNumberTagIdent];
        NSNumber* num = [tag1 objectFromString:[trks objectAtIndex:0]];
        [tagdict setObject:num forKey:MZDiscNumberTagIdent];

        if([trks count] == 2)
        {
            MZTag* tag2 = [MZTag tagForIdentifier:MZDiscCountTagIdent];
            NSNumber* count = [tag2 objectFromString:[trks objectAtIndex:1]];
            [tagdict setObject:count forKey:MZDiscCountTagIdent];
        }
    }
        
    // Filename auto set
    [tagdict setObject:[fileName lastPathComponent] forKey:MZFileNameTagIdent];
    id title = [tagdict objectForKey:MZTitleTagIdent];
    if(![title isKindOfClass:[NSString class]])
    {
        NSString* newTitle = [MZPluginController extractTitleFromFilename:fileName];
        [tagdict setObject:newTitle forKey:MZTitleTagIdent];
    }

    // Special image handling
    NSString* covr = [dict objectForKey:@"covr"];
    if(covr)
        [tagdict setObject:[NSNull null] forKey:MZPictureTagIdent];
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


-(id<MZDataController>)saveChanges:(MetaEdits *)data
          delegate:(id<MZDataWriteDelegate>)delegate
             queue:(NSOperationQueue *)queue;
{
    NSMutableArray* args = [NSMutableArray array];
    [args addObject:[data loadedFileName]];
    
    [args addObject:@"--output"];
    [args addObject:[data savedTempFileName]];
    
    NSDictionary* changes = [data changes];
    for(NSString* key in [changes allKeys])
    {
        NSString* map = [write_mapping objectForKey:key];
        if(map)
        {
            MZTag* tag = [MZTag tagForIdentifier:key];
            id value = [changes objectForKey:key];
            value = [tag stringForObject:value];
            [args addObject:[@"--" stringByAppendingString:map]];
            [args addObject:value];
        }
    }

    // Special video type handling
    id videoType = [changes objectForKey:MZVideoTypeTagIdent];
    if(videoType)
    {
        MZLoggerDebug(@"Video type %@", videoType);
        [args addObject:@"--stik"];
        [args addObject:[NSString stringWithFormat:@"value=%d", [videoType intValue]]];
    }
    
    // Special rating handling
    id rating = [changes objectForKey:MZRatingTagIdent];
    if(rating)
    {
        MZLoggerDebug(@"Rating %@", rating);
        NSString* rate = [rating_write objectForKey:rating];
        if(rate)
        {
            [args addObject:@"--rDNSatom"];
            [args addObject:rate];
            [args addObject:@"name=iTunEXTC"];
            [args addObject:@"domain=com.apple.iTunes"];
        }
    }

    // Sort tags
    sortTags(args, changes, MZSortTitleTagIdent, @"name");
    sortTags(args, changes, MZSortArtistTagIdent, @"artist");
    sortTags(args, changes, MZSortAlbumArtistTagIdent, @"albumartist");
    sortTags(args, changes, MZSortAlbumTagIdent, @"album");
    sortTags(args, changes, MZSortTVShowTagIdent, @"show");
    sortTags(args, changes, MZSortComposerTagIdent, @"composer");
    
    // Special track number/count handling
    {
        MZTag* numberTag = [MZTag tagForIdentifier:MZTrackNumberTagIdent];
        MZTag* countTag = [MZTag tagForIdentifier:MZTrackCountTagIdent];
        id number = [changes objectForKey:[numberTag identifier]];
        if(!number)
        {
            numberTag = [MZTag tagForIdentifier:MZTVEpisodeTagIdent];
            number = [changes objectForKey:[numberTag identifier]];
        }
        id count = [changes objectForKey:[countTag identifier]];
        if(number || count)
        {
            number = [numberTag stringForObject:number];
            count = [countTag stringForObject:count];
            NSUInteger numberLen = [number length];
            NSUInteger countLen = [count length];
        
            NSString* value = @"";
            if(numberLen > 0 || countLen > 0)
            {
                if(numberLen > 0 && countLen > 0)
                    value = [NSString stringWithFormat:@"%@/%@", number, count];
                else if(numberLen > 0)
                    value = number;
                else
                    value = [NSString stringWithFormat:@"/%@", count];
            }
            [args addObject:@"--tracknum"];
            [args addObject:value];
        }
    }

    // Special disc number/count handling
    {
        MZTag* numberTag = [MZTag tagForIdentifier:MZDiscNumberTagIdent];
        MZTag* countTag = [MZTag tagForIdentifier:MZDiscCountTagIdent];
        id number = [changes objectForKey:[numberTag identifier]];
        id count = [changes objectForKey:[countTag identifier]];

        if(number || count)
        {
            number = [numberTag stringForObject:number];
            count = [countTag stringForObject:count];
            NSUInteger numberLen = [number length];
            NSUInteger countLen = [count length];

            NSString* value = @"";
            if(numberLen > 0 || countLen > 0)
            {
                if(numberLen > 0 && countLen > 0)
                    value = [NSString stringWithFormat:@"%@/%@", number, count];
                else if(numberLen > 0)
                    value = number;
                else
                    value = [NSString stringWithFormat:@"/%@", count];
            }
            [args addObject:@"--disk"];
            [args addObject:value];
        }
    }
    
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

        pictureFile = [NSString temporaryPathWithFormat:@"MetaZImage_%@.png"];
                
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
            MZLoggerError(@"Failed to write image to temp '%@' %@", pictureFile, [error localizedDescription]);
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
            NSString* movi = [[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding] autorelease];
            [args addObject:movi];
        }
        else {
            [args addObject:@""];
        }
        [args addObject:@"name=iTunMOVI"];
        [args addObject:@"domain=com.apple.iTunes"];
    }
    
    NSString* fileName;
    if([args count]-3 == 0)
        fileName = [data loadedFileName];
    else
        fileName = [data savedTempFileName];
        
    APWriteOperationsController* ctrl = 
        [APWriteOperationsController controllerWithProvider:self
                                                   delegate:delegate
                                                      edits:data];

    APMainWriteTask* mainWrite = [APMainWriteTask taskWithController:ctrl pictureFile:pictureFile];
    [mainWrite setLaunchPath:[self launchPath]];
    [mainWrite setArguments:args];
    [ctrl addOperation:mainWrite];

    // Sometimes when writing to a network drive the file is left in a state
    // (I think it is a cache flush issue) so that a subsequent chapter write
    // breaks the file. I hope (have not encountered the issue in a long time)
    // that this extra chapter read at least detects the issue.
    APChapterReadDataTask* chapterRead = [APChapterReadDataTask taskWithFileName:fileName dictionary:nil];
    [chapterRead setLaunchPath:[self launchChapsPath]];
    [chapterRead addDependency:mainWrite];
    [ctrl addOperation:chapterRead];

    // Special chapters handling
    id chaptersObj = [changes objectForKey:MZChaptersTagIdent];
    NSString* chaptersFile = nil;
    if(chaptersObj == [NSNull null] || (chaptersObj && [chaptersObj count] == 0))
    {
        chaptersFile = @"";
    }
    else if(chaptersObj)
    {
        NSArray* chapters = chaptersObj;
        chaptersFile = [NSString temporaryPathWithFormat:@"MetaZChapters_%@.txt"];

        NSString* data = [[chapters arrayByPerformingSelector:@selector(description)]
            componentsJoinedByString:@"\n"];
                
        NSError* error = nil;
        if(![data writeToFile:chaptersFile atomically:NO encoding:NSUTF8StringEncoding error:&error])
        {
            MZLoggerError(@"Failed to write chapters to temp '%@' %@", chaptersFile, [error localizedDescription]);
            chaptersFile = nil;
        }
    }
    
    if(chaptersFile)
    {
        APChapterWriteTask* chapterWrite = [APChapterWriteTask
                taskWithFileName:fileName
                    chaptersFile:chaptersFile];
        [chapterWrite setLaunchPath:[self launchChapsPath]];
        [chapterWrite addDependency:chapterRead];
        [ctrl addOperation:chapterWrite];
    }

    [writes addObject:ctrl];

    [delegate dataProvider:self controller:ctrl writeStartedForEdits:data];
    [ctrl addOperationsToQueue:queue];

    return ctrl;
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
