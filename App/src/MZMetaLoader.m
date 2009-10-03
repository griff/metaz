//
//  MetaLoader.m
//  MetaZ
//
//  Created by Brian Olsen on 25/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZMetaLoader.h"

@implementation MZMetaLoader
@synthesize files;

#pragma mark - initialization 

static MZMetaLoader* sharedLoader = nil;

+(MZMetaLoader *)sharedLoader {
    if(!sharedLoader)
        [[[MZMetaLoader alloc] init] release];
    return sharedLoader;
}

-(id)init {
    self = [super init];

    if(sharedLoader)
    {
        [self release];
        self = [sharedLoader retain];
    } else if(self)
    {
        files = [[NSMutableArray alloc] init];
        sharedLoader = [self retain];
    }
    return self;
}

-(void)dealloc {
    [files release];
    [super dealloc];
}


-(NSArray *)types {
    return [[MZPluginController sharedInstance] dataProviderTypes];
}

-(void)removeAllObjects
{
    [self willChangeValueForKey:@"files"];
    [files removeAllObjects];
    [self didChangeValueForKey:@"files"];
}


-(BOOL)loadFromFile:(NSString *)fileName
{
    return [self loadFromFile:fileName toIndex:[files count]];
}

-(BOOL)loadFromFiles:(NSArray *)fileNames
{
    return [self loadFromFiles:fileNames toIndex:[files count]];
}

- (BOOL)loadFromFile:(NSString *)fileName toIndex:(NSUInteger)index
{
    NSAssert(fileName, @"Provided fileName");
    return [self loadFromFiles:[NSArray arrayWithObject:fileName] toIndex:index];
}

- (BOOL)loadFromFiles:(NSArray *)fileNames toIndex:(NSUInteger)index
{
    NSAssert(fileNames, @"Provided filenames");
    if([fileNames count]==0)
        return YES;
    return [self loadFromFiles:fileNames
                     toIndexes:[NSIndexSet indexSetWithIndexesInRange:
                    NSMakeRange(index, [fileNames count])]];
}

- (BOOL)loadFromFiles:(NSArray *)fileNames toIndexes:(NSIndexSet*)indexes
{
    NSAssert(fileNames, @"Provided filenames");
    if([fileNames count]==0)
        return YES;
    NSAssert([fileNames count]==[indexes count], @"Count of indexes and filenames");

    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:[fileNames count]];
    int missingType = 0;
    MZVideoType def = [[NSUserDefaults standardUserDefaults] integerForKey:@"incomingVideoType"];
    for ( NSString* fileName in fileNames )
    {
        //NSLog(@"Loading file '%@'", fileName);
        MetaEdits* edits = [[MZPluginController sharedInstance] loadDataFromFile:fileName];
        if(edits)
        {
            if(![edits videoType])
            {
                if(def<=MZUnsetVideoType)
                    missingType++;
                else
                    [edits setVideoType:def];
            }
            [arr addObject:edits];
        }
        else
            NSLog(@"Could no load file '%@'", fileName);
    }
    if(missingType>0)
    {
        def = MZUnsetVideoType;
        NSInteger lastSelection = -1;
        for(MetaEdits* edits in arr)
        {
            if(![edits videoType])
            {
                missingType--;
                BOOL applyAll = NO;
                if(def == MZUnsetVideoType)
                {
                    NSAlert* alert = [[NSAlert alloc] init];
                    [alert setMessageText:
                        [NSString stringWithFormat:
                            NSLocalizedString(@"Video type for file \"%@\" could not be determined", @"Video type prompt"),
                            [edits fileName]]];
                    NSPopUpButton* sel = [[NSPopUpButton alloc] 
                        initWithFrame:NSMakeRect(0, 0, 145, 25)
                            pullsDown:NO];
                        
                    [sel addItemWithTitle:NSLocalizedString(@"Movie", @"Video type")];
                    [sel addItemWithTitle:NSLocalizedString(@"Normal", @"Video type")];
                    [sel addItemWithTitle:NSLocalizedString(@"Audiobook", @"Video type")];
                    [sel addItemWithTitle:NSLocalizedString(@"Whacked Bookmark", @"Video type")];
                    [sel addItemWithTitle:NSLocalizedString(@"Music Video", @"Video type")];
                    [sel addItemWithTitle:NSLocalizedString(@"Short Film", @"Video type")];
                    [sel addItemWithTitle:NSLocalizedString(@"TV Show", @"Video type")];
                    [sel addItemWithTitle:NSLocalizedString(@"Booklet", @"Video type")];
                
                    if(lastSelection>=0)
                        [sel selectItemAtIndex:lastSelection];

                    [alert setAccessoryView:sel];
                    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"Button")];
                    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Button")];

                    if(missingType>0)
                    {
                        [alert setShowsSuppressionButton:YES];
                        [[alert suppressionButton] setTitle:
                            NSLocalizedString(@"Apply to all", @"Confirmation text")];
                    }
                    
                    NSInteger returnCode = [alert runModal];
                    lastSelection = [sel indexOfSelectedItem];
                    if(missingType>0)
                        applyAll = [[alert suppressionButton] state] == NSOnState;

                    [sel release];
                    [alert release];

                    if(returnCode == NSAlertFirstButtonReturn)
                    {
                        switch (lastSelection) {
                            case 0:
                                def = MZMovieVideoType;
                                break;
                            case 1:
                                def = MZNormalVideoType;
                                break;
                            case 2:
                                def = MZAudiobookVideoType;
                                break;
                            case 3:
                                def = MZWhackedBookmarkVideoType;
                                break;
                            case 4:
                                def = MZMusicVideoType;
                                break;
                            case 5:
                                def = MZShortFilmVideoType;
                                break;
                            case 6:
                                def = MZTVShowVideoType;
                                break;
                            case 7:
                                def = MZBookletVideoType;
                                break;
                        }
                    } else
                        return NO;
                }
                if(def!=-1)
                    [edits setVideoType:def];
                if(!applyAll)
                    def = -1;
            }
        }
    }
    [self willChangeValueForKey:@"files"];
    [files insertObjects:arr atIndexes:indexes];
    [self didChangeValueForKey:@"files"];
    return YES;
}

- (void)moveObjects:(NSArray *)objects toIndex:(NSUInteger)index
{
    [self willChangeValueForKey:@"files"];
    NSMutableIndexSet* idx = [[[NSMutableIndexSet alloc] init] autorelease];
    for(MetaEdits* edit in objects)
    {
        for(int i=[files count]-1; i>=0; i--)
        {
            MetaEdits* ob = [files objectAtIndex:i];
            if(ob == edit)
                [idx addIndex:i];
        }
    }
    [files removeObjectsAtIndexes:idx];

    index -= [idx countOfIndexesInRange:NSMakeRange(0, index)];
    for(int i=[objects count]-1; i>=0; i--)
    {
        [files insertObject:[objects objectAtIndex:i] atIndex:index];
    }
    [self didChangeValueForKey:@"files"];
}

- (void)reloadEdits:(MetaEdits *)edits
{
    [self willChangeValueForKey:@"files"];
    [files addObject:edits];
    [self didChangeValueForKey:@"files"];
}

@end
