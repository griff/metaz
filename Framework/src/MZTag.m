//
//  MZTag.m
//  MetaZ
//
//  Created by Brian Olsen on 23/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MZTag.h>
#import <MetaZKit/MZConstants.h>
#import <MetaZKit/MZTimeCode.h>
#import <MetaZKit/NSDate+UTC.h>
#import <MetaZKit/MZLogger.h>
#import <MetaZKit/NSString+MZAllInCharacterSet.h>

@interface MZVideoTypeTagClass : MZEnumTag
{
    NSArray* typeNames;
    NSMutableArray* typeValues;
}
- (id)init;

@end

@interface MZRatingTag : MZEnumTag
{
    NSArray* ratingNames;
    NSArray* ratingNamesNonStrict;
    NSMutableArray* ratingValuesNonStrict;
}
- (id)init;

@end

@implementation MZTag

+ (void)initialize
{
    if(self != [MZTag class])
        return;

    // Info tags
    [self registerTag:[MZStringTag tagWithIdentifier:MZFileNameTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZPictureTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZTitleTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZArtistTagIdent]];
    [self registerTag:[MZYearDateTag tagWithIdentifier:MZDateTagIdent]];
    [self registerTag:[MZRatingTag tag]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZGenreTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZAlbumTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZAlbumArtistTagIdent]];
    [self registerTag:[MZDateTag tagWithIdentifier:MZPurchaseDateTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZShortDescriptionTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZLongDescriptionTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZAlbumArtistTagIdent]];

    // Video tags
    [self registerTag:[MZVideoTypeTagClass tag]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZActorsTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZDirectorTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZProducerTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZScreenwriterTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZTVShowTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZTVEpisodeIDTagIdent]];
    [self registerTag:[MZIntegerTag tagWithIdentifier:MZTVSeasonTagIdent]];
    [self registerTag:[MZIntegerTag tagWithIdentifier:MZTVEpisodeTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZTVNetworkTagIdent]];

    // Sort tags
    [self registerTag:[MZStringTag tagWithIdentifier:MZSortTitleTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZSortArtistTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZSortAlbumTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZSortAlbumArtistTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZSortTVShowTagIdent]];
    
    // Advanced tags
    [self registerTag:[MZStringTag tagWithIdentifier:MZFeedURLTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZEpisodeURLTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZCategoryTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZKeywordTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZAdvisoryTagIdent]];
    [self registerTag:[MZBoolTag tagWithIdentifier:MZPodcastTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZCopyrightTagIdent]];
    [self registerTag:[MZIntegerTag tagWithIdentifier:MZTrackNumberTagIdent]];
    [self registerTag:[MZIntegerTag tagWithIdentifier:MZTrackCountTagIdent]];
    [self registerTag:[MZIntegerTag tagWithIdentifier:MZDiscNumberTagIdent]];
    [self registerTag:[MZIntegerTag tagWithIdentifier:MZDiscCountTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZGroupingTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZEncodingToolTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZCommentTagIdent]];
    [self registerTag:[MZBoolTag tagWithIdentifier:MZGaplessTagIdent]];
    [self registerTag:[MZBoolTag tagWithIdentifier:MZCompilationTagIdent]];
    
    // Chapter tags
    [self registerTag:[MZTag tagWithIdentifier:MZChaptersTagIdent]];
    [self registerTag:[MZReadOnlyTag tagWithIdentifier:MZChapterNamesTagIdent]];

    [self registerTag:[MZTimeCodeTag tagWithIdentifier:MZDurationTagIdent]];
    
    [self registerTag:[MZStringTag tagWithIdentifier:MZIMDBTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZASINTagIdent]];
    [self registerTag:[MZIntegerTag tagWithIdentifier:MZDVDSeasonTagIdent]];
    [self registerTag:[MZIntegerTag tagWithIdentifier:MZDVDEpisodeTagIdent]];

}

