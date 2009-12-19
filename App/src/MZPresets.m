//
//  MZPresets.m
//  MetaZ
//
//  Created by Brian Olsen on 25/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZPresets.h"

NSString* const MZPresetAddedNotification = @"MZPresetAddedNotification";
NSString* const MZPresetRemovedNotification = @"MZPresetRemovedNotification";
NSString* const MZPresetRenamedNotification = @"MZPresetRenamedNotification";

NSString* const MZPresetKey = @"MZPresetKey";
NSString* const MZPresetOldNameKey = @"MZPresetOldNameKey";
NSString* const MZPresetNewNameKey = @"MZPresetNewNameKey";

@interface MZPreset ()
- (void)replaceValue:(id)value forTag:(NSString *)tag;
@end

@implementation MZPreset

+ (id)presetWithName:(NSString *)name values:(NSDictionary *)values
{
    return [[[self alloc] initWithName:name values:values] autorelease];
}

- (id)initWithName:(NSString *)theName values:(NSDictionary *)theValues
{
    self = [super init];
    if(self)
    {
        name = [theName retain];
        values = [[NSDictionary alloc] initWithDictionary:theValues];
    }
    return self;
}

- (void)dealloc
{
    [name release];
    [values release];
    [super dealloc];
}

@synthesize name;
@synthesize values;

- (void)setName:(NSString *)newName
{
    NSString* oldName = [name retain];
    [name release];
    name = [newName retain];
    [[MZPresets sharedPresets] saveWithError:NULL];

    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
        oldName, MZPresetOldNameKey,
        newName, MZPresetNewNameKey,
        nil];
    [[NSNotificationCenter defaultCenter] 
        postNotificationName:MZPresetRenamedNotification object:self userInfo:userInfo];
    [oldName release];
}

- (void)applyToObject:(id)object withPrefix:(NSString *)prefix
{
    for(NSString* key in [values allKeys])
    {
        MZTag* tag = [MZTag tagForIdentifier:key];
        id value = [values objectForKey:key];
        value = [tag convertObjectForRetrival:value];
        NSString* keyPath = [prefix stringByAppendingString:key];
        [object setValue:value forKeyPath:keyPath];
    }
}

- (void)replaceValue:(id)value forTag:(NSString *)tag
{
    NSMutableDictionary* mutDict = [values mutableCopyWithZone:[self zone]];
    [mutDict setObject:value forKey:tag];
    [values release];
    values = [mutDict copyWithZone:self.zone];
    [mutDict release];
}

#pragma mark - NSCoding implementation

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self)
    {
        if([decoder allowsKeyedCoding])
        {
            name = [[decoder decodeObjectForKey:@"name"] retain];
            values = [[decoder decodeObjectForKey:@"values"] retain];
        }
        else
        {
            name = [[decoder decodeObject] retain];
            values = [[decoder decodeObject] retain];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if([encoder allowsKeyedCoding])
    {
        [encoder encodeObject:name forKey:@"name"];
        [encoder encodeObject:values forKey:@"values"];
    }
    else
    {
        [encoder encodeObject:name];
        [encoder encodeObject:values];
    }
}

@end


@implementation MZPresets

static MZPresets* sharedPresets = nil;

+(MZPresets *)sharedPresets
{
    if(!sharedPresets)
        [[[MZPresets alloc] init] release];
    return sharedPresets;
}

/*
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
    return !([key isEqual:@"queueItems"] || [key isEqual:@"status"]);
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet* sup = [super keyPathsForValuesAffectingValueForKey:key];
    if([key isEqualToString:@"pendingItems"] ||
        [key isEqualToString:@"completedItems"])
    {
        return [sup setByAddingObject:@"queueItems"];
    }
    return sup;
}
*/

-(id)init
{
    self = [super init];

    if(sharedPresets)
    {
        [self release];
        self = [sharedPresets retain];
    } else if(self)
    {
        sharedPresets = [self retain];
        fileName = [[@"MetaZ" stringByAppendingPathComponent:@"MetaZ.presets"] retain];
        presets = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] 
            addObserver:self
               selector:@selector(applicationDidFinishLaunching:)
                   name:NSApplicationDidFinishLaunchingNotification
                 object:NSApp];
    }
    return self;
}

-(void)dealloc
{
    [fileName release];
    //[queueItems release];
    [super dealloc];
}

@synthesize presets;

- (void)removeObjectFromPresetsAtIndex:(NSUInteger)index
{
    MZPreset* preset = [[presets objectAtIndex:index] retain];
    [self willChangeValueForKey:@"presets"];
    [presets removeObjectAtIndex:index];
    [self saveWithError:NULL];
    [self didChangeValueForKey:@"presets"];
    
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:preset forKey:MZPresetKey];
    [[NSNotificationCenter defaultCenter] 
        postNotificationName:MZPresetRemovedNotification object:self userInfo:userInfo];
    [preset release];
}

