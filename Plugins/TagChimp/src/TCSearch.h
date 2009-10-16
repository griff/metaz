//
//  TCSearch.h
//  MetaZ
//
//  Created by Brian Olsen on 13/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface TCSearch : NSObject <MZRESTWrapperDelegate>
{
    id provider;
    MZRESTWrapper* wrapper;
    NSDictionary* mapping;
    NSArray* ratingNames;
    BOOL canceled;
    id<MZSearchProviderDelegate> delegate;
}

- (id)initWithProvider:(id)provider delegate:(id<MZSearchProviderDelegate>)delegate wrapper:(MZRESTWrapper *)wrapper;
- (void)cancel;

@end
