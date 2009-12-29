//
//  MetaLoader.m
//  MetaZ
//
//  Created by Brian Olsen on 25/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZMetaLoader.h"
#import "MZWriteQueue.h"
#import "MZWriteQueueStatus.h"
#import "NSUserDefaults+KeyPath.h"

@interface LoadOperation : NSOperation
{
    NSString* filePath;
    NSUInteger index;
    MetaEdits* edits;
}

+ (id)loadWithFilePath:(NSString *)filePath atIndex:(NSUInteger )index;
- (id)initWithFilePath:(NSString *)filePath atIndex:(NSUInteger )index;

@property (readonly) NSString* filePath;
@property (readonly) NSUInteger index;
@property (readonly) MetaEdits* edits;

- (void)main;

@end


@interface MZMetaLoader (Private)

- (void)loadedFile:(LoadOperation *)operation;

@end


@implementation MZMetaLoader
@synthesize files;

#pragma mark - initialization 

static MZMetaLoader* sharedLoader = nil;

+(MZMetaLoader *)sharedLoader
{
    if(!sharedLoader)
        [[[MZMetaLoader alloc] init] release];
    return sharedLoader;
}

-(id)init
{
    self = [super init];

    if(sharedLoader)
    {
        [self release];
        self = [sharedLoader retain];
    } else if(self)
    {
        files = [[NSMutableArray alloc] init];
        queue = [[NSOperationQueue alloc] init];
        loading = [[NSMutableArray alloc] init];
        sharedLoader = [self retain];
    }
    return self;
}

-(void)dealloc
{
    [files release];
    [queue release];
    [loading release];
    [super dealloc];
}


-(NSArray *)types
{
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
    
    BOOL suppressAlreadyLoadedWarning = [[NSUserDefaults standardUserDefaults]
        boolForKeyPath:MZDataProviderFileAlreadyLoadedWarningKey];
    NSMutableArray* realFileNames = [NSMutableArray arrayWithArray:fileNames];
    NSMutableIndexSet* realIndexes = [[[NSMutableIndexSet alloc] initWithIndexSet:indexes] autorelease];
        
    NSArray* loadedFileNames = [files arrayByPerformingKeyPath:@"loadedFileName"];
    NSMutableArray* queuedFileNames = [NSMutableArray array];
    for(MZWriteQueueStatus* status in [[MZWriteQueue sharedQueue] queueItems])
    {
        if(![status completed])
            [queuedFileNames addObject:[[status edits] loadedFileName]];
    }
    NSInteger index = [indexes lastIndex];
    for(NSInteger i=[fileNames count]-1; i>=0; i--)
    {
        NSString* fileName = [fileNames objectAtIndex:i];
        NSInteger idx = [loadedFileNames indexOfObject:fileName];
        BOOL inQueue = NO;
        BOOL inLoading = NO;
        if(idx == NSNotFound)
        {
            idx = [queuedFileNames indexOfObject:fileName];
            inQueue = idx != NSNotFound;
        }

        if(idx == NSNotFound)
        {
            idx = [loading indexOfObject:fileName];
            inLoading = idx != NSNotFound;
        }
            
        if(idx != NSNotFound)
        {
            NSString* basefile = [fileName lastPathComponent];
            if(!suppressAlreadyLoadedWarning)
            {
                NSAlert* alert = [[NSAlert alloc] init];
                if(inQueue)
                {
                    [alert setMessageText:
                        [NSString stringWithFormat:
                            NSLocalizedString(@"File \"%@\" is already in queue", @"Already loaded warning message"),
                                basefile]];
                }
                else if(inLoading)
                {
                    [alert setMessageText:
                        [NSString stringWithFormat:
                            NSLocalizedString(@"File \"%@\" is already being loaded", @"Already loaded warning message"),
                                basefile]];
                }
                else
                {
                    [alert setMessageText:
                        [NSString stringWithFormat:
                            NSLocalizedString(@"File \"%@\" is already loaded", @"Already loaded warning message"),
                                basefile]];
                }
                /*
                [alert setInformativeText::
                    [NSString stringWithFormat:
                        NSLocalizedString(@"Do you wish to load it anyway?", @"Already loaded title prompt"),
                            [edits fileName]]];
                */
                [alert setShowsSuppressionButton:YES];
                [alert addButtonWithTitle:NSLocalizedString(@"OK", @"Button")];

                [alert runModal];
                suppressAlreadyLoadedWarning = [[alert suppressionButton] state] == NSOnState;
                [[NSUserDefaults standardUserDefaults]
                    setBool:suppressAlreadyLoadedWarning 
                    forKeyPath:MZDataProviderFileAlreadyLoadedWarningKey];
                [alert release];
            }
            [realFileNames removeObjectAtIndex:i];
            [realIndexes removeIndex:index];
            //if(index>=[files count])
            //MZLoggerDebug(@"Shifting %d", [indexes lastIndex]);
            if([realIndexes countOfIndexesInRange:NSMakeRange(index, [indexes lastIndex]+1)] > 0)
            {
                //MZLoggerDebug(@"Shifting %d", [indexes lastIndex]);
                [realIndexes shiftIndexesStartingAtIndex:[indexes indexGreaterThanIndex:index] by:-1];
            }
        }
        index = [indexes indexLessThanIndex:index];
    }
    fileNames = realFileNames;
    indexes = realIndexes;

    if([loading count]==0)
    {
        defaultVideoType = [[NSUserDefaults standardUserDefaults] integerForKey:@"incomingVideoType"];
        lastSelection = MZUnsetVideoType;
    }

    [loading addObjectsFromArray:fileNames];

    /*
    NSMutableArray* arr = [NSMutableArray arrayWithCapacity:[fileNames count]];
    int missingType = 0;
    MZVideoType def = [[NSUserDefaults standardUserDefaults] integerForKey:@"incomingVideoType"];
    */
    index = [indexes firstIndex];
    for ( NSString* fileName in fileNames )
    {
        [queue addOperation:[LoadOperation loadWithFilePath:fileName atIndex:index]];
        index = [indexes indexGreaterThanIndex:index];
    }
    /*
    if(missingType>0)
    {
        def = MZUnsetVideoType;
        MZVideoType lastSelection = MZUnsetVideoType;
        BOOL applyAll = NO;
        for(MetaEdits* edits in arr)
        {
            if([edits videoType] == MZUnsetVideoType)
            {
                missingType--;
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
                    MZTag* tag = [MZTag tagForIdentifier:MZVideoTypeTagIdent];
                    [sel setCell:[tag editorCell]];
                    [sel setKeyEquivalent:@"t"];
                    [sel setKeyEquivalentModifierMask:NSCommandKeyMask];

                    if(lastSelection!=MZUnsetVideoType)
                        [sel selectItemWithTag:lastSelection];

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
                    lastSelection = [[sel selectedItem] tag];
                    if(missingType>0)
                        applyAll = [[alert suppressionButton] state] == NSOnState;

                    [sel release];
                    [alert release];

                    if(returnCode == NSAlertFirstButtonReturn)
                    {
                        def = lastSelection;
                    } else
                        return NO;
                }
                if(def!=MZUnsetVideoType)
                    [edits setVideoType:def];
                if(!applyAll)
                    def = MZUnsetVideoType;
            }
        }
    }
    [self willChangeValueForKey:@"files"];
    [files insertObjects:arr atIndexes:indexes];
    [self didChangeValueForKey:@"files"];
    */
    return YES;
}

