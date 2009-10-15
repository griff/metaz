//
//  SearchMeta.h
//  MetaZ
//
//  Created by Brian Olsen on 04/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaData.h>
#import <MetaZKit/MZDynamicObject.h>
#import <MetaZKit/MZPriorObserverFix.h>

@interface SearchMeta : MZDynamicObject <MetaData> {
    NSObject<MetaData>* provider;
    IBOutlet NSArrayController* searchController;
    MZPriorObserverFix* observeFix;
}

-(id)initWithProvider:(id<MetaData>)aProvider controller:(NSArrayController *)aController;

-(NSString *)loadedFileName;
-(NSString *)fileName;

@end
