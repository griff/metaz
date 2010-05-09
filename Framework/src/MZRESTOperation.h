//
//  MZRESTOperation.h
//  MetaZ
//
//  Created by Nigel Graham on 13/04/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZRESTWrapper.h>

@interface MZRESTOperation : NSOperation <MZRESTWrapperDelegate>
{
    MZRESTWrapper* wrapper;
    NSURL* searchURL;
    NSString* verb;
    NSDictionary* parameters;
    BOOL finished;
    BOOL executing;
}
+ (Class)restWrapper;

- (id)initWithURL:(NSURL *)url usingVerb:(NSString *)verb parameters:(NSDictionary *)params;

@property(getter=isFinished,assign) BOOL finished;
@property(getter=isExecuting,assign) BOOL executing;

- (void)start;
- (BOOL)isConcurrent;
- (void)cancel;
- (void)waitUntilFinished;

- (void)operationFinished;

@end