static NSMutableDictionary *sharedTags = nil;
+ (void)registerTag:(MZTag *)tag
{
    @synchronized(self)
    {
        if(!sharedTags)
            sharedTags = [[NSMutableDictionary alloc] init];
        [sharedTags setObject:tag forKey:[tag identifier]];
    }
}

+ (MZTag *)tagForIdentifier:(NSString *)identifier
{
    MZTag *ret = nil;
    @synchronized(self)
    {
        if(sharedTags)
            ret = [sharedTags objectForKey:identifier];
    }
    return ret;
}

+ (NSArray*)infoTags
{
    return [NSArray arrayWithObjects:
        [self tagForIdentifier:MZFileNameTagIdent],
        [self tagForIdentifier:MZPictureTagIdent],
        [self tagForIdentifier:MZTitleTagIdent],
        [self tagForIdentifier:MZArtistTagIdent],
        [self tagForIdentifier:MZDateTagIdent],
        [self tagForIdentifier:MZRatingTagIdent],
        [self tagForIdentifier:MZGenreTagIdent],
        [self tagForIdentifier:MZAlbumTagIdent],
        [self tagForIdentifier:MZAlbumArtistTagIdent],
        [self tagForIdentifier:MZPurchaseDateTagIdent],
        [self tagForIdentifier:MZShortDescriptionTagIdent],
        [self tagForIdentifier:MZLongDescriptionTagIdent],
        [self tagForIdentifier:MZAlbumArtistTagIdent],
        nil];
}

+ (NSArray*)videoTags
{
    return [NSArray arrayWithObjects:
        [self tagForIdentifier:MZVideoTypeTagIdent],
        [self tagForIdentifier:MZActorsTagIdent],
        [self tagForIdentifier:MZDirectorTagIdent],
        [self tagForIdentifier:MZProducerTagIdent],
        [self tagForIdentifier:MZScreenwriterTagIdent],
        [self tagForIdentifier:MZTVShowTagIdent],
        [self tagForIdentifier:MZTVEpisodeIDTagIdent],
        [self tagForIdentifier:MZTVSeasonTagIdent],
        [self tagForIdentifier:MZTVEpisodeTagIdent],
        [self tagForIdentifier:MZTVNetworkTagIdent],
        nil];
}

+ (NSArray*)sortTags
{
    return [NSArray arrayWithObjects:
        [self tagForIdentifier:MZSortTitleTagIdent],
        [self tagForIdentifier:MZSortArtistTagIdent],
        [self tagForIdentifier:MZSortAlbumTagIdent],
        [self tagForIdentifier:MZSortAlbumArtistTagIdent],
        [self tagForIdentifier:MZSortTVShowTagIdent],
        nil];
}

+ (NSArray*)advancedTags
{
    return [NSArray arrayWithObjects:
        [self tagForIdentifier:MZFeedURLTagIdent],
        [self tagForIdentifier:MZEpisodeURLTagIdent],
        [self tagForIdentifier:MZCategoryTagIdent],
        [self tagForIdentifier:MZKeywordTagIdent],
        [self tagForIdentifier:MZAdvisoryTagIdent],
        [self tagForIdentifier:MZPodcastTagIdent],
        [self tagForIdentifier:MZCopyrightTagIdent],
        [self tagForIdentifier:MZTrackNumberTagIdent],
        [self tagForIdentifier:MZTrackCountTagIdent],
        [self tagForIdentifier:MZDiscNumberTagIdent],
        [self tagForIdentifier:MZDiscCountTagIdent],
        [self tagForIdentifier:MZGroupingTagIdent],
        [self tagForIdentifier:MZEncodingToolTagIdent],
        [self tagForIdentifier:MZCommentTagIdent],
        [self tagForIdentifier:MZGaplessTagIdent],
        [self tagForIdentifier:MZCompilationTagIdent],
        nil];
}

+ (NSArray *)chapterTags
{
    return [NSArray arrayWithObjects:
        [self tagForIdentifier:MZChaptersTagIdent],
        [self tagForIdentifier:MZChapterNamesTagIdent],
        nil];
}

