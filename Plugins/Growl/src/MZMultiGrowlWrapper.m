//
//  MZMultiGrowlWrapper.m
//  MetaZ
//
//  Created by Brian Olsen on 17/01/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MZMultiGrowlWrapper.h"
#import <MetaZKit/MZLogger.h>

@interface MZMultiGrowlWrapper ()
- (void)load;
@end

@implementation MZMultiGrowlWrapper

static MZMultiGrowlWrapper *_MZSharedMultiGrowlWrapper = nil;
+ (MZMultiGrowlWrapper *)shared
{
    MZMultiGrowlWrapper* _shared = nil;
    @synchronized(self)
    {
        if (_MZSharedMultiGrowlWrapper == nil)
            [[[MZMultiGrowlWrapper alloc] init] release];
        _shared = _MZSharedMultiGrowlWrapper;
    }
    return _shared;
}

+ (void) notifyWithTitle:(NSString *)title
			 description:(NSString *)description
		notificationName:(NSString *)notifName
				iconData:(NSData *)iconData
				priority:(signed int)priority
				isSticky:(BOOL)isSticky
			clickContext:(id)clickContext;
{
    [[self shared] notifyWithTitle:title
                       description:description
                  notificationName:notifName
                          iconData:iconData
                          priority:priority
                          isSticky:isSticky
                      clickContext:clickContext];
}

+ (BOOL)isGrowlSupported;
{
    return [[self shared] isGrowlSupported];
}
+ (BOOL)isGrowlRunning;
{
    return [[self shared] isGrowlRunning];
}

+ (BOOL)isMistEnabled;
{
    return [[self shared] isMistEnabled];
}

+ (void)setGrowlDelegate:(id)delegate;
{
    [[self shared] setGrowlDelegate:delegate];
}

-(id)init
{
    self = [super init];

    @synchronized([self class])
    {
        if(_MZSharedMultiGrowlWrapper != nil)
        {
            [self release];
            self = [_MZSharedMultiGrowlWrapper retain];
        } else if(self)
        {
            [self load];
            _MZSharedMultiGrowlWrapper = [self retain];
        }
    }
    return self;
}

- (void)load
{
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [[mainBundle privateFrameworksPath] stringByAppendingPathComponent:@"Growl.framework"];
    path = [path stringByAppendingPathComponent:@"Versions"];
    if(NSAppKitVersionNumber >= 1038)
        path = [path stringByAppendingPathComponent:@"1.3.1"];
    else
        path = [path stringByAppendingPathComponent:@"1.2.3"];
	
    MZLoggerDebug(@"path: %@", path);
    NSBundle *growlFramework = [NSBundle bundleWithPath:path];
    if([growlFramework load])
	{
		NSDictionary *infoDictionary = [growlFramework infoDictionary];
		MZLoggerInfo(@"Using Growl.framework %@ (%@)",
			  [infoDictionary objectForKey:@"CFBundleShortVersionString"],
			  [infoDictionary objectForKey:(NSString *)kCFBundleVersionKey]);
	
		GrowlApplicationBridge = NSClassFromString(@"GrowlApplicationBridge");
	}
}

- (BOOL)isGrowlRunning;
{
    if([GrowlApplicationBridge respondsToSelector:@selector(isGrowlRunning)])
       return [GrowlApplicationBridge isGrowlRunning];
    return NO;
}

- (BOOL)isMistEnabled;
{
    if([GrowlApplicationBridge respondsToSelector:@selector(isMistEnabled)])
       return [GrowlApplicationBridge isMistEnabled];
    return NO;
}

- (BOOL)isGrowlSupported
{
    BOOL running = [self isGrowlRunning];
    if(running)
        return YES;
    return [self isMistEnabled];
}

- (void)setGrowlDelegate:(id)delegate
{
    if([GrowlApplicationBridge respondsToSelector:@selector(setGrowlDelegate:)])
        [GrowlApplicationBridge performSelector:@selector(setGrowlDelegate:) withObject:delegate];
}

- (void) notifyWithTitle:(NSString *)title
			 description:(NSString *)description
		notificationName:(NSString *)notifName
				iconData:(NSData *)iconData
				priority:(signed int)priority
				isSticky:(BOOL)isSticky
			clickContext:(id)clickContext
{
    if([GrowlApplicationBridge respondsToSelector:@selector(notifyWithTitle:description:notificationName:iconData:priority:isSticky:clickContext:)])
    {
        [GrowlApplicationBridge notifyWithTitle:title
                                    description:description 
                               notificationName:notifName
                                       iconData:iconData
                                       priority:priority
                                       isSticky:isSticky
                                   clickContext:clickContext];
    }
}


@end
