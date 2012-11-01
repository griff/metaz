//
//  MZRemoteData.m
//  MetaZ
//
//  Created by Brian Olsen on 19/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZRemoteData.h"
#import <MetaZKit/MZLogger.h>


@interface MZRemoteData()

+ (NSOperationQueue *)sharedQueue;

@property(readwrite, retain) NSData* data;
@property(readwrite) BOOL isLoaded;
@property(readwrite, retain) NSError* error;
@property(readwrite, retain) ASIHTTPRequest* request;

@end


@implementation MZRemoteData
@synthesize url;
@synthesize data;
@synthesize isLoaded;
@synthesize error;
@synthesize request;
@synthesize userInfo;

+ (NSOperationQueue *)sharedQueue
{
    static NSOperationQueue *_MZSharedRemoteDataOperationQueue = nil;
    @synchronized(self)
    {
        if (_MZSharedRemoteDataOperationQueue == nil)
        {
            _MZSharedRemoteDataOperationQueue = [[NSOperationQueue alloc] init];
            [_MZSharedRemoteDataOperationQueue setMaxConcurrentOperationCount:12];
        }
    }
    return _MZSharedRemoteDataOperationQueue;
}

+ (id)dataWithURL:(NSURL *)url
{
    return [[[self alloc] initWithURL:url] autorelease];
}

- (id)initWithURL:(NSURL *)finalURL
{
    self = [super init];
    if(self)
    {
        url = [finalURL retain];
    }
    return self;
}

- (void)dealloc
{
    [request clearDelegatesAndCancel];
    [request release];
    [data release];
    [error release];
    self.userInfo = nil;
    [super dealloc];
}

- (void)loadData
{
    @synchronized(self)
    {
        if(self.request == nil && self.data == nil)
        {
            self.error = nil;
            self.isLoaded = NO;
            ASIHTTPRequest* req = [ASIHTTPRequest requestWithURL:self.url];
            req.delegate = self;
            self.request = req;
            [[MZRemoteData sharedQueue] addOperation:req];
        }
    }
}

- (void)requestFinished:(ASIHTTPRequest *)theRequest
{
    if(![theRequest responseData])
    {
        MZLoggerDebug(@"Response data for url %@ is nil", self.url);
    }
    @synchronized(self)
    {
        self.data = [theRequest responseData];
        self.isLoaded = YES;
        self.request = nil;
    }
}
 
- (void)requestFailed:(ASIHTTPRequest *)theRequest
{
    @synchronized(self)
    {
        self.error = [theRequest error];
        self.isLoaded = YES;
        self.request = nil;
    }
}

@end

