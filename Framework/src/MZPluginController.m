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

const NSInteger errMZPluginMissingInstallLocation = -1;
const NSInteger errMZPluginAlreadyExists = -2;
const NSInteger errMZPluginFailedToCreateBundle = -3;
const NSInteger errMZPluginUnknownPluginType = -4;
const NSInteger errMZPluginAlreadyLoaded = -5;
const NSInteger errMZPluginFailedToLoadSource = -6;
const NSInteger errMZPluginFailedToLoadPrincipalClass = -7;
const NSInteger errMZPluginFailedToCreatePrincipalClass = -8;


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


@interface MZPluginController()

- (id)loadPluginSourceWithName:(NSString *)name fromURL:(NSURL *)pathURL error:(NSError **)error;
- (BOOL)loadPluginFromSource:(id)source error:(NSError **)error;
- (BOOL)loadPlugin:(NSString *)name fromURL:(NSURL *)url error:(NSError **)error;

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
        [searchQueue setMaxConcurrentOperationCount:12];
        loadedBundles = [[NSMutableSet alloc] init];
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
    [loadedBundles release];
    [super dealloc];
}

@synthesize delegate;
@synthesize loadQueue;
@synthesize saveQueue;
@synthesize searchQueue;

- (BOOL)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex
{
    if(![[error domain] isEqualToString:@"MZPluginController"] || [error code] != errMZPluginAlreadyExists)
        return NO;
    
    if(recoveryOptionIndex == 0)
    {
        NSURL* url = [[error userInfo] objectForKey:@"URL"];
        return [self installPlugin:url force:YES error:NULL];
    }
    return NO;
}

- (void)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex delegate:(id)theDelegate didRecoverSelector:(SEL)didRecoverSelector contextInfo:(void *)contextInfo
{
    BOOL ret = [self attemptRecoveryFromError:error optionIndex:recoveryOptionIndex];
    
    NSMethodSignature* sig = [theDelegate methodSignatureForSelector:didRecoverSelector];
    NSInvocation* inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv setSelector:didRecoverSelector];
    [inv setTarget:theDelegate];
    [inv setArgument:&ret atIndex:2];
    [inv setArgument:contextInfo atIndex:3];
    [inv invoke];
}

- (BOOL)installPlugin:(NSURL *)thePlugin force:(BOOL)force error:(NSError **)error;
{
    NSFileManager *mgr = [NSFileManager manager];
    NSString* thePluginPath = [thePlugin path];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    if ([paths count] == 0)
    {
        if(error)
        {
            NSDictionary* info = [NSDictionary dictionaryWithObject:@"No application support directory" forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"MZPluginController" code:errMZPluginMissingInstallLocation userInfo:info];
        }
        return NO;
    }
    
    NSString *destinationDir = [[[paths objectAtIndex:0]
                stringByAppendingPathComponent: @"MetaZ"]
                stringByAppendingPathComponent: @"Plugins"];
    BOOL isDir;
    if([mgr fileExistsAtPath:destinationDir isDirectory:&isDir])
    {
        if(!isDir)
        {
            if(![mgr removeItemAtPath:destinationDir error:error])
                return NO;
            if(![mgr createDirectoryAtPath:destinationDir withIntermediateDirectories:YES attributes:nil error:error])
                return NO;
        }
    }
    else if(![mgr createDirectoryAtPath:destinationDir withIntermediateDirectories:YES attributes:nil error:error])
        return NO;
            
    NSString* name = [thePluginPath lastPathComponent];
    NSString *destinationPath = [destinationDir stringByAppendingPathComponent:name];
                   
    if([mgr fileExistsAtPath:destinationPath isDirectory:&isDir])
    {
        if(!force)
        {
            if(error)
            {
                NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"Plugin already exists", NSLocalizedDescriptionKey,
                    [NSString stringWithFormat:@"A plugin called '%@' already exists.\nDo you wish to replace it?", name],
                        NSLocalizedRecoverySuggestionErrorKey,
                    [NSArray arrayWithObjects:@"Replace", @"Cancel", nil], NSLocalizedRecoveryOptionsErrorKey,
                    self, NSRecoveryAttempterErrorKey,
                    thePlugin, @"URL",
                nil ];
            
                *error = [NSError errorWithDomain:@"MZPluginController" code:errMZPluginAlreadyExists userInfo:info];
            }
            return NO;
        }
        MZPlugin* plg = nil;
        for(MZPlugin* plugin in [self loadedPlugins])
        {
            if([[plugin pluginPath] isEqualToString:destinationPath])
                plg = plugin;
        }
        if(plg)
            [self unloadPlugin:plg];
        if(![mgr removeItemAtPath:destinationPath error:error])
            return NO;
    }
        
    if([mgr copyItemAtPath:thePluginPath toPath:destinationPath error:error])
    {
        if(![self loadPlugin:name fromURL:[NSURL fileURLWithPath:destinationDir] error:error])
        {
            [mgr removeItemAtPath:destinationPath error:NULL];
            return NO;
        }
        return YES;
    }
    return NO;
}

