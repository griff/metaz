//
//  MZPluginController.m
//  MetaZ
//
//  Created by Brian Olsen on 26/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MZPluginController.h>
#import "MZPlugin-Private.h"

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
    NSString* title = [edits title];
    if(title == nil)
    {
        [[edits undoManager] disableUndoRegistration];
        NSString* loadedFileName = [edits fileName];
        NSAssert(loadedFileName != nil, @"Bad loaded file name");
        NSAssert( ((NSNull*)loadedFileName) != [NSNull null], @"Bad loaded file name" );
        NSString* newTitle = [loadedFileName substringToIndex:[loadedFileName length] - [[loadedFileName pathExtension] length] - 1];
        [edits setTitle:newTitle];
        [[edits undoManager] enableUndoRegistration];
    }
}

- (MetaEdits *)loadDataFromFile:(NSString *)path
{
    id<MZDataProvider> provider = [self dataProviderForPath:path];
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
    return [edits autorelease];
}

@end
