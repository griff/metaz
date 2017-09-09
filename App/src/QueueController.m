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
#import "Resources.h"

@interface QueueController ()
@property(readwrite) NSInteger targetProgress;
@property(readwrite) NSInteger progress;

- (void)registerAsObserver;
- (void)unregisterAsObserver;
@end

@implementation QueueController
@synthesize filesController;
@synthesize mainWindow;
@synthesize targetProgress;
@synthesize progress;
@synthesize progressBar;
@synthesize mainView;
@synthesize pendingLabel;

-(id)init
{
    self = [super init];
    if(self)
    {
        controller = nil;
        writeQueue = [[MZWriteQueue sharedQueue] retain];
        dockIndicator = [[UKDockProgressIndicator alloc] init];
        [self registerAsObserver];
    }
    return self;
}

-(void)dealloc
{
    [self unregisterAsObserver];
    [writeQueue release];
    [controller release];
    [filesController release];
    [dockIndicator release];
    [progressBar release];
    [mainView release];
    [pendingLabel release];
    [animation stopAnimationChain];
    [animation release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [dockIndicator setMinValue:0];
    [dockIndicator bind:@"maxValue" toObject:self withKeyPath:@"targetProgress" options:nil];
    [dockIndicator bind:@"doubleValue" toObject:self withKeyPath:@"progress" options:nil];

    // Store frame sizes for animation
    mainRect = [mainView frame];
    pendingRect = [pendingLabel frame];
    progressRect = [progressBar frame];
    progressResizeHeight = pendingRect.origin.y - progressRect.origin.y;

    // Hide progress bar
    mainRect.origin.y -= progressResizeHeight;
    mainRect.size.height += progressResizeHeight;
    pendingRect.origin.y -= progressResizeHeight;
    progressRect.origin.y -= progressResizeHeight;
    [mainView setFrame:mainRect];
    [pendingLabel setFrame:pendingRect];
    [progressBar setHidden:YES];
    [progressBar setFrame:progressRect];
    progressShowing = NO;

    [dockIndicator setHidden:YES];
}

- (void)registerAsObserver
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching:) name:NSApplicationDidFinishLaunchingNotification object:NSApp];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDriverDidFinish:) name:SUUpdateDriverFinishedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queueCompletedPercent:) name:MZQueueItemCompletedPercentNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillResize:) name:MZNSWindowWillResizeNotification object:mainWindow];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:mainWindow];
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

