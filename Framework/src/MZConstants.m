//
//  MZConstants.m
//  MetaZ
//
//  Created by Brian Olsen on 02/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZConstants.h"

// Info
NSString* const MZFileNameTagIdent = @"fileName";
NSString* const MZPictureTagIdent = @"picture";
NSString* const MZTitleTagIdent = @"title";
NSString* const MZArtistTagIdent = @"artist";
NSString* const MZDateTagIdent = @"date";
NSString* const MZRatingTagIdent = @"rating";
NSString* const MZGenreTagIdent = @"genre";
NSString* const MZAlbumTagIdent = @"album";
NSString* const MZAlbumArtistTagIdent = @"albumArtist";
NSString* const MZPurchaseDateTagIdent = @"purchaseDate";
NSString* const MZShortDescriptionTagIdent = @"shortDescription";
NSString* const MZLongDescriptionTagIdent = @"longDescription";

// Video
NSString* const MZVideoTypeTagIdent = @"videoType";
NSString* const MZActorsTagIdent = @"actors";
NSString* const MZDirectorTagIdent = @"director";
NSString* const MZProducerTagIdent = @"producer";
NSString* const MZScreenwriterTagIdent = @"screenwriter";
NSString* const MZTVShowTagIdent = @"tvShow";
NSString* const MZTVEpisodeIDTagIdent = @"tvEpisodeID";
NSString* const MZTVSeasonTagIdent = @"tvSeason";
NSString* const MZTVEpisodeTagIdent = @"tvEpisode";
NSString* const MZTVNetworkTagIdent = @"tvNetwork";


// Sort
NSString* const MZSortTitleTagIdent = @"sortTitle";
NSString* const MZSortArtistTagIdent = @"sortArtist";
NSString* const MZSortAlbumTagIdent = @"sortAlbum";
NSString* const MZSortAlbumArtistTagIdent = @"sortAlbumArtist";
NSString* const MZSortTVShowTagIdent = @"sortTvShow";
NSString* const MZSortComposerTagIdent = @"sortComposer";

// MetaX Advanced
NSString* const MZFeedURLTagIdent = @"feedURL";
NSString* const MZEpisodeURLTagIdent = @"episodeURL";
NSString* const MZCategoryTagIdent = @"category";
NSString* const MZKeywordTagIdent = @"keyword";
NSString* const MZAdvisoryTagIdent = @"advisory";
NSString* const MZPodcastTagIdent = @"podcast";
NSString* const MZCopyrightTagIdent = @"copyright";
NSString* const MZTrackNumberTagIdent = @"trackNo";
NSString* const MZTrackCountTagIdent = @"trackCount";
NSString* const MZDiscNumberTagIdent = @"discNo";
NSString* const MZDiscCountTagIdent = @"discCount";
NSString* const MZGroupingTagIdent = @"grouping";
NSString* const MZEncodingToolTagIdent = @"encodingTool";
NSString* const MZCommentTagIdent = @"comment";
NSString* const MZGaplessTagIdent = @"gapless";
NSString* const MZCompilationTagIdent = @"compilation";


NSString* const MZChaptersTagIdent = @"chapters";
NSString* const MZChapterNamesTagIdent = @"chapterNames";
NSString* const MZDurationTagIdent = @"duration";

NSString* const MZIMDBTagIdent = @"imdb";
NSString* const MZASINTagIdent = @"asin";
NSString* const MZDVDSeasonTagIdent = @"dvdSeason";
NSString* const MZDVDEpisodeTagIdent = @"dvdEpisode";
NSString* const MZiTunesPersistentIDTagIdent = @"iTunesPersistentID";
NSString* const MZTVAppPersistentIDTagIdent = @"TVAppPersistentID";

/* Notifications */
NSString* const MZDataProviderLoadedNotification = @"MZDataProviderLoadedNotification";
NSString* const MZDataProviderWritingStartedNotification = @"MZDataProviderWritingStartedNotification";
NSString* const MZDataProviderWritingCanceledNotification = @"MZDataProviderWritingCanceledNotification";
NSString* const MZDataProviderWritingFinishedNotification = @"MZDataProviderWritingFinishedNotification";
NSString* const MZSearchFinishedNotification = @"MZSearchFinishedNotification";
NSString* const MZUndoActionNameNotification = @"MZUndoActionNameNotification";
NSString* const MZMetaEditsDeallocating = @"MZMetaEditsDeallocating";

NSString* const MZQueueStartedNotification = @"MZQueueStartedNotification";
NSString* const MZQueueItemStartedNotification = @"MZQueueItemStartedNotification";
NSString* const MZQueueItemCompletedPercentNotification = @"MZQueueItemCompletedPercentNotification";
NSString* const MZQueueItemCompletedNotification = @"MZQueueItemCompletedNotification";
NSString* const MZQueueItemFailedNotification = @"MZQueueItemFailedNotification";
NSString* const MZQueueCompletedNotification = @"MZQueueCompletedNotification";

NSString* const MZMetaLoaderStartedNotification = @"MZMetaLoaderStartedNotification";
NSString* const MZMetaLoaderFinishedNotification = @"MZMetaLoaderFinishedNotification";

NSString* const MZMetaEditsNotificationKey = @"MZMetaEditsNotificationKey";
NSString* const MZUndoActionNameKey = @"MZUndoActionNameKey";
NSString* const MZDataControllerNotificationKey = @"MZDataControllerNotificationKey";
NSString* const MZNSErrorKey = @"MZNSErrorKey";

// Standard alert ids
NSString* const MZDataProviderFileAlreadyLoadedWarningKey = @"alerts.warnings.fileAlreadyLoaded";

NSString* const iTunesMetadataPboardType = @"com.apple.itunes.metadata";
NSString* const TVAppMetadataPboardType = @"com.apple.tv.metadata";
NSString* const iTunesPboardType = @"CorePasteboardFlavorType 0x6974756E";

// Plugin UTI
const CFStringRef kMZUTMetaZPlugin = CFSTR("org.maven-group.MetaZ.plugin");
const CFStringRef kMZUTMetaZActionsPlugin = CFSTR("org.maven-group.MetaZ.plugin.actions");
const CFStringRef kMZUTMetaZDataProviderPlugin = CFSTR("org.maven-group.MetaZ.plugin.dataprovider");
const CFStringRef kMZUTMetaZSearchProviderPlugin = CFSTR("org.maven-group.MetaZ.plugin.searchprovider");
const CFStringRef kMZUTAppleScriptText = CFSTR("com.apple.applescript.text");
const CFStringRef kMZUTAppleScript = CFSTR("com.apple.applescript.script");
const CFStringRef kMZUTAppleScriptBundle = CFSTR("com.latenightsw.osa.bundle");
