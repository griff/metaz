//
//  SearchTableView.h
//  MetaZ
//
//  Created by Brian Olsen on 17/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchTableView : NSTableView
{
    NSArrayController* searchController;

}
@property (nonatomic, retain) IBOutlet NSArrayController* searchController;

@end
