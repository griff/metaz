//
//  GenreDataSource.h
//  MetaZ
//
//  Created by Brian Olsen on 09/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GenreDataSource : NSObject {
    NSArray* genres;
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox;
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index;
- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)aString;
- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString;

- (void)dataWritingStarted:(NSNotification *)note;

@end