- (NSArray *)pluginsWithClass:(Class )cls
{
    NSMutableArray* ret = [NSMutableArray array];
    NSArray* thePlugins = [self loadedPlugins];
    for(MZPlugin* plugin in thePlugins)
    {
        if(![plugin isEnabled])
            continue;
        if([plugin isKindOfClass:cls])
            [ret addObject:plugin];
    }
    NSSortDescriptor* desc = [[NSSortDescriptor alloc ] initWithKey:@"label" ascending:YES];
    [ret sortUsingDescriptors:[NSArray arrayWithObject:desc]];
    [desc release];
    return ret;
}

- (NSArray *)activePlugins;
{
    return [self pluginsWithClass:[MZPlugin class]];
}

- (NSArray *)actionsPlugins;
{
    return [self pluginsWithClass:[MZActionsPlugin class]];
}

- (NSArray *)dataProviderPlugins;
{
    return [self pluginsWithClass:[MZDataProviderPlugin class]];
}

- (NSArray *)searchProviderPlugins;
{
    return [self pluginsWithClass:[MZSearchProviderPlugin class]];
}

- (id)loadPluginSourceWithName:(NSString *)name fromURL:(NSURL *)pathURL error:(NSError **)error
{
    id ret;
    NSString* pluginPath = [[pathURL path] stringByAppendingPathComponent:name];
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (CFStringRef)[pluginPath pathExtension], NULL);
    MZLoggerDebug(@"Loading plugin at path '%@'", pluginPath);
    if(UTTypeConformsTo(uti, kMZUTMetaZPlugin))
    {
        NSBundle* plugin = [NSBundle bundleWithPath:pluginPath];
        if(!plugin)
        {
            NSString* msg = [NSString stringWithFormat:@"Failed to create plugin bundle at path '%@'", pluginPath];
            if(error)
            {
                NSDictionary* info = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
                *error = [NSError errorWithDomain:@"MZPluginController" code:errMZPluginFailedToCreateBundle userInfo:info];
            }
            else
                MZLoggerError(@"%@", msg);
        }
        ret = plugin;
    }
    else if(UTTypeEqual(uti, kMZUTAppleScriptText) || UTTypeConformsTo(uti, kMZUTAppleScriptText) ||
            UTTypeEqual(uti, kMZUTAppleScript) || UTTypeConformsTo(uti, kMZUTAppleScript) ||
            UTTypeEqual(uti, kMZUTAppleScriptBundle) || UTTypeConformsTo(uti, kMZUTAppleScriptBundle))
    {
        NSURL* url = [NSURL URLWithString:[name gtm_stringByEscapingForURLArgument] relativeToURL:pathURL];
        MZScriptActionsPlugin* plugin = [MZScriptActionsPlugin pluginWithURL:url];
        ret = plugin;
    }
    CFRelease(uti);
    return ret;
}

- (NSArray *)plugins
{
    if(!plugins)
    {
        NSMutableArray* thePlugins = [[NSMutableArray alloc] init];
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
                    id plugin = [self loadPluginSourceWithName:pluginDir fromURL:pathURL error:NULL];
                    if(plugin)
                        [thePlugins addObject:plugin];
                }
            }
        }
        plugins = thePlugins;
    }
    return plugins;
}

