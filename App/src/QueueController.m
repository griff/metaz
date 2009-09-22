//
//  QueueController.m
//  MetaZ
//
//  Created by Brian Olsen on 14/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "QueueController.h"
#import "MZMetaLoader.h"
#import "QueueWindowController.h"


@interface QueueController (Private)
- (void)registerAsObserver;
- (void)unregisterAsObserver;
@end

@implementation QueueController
@synthesize mainWindow;

-(id)init
{
    self = [super init];
    if(self)
    {
        controller = nil;
        writeQueue = [[MZWriteQueue sharedQueue] retain];
        [self registerAsObserver];
    }
    return self;
}

-(void)dealloc
{
    [self unregisterAsObserver];
    [writeQueue release];
    if(controller) [controller release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)note
{
    [writeQueue loadQueueWithError:NULL];
    int count = [[writeQueue queue] count];
    if(count > 0)
    {
        NSString* title = [NSString stringWithFormat:
                NSLocalizedString(@"MetaZ Has Detected %d Pending Item(s) In Your Queue", nil),
                count];
        NSBeginCriticalAlertSheet(title, 
                NSLocalizedString(@"Reload Queue", nil), nil,
                NSLocalizedString(@"Empty Queue", nil),
                mainWindow,
                self, nil, @selector(didDismissReload:returnCode:contextInfo:), nil,
                NSLocalizedString(@"Do you want to reload them ?", nil)
                );
    }
}

-(void)didDismissReload:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if(returnCode == NSAlertOtherReturn)
        [writeQueue removeAllObjects];
}

- (void)registerAsObserver
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:NSApp];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDriverDidFinish:) name:SUUpdateDriverFinishedNotification object:nil];
}

- (void)unregisterAsObserver
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)addToQueue:(id)sender
{
    NSArray* files = [[MZMetaLoader sharedLoader] files];
    [[MZWriteQueue sharedQueue] addArrayToQueue:files];
    [[MZMetaLoader sharedLoader] removeAllObjects];
}

- (IBAction)showQueue:(id)sender
{
    if(!controller)
        controller = [[QueueWindowController alloc] initWithWindowNibName:@"Queue" owner:self];
    [controller showWindow:self];
}

- (IBAction)startStopEncoding:(id)sender
{
    [[MZWriteQueue sharedQueue] removeObjectAtIndex:1];
}

- (IBAction)pauseResumeEncoding:(id)sender
{
}

@end
