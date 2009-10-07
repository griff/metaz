
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
    MZNoRating,

    //US
    MZ_G_Rating,
    MZ_PG_Rating,
    MZ_PG13_Rating,
    MZ_R_Rating,
    MZ_NC17_Rating,
    MZ_Unrated_Rating,
    
    //US-TV
    MZ_TVY7_Rating,
    MZ_TVY_Rating,
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
FOUNDATION_EXPORT NSString* const MZFileNameTagIdent;
FOUNDATION_EXPORT NSString* const MZPictureTagIdent;
FOUNDATION_EXPORT NSString* const MZTitleTagIdent;
FOUNDATION_EXPORT NSString* const MZArtistTagIdent;
FOUNDATION_EXPORT NSString* const MZDateTagIdent;
FOUNDATION_EXPORT NSString* const MZRatingTagIdent;
FOUNDATION_EXPORT NSString* const MZGenreTagIdent;
FOUNDATION_EXPORT NSString* const MZAlbumTagIdent;
FOUNDATION_EXPORT NSString* const MZAlbumArtistTagIdent;
FOUNDATION_EXPORT NSString* const MZPurchaseDateTagIdent;
FOUNDATION_EXPORT NSString* const MZShortDescriptionTagIdent;
FOUNDATION_EXPORT NSString* const MZLongDescriptionTagIdent;

// Video
FOUNDATION_EXPORT NSString* const MZVideoTypeTagIdent;
FOUNDATION_EXPORT NSString* const MZActorsTagIdent;
FOUNDATION_EXPORT NSString* const MZDirectorTagIdent;
FOUNDATION_EXPORT NSString* const MZProducerTagIdent;
FOUNDATION_EXPORT NSString* const MZScreenwriterTagIdent;
FOUNDATION_EXPORT NSString* const MZTVShowTagIdent;
FOUNDATION_EXPORT NSString* const MZTVEpisodeIDTagIdent;
FOUNDATION_EXPORT NSString* const MZTVSeasonTagIdent;
FOUNDATION_EXPORT NSString* const MZTVEpisodeTagIdent;
FOUNDATION_EXPORT NSString* const MZTVNetworkTagIdent;


// Sort
FOUNDATION_EXPORT NSString* const MZSortTitleTagIdent;
FOUNDATION_EXPORT NSString* const MZSortArtistTagIdent;
FOUNDATION_EXPORT NSString* const MZSortAlbumTagIdent;
FOUNDATION_EXPORT NSString* const MZSortAlbumArtistTagIdent;
FOUNDATION_EXPORT NSString* const MZSortTVShowTagIdent;
FOUNDATION_EXPORT NSString* const MZSortComposerTagIdent;

// MetaX Advanced
FOUNDATION_EXPORT NSString* const MZFeedURLTagIdent;
FOUNDATION_EXPORT NSString* const MZEpisodeURLTagIdent;
FOUNDATION_EXPORT NSString* const MZCategoryTagIdent;
FOUNDATION_EXPORT NSString* const MZKeywordTagIdent;
FOUNDATION_EXPORT NSString* const MZAdvisoryTagIdent;
FOUNDATION_EXPORT NSString* const MZPodcastTagIdent;
FOUNDATION_EXPORT NSString* const MZCopyrightTagIdent;
FOUNDATION_EXPORT NSString* const MZTrackNumberTagIdent;
FOUNDATION_EXPORT NSString* const MZTrackCountTagIdent;
FOUNDATION_EXPORT NSString* const MZDiscNumberTagIdent;
FOUNDATION_EXPORT NSString* const MZDiscCountTagIdent;
FOUNDATION_EXPORT NSString* const MZGroupingTagIdent;
FOUNDATION_EXPORT NSString* const MZEncodingToolTagIdent;
FOUNDATION_EXPORT NSString* const MZCommentTagIdent;
FOUNDATION_EXPORT NSString* const MZGaplessTagIdent;
FOUNDATION_EXPORT NSString* const MZCompilationTagIdent;


FOUNDATION_EXPORT NSString* const MZChaptersTagIdent;
FOUNDATION_EXPORT NSString* const MZChapterNamesTagIdent;

