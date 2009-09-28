//
//  MZTag.m
//  MetaZ
//
//  Created by Brian Olsen on 23/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MZTag.h>
#import <MetaZKit/MZConstants.h>

@interface MZTagCollections : NSObject
{
    NSArray* infoTags;
    NSArray* videoTags;
    NSArray* sortTags;
    NSArray* advancedTags;
    NSArray* allKnownTags;
}


@end


@implementation MZTag

+ (NSArray*)infoTags
{
    return [NSArray arrayWithObjects:
        MZFileNameTag, MZPictureTag, MZTitleTag, MZArtistTag, MZDateTag, MZRatingTag,
        MZGenreTag, MZAlbumTag, MZAlbumArtistTag, MZPurchaseDateTag, MZShortDescriptionTag,
        MZLongDescriptionTag,
        nil];
}

+ (NSArray*)videoTags
{
    return [NSArray arrayWithObjects:
        MZVideoTypeTag, MZActorsTag, MZDirectorTag, MZProducerTag, MZScreenwriterTag,
        MZTVShowTag, MZTVEpisodeIDTag, MZTVSeasonTag, MZTVEpisodeTag, MZTVNetworkTag,
        nil];
}

+ (NSArray*)sortTags
{
    return [NSArray arrayWithObjects:
        MZSortTitleTag, MZSortArtistTag, MZSortAlbumTag, MZSortAlbumArtistTag,
        MZSortTVShowTag,
        nil];
}

+ (NSArray*)advancedTags
{
    return [NSArray arrayWithObjects:
        MZFeedURLTag, MZEpisodeURLTag, MZCategoryTag, MZKeywordTag, MZAdvisoryTag,
        MZPodcastTag, MZCopyrightTag, MZTrackNumberTag, MZTrackCountTag,
        MZDiscNumberTag, MZDiscCountTag, MZGroupingTag, MZEncodingToolTag, MZCommentTag,
        MZGaplessTag, MZCompilationTag,
        nil];
}

+ (NSArray*)allKnownTags
{
    return [[[[self infoTags] arrayByAddingObjectsFromArray:[self videoTags]]
                    arrayByAddingObjectsFromArray:[self sortTags]]
                    arrayByAddingObjectsFromArray:[self advancedTags]];
}


@end
