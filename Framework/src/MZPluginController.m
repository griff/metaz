//
//  MZPluginController.m
//  MetaZ
//
//  Created by Brian Olsen on 26/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MZPluginController.h>
#import <MetaZKit/MZLogger.h>
#import <MetaZKit/NSFileManager+MZCreate.h>
#import <MetaZKit/MZScriptActionsPlugin.h>
#import <MetaZKit/GTMNSString+URLArguments.h>
#import "MZPlugin+Private.h"

@interface MZWriteNotification : NSObject <MZDataWriteDelegate>
{
    id<MZDataWriteDelegate> delegate;
}

+ (id)notifierWithDelegate:(id<MZDataWriteDelegate>)delegate;
- (id)initWithDelegate:(id<MZDataWriteDelegate>)delegate;

@end


@interface MZReadNotification : NSObject <MZDataReadDelegate>
{
    MZPluginController* controller;
    id<MZEditsReadDelegate> delegate;
}

+ (id)notifierWithController:(MZPluginController *)controller
                    delegate:(id<MZEditsReadDelegate>)delegate;
- (id)initWithController:(MZPluginController *)controller
                delegate:(id<MZEditsReadDelegate>)delegate;

@end


@interface MZSearchDelegate : NSObject <MZSearchProviderDelegate>
{
    id<MZSearchProviderDelegate> delegate;
    NSUInteger performedSearches;
    NSUInteger finishedSearches;
}
@property (readonly) NSUInteger performedSearches;
@property (readonly) NSUInteger finishedSearches;

+ (id)searchWithDelegate:(id<MZSearchProviderDelegate>)delegate;
- (id)initWithSearchDelegate:(id<MZSearchProviderDelegate>)delegate;

- (void)performedSearch;

@end


@implementation MZPluginController

+ (NSSet *)keyPathsForValuesAffectingDataProviderTypes
{
    return [NSSet setWithObjects:@"activePlugins", nil];
}

+ (NSArray *)pluginPaths
{
    //NSFileManager *mgr = [NSFileManager manager];
    NSMutableArray* ret = [NSMutableArray arrayWithCapacity:5];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSAllDomainsMask, YES);
    for(NSString * path in paths)
    {
            NSString *destinationDir = [[path
                        stringByAppendingPathComponent:@"MetaZ"]
                        stringByAppendingPathComponent:@"Plugins"];
            [ret addObject:destinationDir];
    }
    [ret addObject:[[NSBundle mainBundle] builtInPlugInsPath]];
    return [NSArray arrayWithArray:ret];
}

