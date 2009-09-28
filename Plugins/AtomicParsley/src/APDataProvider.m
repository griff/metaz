//
//  APMetaProvider.m
//  MetaZ
//
//  Created by Brian Olsen on 23/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "APDataProvider.h"

@interface APDataProvider (Private)

- (NSString *)launchPath;

@end

@implementation APDataProvider

- (id)init
{
    self = [super init];
    if(self)
    {
        types = [[NSArray alloc] initWithObjects:
            @"public.mpeg-4", @"com.apple.quicktime-movie",
            @"com.apple.protected-mpeg-4-video", nil];
        keys = [[MZTag allKnownTags] retain];
        NSArray* readmapkeys = [NSArray arrayWithObjects:
            @"©nam", @"©ART", @"©day", @"com.apple.iTunes;iTunEXTC", @"©gen",
            @"©alb", @"aART", @"purd", @"desc",
            @"ldes", @"stik", @"tvsh", @"tven",
            @"tvsn", @"tves", @"tvnn", @"purl",
            @"egid",@"catg", @"keyw", @"rtng",
            @"pcst" @"cprt", @"©grp", @"©too",
            @"©cmt", @"pgap", @"cpil", @"sonm",
            @"soar", @"soaa", @"soal",
            @"sosn", nil];
        NSArray* readmapvalues = [NSArray arrayWithObjects:
            MZTitleTag, MZArtistTag, MZDateTag, MZRatingTag, MZGenreTag,
            MZAlbumTag, MZAlbumArtistTag, MZPurchaseDateTag, MZShortDescriptionTag,
            MZLongDescriptionTag, MZVideoTypeTag, MZTVShowTag, MZTVEpisodeIDTag,
            MZTVSeasonTag, MZTVEpisodeTag, MZTVNetworkTag, MZFeedURLTag,
            MZEpisodeURLTag, MZCategoryTag, MZKeywordTag, MZAdvisoryTag,
            MZPodcastTag, MZCopyrightTag, MZGroupingTag, MZEncodingToolTag,
            MZCommentTag, MZGaplessTag, MZCompilationTag, MZSortTitleTag,
            MZSortArtistTag, MZSortAlbumArtistTag, MZSortAlbumTag,
            MZSortTVShowTag,nil];
        read_mapping = [[NSDictionary alloc]
            initWithObjects:readmapvalues
                    forKeys:readmapkeys];


        NSArray* writemapkeys = [NSArray arrayWithObjects:
            MZTitleTag, MZArtistTag, MZDateTag, MZRatingTag, MZGenreTag,
            MZAlbumTag, MZAlbumArtistTag, MZPurchaseDateTag, MZShortDescriptionTag,
            //MZLongDescriptionTag,
            MZVideoTypeTag, MZTVShowTag, MZTVEpisodeIDTag,
            MZTVSeasonTag, MZTVEpisodeTag, MZTVNetworkTag, MZFeedURLTag,
            MZEpisodeURLTag, MZCategoryTag, MZKeywordTag, MZAdvisoryTag,
            MZPodcastTag, MZCopyrightTag, MZGroupingTag, MZEncodingToolTag,
            MZCommentTag, MZGaplessTag, MZCompilationTag,
            nil];
            //MZSortTitleTag, MZSortArtistTag, MZSortAlbumArtistTag,
            //MZSortAlbumTag, MZSortTVShowTag,nil];
        NSArray* writemapvalues = [NSArray arrayWithObjects:
            @"title", @"artist", @"year", @"contentRating", @"genre",
            @"album", @"albumArtist", @"purchaseDate", @"description",
            //@"ldes",
            @"stik", @"TVShowName", @"TVEpisode",
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

    }
    return self;
}

- (void)dealloc
{
    [types release];
    [keys release];
    [read_mapping release];
    [write_mapping release];
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

-(NSArray *)providedKeys
{
    return keys;
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
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
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
    
    NSMutableDictionary* retdict = [NSMutableDictionary dictionaryWithCapacity:[keys count]];
    // Initialize a null value for all known keys
    for(NSString* key in keys)
        [retdict setObject:[NSNull null] forKey:key];

    // Store real parsed values using a simple key -> key mapping
    for(NSString* map in [read_mapping allKeys])
    {
        id value = [dict objectForKey:map];
        if(value)
            [retdict setObject:value forKey:[read_mapping objectForKey:map]];
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
            [retdict setObject:[value componentsJoinedByString:@", "] forKey:MZActorsTag];
        }

        value = [iTunMOVI objectForKey:@"directors"];
        if(value)
        {
            value = [value arrayByPerformingSelector:@selector(objectForKey:) withObject:@"name"];
            [retdict setObject:[value componentsJoinedByString:@", "] forKey:MZDirectorTag];
        }

        value = [iTunMOVI objectForKey:@"producers"];
        if(value)
        {
            value = [value arrayByPerformingSelector:@selector(objectForKey:) withObject:@"name"];
            [retdict setObject:[value componentsJoinedByString:@", "] forKey:MZProducerTag];
        }

        value = [iTunMOVI objectForKey:@"screenwriters"];
        if(value)
        {
            value = [value arrayByPerformingSelector:@selector(objectForKey:) withObject:@"name"];
            [retdict setObject:[value componentsJoinedByString:@", "] forKey:MZScreenwriterTag];
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
        
    [retdict setObject:[fileName lastPathComponent] forKey:MZFileNameTag];
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

-(BOOL)saveChanges:(MetaEdits *)data
          delegate:(id)delgate statusUpdateSelector:(SEL)statusUpdateSelector
{
    NSMutableArray* args = [NSMutableArray array];
    [args addObject:[data loadedFileName]];
    
    NSDictionary* changes = [data tags];
    for(NSString* key in [changes allKeys])
    {
        id value = [changes objectForKey:key];
        if(value == [NSNull null])
            value = @"";
        NSString* map = [write_mapping objectForKey:key];
        if(map)
        {
            [args addObject:[@"--" stringByAppendingString:map]];
            [args addObject:value];
        }
    }
    
    // Sort tags
    sortTags(args, changes, MZSortTitleTag, @"name");
    sortTags(args, changes, MZSortArtistTag, @"artist");
    sortTags(args, changes, MZSortAlbumArtistTag, @"albumartist");
    sortTags(args, changes, MZSortAlbumTag, @"album");
    sortTags(args, changes, MZSortTVShowTag, @"show");
    sortTags(args, changes, MZSortComposerTag, @"composer");
    

    NSTask* task = [[NSTask alloc] init];
    [task setLaunchPath:[self launchPath]];
    [task setArguments:args];
    NSPipe* out = [NSPipe pipe];
    [task setStandardOutput:out];
    [task launch];

    return NO;
}

- (NSString *)launchPath
{
    NSBundle* myBundle = [NSBundle bundleForClass:[self class]];
    return [myBundle pathForResource:@"AtomicParsley32" ofType:nil];
}

@end