- (BOOL)loadPluginFromSource:(id)source error:(NSError **)error;
{
    NSString* identifier;
    if([source isKindOfClass:[NSBundle class]])
        identifier = [source bundleIdentifier];
    else if([source isKindOfClass:[MZScriptActionsPlugin class]])
        identifier = [source identifier];
    else
    {
        NSString* msg = [NSString stringWithFormat:@"Unknown plugin %@ of type %@", 
                source, NSStringFromClass([source class])];
        if(error)
        {
            NSDictionary* info = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"MZPluginController" code:errMZPluginUnknownPluginType userInfo:info];
        }
        else
            MZLoggerError(@"%@", msg);
        return NO;
    }
            
    // the plugins are in the order they should be loaded
    // so if the same identifier is allready loaded we can skib to
    // next
    if([loadedBundles containsObject:identifier])
    {
        NSString* msg = [NSString stringWithFormat:@"Plugin with identifier %@ is already loaded", 
                identifier];
        if(error)
        {
            NSDictionary* info = [NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey];
            *error = [NSError errorWithDomain:@"MZPluginController" code:errMZPluginAlreadyLoaded userInfo:info];
        }
        else
            MZLoggerError(@"%@", msg);
        return NO;
    }
                
    MZPlugin* plugin;
    NSError* err = nil;
    if(![source loadAndReturnError:&err])
    {
        NSString* msg = [NSString stringWithFormat:@"Failed to load code for '%@' because: %@", 
            identifier,
            [err localizedDescription]];
        if(error)
        {
            NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                msg, NSLocalizedDescriptionKey,
                err, NSUnderlyingErrorKey,
                nil];
            *error = [NSError errorWithDomain:@"MZPluginController" code:errMZPluginFailedToLoadSource userInfo:info];
        }
        else
            MZLoggerError(@"%@", msg);
        return NO;
    }
                
    if([source isKindOfClass:[NSBundle class]])
    {
        Class cls = [source principalClass];
        if(cls == Nil)
        {
            NSString* msg = [NSString stringWithFormat:@"Error loading principal class for '%@'", 
                identifier];
            if(error)
            {
                NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                    msg, NSLocalizedDescriptionKey,
                    err, NSUnderlyingErrorKey,
                    nil];
                *error = [NSError errorWithDomain:@"MZPluginController" code:errMZPluginFailedToLoadPrincipalClass userInfo:info];
            }
            else
                MZLoggerError(@"%@", msg);
            return NO;
        }
                
        plugin = [[cls alloc] init];
        if(!plugin)
        {
            NSString* msg = [NSString stringWithFormat:@"Failed to create principal class '%@' for '%@'", 
                NSStringFromClass(cls),
                identifier];
            if(error)
            {
                NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                    msg, NSLocalizedDescriptionKey,
                    err, NSUnderlyingErrorKey,
                    nil];
                *error = [NSError errorWithDomain:@"MZPluginController" code:errMZPluginFailedToCreatePrincipalClass userInfo:info];
            }
            else
                MZLoggerError(@"%@", msg);
            [source unload];
            return NO;
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
    return YES;
}

- (NSArray *)loadedPlugins
{
    if(!loadedPlugins)
    {
        [self willChangeValueForKey:@"loadedPlugins"];
        loadedPlugins = [[NSMutableArray alloc] init];
        NSArray* thePlugins = [self plugins];
        for(id source in thePlugins)
        {
            [self loadPluginFromSource:source error:NULL];
        }
        [self didChangeValueForKey:@"loadedPlugins"];
    }
    return loadedPlugins;
}

- (BOOL)loadPlugin:(NSString *)name fromURL:(NSURL *)url error:(NSError **)error
{
    id source = [self loadPluginSourceWithName:name fromURL:url error:error];
    if(!source)
    {
        return NO;
    }
        
    [self willChangeValueForKey:@"plugins"];
    [plugins addObject:source];
    [self didChangeValueForKey:@"plugins"];
    
    [self willChangeValueForKey:@"loadedPlugins"];
    BOOL ret = [self loadPluginFromSource:source error:error];
    [self didChangeValueForKey:@"loadedPlugins"];
    return ret;
}

