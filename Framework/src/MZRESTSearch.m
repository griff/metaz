//
//  MZRESTSearch.m
//  MetaZ
//
//  Created by Brian Olsen on 18/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZRESTSearch.h"
#import "MZSearchProvider.h"

@implementation MZRESTSearch

+ (Class)restWrapper
{
    return [MZRESTWrapper class];
}

@synthesize isFinished;
@synthesize isExecuting;

- (id)initWithProvider:(id)theProvider delegate:(id<MZSearchProviderDelegate>)theDelegate url:(NSURL *)url usingVerb:(NSString *)theVerb parameters:(NSDictionary *)params;
{
    self = [super init];
    if(self)
    {
        searchURL = [url retain];
        verb = [theVerb retain];
        parameters = [params retain];
        provider = [theProvider retain];
        delegate = [theDelegate retain];
        wrapper = [[[[self class] restWrapper] alloc] init];
        wrapper.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.isExecuting = NO;
    self.isFinished = YES;
    [parameters release];
    [searchURL release];
    [verb release];
    [wrapper cancelConnection];
    [wrapper release];
    [delegate release];
    [super dealloc];
}

- (void)start
{
    self.isExecuting = YES;
    if([self isCancelled])
    {
        id del = delegate;
        [del performSelectorOnMainThread:@selector(searchFinished) withObject:nil waitUntilDone:NO];
        //[delegate searchFinished];
        self.isExecuting = NO;
        self.isFinished = YES;
    }
    else
        [wrapper sendRequestTo:searchURL usingVerb:verb withParameters:parameters];
}

- (BOOL)isConcurrent
{
    return YES;
}

/*
- (BOOL)isExecuting
{
    return wrapper.connection != nil;
}

- (BOOL)isFinished
{
    return self.finished;
}
*/

- (void)cancel
{
    [super cancel];
    if(self.isExecuting)
        [wrapper cancelConnection];
}

#pragma mark - MZRESTWrapperDelegate

- (void)wrapper:(MZRESTWrapper *)theWrapper didRetrieveData:(NSData *)data
{
    //NSLog(@"Got response:\n%@", [theWrapper responseAsText]);
    [delegate searchProvider:provider result:[NSArray array]];
    [delegate searchFinished];
    self.isExecuting = NO;
    self.isFinished = YES;
}

- (void)wrapper:(MZRESTWrapper *)theWrapper didFailWithError:(NSError *)error
{
    NSLog(@"%@ search failed: %@", [self class], [error localizedDescription]);
    [delegate searchFinished];
    self.isExecuting = NO;
    self.isFinished = YES;
}

- (void)wrapper:(MZRESTWrapper *)theWrapper didReceiveStatusCode:(int)statusCode
{
    NSLog(@"%@ got status code: %d", [self class], statusCode);
    [delegate searchFinished];
    self.isExecuting = NO;
    self.isFinished = YES;
}

- (void)wrapperWasCanceled:(MZRESTWrapper *)theWrapper
{
    if(self.isExecuting)
        [delegate searchFinished];
    self.isExecuting = NO;
    self.isFinished = YES;
}

@end
