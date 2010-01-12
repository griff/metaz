//
//  IMDBSearchItem.h
//  MetaZ
//
//  Created by Brian Olsen on 23/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IMDBSearch.h"

@interface IMDBSearchItem : NSOperation
{
    NSString* ident;
    NSString* title;
    id<IMDBScraperProtocol> scraper;
    id delegate;
}

- (id)initWithIdentifier:(NSString *)ident title:(NSString *)title scraper:(id<IMDBScraperProtocol>)scraper delegate:(id<MZSearchProviderDelegate>)delegate;

@end
