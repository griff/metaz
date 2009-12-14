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


@interface QueueController ()
@property(readwrite) NSInteger targetProgress;
@property(readwrite) NSInteger progress;

- (void)registerAsObserver;
- (void)unregisterAsObserver;
@end

@implementation QueueController
@synthesize filesController;
@synthesize mainWindow;
@synthesize playBtn;
@synthesize playBtn2;
@synthesize targetProgress;
@synthesize progress;

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
    [controller release];
    [playBtn release];
    [filesController release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [GrowlApplicationBridge setGrowlDelegate:self];
    if([GrowlApplicationBridge isGrowlInstalled])
    {
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
    }

    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueCompleted:)
               name:MZQueueCompleted
             object:nil];


    // Hide progress bar
    NSRect contentRect = [[mainWindow contentView] bounds];
    NSView* mainView = [[[mainWindow contentView] subviews] objectAtIndex:0];
    NSRect mainRect = [mainView frame];
    NSView* pendingLabel = [[[mainWindow contentView] subviews] objectAtIndex:1];
    NSRect pendingRect = [pendingLabel frame];
    NSView* progressBar = [[[mainWindow contentView] subviews] objectAtIndex:2];
    if((contentRect.size.height - mainRect.size.height) > 32)
    {
        mainRect.origin.y = 32;
        mainRect.size.height += contentRect.size.height - mainRect.size.height-32;
        pendingRect.origin.y = 10;
        [[mainWindow contentView] setAutoresizesSubviews:NO];
        [mainView setFrame:mainRect];
        [pendingLabel setFrameOrigin:pendingRect.origin];
        [progressBar setHidden:YES];
        [[mainWindow contentView] setAutoresizesSubviews:YES];
    }
}

- (void)registerAsObserver
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:NSApp];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDriverDidFinish:) name:SUUpdateDriverFinishedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queueCompletedPercent:) name:MZQueueCompletedPercent object:nil];
    [writeQueue addObserver:self forKeyPath:@"status" options:0 context:nil];
    [writeQueue addObserver:self forKeyPath:@"queueItems.@count" options:0 context:nil];
    [writeQueue addObserver:self forKeyPath:@"completedItems.@count" options:0 context:nil];
}

- (void)unregisterAsObserver
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [writeQueue removeObserver:self forKeyPath:@"status"];
    [writeQueue removeObserver:self forKeyPath:@"queueItems.@count"];
    [writeQueue removeObserver:self forKeyPath:@"completedItems.@count"];
}

/*
- (void)setTargetProgress:(NSInteger)val
{
    targetProgress = val;
}
*/

- (void)updateUI
{
    NSRect windowFrame = [mainWindow frame];
    NSRect contentRect = [[mainWindow contentView] bounds];
    NSView* mainView = [[[mainWindow contentView] subviews] objectAtIndex:0];
    NSRect mainRect = [mainView frame];
    NSView* pendingLabel = [[[mainWindow contentView] subviews] objectAtIndex:1];
    NSRect pendingRect = [pendingLabel frame];
    NSProgressIndicator* progressBar = [[[mainWindow contentView] subviews] objectAtIndex:2];

    RunStatus status = [writeQueue status];
    NSString* playLabel;
    NSString* playImage;
    switch (status)
    {
        case QueueStopped:
            playLabel = NSLocalizedString(@"Start", @"Label for start button");
            playImage = @"Play";

            if((contentRect.size.height - mainRect.size.height) > 32)
            {
                mainRect.origin.y = 32;
                pendingRect.origin.y = 10;
                windowFrame.origin.y += contentRect.size.height - mainRect.size.height-32;
                windowFrame.size.height -= contentRect.size.height - mainRect.size.height-32;
                [[mainWindow contentView] setAutoresizesSubviews:NO];
                [mainView setFrameOrigin:mainRect.origin];
                [pendingLabel setFrameOrigin:pendingRect.origin];
                [progressBar setHidden:YES];
                [progressBar stopAnimation:self];
                [mainWindow setFrame:windowFrame display:YES animate:NO];
                [[mainWindow contentView] setAutoresizesSubviews:YES];
            }
            NSLog(@"Diff %@  %@ %f", NSStringFromRect(windowFrame), NSStringFromRect(mainRect),
                contentRect.size.height - mainRect.size.height);
            break;
        case QueueStopping:
        case QueueRunning:
            playLabel = NSLocalizedString(@"Stop", @"Label for stop button");
            playImage = @"Stop";

            //mainRect.origin.y = 64;
            if((contentRect.size.height - mainRect.size.height) < 64)
            {
                mainRect.origin.y = 64;
                pendingRect.origin.y = 42;
                windowFrame.origin.y -= 64-(contentRect.size.height - mainRect.size.height);
                windowFrame.size.height += 64-(contentRect.size.height - mainRect.size.height);
                [[mainWindow contentView] setAutoresizesSubviews:NO];
                [mainView setFrameOrigin:mainRect.origin];
                [pendingLabel setFrameOrigin:pendingRect.origin];
                [progressBar setHidden:NO];
                [progressBar startAnimation:self];
                [mainWindow setFrame:windowFrame display:YES animate:NO];
                [[mainWindow contentView] setAutoresizesSubviews:YES];
            }
            NSLog(@"Diff %@  %@ %f", NSStringFromRect(windowFrame), NSStringFromRect(mainRect),
                contentRect.size.height - mainRect.size.height);
            break;
        case QueuePaused:
            playLabel = NSLocalizedString(@"Stop", @"Label for stop button");
            playImage = @"Stop";
            break;
    }
    [playBtn setImage:[NSImage imageNamed:playImage]];
    [playBtn setLabel:playLabel];
    if(playBtn2)
    {
        [playBtn2 setImage:[NSImage imageNamed:playImage]];
        [playBtn2 setLabel:playLabel];
    }
}