+ (NSString *)extractTitleFromFilename:(NSString *)fileName
{
    NSString* basefile = [fileName lastPathComponent];
    NSString* newTitle = [basefile substringToIndex:[basefile length] - [[basefile pathExtension] length] - 1];
    newTitle = [newTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([newTitle hasSuffix:@"]"])
    {
        NSInteger len = [newTitle length];
        NSScanner* scanner = [NSScanner scannerWithString:newTitle];
        [scanner setCharactersToBeSkipped:nil];
        [scanner setScanLocation:len-6];
        NSString* temp;
        if([scanner scanString:@"[" intoString:&temp])
        {
            if([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&temp])
            {
                if([scanner scanString:@"]" intoString:&temp] && [scanner scanLocation]==len)
                    newTitle = [newTitle substringToIndex:len-6];
            }
        }
    }
    else if([newTitle hasSuffix:@")"])
    {
        NSInteger len = [newTitle length];
        NSScanner* scanner = [NSScanner scannerWithString:newTitle];
        [scanner setCharactersToBeSkipped:nil];
        [scanner setScanLocation:len-6];
        NSString* temp;
        if([scanner scanString:@"(" intoString:&temp])
        {
            if([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&temp])
            {
                if([scanner scanString:@")" intoString:&temp] && [scanner scanLocation]==len)
                    newTitle = [newTitle substringToIndex:len-6];
            }
        }
    }
    newTitle = [newTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return newTitle;
}

static MZPluginController *gInstance = NULL;

+ (MZPluginController *)sharedInstance
{
    @synchronized(self)
    {
        if (gInstance == NULL)
            gInstance = [[self alloc] init];
    }
    return gInstance;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        loadQueue = [[NSOperationQueue alloc] init];
        saveQueue = [[NSOperationQueue alloc] init];
        searchQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [plugins release];
    [loadedPlugins release];
    [loadQueue release];
    [saveQueue release];
    [searchQueue release];
    [super dealloc];
}

@synthesize delegate;
@synthesize loadQueue;
@synthesize saveQueue;
@synthesize searchQueue;

- (NSArray *)plugins
{
    if(!plugins)
    {
        NSMutableArray* thePlugins = [NSMutableArray array];
        NSArray* paths = [[self class] pluginPaths];
        NSFileManager* mgr = [NSFileManager manager];
        for(NSString* path in paths)
        {
            NSURL* pathURL = [NSURL fileURLWithPath:path];
            BOOL isDir = NO;
            NSError* error = nil;
            if([mgr fileExistsAtPath:path isDirectory:&isDir] && isDir)
            {
                NSArray* pluginPaths = [mgr contentsOfDirectoryAtPath:path error:&error];
                if(!pluginPaths)
                {
                    MZLoggerError(@"Failed to get contents of dir '%@' because: %@", path, [error localizedDescription]);
                    continue;
                }
                for(NSString* pluginDir in pluginPaths)
                {
                    NSString* pluginPath = [path stringByAppendingPathComponent:pluginDir];
                    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[pluginPath pathExtension], NULL);
                    MZLoggerDebug(@"Loading plugin at path '%@'", pluginPath);
                    if(UTTypeConformsTo(uti, kMZUTMetaZPlugin))
                    {
                        NSBundle* plugin = [NSBundle bundleWithPath:pluginPath];
                        if(plugin)
                            [thePlugins addObject:plugin];
                        else
                            MZLoggerError(@"Failed to load plugin at path '%@'", pluginPath);
                    }
                    else if(UTTypeEqual(uti, kMZUTAppleScriptText) || UTTypeConformsTo(uti, kMZUTAppleScriptText) ||
                            UTTypeEqual(uti, kMZUTAppleScript) || UTTypeConformsTo(uti, kMZUTAppleScript))
                    {
                        NSURL* url = [NSURL URLWithString:[pluginDir gtm_stringByEscapingForURLArgument] relativeToURL:pathURL];
                        MZScriptActionsPlugin* plugin = [MZScriptActionsPlugin pluginWithURL:url];
                        [thePlugins addObject:plugin];
                    }
                    CFRelease(uti);
                }
            }
        }
        plugins = [[NSArray alloc] initWithArray:thePlugins];
    }
    return plugins;
}

- (NSArray *)loadedPlugins
{
    if(!loadedPlugins)
    {
        [self willChangeValueForKey:@"loadedPlugins"];
        loadedPlugins = [[NSMutableArray alloc] init];
        NSMutableSet* loadedBundles = [NSMutableSet set];
        NSArray* thePlugins = [self plugins];
        for(id source in thePlugins)
        {
            NSString* identifier;
            if([source isKindOfClass:[NSBundle class]])
                identifier = [source bundleIdentifier];
            else if([source isKindOfClass:[MZScriptActionsPlugin class]])
                identifier = [source identifier];
            else
                MZLoggerError(@"Unknown plugin %@ of type %@", source, NSStringFromClass([source class])); 
            
            // the plugins are in the order they should be loaded
            // so if the same identifier is allready loaded we can skib to
            // next
            if([loadedBundles containsObject:identifier])
                continue;
                
            MZPlugin* plugin;
            NSError* error = nil;
            if(![source loadAndReturnError:&error])
            {
                MZLoggerError(@"Failed to load code for '%@' because: %@", 
                    identifier,
                    [error localizedDescription]);
                continue;
            }
                
            if([source isKindOfClass:[NSBundle class]])
            {
                Class cls = [source principalClass];
                if(cls == Nil)
                {
                    MZLoggerError(@"Error loading principal class for '%@'", 
                        identifier);
                    continue;
                }
                
                plugin = [[cls alloc] init];
                if(!plugin)
                {
                    MZLoggerError(@"Failed to create principal class '%@' for '%@'", 
                        NSStringFromClass(cls),
                        identifier);
                    [source unload];
                    continue;
                }
            }
            else
                plugin = [source retain];

            [loadedBundles addObject:identifier];
            [loadedPlugins addObject:plugin];
            [plugin release];
            MZLoggerInfo(@"Loaded plugin '%@'", identifier);
            [plugin didLoad];
            if([[self delegate] respondsToSelector:@selector(pluginController:loadedPlugin:)])
                [[self delegate] pluginController:self loadedPlugin:plugin];
        }
        [self didChangeValueForKey:@"loadedPlugins"];
    }
    return loadedPlugins;
}

- (void)updateActivePlugins
{
    NSArray* disabledA = [[NSUserDefaults standardUserDefaults] arrayForKey:DISABLED_KEY];
    NSSet* disabled;
    if(disabledA)
        disabled = [NSSet setWithArray:disabledA];
    else
        disabled = [NSSet set];
    
    [self willChangeValueForKey:@"activePlugins"];
    activePlugins = [[NSMutableArray alloc] init];
    for(MZPlugin* plugin in [self loadedPlugins])
    {
        if(![disabled containsObject:[[plugin bundle] bundleIdentifier]])
            [activePlugins addObject:plugin];
        else
            MZLoggerInfo(@"Disabled plugin '%@'", [[plugin bundle] bundleIdentifier]);
    }
    [self didChangeValueForKey:@"activePlugins"];
}

- (NSArray *)activePlugins
{
    if(!activePlugins)
        [self updateActivePlugins];
    return activePlugins;
}


- (BOOL)unloadPlugin:(MZPlugin *)plugin
{
    if([plugin canUnload])
    {
        [plugin willUnload];
        [self willChangeValueForKey:@"loadedPlugins"];
        NSBundle* bundle = [plugin bundle];
        [loadedPlugins removeObject:plugin]; // This should free the plugin object
        [self didChangeValueForKey:@"loadedPlugins"];
        [self updateActivePlugins];
        if([bundle unload])
        {
            if([[self delegate] respondsToSelector:
                @selector(pluginController:unloadedPlugin:)])
            {
                [[self delegate] pluginController:self
                                  unloadedPlugin:[bundle bundleIdentifier]];
            }
            return YES;                      
        }

    }
    return NO;
}

- (MZPlugin *)pluginWithIdentifier:(NSString *)identifier
{
    for(MZPlugin* plugin in [self activePlugins])
    {
        NSBundle* bundle = [plugin bundle];
        if([[bundle bundleIdentifier] isEqualToString:identifier])
            return plugin;
    }
    return nil;
}

- (MZPlugin *)pluginWithPath:(NSString *)path
{
    for(MZPlugin* plugin in [self activePlugins])
    {
        NSBundle* bundle = [plugin bundle];
        if([[bundle bundlePath] isEqualToString:path])
            return plugin;
    }
    return nil;
}

- (id<MZDataProvider>)dataProviderWithIdentifier:(NSString *)identifier
{
    for(MZPlugin* plugin in [self activePlugins])
    {
        NSArray* dataProviders = [plugin dataProviders];
        for(id<MZDataProvider> provider in dataProviders)
            if([[provider identifier] isEqualToString:identifier])
                return provider;
    }
    return nil;
}

- (id<MZDataProvider>)dataProviderForType:(NSString *)uti
{
    for(MZPlugin* plugin in [self activePlugins])
    {
        NSArray* dataProviders = [plugin dataProviders];
        for(id<MZDataProvider> provider in dataProviders)
        {
            NSArray* types = [provider types];
            for(NSString* type in types)
            {
                if(UTTypeConformsTo((CFStringRef)uti, (CFStringRef)type))
                    return provider;
            }
        }
    }
    return nil;
}

- (id<MZDataProvider>)dataProviderForPath:(NSString *)path
{
    NSArray* types = (NSArray*)UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, (CFStringRef)[path pathExtension], kUTTypeMovie);
    for(NSString* uti in types)
    {
        id<MZDataProvider> ret = [self dataProviderForType:uti];
        if(ret)
        {
            [types release];
            return ret;
        }
    }
    [types release];
    return nil;
}

