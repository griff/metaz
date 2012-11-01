//
//  NSObject+WaitUntilChange.m
//  MetaZ
//
//  Created by Brian Olsen on 06/05/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "NSObject+WaitUntilChange.h"
#import "MZLogger.h"
#import "GTMNSObject+KeyValueObserving.h"

@interface MZWaitHandler : NSObject
{
    CFRunLoopRef runLoop;
    CFRunLoopSourceRef source;
    BOOL completed;
}

- (id)init;

- (void)keyChanged:(GTMKeyValueChangeNotification *)notification;
- (void)performHandling;
- (BOOL)runMode:(CFStringRef)mode beforeDate:(NSDate *)limitDate;

@end


void MZWaitHandlerCallBack(void *info)
{
    MZWaitHandler* handler = (MZWaitHandler*)info;
    [handler performHandling];
}

@implementation MZWaitHandler

- (id)init
{
    self = [super init];
    if(self)
    {
        completed = NO;
        CFRunLoopSourceContext context;
        context.version = 0;
        context.info = self;
        context.retain = CFRetain;
        context.release = CFRelease;
        context.copyDescription = CFCopyDescription;
        context.equal = NULL;
        context.hash = NULL;
        context.schedule = NULL;
        context.cancel = NULL;
        context.perform = MZWaitHandlerCallBack;
        
        runLoop = CFRunLoopGetCurrent();
        CFRetain(runLoop);
        source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    }
    return self;
}

- (void)dealloc
{
    CFRelease(runLoop);
    CFRelease(source);
    [super dealloc];
}

- (void)keyChanged:(GTMKeyValueChangeNotification *)notification
{
    CFRunLoopSourceSignal(source);
    CFRunLoopWakeUp(runLoop);
}

- (void)performHandling
{
    completed = YES;
}

- (BOOL)runMode:(CFStringRef)mode beforeDate:(NSDate *)limitDate
{
    CFRunLoopAddSource(runLoop, source, mode);
    while(!completed && [limitDate timeIntervalSinceNow] > 0)
    {
        SInt32 result = CFRunLoopRunInMode(mode, [limitDate timeIntervalSinceNow], true);
        if(result == kCFRunLoopRunFinished || result == kCFRunLoopRunStopped)
            return NO;
    }
    CFRunLoopRemoveSource(runLoop, source, mode);
    return YES;
}

@end


@implementation NSObject (WaitUntilChange)

- (void)waitForChangedKeyPath:(NSString *)keyPath
{
    MZWaitHandler* handler = [[MZWaitHandler alloc] init];
    [self gtm_addObserver:handler forKeyPath:keyPath selector:@selector(keyChanged:) userInfo:nil options:0];
    if(![handler runMode:kCFRunLoopDefaultMode beforeDate:[NSDate distantFuture]])
        MZLoggerDebug(@"Stopped or finished");
    [self gtm_removeObserver:handler forKeyPath:keyPath selector:@selector(keyChanged:)];
    [handler release];
}

@end
