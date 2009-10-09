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
@synthesize filesController;
@synthesize mainWindow;
@synthesize playBtn;
@synthesize pauseBtn;
@synthesize playBtn2;
@synthesize pauseBtn2;

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
    [playBtn2 release];
    [pauseBtn2 release];
    [controller release];
    [playBtn release];
    [pauseBtn release];
    [filesController release];
    [super dealloc];
}

- (void)registerAsObserver
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:NSApp];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDriverDidFinish:) name:SUUpdateDriverFinishedNotification object:nil];
    [writeQueue addObserver:self forKeyPath:@"status" options:0 context:nil];
}

- (void)unregisterAsObserver
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [writeQueue removeObserver:self forKeyPath:@"status"];
}

- (void)updateButtons
{
    RunStatus status = [writeQueue status];
    NSString* playLabel;
    NSString* pauseLabel;
    NSString* playImage;
    NSString* pauseImage;
    switch (status)
    {
        case QueueStopped:
            playLabel = NSLocalizedString(@"Play", @"Label for play button");
            pauseLabel = NSLocalizedString(@"Pause", @"Label for pause button");
            playImage = @"Play";
            pauseImage = @"Pause";
            break;
        case QueueRunning:
            playLabel = NSLocalizedString(@"Stop", @"Label for stop button");
            pauseLabel = NSLocalizedString(@"Pause", @"Label for pause button");
            playImage = @"Stop";
            pauseImage = @"Pause";
            break;
        case QueuePaused:
            playLabel = NSLocalizedString(@"Stop", @"Label for stop button");
            pauseLabel = NSLocalizedString(@"Play", @"Label for play button");
            playImage = @"Stop";
            pauseImage = @"Play";
            break;
    }
    [playBtn setImage:[NSImage imageNamed:playImage]];
    [playBtn setLabel:playLabel];
    [pauseBtn setImage:[NSImage imageNamed:pauseImage]];
    [pauseBtn setLabel:pauseLabel];
    if(playBtn2)
    {
        [playBtn2 setImage:[NSImage imageNamed:playImage]];
        [playBtn2 setLabel:playLabel];
    }
    if(pauseBtn2)
    {
        [pauseBtn2 setImage:[NSImage imageNamed:pauseImage]];
        [pauseBtn setLabel:pauseLabel];
    }
}

#pragma mark - observation callbacks

- (void)applicationDidFinishLaunching:(NSNotification *)note
{
    [writeQueue loadQueueWithError:NULL];
    int count = [[writeQueue queueItems] count];
    if(count > 0)
    {
        NSString* title = [NSString stringWithFormat:
                NSLocalizedString(@"MetaZ Has Detected %d Pending Item(s) In Your Queue", @"Loaded queue message box text"),
                count];
        /*
        NSAlert* alert = [[NSAlert alloc] init];
        [alert setMessageText:title];
        [alert setInformativeText:NSLocalizedString(@"Do you want to reload them ?", @"Loaded queue message question")];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert addButtonWithTitle:NSLocalizedString(@"Reload Queue", @"Button text for reload queue action")];
        [alert addButtonWithTitle:NSLocalizedString(@"Empty Queue", @"Button text for empty queue action")];
        [alert setShowsSuppressionButton:YES];
        [[alert suppressionButton] setTitle:@"Apply to all in queue"];
        NSInteger returnCode = [alert runModal];
        [alert release];
        */
        NSInteger returnCode = NSRunCriticalAlertPanel(title,
                NSLocalizedString(@"Do you want to reload them ?", @"Loaded queue message question"),
                NSLocalizedString(@"Reload Queue", @"Button text for reload queue action"), nil,
                NSLocalizedString(@"Empty Queue", @"Button text for empty queue action")
                );
        if(returnCode == NSAlertOtherReturn)
            [writeQueue removeAllQueueItems];
        /*
        NSBeginCriticalAlertSheet(title, 
                NSLocalizedString(@"Reload Queue", @"Button text for reload queue action"), nil,
                NSLocalizedString(@"Empty Queue", @"Button text for empty queue action"),
                mainWindow,
                self, nil, @selector(didDismissReload:returnCode:contextInfo:), nil,
                NSLocalizedString(@"Do you want to reload them ?", @"Loaded queue message question")
                );
        */
    }
}

-(void)didDismissReload:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if(returnCode == NSAlertOtherReturn)
        [writeQueue removeAllQueueItems];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqual:@"status"] && object == writeQueue)
    {
        [self updateButtons];
    }
}

- (void)windowDidClose:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] 
           removeObserver:self 
                     name:NSWindowWillCloseNotification
                   object:[note object]];
    [playBtn2 release];
    playBtn2 = nil;
    [pauseBtn2 release];
    pauseBtn2 = nil;
    [controller release];
    controller = nil;
}

#pragma mark - as NSUserInterfaceValidations

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
    /*
    if([anItem action] == @selector(showQueue:))
    {
        return [[writeQueue queueItems] count] > 0;
    }
    */
    if([anItem action] == @selector(startStopEncoding:))
    {
        return [[writeQueue queueItems] count] > 0 || 
            [[[MZMetaLoader sharedLoader] files] count] > 0;
    }
    if([anItem action] == @selector(pauseResumeEncoding:))
    {
        return [writeQueue status] != QueueStopped;
    }
    if([anItem action] == @selector(addToQueue:))
    {
        return [[[MZMetaLoader sharedLoader] files] count] > 0;
    }
    return YES;
}


#pragma mark - actions

- (IBAction)addToQueue:(id)sender
{
    if(![mainWindow makeFirstResponder:mainWindow])
    {
        [mainWindow endEditingFor:nil];
    }

    NSArray* files = [filesController arrangedObjects];
    [writeQueue addQueueItems:files];
    [[MZMetaLoader sharedLoader] removeAllObjects];
}

- (IBAction)showQueue:(id)sender
{
    if(!controller)
        controller = [[QueueWindowController alloc] initWithWindowNibName:@"Queue" owner:self];
    [[NSNotificationCenter defaultCenter] 
                addObserver:self 
                 selector:@selector(windowDidClose:)
                     name:NSWindowWillCloseNotification
                   object:[controller window]];
    [controller showWindow:self];
}

- (IBAction)startStopEncoding:(id)sender
{
    if([writeQueue started])
        [writeQueue stop];
    else
    {
        if([[writeQueue queueItems] count] == 0)
            [self addToQueue:sender];
        [writeQueue start];
    }
}

- (IBAction)pauseResumeEncoding:(id)sender
{
    if([writeQueue paused])
        [writeQueue resume];
    else
        [writeQueue pause];
}

@end
