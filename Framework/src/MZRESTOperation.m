//
//  MZRESTOperation.m
//  MetaZ
//
//  Created by Brian Olsen on 13/04/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "MZRESTOperation.h"
#import <MetaZKit/MZLogger.h>
#import "NSObject+WaitUntilChange.h"

@implementation MZRESTOperation

+ (NSSet *)keyPathsForValuesAffectingIsFinished
{
    return [NSSet setWithObjects:@"finished", nil];
}

+ (NSSet *)keyPathsForValuesAffectingIsExecuting
{
    return [NSSet setWithObjects:@"executing", nil];
}

+ (Class)restWrapper
{
    return [MZRESTWrapper class];
}

- (id)initWithURL:(NSURL *)url usingVerb:(NSString *)theVerb parameters:(NSDictionary *)params;
{
    self = [super init];
    if(self)
    {
        searchURL = [url retain];
        verb = [theVerb retain];
        parameters = [params retain];
        wrapper = [[[[self class] restWrapper] alloc] init];
        wrapper.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [self cancel];
    [parameters release];
    [searchURL release];
    [verb release];
    [wrapper release];
    [super dealloc];
}

@synthesize finished;
@synthesize executing;

- (void)startMain
{
    if([self isCancelled])
    {
        [self operationFinished];
        //[delegate searchFinished];
        self.executing = NO;
        self.finished = YES;
    }
    else
        [wrapper sendRequestTo:searchURL usingVerb:verb withParameters:parameters];
}

- (void)start
{
    self.executing = YES;
    [self performSelectorOnMainThread:@selector(startMain) withObject:nil waitUntilDone:YES];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)cancel
{
    [super cancel];
    if(self.executing)
        [wrapper cancelConnection];
}

/*
- (void)waitUntilFinished
{
    if(![self isFinished])
        [self waitForChangedKeyPath:@"finished"];
}
*/

- (void)operationFinished
{
}

#pragma mark - MZRESTWrapperDelegate

- (void)wrapper:(MZRESTWrapper *)theWrapper didRetrieveData:(NSData *)data
{
    //MZLoggerDebug(@"Got response:\n%@", [theWrapper responseAsText]);
    [self operationFinished];
    self.executing = NO;
    self.finished = YES;
}

- (void)wrapper:(MZRESTWrapper *)theWrapper didFailWithError:(NSError *)error
{
    MZLoggerError(@"%@ search failed: %@", [self class], [error localizedDescription]);
    [self operationFinished];
    self.executing = NO;
    self.finished = YES;
}

- (void)wrapper:(MZRESTWrapper *)theWrapper didReceiveStatusCode:(int)statusCode
{
    MZLoggerDebug(@"%@ got status code: %d", [self class], statusCode);
    [self operationFinished];
    self.executing = NO;
    self.finished = YES;
}

- (void)wrapperWasCanceled:(MZRESTWrapper *)theWrapper
{
    if(self.executing)
    {
        [self operationFinished];
        self.executing = NO;
        self.finished = YES;
    }
}

@end
