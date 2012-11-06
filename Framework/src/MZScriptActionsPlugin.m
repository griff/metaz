//
//  MZScriptActionsPlugin.m
//  MetaZ
//
//  Created by Brian Olsen on 05/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <Carbon/Carbon.h>
#import "MZScriptActionsPlugin.h"
#import "NSError+MZScriptError.h"
#import "AEVTBuilder.h"
#import "MetaEdits.h"
#import "MZLogger.h"
#import "MZPlugin+Private.h"

#define MZQueueStarted @"MZQueueStarted"
#define MZQueueCompletedPercent @"MZQueueCompletedPercent"
#define MZQueueItemCompleted @"MZQueueItemCompleted"
#define MZQueueItemFailed @"MZQueueItemFailed"
#define MZQueueCompleted @"MZQueueCompleted"

@implementation MZScriptActionsPlugin

+ (id)pluginWithURL:(NSURL *)url;
{
    return [[[self alloc] initWithURL:url] autorelease];
}

- (id)initWithURL:(NSURL *)theURL;
{
    self = [super init];
    if(self)
    {
        url = [theURL retain];
        identifier = [[[[url path] lastPathComponent] stringByDeletingPathExtension] retain];
    }
    return self;
}

- (void)dealloc
{
    [url release];
    [identifier release];
    [script release];
    [super dealloc];
}

@synthesize url;
@synthesize script;

- (NSString *)identifier
{
    return identifier;
}

- (NSString *)label
{
    return self.identifier;
}

- (NSString *)preferencesNibName
{
    return @"ScriptActionsPluginView";
}

- (BOOL)isBuiltIn
{
    NSURL* urlPath = [NSURL fileURLWithPath:[[NSBundle mainBundle] builtInPlugInsPath]];
    BOOL ret = [[url baseURL] isEqualTo:urlPath];
    return ret;
}

- (BOOL)loadAndReturnError:(NSError **)error
{
    if(!script)
    {
        NSDictionary* errDict = nil;
        script = [[NSAppleScript alloc] initWithContentsOfURL:self.url error:&errDict];
        if(!script || ![script compileAndReturnError:&errDict])
        {
            if(errDict && error)
                *error = [NSError errorWithAppleScriptError:errDict];
            return NO;
        }
    }
    return YES;
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueStarted:)
               name:MZQueueStarted
             object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueItemCompleted:)
               name:MZQueueItemCompleted
             object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueItemFailed:)
               name:MZQueueItemFailed
             object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueCompleted:)
               name:MZQueueCompleted
             object:nil];
}

- (void)executeEvent:(NSAppleEventDescriptor *)event
{
    NSDictionary* errDict = nil;
    NSAppleEventDescriptor* ret = [script executeAppleEvent:event error:&errDict];
    if(!ret)
    {
        NSInteger code = [[errDict objectForKey:NSAppleScriptErrorNumber] integerValue];
        NSString* msg = [errDict objectForKey:NSAppleScriptErrorMessage];
        NSString* app = [errDict objectForKey:NSAppleScriptErrorAppName];
        if(code != -1708 || msg || app)
            MZLoggerError(@"Notification failed %@ %d %@", app, code, msg);
    }
}

- (void)queueStarted:(NSNotification *)note
{    
    ProcessSerialNumber psn = {0, kCurrentProcess};
    NSAppleEventDescriptor* event = [AEVT class:kASAppleScriptSuite id:kASSubroutineEvent target:psn,
        [KEY : keyASSubroutineName],
        [STRING : @"queue_started"],
        nil
    ];
    [self executeEvent:event];
}

- (void)queueItemCompleted:(NSNotification *)note
{
    MetaEdits* edits = [[note userInfo] objectForKey:MZMetaEditsNotificationKey];
    NSString* displayName = [[[edits loadedFileName] lastPathComponent] stringByDeletingPathExtension];
    NSScriptClassDescription *containerClassDesc = (NSScriptClassDescription *)
        [NSScriptClassDescription classDescriptionForClass:[NSApplication class]];// 1
    NSScriptObjectSpecifier* spec = [[[NSNameSpecifier alloc]
        initWithContainerClassDescription:containerClassDesc
        containerSpecifier:nil key:@"queueDocuments"
        name:displayName] autorelease];
    
    ProcessSerialNumber psn = {0, kCurrentProcess};
    NSAppleEventDescriptor* event = [AEVT class:kASAppleScriptSuite id:kASSubroutineEvent target:psn,
        [KEY : keyASSubroutineName],
        [STRING : @"queue_completed"],
        [KEY : keyASPrepositionOn],
        [spec descriptor],
        nil
    ];
    [self executeEvent:event];
}

- (void)queueItemFailed:(NSNotification *)note
{
    MetaEdits* edits = [[note userInfo] objectForKey:MZMetaEditsNotificationKey];
    NSString* displayName = [[[edits loadedFileName] lastPathComponent] stringByDeletingPathExtension];
    NSScriptClassDescription *containerClassDesc = (NSScriptClassDescription *)
        [NSScriptClassDescription classDescriptionForClass:[NSApplication class]];// 1
    NSScriptObjectSpecifier* spec = [[[NSNameSpecifier alloc]
        initWithContainerClassDescription:containerClassDesc
        containerSpecifier:nil key:@"queueDocuments"
        name:displayName] autorelease];

    ProcessSerialNumber psn = {0, kCurrentProcess};
    NSAppleEventDescriptor* event = [AEVT class:kASAppleScriptSuite id:kASSubroutineEvent target:psn,
        [KEY : keyASSubroutineName],
        [STRING : @"queue_failed"],
        [KEY : keyASPrepositionOn],
        [spec descriptor],
        nil
    ];
    [self executeEvent:event];
}

- (void)queueCompleted:(NSNotification *)note
{
    ProcessSerialNumber psn = {0, kCurrentProcess};
    NSAppleEventDescriptor* event = [AEVT class:kASAppleScriptSuite id:kASSubroutineEvent target:psn,
        [KEY : keyASSubroutineName],
        [STRING : @"queue_finished"],
        nil
    ];
    [self executeEvent:event];
}

@end
