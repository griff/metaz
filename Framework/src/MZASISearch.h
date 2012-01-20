//
//  MZASISearch.h
//  MetaZ
//
//  Created by Brian Olsen on 25/08/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/ASIHTTPRequest.h>
#import <MetaZKit/MZSearchProvider.h>

@interface MZASISearchResult : NSObject {
    ASIHTTPRequest* request;
    id provider;
    NSDictionary *parameters;
    id<MZSearchProviderDelegate> delegate;
}

- (id)initWithProvider:(id)provider delegate:(id<MZSearchProviderDelegate>)delegate url:(NSURL *)url parameters:(NSDictionary *)params;

- (void)addToQueue:(NSOperationQueue *)queue;
- (void)cancel;
- (void)clearDelegatesAndCancel;
- (NSArray *)parseResult;

- (void)requestFinished:(ASIHTTPRequest *)request;

- (NSString *)queryStringForParameterDictionary:(NSDictionary *)parameters withUrl:(NSURL *)url;
- (NSDictionary *)preparedParameterDictionaryForInput:(NSDictionary *)inParams;

@end

@interface MZASISearch : MZASISearchResult {
}

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

@end