
#ifdef __cplusplus
#define MZKIT_EXTERN		extern "C"
#else
#define MZKIT_EXTERN		extern
#endif

typedef enum
{
    MZUnsetVideoType = -1,
    MZMovieVideoType = 0,
    MZNormalVideoType = 1,
    MZAudiobookVideoType = 2,
    MZWhackedBookmarkVideoType = 5,
    MZMusicVideoType = 6,
    MZShortFilmVideoType = 9,
    MZTVShowVideoType = 10,
    MZBookletVideoType = 11
    
} MZVideoType;

typedef enum
{
    MZNoRating = 0,

    //US
    MZ_G_Rating,
    MZ_PG_Rating,
    MZ_PG13_Rating,
    MZ_R_Rating,
    MZ_NC17_Rating,
    MZ_Unrated_Rating,
    
    //US-TV
    MZ_TVY_Rating,
    MZ_TVY7_Rating,
    MZ_TVG_Rating,
    MZ_TVPG_Rating,
    MZ_TV14_Rating,
    MZ_TVMA_Rating,
    
    // UK
    MZ_U_Rating,
    MZ_Uc_Rating,
    MZ_PG_UK_Rating,
    MZ_12_UK_Rating,
    MZ_12A_Rating,
    MZ_15_UK_Rating,
    MZ_18_UK_Rating,
    MZ_E_UK_Rating,
    MZ_Unrated_UK_Rating,

    // DE
    MZ_FSK0_Rating,
    MZ_FSK6_Rating,
    MZ_FSK12_Rating,
    MZ_FSK16_Rating,
    MZ_FSK18_Rating,
    
    // IE
    MZ_G_IE_Rating,
    MZ_PG_IE_Rating,
    MZ_12_IE_Rating,
    MZ_15_IE_Rating,
    MZ_16_Rating,
    MZ_18_IE_Rating,
    MZ_Unrated_IE_Rating,
    
    // IE-TV
    MZ_GA_Rating,
    MZ_Ch_Rating,
    MZ_YA_Rating,
    MZ_PS_Rating,
    MZ_MA_IETV_Rating,
    MZ_Unrated_IETV_Rating,
    
    // CA
    MZ_G_CA_Rating,
    MZ_PG_CA_Rating,
    MZ_14_Rating,
    MZ_18_CA_Rating,
    MZ_R_CA_Rating,
    MZ_E_CA_Rating,
    MZ_Unrated_CA_Rating,
    
    // CA-TV
    MZ_C_CATV_Rating,
    MZ_C8_Rating,
    MZ_G_CATV_Rating,
    MZ_PG_CATV_Rating,
    MZ_14Plus_Rating,
    MZ_18Plus_Rating,
    MZ_Unrated_CATV_Rating,
    
    // AU
    MZ_E_AU_Rating,
    MZ_G_AU_Rating,
    MZ_PG_AU_Rating,
    MZ_M_AU_Rating,
    MZ_MA15Plus_AU_Rating,
    MZ_R18Plus_Rating,
    MZ_Unrated_AU_Rating,
    
    // AU-TV
    MZ_P_Rating,
    MZ_C_AUTV_Rating,
    MZ_G_AUTV_Rating,
    MZ_PG_AUTV_Rating,
    MZ_M_AUTV_Rating,
    MZ_MA15Plus_AUTV_Rating,
    MZ_AV15Plus_Rating,
    MZ_Unrated_AUTV_Rating,
    
    // NZ
    MZ_E_NZ_Rating,
    MZ_G_NZ_Rating,
    MZ_PG_NZ_Rating,
    MZ_M_NZ_Rating,
    MZ_R13_Rating,
    MZ_R15_Rating,
    MZ_R16_Rating,
    MZ_R18_Rating,
    MZ_R_NZ_Rating,
    MZ_Unrated_NZ_Rating,
    
    // NZ-TV
    MZ_G_NZTV_Rating,
    MZ_PGR_Rating,
    MZ_AO_Rating,
    MZ_Unrated_NZTV_Rating,
} MZRating;

// Info
MZKIT_EXTERN NSString* const MZFileNameTagIdent;
MZKIT_EXTERN NSString* const MZPictureTagIdent;
MZKIT_EXTERN NSString* const MZTitleTagIdent;
MZKIT_EXTERN NSString* const MZArtistTagIdent;
MZKIT_EXTERN NSString* const MZDateTagIdent;
MZKIT_EXTERN NSString* const MZRatingTagIdent;
MZKIT_EXTERN NSString* const MZGenreTagIdent;
MZKIT_EXTERN NSString* const MZAlbumTagIdent;
MZKIT_EXTERN NSString* const MZAlbumArtistTagIdent;
MZKIT_EXTERN NSString* const MZPurchaseDateTagIdent;
MZKIT_EXTERN NSString* const MZShortDescriptionTagIdent;
MZKIT_EXTERN NSString* const MZLongDescriptionTagIdent;