+ (NSArray*)allKnownTags
{
    return [[[[[[self infoTags] arrayByAddingObjectsFromArray:[self videoTags]]
                    arrayByAddingObjectsFromArray:[self sortTags]]
                    arrayByAddingObjectsFromArray:[self advancedTags]]
                    arrayByAddingObjectsFromArray:[self chapterTags]] 
                    arrayByAddingObject:[self tagForIdentifier:MZDurationTagIdent]];
}

+ (NSString *)localizedNameForKnownIdentifier:(NSString *)identifier
{
    return NSLocalizedStringFromTableInBundle(
            identifier, 
            @"MZTags", 
            [NSBundle bundleForClass:[self class]],
            @"Name for tag");
}

+ (id)tagWithIdentifier:(NSString *)identifier
{
    return [[[self alloc] initWithIdentifier:identifier] autorelease];
}

- (id)initWithIdentifier:(NSString *)theIdentifier
{
    self = [super init];
    if(self)
    {
        identifier = [theIdentifier retain];
    }
    return self;
}

- (void)dealloc
{
    [identifier release];
    [super dealloc];
}

@synthesize identifier;

- (NSString *)localizedName
{
    return [[self class] localizedNameForKnownIdentifier:[self identifier]];
}

- (NSCell *)editorCell
{
    return nil;
}

- (const char*)encoding
{
    return @encode(id);
}

- (id)convertValueToObject:(void*)buffer
{
    id* v = (id*)buffer;
    return *v;
}

- (void)convertObject:(id)obj toValue:(void*)buffer
{
    id* v = (id*)buffer;
    *v = obj;
}

- (id)nullConvertValueToObject:(void*)buffer
{
    id ret = [self convertValueToObject:buffer];
    if(ret)
        return ret;
    return [NSNull null];
}

- (void)nullConvertObject:(id)obj toValue:(void*)buffer
{
    if(obj == [NSNull null])
        obj = nil;
    [self convertObject:obj toValue:buffer];
}

- (id)convertObjectForRetrival:(id)obj
{
    if(obj == [NSNull null])
        return nil;
    return obj;
}

- (id)convertObjectForStorage:(id)obj
{
    if(!obj)
        return [NSNull null];
    return obj;
}

- (id)objectFromString:(NSString *)str
{
    return nil;
}

- (NSString *)stringForObject:(id)obj
{
    if(!obj || obj == [NSNull null] || ![obj respondsToSelector:@selector(stringValue)])
        return @"";
    return [obj stringValue];
}

@end


@implementation MZReadOnlyTag
- (id)convertObjectForStorage:(id)obj
{
    [NSException raise:@"MZTagReadOnly" format:@"Tag '%@' is read only", [self identifier]];
    return nil;
}
@end


@implementation MZStringTag

- (NSCell *)editorCell
{
    return [[[NSTextFieldCell alloc] initTextCell:@""] autorelease]; 
}

- (id)objectFromString:(NSString *)str
{
    if(!str || [str length]==0)
        return nil;
    return str;
}

- (NSString *)stringForObject:(id)obj
{
    if(!obj || obj == [NSNull null])
        return @"";
    return obj;
}


@end


@implementation MZDateTag

- (NSCell *)editorCell
{
    return [[[NSTextFieldCell alloc] initTextCell:@""] autorelease]; 
}

- (id)convertValueToObject:(void*)buffer
{
    NSDate** str = (NSDate**)buffer;
    return *str;
}

- (void)convertObject:(id)obj toValue:(void*)buffer
{
    NSDate** str = (NSDate**)buffer;
    *str = obj;
}

- (id)objectFromString:(NSString *)str
{
    if(!str || [str length]==0)
        return nil;
    
    return [NSDate dateWithUTCString:str];
}

- (NSString *)stringForObject:(id)obj
{
    if(!obj || obj == [NSNull null])
        return @"";
    NSDate* date = obj;
    return [date utcTimestamp];
}

@end


@implementation MZYearDateTag

- (NSCell *)editorCell
{
    return [[[NSTextFieldCell alloc] initTextCell:@""] autorelease]; 
}

- (id)convertValueToObject:(void*)buffer
{
    id* str = (id*)buffer;
    return *str;
}

