//
//  MZNotification.m
//  MetaZ
//
//  Created by Brian Olsen on 24/11/13.
//
//

#import "MZNotification.h"

@interface MZNotification ()
- (void)load;
@end


@implementation MZNotification

static MZNotification* _MZSharedNotification = nil;
+ (MZNotification *)shared
{
    MZNotification* _shared = nil;
    @synchronized(self)
    {
        if (_MZSharedNotification == nil)
            [[[MZNotification alloc] init] release];
        _shared = _MZSharedNotification;
    }
    return _shared;
}

+(void)setDelegate:(id)delegate;
{
    [[self shared] setDelegate:delegate];
}

+(id)delegate;
{
    return [[self shared] delegate];
}

+ (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description
                   path:(NSString *)path;
{
    [[self shared] notifyWithTitle:title description:description path:path];
}

-(id)init
{
    self = [super init];
    
    @synchronized([self class])
    {
        if(_MZSharedNotification != nil)
        {
            [self release];
            self = [_MZSharedNotification retain];
        } else if(self)
        {
            [self load];
            _MZSharedNotification = [self retain];
        }
    }
    return self;
}

# pragma clang diagnostic ignored "-Wobjc-method-access"
- (void)load
{
    Class OSXNotificationCenterClass = NSClassFromString(@"NSUserNotificationCenter");
    center = [OSXNotificationCenterClass defaultUserNotificationCenter];
    OSXNotification = NSClassFromString(@"NSUserNotification");
}

- (void)setDelegate:(id)delegate;
{
    [center setDelegate:delegate];
}

- (id)delegate;
{
    return [center delegate];
}

- (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description
                   path:(NSString *)path;
{
    id notification = [[OSXNotification alloc] init];
    [notification setTitle:title];
    [notification setInformativeText:description];
    [notification setSoundName:@"NSUserNotificationDefaultSoundName"];
    if(path) {
        //[notification setActionButtonTitle:@"Show"];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:path forKey:@"MZPath"];
        [notification setUserInfo:userInfo];
    }
    else
        [notification setHasActionButton:NO];
    [center deliverNotification:notification];
}

@end
