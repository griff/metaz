//
//  MZASISearch.m
//  MetaZ
//
//  Created by Brian Olsen on 25/08/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "MZASISearch.h"
#import <MetaZKit/ASIDownloadCache.h>
#import <MetaZKit/NSString+MZQueryString.h>
#import <MetaZKit/MZLogger.h>
#import <MetaZKit/GTMNSObject+KeyValueObserving.h>

@implementation MZASISearchResult

+ (void)initialize
{
    [ASIHTTPRequest setDefaultCache:[ASIDownloadCache sharedCache]];
}

- (id)initWithProvider:(id)theProvider delegate:(id<MZSearchProviderDelegate>)theDelegate url:(NSURL *)url parameters:(NSDictionary *)theParameters;
{
    self = [super init];
    if(self)
    {
        provider = theProvider;
        delegate = [theDelegate retain];

        parameters = [theParameters retain];
        request = [[MZHTTPRequest alloc] initWithURL:url];
        [request setDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [request cancel];
    [request release];
    [delegate release];
    [parameters release];
    [super dealloc];
}

- (void)addToQueue:(NSOperationQueue *)queue;
{
    if (parameters != nil)
    {
        NSDictionary* prepared = [self preparedParameterDictionaryForInput:parameters];
        NSString* params = [self queryStringForParameterDictionary:prepared withUrl:[request url]];
        
        NSString *urlWithParams = [[[request url] absoluteString] stringByAppendingFormat:@"?%@", params];
        MZLoggerDebug(@"Sending request to %@", urlWithParams);
        [request setURL:[NSURL URLWithString:urlWithParams]];
    }

    [queue addOperation:request];
}

- (void)cancel;
{
    [request cancel];
}

- (void)clearDelegatesAndCancel;
{
    [request clearDelegatesAndCancel];
}


- (NSArray *)parseResult
{
    return [NSArray array];
}

#pragma mark Protected methods
- (NSDictionary *)preparedParameterDictionaryForInput:(NSDictionary *)inParams
{
    [inParams retain];
    return [inParams autorelease];
}

- (NSString *)queryStringForParameterDictionary:(NSDictionary *)theParameters withUrl:(NSURL *)url
{
    return [NSString mz_queryStringForParameterDictionary:theParameters];
}


- (void)requestFinishedBackground:(ASIHTTPRequest *)theRequest;
{
    if([theRequest responseStatusCode] == 200)
        [self performSelectorOnMainThread:@selector(providedResults:) withObject:[self parseResult] waitUntilDone:NO];
}

- (void)providedResults:(NSArray *)results;
{
    [delegate searchProvider:provider result:results];
}

@end


@implementation MZASISearch

- (id)initWithProvider:(id)theProvider delegate:(id<MZSearchProviderDelegate>)theDelegate url:(NSURL *)theUrl parameters:(NSDictionary *)params;
{
    self = [super initWithProvider:theProvider delegate:theDelegate url:theUrl parameters:params];
    if(self)
    {
        [request gtm_addObserver:self forKeyPath:@"isFinished" selector:@selector(operationFinished:) userInfo:nil options:0];
    }
    return self;
}

- (void)dealloc
{
    [request gtm_removeObserver:self forKeyPath:@"isFinished" selector:@selector(operationFinished:)];
    [super dealloc];
}

- (void)operationFinished:(GTMKeyValueChangeNotification *)notification
{
    [request gtm_removeObserver:self forKeyPath:@"isFinished" selector:@selector(operationFinished:)];
    [self performSelectorOnMainThread:@selector(internalFinished) withObject:nil waitUntilDone:YES];
}

- (void)internalFinished
{
    [delegate searchFinished];
}

@end