- (void)convertObject:(id)obj toValue:(void*)buffer
{
    id* str = (id*)buffer;
    *str = obj;
}

- (id)objectFromString:(NSString *)str
{
    if(!str || [str length]==0)
        return nil;

    if([str mz_allInCharacterSet:[NSCharacterSet decimalDigitCharacterSet]])
        return [NSNumber numberWithInt:[str intValue]];
    return [NSDate dateWithUTCString:str];
}

- (NSString *)stringForObject:(id)obj
{
    if(!obj || obj == [NSNull null])
        return @"";
    if([obj isKindOfClass:[NSNumber class]])
        return [obj stringValue];
    NSDate* date = obj;
    return [date utcTimestamp];
}

@end


@implementation MZIntegerTag

- (NSCell *)editorCell
{
    return [[[NSTextFieldCell alloc] initTextCell:@""] autorelease]; 
}

- (id)convertValueToObject:(void*)buffer
{
    NSNumber** str = (NSNumber**)buffer;
    return *str;
}

- (void)convertObject:(id)obj toValue:(void*)buffer
{
    NSNumber** str = (NSNumber**)buffer;
    *str = obj;
}

- (id)objectFromString:(NSString *)str
{
    if(!str || [str length]==0)
        return nil;
    
    NSInteger i = [str integerValue];
    return [NSNumber numberWithInteger:i];
}

@end

@implementation MZBoolTag : MZTag

- (NSCell *)editorCell
{
    return [[[NSTextFieldCell alloc] initTextCell:@""] autorelease]; 
}

- (id)convertValueToObject:(void*)buffer
{
    NSNumber** str = (NSNumber**)buffer;
    return *str;
}

- (void)convertObject:(id)obj toValue:(void*)buffer
{
    NSNumber** str = (NSNumber**)buffer;
    *str = obj;
}

- (id)objectFromString:(NSString *)str
{
    if(!str || [str length]==0)
        return nil;
    
    BOOL value = [str boolValue];
    return [NSNumber numberWithBool:value];
}

@end


@implementation MZTimeCodeTag

- (NSCell *)editorCell
{
    return [[[NSTextFieldCell alloc] initTextCell:@""] autorelease]; 
}

- (id)convertValueToObject:(void*)buffer
{
    MZTimeCode** str = (MZTimeCode**)buffer;
    return *str;
}

- (void)convertObject:(id)obj toValue:(void*)buffer
{
    MZTimeCode** str = (MZTimeCode**)buffer;
    *str = obj;
}

- (id)objectFromString:(NSString *)str
{
    if(!str || [str length]==0)
        return nil;
    
    return [MZTimeCode timeCodeWithString:str];
}

- (id)convertObjectForStorage:(id)obj
{
    [NSException raise:@"MZTagReadOnly" format:@"Tag '%@' is read only", [self identifier]];
    return nil;
}

@end


@interface NSPopUpButtonCell (AddItemWithTag)
- (void)addItemWithTitle:(NSString *)title tag:(NSInteger)tag;
@end

@implementation NSPopUpButtonCell (AddItemWithTag)
- (void)addItemWithTitle:(NSString *)title tag:(NSInteger)tag
{
    [self addItemWithTitle:title];
    [[self lastItem] setTag:tag];
}
@end


@implementation MZEnumTag

+ (id)tag
{
    return [[[self alloc] init] autorelease];
}

- (const char*)encoding
{
    return @encode(int);
}

- (id)convertValueToObject:(void*)buffer
{
    int* value = (int*)buffer;
    return [NSNumber numberWithInt:*value];
}

- (void)convertObject:(id)obj toValue:(void*)buffer
{
    int* ret = (int*)buffer;
    if(!obj || obj == [NSNull null] || ![obj respondsToSelector:@selector(intValue)])
        *ret = [self nilValue];
    else
        *ret = [obj intValue];
}

- (id)convertObjectForRetrival:(id)obj
{
    int ret = [self nilValue];
    if(obj && obj != [NSNull null] && [obj respondsToSelector:@selector(intValue)])
        ret = [obj intValue];
    return [NSNumber numberWithInt:ret];
}

