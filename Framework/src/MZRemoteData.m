//
//  MZRemoteData.m
//  MetaZ
//
//  Created by Brian Olsen on 19/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZRemoteData.h"
#import <MetaZKit/MZLogger.h>
#import <MetaZKit/NSString+MimeTypePattern.h>

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

+ (id)imageDataWithURL:(NSURL *)url;
{
    return [self dataWithURL:url expectedMimeType:@"image/*"];
}

+ (id)dataWithURL:(NSURL *)url
{
    return [[[self alloc] initWithURL:url] autorelease];
}

+ (id)dataWithURL:(NSURL *)url expectedMimeType:(NSString *)mimeType;
{
    return [[[self alloc] initWithURL:url expectedMimeType:mimeType] autorelease];
}

- (id)initWithURL:(NSURL *)finalURL
{
    return [self initWithURL:finalURL expectedMimeType:@"*"];
}

- (id)initWithURL:(NSURL *)finalURL expectedMimeType:(NSString *)mimeType;
{
    self = [super init];
    if(self)
    {
        url = [finalURL retain];
        expectedMimeType = [mimeType retain];
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
    [url release];
    [expectedMimeType release];
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
        NSError* err = [theRequest error];
        if([theRequest responseStatusCode] >= 400)
        {
            if(!err)
            {
                NSDictionary* info = [NSDictionary 
                    dictionaryWithObject:[theRequest responseStatusMessage]
                                  forKey: NSLocalizedDescriptionKey];
                err = [NSError errorWithDomain:NetworkRequestErrorDomain
                                          code:[theRequest responseStatusCode]
                                      userInfo:info];
            }
            self.error = err;
        }
        else
        {
            NSStringEncoding charset = 0;
            NSString* mimeType = nil;
            [ASIHTTPRequest parseMimeType:&mimeType andResponseEncoding:&charset fromContentType:[[theRequest responseHeaders] valueForKey:@"Content-Type"]];

            if([mimeType matchesMimeTypePattern:expectedMimeType])
                self.data = [theRequest responseData];
            else
            {
                MZLoggerError(@"URL '%@' type=%@", self.url, mimeType);
                NSDictionary* info = [NSDictionary 
                    dictionaryWithObject:[NSString stringWithFormat:@"Unsupported Media Type %@", mimeType]
                                  forKey:NSLocalizedDescriptionKey];
                err = [NSError errorWithDomain:NetworkRequestErrorDomain
                                          code:415
                                      userInfo:info];
                self.error = err;
            }

        }
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

