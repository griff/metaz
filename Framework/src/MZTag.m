//
//  MZTag.m
//  MetaZ
//
//  Created by Brian Olsen on 23/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MZTag.h>
#import <MetaZKit/MZConstants.h>

@interface MZVideoTypeTagClass : MZEnumTag {
}
- (id)init;

@end

@interface MZRatingTag : MZEnumTag {
}
- (id)init;

@end


@implementation MZTag

+ (void)initialize
{
    static BOOL initialized = NO;
    /* Make sure code only gets executed once. */
    if (initialized == YES) return;
    initialized = YES;

    // Info tags
    [self registerTag:[MZStringTag tagWithIdentifier:MZFileNameTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZPictureTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZTitleTagIdent]];
    [self registerTag:[MZStringTag tagWithIdentifier:MZArtistTagIdent]];
    [self registerTag:[MZDateTag tagWithIdentifier:MZDateTagIdent]];
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
    [self registerTag:[MZBoolTag tagWithIdentifier:MZAdvisoryTagIdent]];
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
    [self registerTag:[MZTag tagWithIdentifier:MZChapterNamesTagIdent]];
}

static NSMutableDictionary *sharedTags = nil;
+ (void)registerTag:(MZTag *)tag
{
    if(!sharedTags)
        sharedTags = [[NSMutableDictionary alloc] init];
    [sharedTags setObject:tag forKey:[tag identifier]];
}

+ (MZTag *)tagForIdentifier:(NSString *)identifier
{
    if(!sharedTags)
        return nil;
    return [sharedTags objectForKey:identifier];
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
    return [[[[[self infoTags] arrayByAddingObjectsFromArray:[self videoTags]]
                    arrayByAddingObjectsFromArray:[self sortTags]]
                    arrayByAddingObjectsFromArray:[self advancedTags]]
                    arrayByAddingObjectsFromArray:[self chapterTags]];
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

- (NSString *)identifier
{
    return identifier;
}

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
    
    //NSDateFormatter* format = [[NSDateFormatter alloc] init]
    return [NSDate dateWithString:str];
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
    return [super initWithIdentifier:MZVideoTypeTagIdent];
}

- (NSCell *)editorCell
{
    NSPopUpButtonCell* cell = [[[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:NO] autorelease]; 
    [cell addItemWithTitle:NSLocalizedString(@"Movie", @"Video type") tag:MZMovieVideoType];
    [cell addItemWithTitle:NSLocalizedString(@"Normal", @"Video type") tag:MZNormalVideoType];
    [cell addItemWithTitle:NSLocalizedString(@"Audiobook", @"Video type") tag:MZAudiobookVideoType];
    [cell addItemWithTitle:NSLocalizedString(@"Whacked Bookmark", @"Video type") tag:MZWhackedBookmarkVideoType];
    [cell addItemWithTitle:NSLocalizedString(@"Music Video", @"Video type") tag:MZMusicVideoType];
    [cell addItemWithTitle:NSLocalizedString(@"Short Film", @"Video type") tag:MZShortFilmVideoType];
    [cell addItemWithTitle:NSLocalizedString(@"TV Show", @"Video type") tag:MZTVShowVideoType];
    [cell addItemWithTitle:NSLocalizedString(@"Booklet", @"Video type") tag:MZBookletVideoType];
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

@end


@implementation MZRatingTag

- (id)init
{
    return [super initWithIdentifier:MZRatingTagIdent];
}

- (NSCell *)editorCell
{
    NSPopUpButtonCell* cell = [[[NSPopUpButtonCell alloc] initTextCell:@"" pullsDown:NO] autorelease]; 
    /*
    [cell addItemWithTitle:NSLocalizedString(@"Movie", @"Video type") tag:MZMovieVideoType];
    [cell addItemWithTitle:NSLocalizedString(@"Normal", @"Video type") tag:MZNormalVideoType];
    [cell addItemWithTitle:NSLocalizedString(@"Audiobook", @"Video type") tag:MZAudiobookVideoType];
    [cell addItemWithTitle:NSLocalizedString(@"Whacked Bookmark", @"Video type") tag:MZWhackedBookmarkVideoType];
    [cell addItemWithTitle:NSLocalizedString(@"Music Video", @"Video type") tag:MZMusicVideoType];
    [cell addItemWithTitle:NSLocalizedString(@"Short Film", @"Video type") tag:MZShortFilmVideoType];
    [cell addItemWithTitle:NSLocalizedString(@"TV Show", @"Video type") tag:MZTVShowVideoType];
    [cell addItemWithTitle:NSLocalizedString(@"Booklet", @"Video type") tag:MZBookletVideoType];
    */
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

@end