- (void)insertObject:(MZPreset *)preset inPresetsAtIndex:(NSUInteger)index
{
    [self willChangeValueForKey:@"presets"];
    [presets insertObject:preset atIndex:index];
    [self saveWithError:NULL];
    [self didChangeValueForKey:@"presets"];

    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:preset forKey:MZPresetKey];
    [[NSNotificationCenter defaultCenter] 
        postNotificationName:MZPresetAddedNotification object:self userInfo:userInfo];
}

- (void)addObject:(MZPreset *)preset
{
    [self willChangeValueForKey:@"presets"];
    [presets addObject:preset];
    [self saveWithError:NULL];
    [self didChangeValueForKey:@"presets"];

    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:preset forKey:MZPresetKey];
    [[NSNotificationCenter defaultCenter] 
        postNotificationName:MZPresetAddedNotification object:self userInfo:userInfo];
}

- (BOOL)loadWithError:(NSError **)error
{
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    for(NSString * path in paths)
    {
        NSString *destinationPath = [path stringByAppendingPathComponent: fileName];
        if([mgr fileExistsAtPath:destinationPath])
        {
            NSArray* objs = [NSKeyedUnarchiver unarchiveObjectWithFile:destinationPath];
            if(!objs)
            {
                if(error != NULL)
                {
                    //Make NSError;
                    NSDictionary* dict = [NSDictionary dictionaryWithObject:
                        NSLocalizedString(@"Unarchiving of presets failed", @"Unarchiving error")
                        forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"MetaZ" code:12 userInfo:dict];
                }
                return NO;
            }
            [self didChangeValueForKey:@"presets"];
            [presets addObjectsFromArray:objs];
            [self willChangeValueForKey:@"presets"];
            return YES;
        }
    }
    if ([paths count] == 0)
    {
        if(error != NULL)
        {
            //Make NSError;
            NSDictionary* dict = [NSDictionary dictionaryWithObject:
                NSLocalizedString(@"No search paths found", @"Search path error")
                forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"MetaZ" code:10 userInfo:dict];
        }
        return NO;
    }
    
    if(error != NULL)
    {
        //Make NSError;
        NSDictionary* dict = [NSDictionary dictionaryWithObject:
            NSLocalizedString(@"No presets found", @"No presets found error")
            forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"MetaZ" code:13 userInfo:dict];
    }
    return NO;
}

- (BOOL)saveWithError:(NSError **)error
{
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    /*
    NSMutableArray* items = [NSMutableArray array];
    for(MZWriteQueueStatus* obj in queueItems)
        if(![obj completed])
            [items addObject:[obj edits]];
    */
    //if([items count] > 0)
    {
        if ([paths count] > 0)
        {
            NSString *destinationDir = [[paths objectAtIndex:0]
                        stringByAppendingPathComponent: @"MetaZ"];
            BOOL isDir;
            if([mgr fileExistsAtPath:destinationDir isDirectory:&isDir])
            {
                if(!isDir)
                {
                    [mgr removeItemAtPath:destinationDir error:error];
                    [mgr createDirectoryAtPath:destinationDir withIntermediateDirectories:YES attributes:nil error:error];
                }
            }
            else
                [mgr createDirectoryAtPath:destinationDir withIntermediateDirectories:YES attributes:nil error:error];
            
            NSString *destinationPath = [[paths objectAtIndex:0]
                        stringByAppendingPathComponent: fileName];
            if(![NSKeyedArchiver archiveRootObject:presets toFile:destinationPath])
            {
                if(error != NULL)
                {
                    //Make NSError;
                    NSDictionary* dict = [NSDictionary dictionaryWithObject:
                        NSLocalizedString(@"Archiving of presets failed", @"Archiving error")
                        forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"MetaZ" code:11 userInfo:dict];
                }
                return NO;
            }
        }
        else
        {
            if(error != NULL)
            {
                //Make NSError;
                NSDictionary* dict = [NSDictionary dictionaryWithObject:
                    NSLocalizedString(@"No search paths found", @"Search path error")
                    forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"MetaZ" code:10 userInfo:dict];
            }
            return NO;
        }
    }
    /*
    else
    {
        for(NSString * path in paths)
        {
            NSString *destinationPath = [path stringByAppendingPathComponent: fileName];
            if([mgr fileExistsAtPath:destinationPath] && ![mgr removeItemAtPath:destinationPath error:error])
                return NO;
        }
    }
    */
    return YES;
}