- (id)convertObjectForStorage:(id)obj
{
    int ret = [self nilValue];
    if(obj && obj != [NSNull null] && [obj respondsToSelector:@selector(intValue)])
        ret = [obj intValue];
    return [NSNumber numberWithInt:ret];
}

- (int)nilValue
{
    return 0;
}

@end


@implementation MZVideoTypeTagClass

- (id)init
{
    self = [super initWithIdentifier:MZVideoTypeTagIdent];
    if(self)
    {
        typeNames = [[NSArray alloc] initWithObjects:
            @"", @"Movie", @"Normal", 
            @"Audiobook", @"Whacked Bookmark", @"Music Video",
            @"Short Film", @"TV Show", @"Booklet",
            nil];
        NSAssert([typeNames count] == 9, @"Bad number of types");
        int typeValuesTemp[] = {
            MZUnsetVideoType, MZMovieVideoType, MZNormalVideoType, 
            MZAudiobookVideoType, MZWhackedBookmarkVideoType, MZMusicVideoType,
            MZShortFilmVideoType, MZTVShowVideoType, MZBookletVideoType
            };
        typeValues = [[NSMutableArray alloc] init];
        NSInteger count = [typeNames count];
        for(int i=0; i<count; i++)
           [typeValues addObject:[NSNumber numberWithInt:typeValuesTemp[i]]];
    }
    return self;
}