#pragma mark - observation callbacks
- (void)queueCompletedPercent:(NSNotification *)note
{
    NSNumber* changes = [[note userInfo] objectForKey:@"changes"];
    self.progress += [changes intValue];
}

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
        [self updateUI];
    }
    if(([keyPath isEqual:@"queueItems.@count"] || [keyPath isEqual:@"completedItems.@count"]) && object == writeQueue)
    {
        NSInteger nextItemsCount = [[writeQueue queueItems] count];
        NSInteger nextCompletedItemsCount = [[writeQueue completedItems] count];
        if(nextCompletedItemsCount < lastCompletedItemsCount) // Removed completed
        {
            lastCompletedItemsCount = nextCompletedItemsCount;
            lastQueueItemsCount = nextItemsCount;
            return;
        }
        if(nextItemsCount != lastQueueItemsCount) // Added/Removed items
        {
            self.targetProgress += (nextItemsCount-lastQueueItemsCount)*100;
        }
        lastCompletedItemsCount = nextCompletedItemsCount;
        lastQueueItemsCount = nextItemsCount;
    }
}

#pragma mark - notifications

- (void)windowDidClose:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] 
           removeObserver:self 
                     name:NSWindowWillCloseNotification
                   object:[note object]];
    [playBtn2 release];
    playBtn2 = nil;
    [controller release];
    controller = nil;
}

- (void)queueCompleted:(NSNotification *)note
{
    NSInteger action = [[NSUserDefaults standardUserDefaults] integerForKey:@"whenDoneAction"];
    if(action == 2)
    {
        [GrowlApplicationBridge 
            notifyWithTitle:@"Completed queue"
                description:@"Bla Bla\nMore <b>Bla</b>"
           notificationName:@"Queue processing completed"
                   iconData:nil
                   priority:0
                   isSticky:NO
               clickContext:nil];
    }
    if(action == 1 || action == 3)
        NSRunCriticalAlertPanel(@"Queue run done", @"Your MetaZ queue is completed", @"OK", nil, nil);
}

- (void)queueItemCompleted:(NSNotification *)note
{
    NSInteger action = [[NSUserDefaults standardUserDefaults] integerForKey:@"whenDoneAction"];
    if(action == 2 || action == 3)
    {
        MetaEdits* edits = [[note userInfo] objectForKey:MZMetaEditsNotificationKey];
        [GrowlApplicationBridge 
            notifyWithTitle:@"File writing completed"
                description:[NSString stringWithFormat:@"Completed writing %@", [[edits savedFileName] lastPathComponent]]
           notificationName:@"File writing completed"
                   iconData:[edits picture]
                   priority:0
                   isSticky:NO
               clickContext:[edits savedFileName]];
    }
}

- (void)queueItemFailed:(NSNotification *)note
{
    NSInteger action = [[NSUserDefaults standardUserDefaults] integerForKey:@"whenDoneAction"];
    if(action == 2 || action == 3)
    {
        MetaEdits* edits = [[note userInfo] objectForKey:MZMetaEditsNotificationKey];
        [GrowlApplicationBridge 
            notifyWithTitle:@"File writing failed"
                description:[NSString stringWithFormat:@"Failed writing %@", [[edits savedFileName] lastPathComponent]]
           notificationName:@"File writing failed"
                   iconData:[edits picture]
                   priority:0
                   isSticky:NO
               clickContext:[edits loadedFileName]];
    }
}

#pragma mark - as Growl delegate

- (void) growlNotificationWasClicked:(id)clickContext
{
    NSString* path = clickContext;
    [[NSWorkspace sharedWorkspace]
                      selectFile:path
        inFileViewerRootedAtPath:@""];
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
        return [writeQueue status] != QueueStopped ||
            [[writeQueue pendingItems] count] > 0 || 
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
        if([[writeQueue pendingItems] count] == 0)
            [self addToQueue:sender];
        lastQueueItemsCount = [[writeQueue queueItems] count];
        lastCompletedItemsCount = [[writeQueue completedItems] count];
        self.targetProgress = [[writeQueue pendingItems] count]*100;
        self.progress = 0;
        [writeQueue start];
    }
}

@end
