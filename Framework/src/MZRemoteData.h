//
//  MZRemoteData.h
//  MetaZ
//
//  Created by Brian Olsen on 19/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/ASIHTTPRequest.h>

@interface MZRemoteData : NSObject {
    NSData* data;
    BOOL isLoaded;
    NSURL* url;
    NSError* error;
    ASIHTTPRequest* request;
}
+ (id)dataWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url;

@property(readonly) NSURL* url;
@property(readonly, retain) NSData* data;
@property(readonly) BOOL isLoaded;
@property(readonly, retain) NSError* error; 
@property(readonly, retain) ASIHTTPRequest* request;

- (void)loadData;
- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request;

@end