- (NSArray *)dataProviderTypes
{
    NSMutableArray* ret = [NSMutableArray array];
    for(MZPlugin* plugin in [self activePlugins])
    {
        NSArray* dataProviders = [plugin dataProviders];
        for(id<MZDataProvider> provider in dataProviders)
        {
            NSArray* types = [provider types];
            [ret addObjectsFromArray:types];
        }
    }
    return [NSArray arrayWithArray:ret]; 
}

- (id<MZSearchProvider>)searchProviderWithIdentifier:(NSString *)identifier
{
    for(MZPlugin* plugin in [self activePlugins])
    {
        NSArray* searchProviders = [plugin searchProviders];
        for(id<MZSearchProvider> provider in searchProviders)
            if([[provider identifier] isEqualToString:identifier])
                return provider;
    }
    return nil;
}

- (id<MZDataController>)loadFromFile:(NSString *)fileName
                            delegate:(id<MZEditsReadDelegate>)theDelegate
                               extra:(NSDictionary *)extra
{
    id<MZDataProvider> provider = [self dataProviderForPath:fileName];
    if(!provider)
        return nil;

    id<MZDataReadDelegate> otherDelegate = [MZReadNotification notifierWithController:self delegate:theDelegate];
    return [provider loadFromFile:fileName delegate:otherDelegate queue:loadQueue extra:extra];
}