- (void)updateUI
{
    RunStatus status = [writeQueue status];
    switch (status)
    {
        case QueuePaused:
        case QueueStopped:
            if(progressShowing)
            {
                NSRect oldRect = mainRect;
                mainRect.origin.y -= progressResizeHeight;
                mainRect.size.height += progressResizeHeight;
                NSDictionary* mainAnim = [NSDictionary dictionaryWithObjectsAndKeys:
                    mainView, NSViewAnimationTargetKey,
                    [NSValue valueWithRect:oldRect], NSViewAnimationStartFrameKey,
                    [NSValue valueWithRect:mainRect], NSViewAnimationEndFrameKey,
                    nil];
                
                oldRect = pendingRect;
                pendingRect.origin.y -= progressResizeHeight;
                NSDictionary* pendingAnim = [NSDictionary dictionaryWithObjectsAndKeys:
                    pendingLabel, NSViewAnimationTargetKey,
                    [NSValue valueWithRect:oldRect], NSViewAnimationStartFrameKey,
                    [NSValue valueWithRect:pendingRect], NSViewAnimationEndFrameKey,
                    nil];
                
                oldRect = progressRect;
                progressRect.origin.y -= progressResizeHeight;
                NSDictionary* progressAnim = [NSDictionary dictionaryWithObjectsAndKeys:
                    progressBar, NSViewAnimationTargetKey,
                    [NSValue valueWithRect:oldRect], NSViewAnimationStartFrameKey,
                    [NSValue valueWithRect:progressRect], NSViewAnimationEndFrameKey,
                    NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey,
                    nil];
                
                MZViewAnimation* nextAnim = [[MZViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:mainAnim, pendingAnim, progressAnim, nil]];
                if(animation && ([animation isAnimating] || [animation currentProgress]==0.0))
                {
                    [nextAnim startWhenAnimation:animation reachesProgress:1.0];
                    [animation release];
                    animation = nextAnim;
                } else {
                    [animation release];
                    animation = nextAnim;
                    [animation startAnimation];
                }

                [progressBar stopAnimation:self];
                [dockIndicator setHidden:YES];
                progressShowing = NO;
            }
            break;
        case QueueStopping:
        case QueueRunning:
            if(!progressShowing)
            {
                NSRect oldRect = mainRect;
                mainRect.origin.y += progressResizeHeight;
                mainRect.size.height -= progressResizeHeight;
                NSDictionary* mainAnim = [NSDictionary dictionaryWithObjectsAndKeys:
                    mainView, NSViewAnimationTargetKey,
                    [NSValue valueWithRect:oldRect], NSViewAnimationStartFrameKey,
                    [NSValue valueWithRect:mainRect], NSViewAnimationEndFrameKey,
                    nil];
                
                oldRect = pendingRect;
                pendingRect.origin.y += progressResizeHeight;
                NSDictionary* pendingAnim = [NSDictionary dictionaryWithObjectsAndKeys:
                    pendingLabel, NSViewAnimationTargetKey,
                    [NSValue valueWithRect:oldRect], NSViewAnimationStartFrameKey,
                    [NSValue valueWithRect:pendingRect], NSViewAnimationEndFrameKey,
                    nil];
                
                oldRect = progressRect;
                progressRect.origin.y += progressResizeHeight;
                NSDictionary* progressAnim = [NSDictionary dictionaryWithObjectsAndKeys:
                    progressBar, NSViewAnimationTargetKey,
                    [NSValue valueWithRect:oldRect], NSViewAnimationStartFrameKey,
                    [NSValue valueWithRect:progressRect], NSViewAnimationEndFrameKey,
                    NSViewAnimationFadeInEffect, NSViewAnimationEffectKey,
                    nil];
                
                MZViewAnimation* nextAnim = [[MZViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:mainAnim, pendingAnim, progressAnim, nil]];
                if(animation && ([animation isAnimating] || [animation currentProgress]==0.0))
                {
                    [nextAnim startWhenAnimation:animation reachesProgress:1.0];
                    [animation release];
                    animation = nextAnim;
                } else {
                    [animation release];
                    animation = nextAnim;
                    [animation startAnimation];
                }

                [progressBar startAnimation:self];
                [dockIndicator setHidden:NO];
                progressShowing = YES;
            }
            break;
    }
    [NSApp setWindowsNeedUpdate:YES];
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
    NSUInteger count = [[writeQueue queueItems] count];
    if(count > 0)
    {
        NSString* title = [NSString stringWithFormat:
                NSLocalizedString(@"MetaZ Has Detected %d Pending Item(s) In Your Queue", @"Loaded queue message box text"),
                count];
        NSAlert *alert = [NSAlert new];
        alert.alertStyle = NSAlertStyleCritical;
        alert.messageText = title;
        alert.informativeText = NSLocalizedString(@"Do you want to reload them ?", @"Loaded queue message question");
        [alert addButtonWithTitle:NSLocalizedString(@"Reload Queue", @"Button text for reload queue action")];
        [alert addButtonWithTitle:NSLocalizedString(@"Empty Queue", @"Button text for empty queue action")];
        NSModalResponse returnCode = [alert runModal];

        if(returnCode == NSAlertSecondButtonReturn)
            [writeQueue removeAllQueueItems];
    }
}

-(void)didDismissReload:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
    if(returnCode == NSAlertSecondButtonReturn)
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
- (void)windowWillResize:(NSNotification *)notification
{
    [animation stopAnimationChain];
    if([animation currentProgress] < 1.0)
        [animation setCurrentProgress:1.0];
    [animation release];
    animation = nil; 
}

- (void)windowDidResize:(NSNotification *)notification
{
    mainRect = [mainView frame];
    pendingRect = [pendingLabel frame];
    progressRect = [progressBar frame];
}

