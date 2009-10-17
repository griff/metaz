//
//  SearchMeta.h
//  MetaZ
//
//  Created by Brian Olsen on 04/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>

@interface SearchMeta : MZDynamicObject <MetaData> {
    NSObject<MetaData>* provider;
    NSArrayController* searchController;
    BOOL ignoreController;
    MZPriorObserverFix* observeFix;
}

-(id)initWithProvider:(id<MetaData>)aProvider controller:(NSArrayController *)aController;

-(NSString *)loadedFileName;
-(NSString *)fileName;

@end
