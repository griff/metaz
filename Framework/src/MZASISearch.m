//
//  MZASISearch.m
//  MetaZ
//
//  Created by Brian Olsen on 25/08/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "MZASISearch.h"
#import <MetaZKit/ASIDownloadCache.h>

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
    NSMutableDictionary* temp = [NSMutableDictionary dictionary];
    for(NSString* key in theParameters)
    {
        //CFStringRef keyStr = (CFStringRef)[key copy];
        CFStringRef encodedKey = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                        (CFStringRef)key,
                                                                        NULL, 
                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                                        kCFStringEncodingUTF8);
        //CFStringRef value = (CFStringRef)[[parameters objectForKey:key] copy];
        // Escape even the "reserved" characters for URLs 
        // as defined in http://www.ietf.org/rfc/rfc2396.txt
        CFStringRef encodedValue = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                           (CFStringRef)[theParameters objectForKey:key],
                                                                           NULL, 
                                                                           (CFStringRef)@"!*'();:@&=+$,/?%#[]", 
                                                                           kCFStringEncodingUTF8);
        [temp setObject:(NSString*)encodedValue forKey:(NSString*)encodedKey];
        CFRelease(encodedValue);
        //CFRelease(value);
        CFRelease(encodedKey);
    }
    NSArray* paramNames = [[temp allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSMutableString *queryString = [NSMutableString string];
	int i, n = [paramNames count];
	for (i = 0; i < n; i++) {
		NSString *paramName = [paramNames objectAtIndex:i];
		[queryString appendFormat:@"%@=%@", paramName, [temp objectForKey:paramName]];
		if (i < n - 1) [queryString appendString:@"&"];
	}
	return queryString;
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
