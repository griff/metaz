//
//  MZASISearch.h
//  MetaZ
//
//  Created by Brian Olsen on 25/08/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZHTTPRequest.h>
#import <MetaZKit/MZSearchProvider.h>

@interface MZASISearchResult : NSObject {
    MZHTTPRequest* request;
    id provider;
    NSDictionary *parameters;
    id<MZSearchProviderDelegate> delegate;
}

- (id)initWithProvider:(id)theProvider delegate:(id<MZSearchProviderDelegate>)theDelegate url:(NSURL *)theUrl parameters:(NSDictionary *)params;

- (void)addToQueue:(NSOperationQueue *)queue;
- (void)cancel;
- (void)clearDelegatesAndCancel;
- (NSArray *)parseResult;

- (void)requestFinishedBackground:(ASIHTTPRequest *)request;
- (void)providedResults:(NSArray *)results;

- (NSString *)queryStringForParameterDictionary:(NSDictionary *)parameters withUrl:(NSURL *)url;
- (NSDictionary *)preparedParameterDictionaryForInput:(NSDictionary *)inParams;

@end

@interface MZASISearch : MZASISearchResult {
}

- (void)internalFinished;

@end