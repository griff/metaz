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
@synthesize playBtn;
@synthesize playBtn2;
@synthesize menuItem;
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
    [playBtn2 release];
    [controller release];
    [playBtn release];
    [filesController release];
    [startTime release];
    [menuItem release];
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
           selector:@selector(queueStarted:)
               name:MZQueueStarted
             object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(queueCompleted:)
               name:MZQueueCompleted
             object:nil];

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
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queueCompletedPercent:) name:MZQueueCompletedPercent object:nil];
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

/*
- (void)setTargetProgress:(NSInteger)val
{
    targetProgress = val;
}
*/

- (void)updateUI
{
    RunStatus status = [writeQueue status];
    NSString* playLabel = nil;
    NSString* playImage = nil;
    NSString* menuLabel = nil;
    switch (status)
    {
        case QueueStopped:
            playLabel = NSLocalizedString(@"Start", @"Label for start button");
            playImage = @"Play";
            menuLabel = NSLocalizedString(@"Start Queue", @"Label for start queue menu");

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
            playLabel = NSLocalizedString(@"Stop", @"Label for stop button");
            playImage = @"Stop";
            menuLabel = NSLocalizedString(@"Stop Queue", @"Label for stop queue menu");

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
        case QueuePaused:
            playLabel = NSLocalizedString(@"Stop", @"Label for stop button");
            playImage = @"Stop";
            menuLabel = NSLocalizedString(@"Stop Queue", @"Label for stop queue menu");
            break;
    }
    [playBtn setImage:[NSImage imageNamed:playImage]];
    [playBtn setLabel:playLabel];
    if(playBtn2)
    {
        [playBtn2 setImage:[NSImage imageNamed:playImage]];
        [playBtn2 setLabel:playLabel];
    }
    [menuItem setTitle:menuLabel];
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
    [playBtn2 release];
    playBtn2 = nil;
    [controller release];
    controller = nil;
}

- (void)queueStarted:(NSNotification *)note
{
    [startTime release];
    startTime = [[NSDate alloc] init];
}

- (void)queueCompleted:(NSNotification *)note
{
    NSInteger action = [[NSUserDefaults standardUserDefaults] integerForKey:@"whenDoneAction"];
    if(action == 2 || action == 5 || action == 1 || action == 3)
    {
        NSString* intervalStr;
        NSTimeInterval interval = [startTime timeIntervalSinceNow]*-1.0;
        if(interval > 86400) // Days
        {
            interval = interval/86400;
            intervalStr = [NSString stringWithFormat:@"%1.1f days", interval];
        }
        else if (interval > 3600) // Hours
        {
            interval = interval/3600;
            intervalStr = [NSString stringWithFormat:@"%1.1f hours", interval];
        }
        else if (interval > 60) // Minutes
        {
            interval = interval/60;
            intervalStr = [NSString stringWithFormat:@"%1.1f min", interval];
        }
        else
        {
            intervalStr = [NSString stringWithFormat:@"%1.0f sec", interval];
        }

        NSString * title = NSLocalizedString(@"Queue run completed", @"Queue completed title");
        NSString * msg = [NSString stringWithFormat:
                    NSLocalizedString(@"Your MetaZ queue completed in %@",
                        "Queue completed alert message"),
                    intervalStr];

        if(action == 2 || action == 5)
        {
            [GrowlApplicationBridge 
                notifyWithTitle:title
                    description:msg
               notificationName:@"Queue processing completed"
                       iconData:nil
                       priority:0
                       isSticky:NO
                   clickContext:nil];
        }

        if(action == 1 || action == 3)
            NSRunAlertPanel( title, msg, NSLocalizedString(@"OK", @"OK button text"), nil, nil);
    }
    if(action == 4 || action == 5)
        [NSApp terminate:self];
}

- (void)queueItemCompleted:(NSNotification *)note
{
    NSInteger action = [[NSUserDefaults standardUserDefaults] integerForKey:@"whenDoneAction"];
    if(action == 2 || action == 3 || action == 5)
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