// Video
MZKIT_EXTERN NSString* const MZVideoTypeTagIdent;
MZKIT_EXTERN NSString* const MZActorsTagIdent;
MZKIT_EXTERN NSString* const MZDirectorTagIdent;
MZKIT_EXTERN NSString* const MZProducerTagIdent;
MZKIT_EXTERN NSString* const MZScreenwriterTagIdent;
MZKIT_EXTERN NSString* const MZTVShowTagIdent;
MZKIT_EXTERN NSString* const MZTVEpisodeIDTagIdent;
MZKIT_EXTERN NSString* const MZTVSeasonTagIdent;
MZKIT_EXTERN NSString* const MZTVEpisodeTagIdent;
MZKIT_EXTERN NSString* const MZTVNetworkTagIdent;


// Sort
MZKIT_EXTERN NSString* const MZSortTitleTagIdent;
MZKIT_EXTERN NSString* const MZSortArtistTagIdent;
MZKIT_EXTERN NSString* const MZSortAlbumTagIdent;
MZKIT_EXTERN NSString* const MZSortAlbumArtistTagIdent;
MZKIT_EXTERN NSString* const MZSortTVShowTagIdent;
MZKIT_EXTERN NSString* const MZSortComposerTagIdent;

// MetaX Advanced
MZKIT_EXTERN NSString* const MZFeedURLTagIdent;
MZKIT_EXTERN NSString* const MZEpisodeURLTagIdent;
MZKIT_EXTERN NSString* const MZCategoryTagIdent;
MZKIT_EXTERN NSString* const MZKeywordTagIdent;
MZKIT_EXTERN NSString* const MZAdvisoryTagIdent;
MZKIT_EXTERN NSString* const MZPodcastTagIdent;
MZKIT_EXTERN NSString* const MZCopyrightTagIdent;
MZKIT_EXTERN NSString* const MZTrackNumberTagIdent;
MZKIT_EXTERN NSString* const MZTrackCountTagIdent;
MZKIT_EXTERN NSString* const MZDiscNumberTagIdent;
MZKIT_EXTERN NSString* const MZDiscCountTagIdent;
MZKIT_EXTERN NSString* const MZGroupingTagIdent;
MZKIT_EXTERN NSString* const MZEncodingToolTagIdent;
MZKIT_EXTERN NSString* const MZCommentTagIdent;
MZKIT_EXTERN NSString* const MZGaplessTagIdent;
MZKIT_EXTERN NSString* const MZCompilationTagIdent;


MZKIT_EXTERN NSString* const MZChaptersTagIdent;
MZKIT_EXTERN NSString* const MZChapterNamesTagIdent;
MZKIT_EXTERN NSString* const MZDurationTagIdent;

MZKIT_EXTERN NSString* const MZIMDBTagIdent;
MZKIT_EXTERN NSString* const MZASINTagIdent;
MZKIT_EXTERN NSString* const MZDVDSeasonTagIdent;
MZKIT_EXTERN NSString* const MZDVDEpisodeTagIdent;

/* Notifications */
MZKIT_EXTERN NSString* const MZDataProviderLoadedNotification;
MZKIT_EXTERN NSString* const MZDataProviderWritingStartedNotification;
MZKIT_EXTERN NSString* const MZDataProviderWritingCanceledNotification;
MZKIT_EXTERN NSString* const MZDataProviderWritingFinishedNotification;
MZKIT_EXTERN NSString* const MZSearchFinishedNotification;
MZKIT_EXTERN NSString* const MZUndoActionNameNotification;
MZKIT_EXTERN NSString* const MZMetaEditsDeallocating;

MZKIT_EXTERN NSString* const MZMetaEditsNotificationKey;
MZKIT_EXTERN NSString* const MZUndoActionNameKey;
MZKIT_EXTERN NSString* const MZDataControllerNotificationKey;
MZKIT_EXTERN NSString* const MZDataControllerErrorKey;

// Standard alert ids
MZKIT_EXTERN NSString* const MZDataProviderFileAlreadyLoadedWarningKey;


void MZRelease(const void * ns);
const void * MZRetain(const void * ns);
CFStringRef MZCopyDescription(const void *ns);