- (NSArray *)loadFromMetaXWithError:(NSError **)error
{
    NSArray* keys = [NSArray arrayWithObjects:
        @"Title", @"Artist", @"Date", @"Rating",
        @"Genre", @"Album", @"AlbumArtist",
        @"PurchaseDate", @"Review",
        @"LongDescription", @"VideoKind", @"Cast", 
        @"Director", @"Producer", @"Writer",
        @"Show", @"EpisodeID", @"Season", 
        @"Episode", @"Network", @"SortName",
        @"SortArtist", @"SortAlbumArtist", @"SortAlbum",
        @"SortShow", @"FeedURL", @"EpisodeURL",
        @"Category", @"Keyword",
        //@"Advisory",
        @"Podcast", @"Copyright", @"Track",
        @"TrackTotal", @"Disk", @"DiskTotal",
        @"Grouping", @"Tool", @"Comment",
        @"Gapless", @"Compilation", @"Image",
        nil];
    NSArray* values = [NSArray arrayWithObjects:
        MZTitleTagIdent, MZArtistTagIdent, MZDateTagIdent, MZRatingTagIdent,
        MZGenreTagIdent, MZAlbumTagIdent, MZAlbumArtistTagIdent,
        MZPurchaseDateTagIdent, MZShortDescriptionTagIdent,
        MZLongDescriptionTagIdent, MZVideoTypeTagIdent, MZActorsTagIdent,
        MZDirectorTagIdent, MZProducerTagIdent, MZScreenwriterTagIdent,
        MZTVShowTagIdent, MZTVEpisodeIDTagIdent, MZTVSeasonTagIdent,
        MZTVEpisodeTagIdent, MZTVNetworkTagIdent, MZSortTitleTagIdent,
        MZSortArtistTagIdent, MZSortAlbumArtistTagIdent, MZSortAlbumTagIdent,
        MZSortTVShowTagIdent, MZFeedURLTagIdent, MZEpisodeURLTagIdent,
        MZCategoryTagIdent, MZKeywordTagIdent,
        //MZAdvisoryTagIdent,
        MZPodcastTagIdent, MZCopyrightTagIdent, MZTrackNumberTagIdent,
        MZTrackCountTagIdent, MZDiscNumberTagIdent, MZDiscCountTagIdent,
        MZGroupingTagIdent, MZEncodingToolTagIdent, MZCommentTagIdent,
        MZGaplessTagIdent, MZCompilationTagIdent, MZPictureTagIdent,
        nil];
    NSDictionary* convert = [NSDictionary dictionaryWithObjects:values forKeys:keys];

    NSMutableArray* ret = [[NSMutableArray alloc] init];

    NSString* file = [@"MetaX" stringByAppendingPathComponent:@"MetaX-Presets"];
    NSFileManager *mgr = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    for(NSString * path in paths)
    {
        NSString *destinationPath = [path stringByAppendingPathComponent: file];
        if([mgr fileExistsAtPath:destinationPath])
        {
            id objs = nil;
            @try {
                objs = [NSKeyedUnarchiver unarchiveObjectWithFile:destinationPath];
            }
            @catch (NSException * e) {
                if(![[e name] isEqual:NSInvalidArgumentException])
                    @throw;
            }
            if(!objs)
                objs = [NSUnarchiver unarchiveObjectWithFile:destinationPath];
            
            if(!objs)
            {
                if(error != NULL)
                {
                    //Make NSError;
                    NSDictionary* dict = [NSDictionary dictionaryWithObject:
                        NSLocalizedString(@"Unarchiving of presets failed", @"Unarchiving error")
                        forKey:NSLocalizedDescriptionKey];
                    *error = [NSError errorWithDomain:@"MetaZ" code:12 userInfo:dict];
                }
                return nil;
            }
            NSArray* arr = objs;
            for(NSDictionary* preset in arr)
            {
                NSString* presetName = [preset objectForKey:@"PresetName"];
                NSMutableDictionary* presetValues = [[NSMutableDictionary alloc] init];
                for(NSString* key in keys)
                {
                    id inValue = [preset objectForKey:key];
                    if(inValue)
                    {
                        NSString* mzKey = [convert objectForKey:key];
                        MZTag* tag = [MZTag tagForIdentifier:mzKey];
                        if([inValue isKindOfClass:[NSString class]])
                        {
                            NSString* strValue = inValue;
                            inValue = [tag objectFromString:strValue];
                        }
                        inValue = [tag convertObjectForStorage:inValue];
                        [presetValues setObject:inValue forKey:mzKey];
                    }
                }
                MZPreset* retPreset = [[[MZPreset alloc] initWithName:presetName values:presetValues] autorelease];
                [ret addObject:retPreset];
            }
        }
    }
    if ([paths count] == 0)
    {
        if(error != NULL)
        {
            //Make NSError;
            NSDictionary* dict = [NSDictionary dictionaryWithObject:
                NSLocalizedString(@"No search paths found", @"Search path error")
                forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"MetaZ" code:10 userInfo:dict];
        }
        return nil;
    }
    return [NSArray arrayWithArray:ret];
    /*
    if(error != NULL)
    {
        //Make NSError;
        NSDictionary* dict = [NSDictionary dictionaryWithObject:
            NSLocalizedString(@"No presets found", @"No presets found error")
            forKey:NSLocalizedDescriptionKey];
        *error = [NSError errorWithDomain:@"MetaZ" code:14 userInfo:dict];
    }
    return nil;
    */
}

