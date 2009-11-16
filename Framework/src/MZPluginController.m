//
//  MZPluginController.m
//  MetaZ
//
//  Created by Brian Olsen on 26/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MZPluginController.h>
#import "MZPlugin+Private.h"

@interface MZWriteNotification : NSObject <MZDataWriteDelegate>
{
    id<MZDataWriteDelegate> delegate;
}

+ (id)notifierWithDelegate:(id<MZDataWriteDelegate>)delegate;
- (id)initWithDelegate:(id<MZDataWriteDelegate>)delegate;

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
@synthesize delegate;

static MZPluginController *gInstance = NULL;

+ (NSArray *)pluginPaths
{
    //NSFileManager *mgr = [NSFileManager defaultManager];
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
    return self;
}

- (void)dealloc
{
    [plugins release];
    [loadedPlugins release];
    [typesCache release];
    [super dealloc];
}

- (NSArray *)plugins
{
    if(!plugins)
    {
        NSMutableArray* thePlugins = [NSMutableArray array];
        NSArray* paths = [[self class] pluginPaths];
        NSFileManager* mgr = [NSFileManager defaultManager];
        for(NSString* path in paths)
        {
            BOOL isDir = NO;
            NSError* error = nil;
            if([mgr fileExistsAtPath:path isDirectory:&isDir] && isDir)
            {
                NSArray* pluginPaths = [mgr contentsOfDirectoryAtPath:path error:&error];
                if(!pluginPaths)
                {
                    NSLog(@"Failed to get contents of dir '%@' because: %@", path, [error localizedDescription]);
                    continue;
                }
                for(NSString* pluginDir in pluginPaths)
                {
                    NSString* pluginPath = [path stringByAppendingPathComponent:pluginDir];
                    NSBundle* plugin = [NSBundle bundleWithPath:pluginPath];
                    if(plugin)
                        [thePlugins addObject:plugin];
                    else
                        NSLog(@"Failed to load plugin at path '%@'", pluginPath);
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
        NSArray* thePlugins = [self plugins];
        for(NSBundle* bundle in thePlugins)
        {
            NSError* error = nil;
            if(![bundle loadAndReturnError:&error])
            {
                NSLog(@"Failed to load code for '%@' because: %@", 
                    [bundle bundleIdentifier],
                    [error localizedDescription]);
                continue;
            }
            Class cls = [bundle principalClass];
            if(cls == Nil)
            {
                NSLog(@"Error loading principal class for '%@'", 
                    [bundle bundleIdentifier]);
                continue;
            }
            MZPlugin* plugin = [[cls alloc] init];
            [loadedPlugins addObject:plugin];
            [plugin release];
            NSLog(@"Loaded plugin '%@'", [bundle bundleIdentifier]);
            if([[self delegate] respondsToSelector:@selector(pluginController:loadedPlugin:)])
                [[self delegate] pluginController:self loadedPlugin:plugin];
        }
        [self didChangeValueForKey:@"loadedPlugins"];
    }
    return loadedPlugins;
}

- (BOOL)unloadPlugin:(MZPlugin *)plugin
{
    if([plugin canUnload])
    {
        [self willChangeValueForKey:@"loadedPlugins"];
        NSBundle* bundle = [NSBundle bundleForClass:[plugin class]];
        [typesCache release];
        typesCache = nil;
        [loadedPlugins removeObject:plugin]; // This should free the plugin object
        [self didChangeValueForKey:@"loadedPlugins"];
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
    for(MZPlugin* plugin in [self loadedPlugins])
    {
        NSBundle* bundle = [NSBundle bundleForClass:[plugin class]];
        if([[bundle bundleIdentifier] isEqualToString:identifier])
            return plugin;
    }
    return nil;
}

- (MZPlugin *)pluginWithPath:(NSString *)path
{
    for(MZPlugin* plugin in [self loadedPlugins])
    {
        NSBundle* bundle = [NSBundle bundleForClass:[plugin class]];
        if([[bundle bundlePath] isEqualToString:path])
            return plugin;
    }
    return nil;
}

- (id<MZDataProvider>)dataProviderWithIdentifier:(NSString *)identifier
{
    for(MZPlugin* plugin in [self loadedPlugins])
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
    for(MZPlugin* plugin in [self loadedPlugins])
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
    NSString* uti = [[NSWorkspace sharedWorkspace] typeOfFile:path error:NULL];
    if(!uti)
        return nil;
    return [self dataProviderForType:uti];
}

- (NSArray *)dataProviderTypes
{
    if(!typesCache)
    {
        NSMutableArray* ret = [NSMutableArray array];
        for(MZPlugin* plugin in [self loadedPlugins])
        {
            NSArray* dataProviders = [plugin dataProviders];
            for(id<MZDataProvider> provider in dataProviders)
            {
                NSArray* types = [provider types];
                [ret addObjectsFromArray:types];
            }
        }
        typesCache = [[NSArray alloc] initWithArray:ret];
    }
    return typesCache;
}

- (id<MZSearchProvider>)searchProviderWithIdentifier:(NSString *)identifier
{
    for(MZPlugin* plugin in [self loadedPlugins])
    {
        NSArray* searchProviders = [plugin searchProviders];
        for(id<MZSearchProvider> provider in searchProviders)
            if([[provider identifier] isEqualToString:identifier])
                return provider;
    }
    return nil;
}

-(void)fixTitle:(MetaEdits* )edits {
    NSAssert([[edits fileName] isKindOfClass:[NSString class]], @"Bad file name");
    NSAssert([[edits title] isKindOfClass:[NSString class]], @"Bad title");
    /*
    NSString* title = [edits title];
    if(title == nil)
    {
        [[edits undoManager] disableUndoRegistration];
        NSString* newTitle = [loadedFileName substringToIndex:[loadedFileName length] - [[loadedFileName pathExtension] length] - 1];
        [edits setTitle:newTitle];
        [[edits undoManager] enableUndoRegistration];
    }
    */
}

- (MetaEdits *)loadDataFromFile:(NSString *)path
{
    id<MZDataProvider> provider = [self dataProviderForPath:path];
    if(!provider)
        return nil;
    MetaLoaded* loaded = [provider loadFromFile:path];
    id next = nil;
    if([[self delegate] respondsToSelector:@selector(pluginController:extraMetaDataForProvider:loaded:)])
    {
        next = [[self delegate] pluginController:self
                        extraMetaDataForProvider:provider
                                          loaded:loaded];
    }
    if(!next)
        next = loaded;
    MetaEdits* edits = [[MetaEdits alloc] initWithProvider:next];
    [self fixTitle:edits];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:edits forKey:MZMetaEditsNotificationKey];
    [[NSNotificationCenter defaultCenter]
            postNotificationName:MZDataProviderLoadedNotification
                          object:provider
                        userInfo:userInfo];
    return [edits autorelease];
}

- (id<MZDataWriteController>)saveChanges:(MetaEdits *)data
                                delegate:(id<MZDataWriteDelegate>)theDelegate
{
    NSFileManager* mgr = [NSFileManager defaultManager];
    BOOL isDir;
    if(![mgr fileExistsAtPath:[data loadedFileName] isDirectory:&isDir] || isDir )
        return nil;
    id<MZDataProvider> provider = [data owner];
    id<MZDataWriteDelegate> otherDelegate = [MZWriteNotification notifierWithDelegate:theDelegate];
    return [provider saveChanges:data delegate:otherDelegate];
}

- (void)searchAllWithData:(NSDictionary *)data
                 delegate:(id<MZSearchProviderDelegate>)theDelegate
{
    MZSearchDelegate* searchDelegate = [MZSearchDelegate searchWithDelegate:theDelegate];
    for(MZPlugin* plugin in [self loadedPlugins])
    {
        NSArray* searchProviders = [plugin searchProviders];
        for(id<MZSearchProvider> provider in searchProviders)
        {
            if([provider searchWithData:data delegate:searchDelegate])
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
          controller:(id<MZDataWriteController>)controller
        writeStartedForEdits:(MetaEdits *)edits
{
    NSArray* keys = [NSArray arrayWithObjects:MZMetaEditsNotificationKey, MZDataWriteControllerNotificationKey, nil];
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
          controller:(id<MZDataWriteController>)controller
        writeCanceledForEdits:(MetaEdits *)edits
{
    NSArray* keys = [NSArray arrayWithObjects:MZMetaEditsNotificationKey, MZDataWriteControllerNotificationKey, nil];
    NSArray* values = [NSArray arrayWithObjects:edits, controller, nil];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [[NSNotificationCenter defaultCenter]
            postNotificationName:MZDataProviderWritingCanceledNotification
                          object:provider
                        userInfo:userInfo];
    if([delegate respondsToSelector:@selector(dataProvider:controller:writeCanceledForEdits:)])
        [delegate dataProvider:provider controller:controller writeCanceledForEdits:edits];
}

- (void)dataProvider:(id<MZDataProvider>)provider
          controller:(id<MZDataWriteController>)controller
        writeFinishedForEdits:(MetaEdits *)edits percent:(int)percent
{
    if([delegate respondsToSelector:@selector(dataProvider:controller:writeFinishedForEdits:percent:)])
        [delegate dataProvider:provider controller:controller writeFinishedForEdits:edits percent:percent];
}

- (void)dataProvider:(id<MZDataProvider>)provider
          controller:(id<MZDataWriteController>)controller
        writeFinishedForEdits:(MetaEdits *)edits
{
    NSArray* keys = [NSArray arrayWithObjects:MZMetaEditsNotificationKey, MZDataWriteControllerNotificationKey, nil];
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
        /*
        NSArray* keys = [NSArray arrayWithObjects:MZMetaEditsNotificationKey, MZDataWriteControllerNotificationKey, nil];
        NSArray* values = [NSArray arrayWithObjects:edits, controller, nil];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        */
        if([delegate respondsToSelector:@selector(searchFinished)])
            [delegate searchFinished];
        [[NSNotificationCenter defaultCenter]
                postNotificationName:MZSearchFinishedNotification
                              object:[MZPluginController sharedInstance]
                            userInfo:nil];
    }
}

@end