- (id<MZDataController>)saveChanges:(MetaEdits *)data
                           delegate:(id<MZDataWriteDelegate>)theDelegate
{
    id<MZDataProvider> provider = [data owner];
    id<MZDataWriteDelegate> otherDelegate = [MZWriteNotification notifierWithDelegate:theDelegate];
    return [provider saveChanges:data delegate:otherDelegate queue:saveQueue];
}

- (void)searchAllWithData:(NSDictionary *)data
                 delegate:(id<MZSearchProviderDelegate>)theDelegate
{
    MZSearchDelegate* searchDelegate = [MZSearchDelegate searchWithDelegate:theDelegate];
    for(MZPlugin* plugin in [self activePlugins])
    {
        NSArray* searchProviders = [plugin searchProviders];
        for(id<MZSearchProvider> provider in searchProviders)
        {
            if([provider searchWithData:data delegate:searchDelegate queue:searchQueue])
                [searchDelegate performedSearch];
        }
    }
    if(searchDelegate.performedSearches == 0)
    {
        [searchDelegate performedSearch];
        [searchDelegate searchFinished];
    }
}

@end


@implementation MZWriteNotification

+ (id)notifierWithDelegate:(id<MZDataWriteDelegate>)delegate
{
    return [[[self alloc] initWithDelegate:delegate] autorelease];
}

- (id)initWithDelegate:(id<MZDataWriteDelegate>)theDelegate
{
    self = [super init];
    if(self)
        delegate = [theDelegate retain];
    return self;
}

- (void)dealloc
{
    [delegate release];
    [super dealloc];
}

- (void)dataProvider:(id<MZDataProvider>)provider
          controller:(id<MZDataController>)controller
        writeStartedForEdits:(MetaEdits *)edits
{
    NSArray* keys = [NSArray arrayWithObjects:MZMetaEditsNotificationKey, MZDataControllerNotificationKey, nil];
    NSArray* values = [NSArray arrayWithObjects:edits, controller, nil];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [[NSNotificationCenter defaultCenter]
            postNotificationName:MZDataProviderWritingStartedNotification
                          object:provider
                        userInfo:userInfo];
    if([delegate respondsToSelector:@selector(dataProvider:controller:writeStartedForEdits:)])
        [delegate dataProvider:provider controller:controller writeStartedForEdits:edits];
}

- (void)dataProvider:(id<MZDataProvider>)provider
          controller:(id<MZDataController>)controller
        writeCanceledForEdits:(MetaEdits *)edits
            error:(NSError *)error
{
    NSArray* keys;
    NSArray* values;
    if(error)
    {
        keys = [NSArray arrayWithObjects:MZMetaEditsNotificationKey, 
                MZDataControllerNotificationKey, 
                MZDataControllerErrorKey, nil];
        values = [NSArray arrayWithObjects:edits, controller, error, nil];
    }
    else
    {
        keys = [NSArray arrayWithObjects:MZMetaEditsNotificationKey, 
                MZDataControllerNotificationKey, nil];
        values = [NSArray arrayWithObjects:edits, controller, nil];
    }

    NSDictionary* userInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [[NSNotificationCenter defaultCenter]
            postNotificationName:MZDataProviderWritingCanceledNotification
                          object:provider
                        userInfo:userInfo];
    if([delegate respondsToSelector:@selector(dataProvider:controller:writeCanceledForEdits:error:)])
        [delegate dataProvider:provider controller:controller writeCanceledForEdits:edits error:error];
}

