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
        request = [[ASIHTTPRequest alloc] initWithURL:url];
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


- (void)requestFinished:(ASIHTTPRequest *)theRequest;
{
    if([theRequest responseStatusCode] == 200)
        [delegate searchProvider:provider result:[self parseResult]];
}

@end


@implementation MZASISearch

- (void)requestFinished:(ASIHTTPRequest *)theRequest;
{
    [super requestFinished:theRequest];
    [delegate searchFinished];
}

- (void)requestFailed:(ASIHTTPRequest *)theRequest;
{
    [delegate searchFinished];
}

@end
