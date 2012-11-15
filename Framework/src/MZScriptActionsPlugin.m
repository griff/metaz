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

enum {
    keyMZStarted   = 'star',
    keyMZCompleted = 'comp',
    keyMZFailed    = 'fail',
    keyMZOpenDoc   = 'odoc',
    keyMZQueue     = 'MZqu',
    keyMZQueueItem = 'MZqi',
    keyMZEvent     = 'MZev',
    keyMZError     = 'Merr',
};

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
               name:MZQueueStartedNotification
             object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueItemStarted:)
               name:MZQueueItemStartedNotification
             object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueItemCompleted:)
               name:MZQueueItemCompletedNotification
             object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueItemFailed:)
               name:MZQueueItemFailedNotification
             object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueCompleted:)
               name:MZQueueCompletedNotification
             object:nil];

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(openedDocument:)
               name:MZMetaLoaderFinishedNotification
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

/*
		<event name="queue started processing" code="MZqustar" description="The queue started processing items"/>
*/
- (void)queueStarted:(NSNotification *)note
{    
    ProcessSerialNumber psn = {0, kCurrentProcess};
    NSAppleEventDescriptor* event = [AEVT class:keyMZQueue id:keyMZStarted target:psn,
        nil
    ];
    [self executeEvent:event];
}

/*
		<event name="queue started" code="MZqistar" description="The queue started writing document">
			<direct-parameter description="The document written" type="document"/>
        </event>
*/
- (void)queueItemStarted:(NSNotification *)note
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
    NSAppleEventDescriptor* event = [AEVT class:keyMZQueueItem id:keyMZStarted target:psn,
        [KEY : keyDirectObject],
        [spec descriptor],
        nil
    ];
    [self executeEvent:event];
}

/*
		<event name="queue completed" code="MZqicomp" description="The queue finished writing document">
			<direct-parameter description="The document written" type="document"/>
        </event>
*/
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
    NSAppleEventDescriptor* event = [AEVT class:keyMZQueueItem id:keyMZCompleted target:psn,
        [KEY : keyDirectObject],
        [spec descriptor],
        nil
    ];
    [self executeEvent:event];
}

/*
		<event name="queue failed to write" code="MZqifail" description="The queue failed writing document">
			<direct-parameter description="The document written" type="document"/>
			<parameter name="because of" code="Merr" optional="yes" description="The error that cause the failure" type="text">
				<cocoa key="error"/>
            </parameter>
        </event>
*/
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
        
    NSError* error = [[note userInfo] objectForKey:MZNSErrorKey];

    ProcessSerialNumber psn = {0, kCurrentProcess};
    NSAppleEventDescriptor* event = [AEVT class:keyMZQueueItem id:keyMZFailed target:psn,
        [KEY : keyDirectObject],
        [spec descriptor],
        [KEY : keyMZError],
        [STRING : [error localizedDescription]],
        nil
    ];
    [self executeEvent:event];
}

/*
		<event name="queue finished processing" code="MZqucomp" description="The queue finished processing items"/>
*/
- (void)queueCompleted:(NSNotification *)note
{
    ProcessSerialNumber psn = {0, kCurrentProcess};
    NSAppleEventDescriptor* event = [AEVT class:keyMZQueue id:keyMZCompleted target:psn,
        nil
    ];
    [self executeEvent:event];
}

/*
        <event name="opened document" code="MZevodoc" description="Opened a document">
            <direct-parameter description="The document opened" type="document"/>
        </event>
*/
- (void)openedDocument:(NSNotification *)note
{
    MetaEdits* edits = [[note userInfo] objectForKey:MZMetaEditsNotificationKey];
    if(edits)
    {
        NSString* displayName = [[[edits loadedFileName] lastPathComponent] stringByDeletingPathExtension];
        NSScriptClassDescription *containerClassDesc = (NSScriptClassDescription *)
            [NSScriptClassDescription classDescriptionForClass:[NSApplication class]];// 1
        NSScriptObjectSpecifier* spec = [[[NSNameSpecifier alloc]
            initWithContainerClassDescription:containerClassDesc
            containerSpecifier:nil key:@"orderedDocuments"
            name:displayName] autorelease];
    
        ProcessSerialNumber psn = {0, kCurrentProcess};
        NSAppleEventDescriptor* event = [AEVT class:keyMZEvent id:keyMZOpenDoc target:psn,
            [KEY : keyDirectObject],
            [spec descriptor],
            nil
        ];
        [self executeEvent:event];
    }
}

@end
