//
//  AtomicParsleyMetaProvider.m
//  MetaZ
//
//  Created by Brian Olsen on 23/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "AtomicParsleyDataProvider.h"
#import "MZTag.h"
#import "NSArray-Mapping.h"

@interface AtomicParsleyDataProvider (Private)

- (NSString *)launchPath;

@end

@implementation AtomicParsleyDataProvider

- (id)init
{
    self = [super init];
    if(self)
    {
        types = [[NSArray alloc] initWithObjects:
            @"public.mpeg-4", @"com.apple.quicktime-movie",
            @"com.apple.protected-mpeg-4-video", nil];
        extensions = [[NSArray alloc] initWithObjects:@"mp4", @"m4v", @"m4a", nil];
        keys = [[MZTag allKnownTags] retain];
        NSArray* mapkeys = [NSArray arrayWithObjects:
            @"©nam", @"©ART", @"©day", @"com.apple.iTunes;iTunEXTC", @"©gen",
            @"©alb", @"aART", @"purd", @"desc",
            @"ldes", @"stik", @"tvsh", @"tven",
            @"tvsn", @"tves", @"tvnn", @"purl",
            @"egid",@"catg", @"keyw", @"rtng",
            @"cprt", @"©grp", @"©too", @"©cmt",
            @"sonm", @"soar", @"soaa", @"soal",
            @"sosn", nil];
        NSArray* mapvalues = [NSArray arrayWithObjects:
            MZTitleTag, MZArtistTag, MZDateTag, MZRatingTag, MZGenreTag,
            MZAlbumTag, MZAlbumArtistTag, MZPurchaseDateTag, MZShortDescriptionTag,
            MZLongDescriptionTag, MZVideoTypeTag, MZTVShowTag, MZTVEpisodeIDTag,
            MZTVSeasonTag, MZTVEpisodeTag, MZTVNetworkTag, MZFeedURLTag,
            MZEpisodeURLTag, MZCategoryTag, MZKeywordTag, MZAdvisoryTag,
            MZCopyrightTag, MZGroupingTag, MZEncodingToolTag, MZCommentTag,
            MZSortTitleTag, MZSortArtistTag, MZSortAlbumArtistTag, MZSortAlbumTag,
            MZSortTVShowTag,nil];
        mapping = [[NSDictionary alloc] initWithObjects:mapvalues forKeys:mapkeys];
    }
    return self;
}

- (void)dealloc
{
    [types release];
    [extensions release];
    [keys release];
    [mapping release];
    [super dealloc];
}

-(NSArray *)types
{
    return types;
}

-(NSArray *)extensions
{
    return extensions;
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
    for(NSString* map in [mapping allKeys])
    {
        id value = [dict objectForKey:map];
        if(value)
            [retdict setObject:value forKey:[mapping objectForKey:map]];
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
    return [MetaLoaded metaWithFilename:fileName dictionary:retdict];
}

-(void)saveChanges:(MetaEdits *)data
{
}

- (NSString *)launchPath
{
    NSBundle* myBundle = [NSBundle bundleForClass:[self class]];
    return [myBundle pathForResource:@"AtomicParsley32" ofType:nil];
}

@end