- (NSCell *)editorCell
{
    NSPopUpButtonCell* cell = [[[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:NO] autorelease]; 
    [cell addItemWithTitle:NSLocalizedStringFromTable(@"Movie", @"VideoType", @"Video type") tag:MZMovieVideoType];
    [cell addItemWithTitle:NSLocalizedStringFromTable(@"Normal", @"VideoType", @"Video type") tag:MZNormalVideoType];
    [cell addItemWithTitle:NSLocalizedStringFromTable(@"Audiobook", @"VideoType", @"Video type") tag:MZAudiobookVideoType];
    [cell addItemWithTitle:NSLocalizedStringFromTable(@"Whacked Bookmark", @"VideoType", @"Video type") tag:MZWhackedBookmarkVideoType];
    [cell addItemWithTitle:NSLocalizedStringFromTable(@"Music Video", @"VideoType", @"Video type") tag:MZMusicVideoType];
    [cell addItemWithTitle:NSLocalizedStringFromTable(@"Short Film", @"VideoType", @"Video type") tag:MZShortFilmVideoType];
    [cell addItemWithTitle:NSLocalizedStringFromTable(@"TV Show", @"VideoType", @"Video type") tag:MZTVShowVideoType];
    [cell addItemWithTitle:NSLocalizedStringFromTable(@"Booklet", @"VideoType", @"Video type") tag:MZBookletVideoType];
    return cell;
}

- (const char*)encoding
{
    return @encode(MZVideoType);
}

- (int)nilValue
{
    return MZUnsetVideoType;
}

- (id)objectFromString:(NSString *)str
{
    if(!str)
        return [NSNumber numberWithInt:MZUnsetVideoType];
    NSInteger i = [typeNames indexOfObject:str];
    if(i == NSNotFound)
    {
        MZLoggerError(@"Found no video type for '%@'", str);
        return [NSNumber numberWithInt:MZUnsetVideoType];
    }
    return [typeValues objectAtIndex:i];
}

- (NSString *)stringForObject:(id)obj
{
    if(!obj || obj == [NSNull null] || ![obj respondsToSelector:@selector(intValue)])
        return @"";
    MZVideoType type = [obj intValue];
    int count = [typeValues count];
    for(int i=0; i<count; i++)
    {
        NSNumber* num = [typeValues objectAtIndex:i];
        if(type == [num intValue])
            return [typeNames objectAtIndex:i];
    }
    return @"";
}


@end


@implementation MZRatingTag

- (id)init
{
    self =  [super initWithIdentifier:MZRatingTagIdent];
    if(self)
    {
        ratingNames = [[NSArray alloc] initWithObjects:
            @"No Rating",
            // US
            @"G", @"PG", @"PG-13", @"R", @"NC-17", @"Unrated",
            // US TV
            @"TV-Y", @"TV-Y7", @"TV-G", @"TV-PG", @"TV-14", @"TV-MA",
            // UK
            @"U", @"Uc", @"PG (UK)", @"12 (UK)", @"12A", @"15 (UK)", @"18 (UK)", @"E (UK)", @"UNRATED (UK)",
            // DE
            @"FSK-0", @"FSK-6", @"FSK-12", @"FSK-16", @"FSK-18",
            // IE
            @"G (IE)", @"PG (IE)", @"12 (IE)", @"15 (IE)", @"16", @"18 (IE)", @"UNRATED (IE)",
            // IE TV
            @"GA", @"Ch", @"YA", @"PS", @"MA (IE-TV)", @"UNRATED (IE-TV)",
            // CA
            @"G (CA)", @"PG (CA)", @"14", @"18 (CA)", @"R (CA)", @"E (CA)", @"UNRATED (CA)",
            // CA-TV
            @"C (CA-TV)", @"C8", @"G (CA-TV)", @"PG (CA-TV)", @"14+", @"18+", @"UNRATED (CA-TV)",
            // AU
            @"E (AU)", @"G (AU)", @"PG (AU)", @"M (AU)", @"MA 15+", @"R 18+", @"UNRATED (AU)",
            // AU TV
            @"P", @"C (AU-TV)", @"G (AU-TV)", @"PG (AU-TV)", @"M (AU-TV)", @"MA 15+ (AU-TV)", @"AV 15+", @"UNRATED (AU-TV)",
            // NZ
            @"E (NZ)", @"G (NZ)", @"PG (NZ)", @"M (NZ)", @"R13", @"R15", @"R16",
            @"R18", @"R (NZ)", @"UNRATED (NZ)",
            // NZ TV
            @"G (NZ-TV)", @"PGR", @"AD", @"UNRATED (NZ-TV)",
            nil];
        NSAssert([ratingNames count] == MZ_Unrated_NZTV_Rating+1, @"Bad number of ratings");
        ratingNamesNonStrict = [[NSArray alloc] initWithObjects:
            @"UNRATED",
            @"FSK 0", @"FSK 6", @"FSK 12", @"FSK 16", @"FSK 18",
            nil];
        int ratingNonStrictValues[] = {
            MZ_Unrated_Rating,
            MZ_FSK0_Rating, MZ_FSK6_Rating, MZ_FSK12_Rating, MZ_FSK16_Rating, MZ_FSK18_Rating
            };
        ratingValuesNonStrict = [[NSMutableArray alloc] init];
        NSInteger count = [ratingNamesNonStrict count];
        for(int i=0; i<count; i++)
           [ratingValuesNonStrict addObject:[NSNumber numberWithInt:ratingNonStrictValues[i]]];
    }
    return self;
}

- (void)dealloc
{
    [ratingNames release];
    [ratingNamesNonStrict release];
    [ratingValuesNonStrict release];
    [super dealloc];
}

- (NSCell *)editorCell
{
    NSPopUpButtonCell* cell = [[[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:NO] autorelease];
    NSInteger count = [ratingNames count];
    for(NSInteger i=0; i<count; i++)
    {
        [cell addItemWithTitle:[ratingNames objectAtIndex:i] tag:i];
    }
    return cell;
}

- (const char*)encoding
{
    return @encode(MZRating);
}

- (int)nilValue
{
    return MZNoRating;
}

- (id)objectFromString:(NSString *)str
{
    if(!str || [str length] == 0)
        return [NSNumber numberWithInt:MZNoRating];
    NSInteger i = [ratingNames indexOfObject:str];
    if(i == NSNotFound)
    {
        i = [ratingNamesNonStrict indexOfObject:str];
        if(i != NSNotFound)
            i = [[ratingValuesNonStrict objectAtIndex:i] integerValue];
    }
    if(i == NSNotFound)
    {
        MZLoggerError(@"Found no rating for '%@'", str);
        return [NSNumber numberWithInt:MZNoRating];
    }
    return [NSNumber numberWithInt:i];
}


@end