- (void)windowDidClose:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] 
           removeObserver:self 
                     name:NSWindowWillCloseNotification
                   object:[note object]];
    [controller release];
    controller = nil;
}

#pragma mark - as NSToolbarItemValidation
- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    if([theItem action] == @selector(startStopEncoding:))
    {
        RunStatus status = [writeQueue status];
        NSString* playLabel = nil;
        NSString* playImage = nil;
        switch (status)
        {
            case QueueStopped:
                playLabel = NSLocalizedString(@"Start", @"Label for start button");
                playImage = @"Play";
                break;
            case QueueStopping:
            case QueueRunning:
                playLabel = NSLocalizedString(@"Stop", @"Label for stop button");
                playImage = @"Stop";
                break;
            case QueuePaused:
                playLabel = NSLocalizedString(@"Stop", @"Label for stop button");
                playImage = @"Stop";
                break;
        }
        [theItem setImage:[NSImage imageNamed:playImage]];
        [theItem setLabel:playLabel];
    }
    
    return [self validateUserInterfaceItem:theItem];
}

#pragma mark - as NSMenuValidation
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if([menuItem action] == @selector(startStopEncoding:))
    {
        RunStatus status = [writeQueue status];
        NSString* menuLabel = nil;
        switch (status)
        {
            case QueueStopped:
                menuLabel = NSLocalizedString(@"Start Queue", @"Label for start queue menu");
                break;
            case QueueStopping:
            case QueueRunning:
                menuLabel = NSLocalizedString(@"Stop Queue", @"Label for stop queue menu");
                break;
            case QueuePaused:
                menuLabel = NSLocalizedString(@"Stop Queue", @"Label for stop queue menu");
                break;
        }
        [menuItem setTitle:menuLabel];
    }
    
    return [self validateUserInterfaceItem:menuItem];
}

#pragma mark - as NSUserInterfaceValidations

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
    if([anItem action] == @selector(startEncoding:))
    {
        return [writeQueue status] == QueueStopped &&
            [[writeQueue pendingItems] count] > 0;
    }
    if([anItem action] == @selector(stopEncoding:))
    {
        return [writeQueue started];
    }
    if([anItem action] == @selector(startStopEncoding:))
    {
        return [writeQueue status] != QueueStopped ||
            [[writeQueue pendingItems] count] > 0 || 
            [[[MZMetaLoader sharedLoader] files] count] > 0;
    }
    if([anItem action] == @selector(addToQueue:) || [anItem action] == @selector(writeSelected:))
    {
        return [[filesController selectedObjects] count] > 0;
    }
    if([anItem action] == @selector(addAllToQueue:) || [anItem action] == @selector(writeAll:))
    {
        return [[[MZMetaLoader sharedLoader] files] count] > 0;
    }
    return YES;
}


#pragma mark - actions

- (IBAction)writeSelected:(id)sender
{
    [self addToQueue:sender];
    [self startEncoding:sender];
}

- (IBAction)writeAll:(id)sender
{
    [self addAllToQueue:sender];
    [self startEncoding:sender];
}

- (IBAction)addToQueue:(id)sender
{
    if(![mainWindow makeFirstResponder:mainWindow])
    {
        [mainWindow endEditingFor:nil];
    }

    NSArray* files = [filesController selectedObjects];
    [writeQueue addQueueItems:files];
    [filesController remove:sender];
}

- (IBAction)addAllToQueue:(id)sender
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

- (IBAction)stopEncoding:(id)sender
{
    [writeQueue stop];
}

- (IBAction)startEncoding:(id)sender
{
    if([writeQueue started] || [[writeQueue pendingItems] count] == 0)
        return;
    lastQueueItemsCount = [[writeQueue queueItems] count];
    lastCompletedItemsCount = [[writeQueue completedItems] count];
    self.targetProgress = [[writeQueue pendingItems] count]*100;
    self.progress = 0;
    [writeQueue start];
}

- (IBAction)startStopEncoding:(id)sender
{
    if([writeQueue started])
        [writeQueue stop];
    else
    {
        if([[writeQueue pendingItems] count] == 0)
            [self addToQueue:sender];
        [self startEncoding:sender];    
    }
}

@end