- (void)dataProvider:(id<MZDataProvider>)provider
          controller:(id<MZDataController>)controller
        writeFinishedForEdits:(MetaEdits *)edits percent:(int)percent
{
    if([delegate respondsToSelector:@selector(dataProvider:controller:writeFinishedForEdits:percent:)])
        [delegate dataProvider:provider controller:controller writeFinishedForEdits:edits percent:percent];
}

- (void)dataProvider:(id<MZDataProvider>)provider
          controller:(id<MZDataController>)controller
        writeFinishedForEdits:(MetaEdits *)edits
{
    NSArray* keys = [NSArray arrayWithObjects:MZMetaEditsNotificationKey, MZDataControllerNotificationKey, nil];
    NSArray* values = [NSArray arrayWithObjects:edits, controller, nil];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [[NSNotificationCenter defaultCenter]
            postNotificationName:MZDataProviderWritingFinishedNotification
                          object:provider
                        userInfo:userInfo];

    if([delegate respondsToSelector:@selector(dataProvider:controller:writeFinishedForEdits:)])
        [delegate dataProvider:provider controller:controller writeFinishedForEdits:edits];
}

@end


@implementation MZReadNotification

+ (id)notifierWithController:(MZPluginController *)controller
                    delegate:(id<MZEditsReadDelegate>)delegate
{
    return [[[self alloc] initWithController:controller delegate:delegate] autorelease];
}

- (id)initWithController:(MZPluginController *)theController
                delegate:(id<MZEditsReadDelegate>)theDelegate
{
    self = [super init];
    if(self)
    {
        controller = [theController retain];
        delegate = [theDelegate retain];
    }
    return self;
}

- (void)dealloc
{
    [controller release];
    [delegate release];
    [super dealloc];
}

- (void)dataProvider:(id<MZDataProvider>)provider
          controller:(id<MZDataController>)theController
          loadedMeta:(MetaLoaded *)loaded
            fromFile:(NSString *)fileName
               error:(NSError *)error
{
    MetaEdits* edits = nil;
    if(loaded)
    {
        id next = nil;
        if([[controller delegate] respondsToSelector:@selector(pluginController:extraMetaDataForProvider:loaded:)])
        {
            next = [[controller delegate] pluginController:controller
                                  extraMetaDataForProvider:provider
                                                    loaded:loaded];
        }
        if(!next)
            next = loaded;
        edits = [MetaEdits editsWithProvider:next];
        NSAssert([[edits fileName] isKindOfClass:[NSString class]], @"Bad file name");
        NSAssert([[edits title] isKindOfClass:[NSString class]], @"Bad title");
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:edits forKey:MZMetaEditsNotificationKey];
        [[NSNotificationCenter defaultCenter]
                postNotificationName:MZDataProviderLoadedNotification
                              object:provider
                            userInfo:userInfo];
    }
    [delegate dataProvider:provider controller:theController loadedEdits:edits fromFile:fileName error:error];
}

@end


@implementation MZSearchDelegate
@synthesize performedSearches;
@synthesize finishedSearches;

+ (id)searchWithDelegate:(id<MZSearchProviderDelegate>)theDelegate
{
    return [[[MZSearchDelegate alloc] initWithSearchDelegate:theDelegate] autorelease];
}

- (id)initWithSearchDelegate:(id<MZSearchProviderDelegate>)theDelegate
{
    self = [super init];
    if(self)
    {
        delegate = [theDelegate retain];
    }
    return self;
}

- (void)dealloc
{
    [delegate release];
    [super dealloc];
}

- (void)performedSearch
{
    performedSearches++;
}

- (void) searchProvider:(id<MZSearchProvider>)provider result:(NSArray*)result
{
    [delegate searchProvider:provider result:result];
}

- (void) searchFinished
{
    finishedSearches++;
    if(finishedSearches==performedSearches)
    {
        if([delegate respondsToSelector:@selector(searchFinished)])
            [delegate searchFinished];
        [[NSNotificationCenter defaultCenter]
                postNotificationName:MZSearchFinishedNotification
                              object:[MZPluginController sharedInstance]
                            userInfo:nil];
    }
}

@end

