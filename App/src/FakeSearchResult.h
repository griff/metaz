//
//  PureSearchResult.h
//  MetaZ
//
//  Created by Brian Olsen on 16/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FakeSearchResult : NSObject {
    NSArrayController* filesController;
    NSString* searchResultTitle;
    BOOL hasChapters;
}
@property(readonly) NSImage* icon;
@property(readonly) NSString* searchResultTitle;
@property(readonly) BOOL hasChapters;

+ (id)resultWithController:(NSArrayController *)controller;
- (id)initWithController:(NSArrayController *)controller;

- (NSMenu*)menu;
- (void)updateTitle;
- (void)updateChapters;

@end