- (BOOL)unloadPlugin:(MZPlugin *)plugin
{
    if([plugin canUnload])
    {
        [plugin retain];
        [plugin willUnload];
        
        [self willChangeValueForKey:@"plugins"];
        [plugins removeObject:plugin];
        [plugins removeObject:[plugin bundle]];
        [self didChangeValueForKey:@"plugins"];

        [self willChangeValueForKey:@"loadedPlugins"];
        [loadedPlugins removeObject:plugin];
        [self didChangeValueForKey:@"loadedPlugins"];
        
        [loadedBundles removeObject:[plugin identifier]];
        
        BOOL unloaded = [plugin unload];
        [plugin release];
        if(unloaded)
        {
            if([[self delegate] respondsToSelector:
                @selector(pluginController:unloadedPlugin:)])
            {
                [[self delegate] pluginController:self
                                  unloadedPlugin:[plugin identifier]];
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
        if([[plugin identifier] isEqualToString:identifier])
            return plugin;
    }
    return nil;
}

- (MZPlugin *)pluginWithPath:(NSString *)path
{
    for(MZPlugin* plugin in [self activePlugins])
    {
        if([[plugin pluginPath] isEqualToString:path])
            return plugin;
    }
    return nil;
}

- (MZDataProviderPlugin *)dataProviderWithIdentifier:(NSString *)identifier
{
    for(MZDataProviderPlugin* provider in [self dataProviderPlugins])
    {
        if([[provider identifier] isEqualToString:identifier])
            return provider;
    }
    return nil;
}

- (MZDataProviderPlugin *)dataProviderForType:(NSString *)uti
{
    for(MZDataProviderPlugin* provider in [self dataProviderPlugins])
    {
        NSArray* types = [provider types];
        for(NSString* type in types)
        {
            if(UTTypeConformsTo((CFStringRef)uti, (CFStringRef)type))
                return provider;
        }
    }
    return nil;
}

- (MZDataProviderPlugin *)dataProviderForPath:(NSString *)path
{
    NSArray* types = (NSArray*)UTTypeCreateAllIdentifiersForTag(kUTTagClassFilenameExtension, (CFStringRef)[path pathExtension], kUTTypeMovie);
    for(NSString* uti in types)
    {
        MZDataProviderPlugin* ret = [self dataProviderForType:uti];
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
    for(MZDataProviderPlugin* provider in [self dataProviderPlugins])
    {
        NSArray* types = [provider types];
        [ret addObjectsFromArray:types];
    }
    return [NSArray arrayWithArray:ret]; 
}

- (MZSearchProviderPlugin *)searchProviderWithIdentifier:(NSString *)identifier
{
    for(MZSearchProviderPlugin* provider in [self searchProviderPlugins])
        if([[provider identifier] isEqualToString:identifier])
            return provider;
    return nil;
}

- (id<MZDataController>)loadFromFile:(NSString *)fileName
                            delegate:(id<MZEditsReadDelegate>)theDelegate
                               extra:(NSDictionary *)extra
{
    MZDataProviderPlugin* provider = [self dataProviderForPath:fileName];
    if(!provider)
        return nil;

    id<MZDataReadDelegate> otherDelegate = [MZReadNotification notifierWithController:self delegate:theDelegate];
    return [provider loadFromFile:fileName delegate:otherDelegate queue:loadQueue extra:extra];
}

- (id<MZDataController>)saveChanges:(MetaEdits *)data
                           delegate:(id<MZDataWriteDelegate>)theDelegate
{
    MZDataProviderPlugin* provider = [data owner];
    id<MZDataWriteDelegate> otherDelegate = [MZWriteNotification notifierWithDelegate:theDelegate];
    return [provider saveChanges:data delegate:otherDelegate queue:saveQueue];
}

- (void)searchAllWithData:(NSDictionary *)data
                 delegate:(id<MZSearchProviderDelegate>)theDelegate
{
    MZSearchDelegate* searchDelegate = [MZSearchDelegate searchWithDelegate:theDelegate];
    for(MZSearchProviderPlugin* provider in [self searchProviderPlugins])
    {
        if([provider searchWithData:data delegate:searchDelegate queue:searchQueue])
            [searchDelegate performedSearch];
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

- (void)dataProvider:(MZDataProviderPlugin *)provider
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

- (void)dataProvider:(MZDataProviderPlugin *)provider
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
                MZNSErrorKey, nil];
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

- (void)dataProvider:(MZDataProviderPlugin *)provider
          controller:(id<MZDataController>)controller
        writeFinishedForEdits:(MetaEdits *)edits percent:(int)percent
{
    if([delegate respondsToSelector:@selector(dataProvider:controller:writeFinishedForEdits:percent:)])
        [delegate dataProvider:provider controller:controller writeFinishedForEdits:edits percent:percent];
}

- (void)dataProvider:(MZDataProviderPlugin *)provider
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

- (void)dataProvider:(MZDataProviderPlugin *)provider
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

- (void) searchProvider:(MZSearchProviderPlugin *)provider result:(NSArray*)result
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

