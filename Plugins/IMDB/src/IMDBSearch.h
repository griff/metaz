//
//  IMDBSearch.h
//  MetaZ
//
//  Created by Brian Olsen on 23/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@protocol IMDBScraperProtocol <NSObject>

- (void)parseData:(NSString *)data withQueue:(NSOperationQueue *)queue delegate:(id)delegate;
- (void)parseMovie:(NSString *)data delegate:(id)delegate;

@end


@interface IMDBSearch : NSOperation
{
    NSString* title;
    id<IMDBScraperProtocol> scraper;
    NSOperationQueue* queue;
    id delegate;
}

- (id)initWithTitle:(NSString *)title delegate:(id<MZSearchProviderDelegate>)delegate;

@end
