//
//  MZRemoteData.m
//  MetaZ
//
//  Created by Brian Olsen on 19/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MZRemoteData.h"

@interface MZRemoteDataOperation : NSOperation
{
    /*
    NSMutableURLRequest *request;
    NSURLResponse* response;
    NSURLConnection* connection;
    */
    MZRemoteData* owner;
    /*
    NSInteger contentLength;
    NSInteger loaded;
    */
}

- (id)initWithOwner:(MZRemoteData *)owner;

/*
@property(assign) NSInteger contentLength;
@property(assign) NSInteger loaded;

- (void)start;
- (void)cancel;

- (BOOL)isExecuting;
- (BOOL)isConcurrent;
- (BOOL)isFinished;
*/

@end

@interface MZRemoteData()

@property(readwrite, retain) NSData* data;
@property(readwrite) BOOL isLoaded;
@property(readwrite, retain) NSError* error;
@property(readwrite, retain) NSOperation* operation;

@end


static NSOperationQueue *MZSharedRemoteDataOperationQueue() {
    static NSOperationQueue *_MZSharedRemoteDataOperationQueue = nil;
    if (_MZSharedRemoteDataOperationQueue == nil) {
        _MZSharedRemoteDataOperationQueue = [[NSOperationQueue alloc] init];
    }
    return _MZSharedRemoteDataOperationQueue;
}


@implementation MZRemoteData

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

@synthesize url;
@synthesize data;
@synthesize isLoaded;
@synthesize error;
@synthesize operation;

- (NSOperation *)loadData
{
    @synchronized(self)
    {
        if(self.operation == nil && self.data == nil)
        {
            self.error = nil;
            self.isLoaded = NO;
            NSOperation* op = [[[MZRemoteDataOperation alloc] initWithOwner:self] autorelease];
            self.operation = op;
            [MZSharedRemoteDataOperationQueue() addOperation:op];
            return op;
        }
        return self.operation;
    }
    return nil;
}

- (void)completedDataLoad:(NSData *)loadedData
{
    @synchronized(self)
    {
        self.data = loadedData;
        self.isLoaded = YES;
        self.operation = nil;
    }
}

- (void)loadedData:(NSData *)loadedData
{
    [self performSelectorOnMainThread:@selector(completedDataLoad:) withObject:loadedData waitUntilDone:YES];
}

- (void)failedWithError:(NSError *)actualError
{
    @synchronized(self)
    {
        self.error = actualError;
        self.isLoaded = YES;
        self.operation = nil;
    }
}

/*
- (void)loadImage
{
}

- (void)blaBla
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:finalURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

        NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:request
                                               delegate:self
                                       startImmediately:YES];
        
        if (!conn)
        {
            if ([delegate respondsToSelector:@selector(wrapper:didFailWithError:)])
            {
                NSMutableDictionary* info = [NSMutableDictionary dictionaryWithObject:[request URL] forKey:NSErrorFailingURLStringKey];
                [info setObject:@"Could not open connection" forKey:NSLocalizedDescriptionKey];
                NSError* error = [NSError errorWithDomain:@"Wrapper" code:1 userInfo:info];
                [delegate wrapper:self didFailWithError:error];
            }
        }
        else {
            self.connection = conn;
        }

}
*/
@end

@implementation MZRemoteDataOperation

- (id)initWithOwner:(MZRemoteData *)theOwner
{
    self = [super init];
    if(self)
    {
        owner = [theOwner retain];
    }
    return self;
}

/*
@synthesize contentLength;
@synthesize loaded;
*/
- (void)main
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    @try {
 
        NSError* error = nil;
        NSData* data = [NSData dataWithContentsOfURL:owner.url options:0 error:&error];
        if(data)
        {
            NSImage* image = [[NSImage alloc] initWithContentsOfURL:owner.url];
            if(!image)
            {
                NSString* str = [[[NSString alloc] initWithData:data 
                                 encoding:NSUTF8StringEncoding] autorelease];
                NSLog(@"Bad image url: %@", [owner.url absoluteString]);//, str);
            }
            [owner loadedData:data];
        }
        else
            [owner performSelectorOnMainThread:@selector(failedWithError:) withObject:error waitUntilDone:YES];
 
    }
    @catch(...) {
        // Do not rethrow exceptions.
    }
    [pool release];
}

/*
- (BOOL)isConcurrent
{
    return YES;
}

- (void)start
{
    @synchronized(self)
    {
        self.isExecuting = YES;
        if([self isCancelled])
        {
            self.isExecuting = NO;
            self.isFinished = YES;
        }
        NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:request
                                                                delegate:self
                                                        startImmediately:NO];
        if (!conn)
        {
            NSMutableDictionary* info = [NSMutableDictionary dictionaryWithObject:[request URL] forKey:NSErrorFailingURLStringKey];
            [info setObject:@"Could not open connection" forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:@"Wrapper" code:1 userInfo:info];
            
            if ([delegate respondsToSelector:@selector(wrapper:didFailWithError:)])
            {
                [delegate wrapper:self didFailWithError:error];
            }
        }
        else {
            [conn unscheduleFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            [conn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [conn start];
            self.connection = conn;
        }
    }
}
*/

@end