#pragma mark - observation callbacks

- (void)applicationDidFinishLaunching:(NSNotification *)note
{
    NSError* error;
    if(![self loadWithError:&error])
    {
        if([error code] == 13) // No presets found
        {
            NSArray* mxPresets = [self loadFromMetaXWithError:&error];
            if(mxPresets && [mxPresets count] > 0)
            {
                NSString* title = [NSString stringWithFormat:
                        NSLocalizedString(@"Found %d MetaX Presets", @"Found MetaX presets message box text"),
                        [mxPresets count]];
                NSInteger returnCode = NSRunCriticalAlertPanel(title,
                        NSLocalizedString(@"Do you wish to import them ?", @"Found MetaX presets message question"),
                        NSLocalizedString(@"Import", @"Button text for presets import action"), nil,
                        NSLocalizedString(@"Ignore", @"Button text for presets ignore action")
                );
                if(returnCode == NSAlertDefaultReturn)
                {
                    [self willChangeValueForKey:@"presets"];
                    [presets addObjectsFromArray:mxPresets];
                    [self didChangeValueForKey:@"presets"];
                }
                if(![self saveWithError:&error])
                {
                    MZLoggerError(@"Save Error %@", [error localizedDescription]);
                }
            }
        }
    }
    else
    {
        // Check for bad MetaX import
        NSArray* mxPresets = nil;
        BOOL changed = NO;
        MZVideoType lastSelection = MZUnsetVideoType;
        for(MZPreset* preset in presets)
        {
            id kind = [[preset values] objectForKey:MZVideoTypeTagIdent];
            if([kind isKindOfClass:[NSNumber class]])
            {
                NSNumber* num = kind;
                if([num intValue] == MZUnsetVideoType)
                    kind = [NSNull null];
            }
            if(kind == [NSNull null])
            {
                if(!mxPresets)
                {
                    mxPresets = [self loadFromMetaXWithError:&error];
                    if(!mxPresets)
                        mxPresets = [NSArray array];
                }
                BOOL found = NO;
                for(MZPreset* mxPreset in mxPresets)
                {
                    if([mxPreset.name isEqual:preset.name])
                    {
                        [preset replaceValue:[[mxPreset values] objectForKey:MZVideoTypeTagIdent]
                            forTag:MZVideoTypeTagIdent];
                        found = YES;
                        changed = YES;
                        break;
                    }
                }
                if(!found)
                {
                    MZLoggerInfo(@"Detected null video kind but found no matching MetaX preset");
                    NSAlert* alert = [[NSAlert alloc] init];
                    [alert setMessageText:NSLocalizedString(
                            @"Found Bad MetaX Preset Import",
                            @"Found bad MetaX preset message box text")];
                    [alert setInformativeText:[NSString stringWithFormat:
                        NSLocalizedString(@"Preset '%@' has an empty video type.\n"
                            "This is most likely due to a bad MetaX import done "
                            "by a previous version of MetaZ.\nWe were unable to "
                            "find the preset with the same name in your current "
                            "MetaX presets so you need to specify the video type bellow.",
                            @"Found bad MetaX preset message"),
                        preset.name]];
                    
                    NSPopUpButton* sel = [[NSPopUpButton alloc] 
                        initWithFrame:NSMakeRect(0, 0, 145, 25)
                            pullsDown:NO];
                    MZTag* tag = [MZTag tagForIdentifier:MZVideoTypeTagIdent];
                    [sel setCell:[tag editorCell]];
                    [sel setKeyEquivalent:@"t"];
                    [sel setKeyEquivalentModifierMask:NSCommandKeyMask];
                    
                    if(lastSelection != MZUnsetVideoType)
                        [sel selectItemWithTag:lastSelection];
                    [alert setAccessoryView:sel];
                    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"Button")];

                    NSInteger returnCode = [alert runModal];
                    lastSelection = [[sel selectedItem] tag];

                    [sel release];
                    [alert release];

                    if(returnCode == NSAlertFirstButtonReturn)
                    {
                        id value = [tag convertValueToObject:&lastSelection];
                        value = [tag convertObjectForStorage:value];
                        [preset replaceValue:value forTag:MZVideoTypeTagIdent];
                        changed = YES;
                    }
                }
            }
        }
        if(changed)
        {
            if(![self saveWithError:&error])
            {
                MZLoggerError(@"Save Error %@", [error localizedDescription]);
            }
        }
        
    }
}

@end