- (void)loadedFile:(LoadOperation *)operation
{
    MetaEdits* edits = operation.edits;
    if(!edits)
    {
        [loading removeObject:operation.filePath];
        NSString* baseFile = [operation.filePath lastPathComponent];
        NSRunCriticalAlertPanel([NSString stringWithFormat:
            NSLocalizedString(@"The file '%@' is in an unsupported format.", @"Bad file title"), baseFile],
            @"", NSLocalizedString(@"OK", @"Button text"), nil, nil);
        MZLoggerError(@"Could no load file '%@'", operation.filePath);
        return;
    }

    if([edits videoType] == MZUnsetVideoType)
    {
        if(defaultVideoType<=MZUnsetVideoType)
        {
            NSAlert* alert = [[NSAlert alloc] init];
            [alert setMessageText:
                [NSString stringWithFormat:
                    NSLocalizedString(@"Video type for file \"%@\" could not be determined", @"Video type prompt"),
                    [edits fileName]]];
            NSPopUpButton* sel = [[NSPopUpButton alloc] 
                initWithFrame:NSMakeRect(0, 0, 145, 25)
                    pullsDown:NO];
            MZTag* tag = [MZTag tagForIdentifier:MZVideoTypeTagIdent];
            [sel setCell:[tag editorCell]];
            [sel setKeyEquivalent:@"t"];
            [sel setKeyEquivalentModifierMask:NSCommandKeyMask];

            if(lastSelection!=MZUnsetVideoType)
                [sel selectItemWithTag:lastSelection];

            [alert setAccessoryView:sel];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"Button")];
            [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Button")];

            if([loading count]>1)
            {
                [alert setShowsSuppressionButton:YES];
                [[alert suppressionButton] setTitle:
                    NSLocalizedString(@"Apply to all", @"Confirmation text")];
            }
            
            NSInteger returnCode = [alert runModal];
            lastSelection = [[sel selectedItem] tag];
            BOOL applyAll = [loading count]>1 && [[alert suppressionButton] state] == NSOnState;

            [sel release];
            [alert release];

            if(returnCode != NSAlertFirstButtonReturn)
            {
                [loading removeObject:operation.filePath];
                return;
            }
                
            [edits setVideoType:lastSelection];
            if(applyAll)
                defaultVideoType = lastSelection;
        }
        else
            [edits setVideoType:defaultVideoType];
    }
    
    NSUInteger index = operation.index;
    if(index > [files count])
        index = [files count];

    [self willChangeValueForKey:@"files"];
    [files insertObject:edits atIndex:index];
    [self didChangeValueForKey:@"files"];
    [loading removeObject:operation.filePath];
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
    [edits prepareFromQueue];
    [files addObject:edits];
    [self didChangeValueForKey:@"files"];
}

@end

@implementation LoadOperation

+ (id)loadWithFilePath:(NSString *)filePath atIndex:(NSUInteger )index
{
    return [[[self alloc] initWithFilePath:filePath atIndex:index] autorelease];
}

- (id)initWithFilePath:(NSString *)theFilePath atIndex:(NSUInteger )theIndex
{
    self = [super init];
    if(self)
    {
        filePath = [theFilePath retain];
        index = theIndex;
    }
    return self;
}

- (void)dealloc
{
    [filePath release];
    [super dealloc];
}

@synthesize edits;
@synthesize index;
@synthesize filePath;

- (void)main
{
    if(![self isCancelled])
        edits = [[MZPluginController sharedInstance] loadDataFromFile:filePath];
    [[MZMetaLoader sharedLoader] performSelectorOnMainThread:@selector(loadedFile:) 
                withObject:self
                waitUntilDone:YES
                modes:[NSArray arrayWithObject:NSDefaultRunLoopMode]]; 
}

@end

