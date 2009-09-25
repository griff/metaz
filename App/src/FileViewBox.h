//
//  FileViewBox.h
//  MetaZ
//
//  Created by Brian Olsen on 14/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FileViewBox : NSBox {
    NSTabView* tabView;
    NSTextField* label;
    NSButton* disclosure;
}
@property (nonatomic, retain) IBOutlet NSTabView *tabView;
@property (nonatomic, retain) IBOutlet NSTextField* label;
@property (nonatomic, retain) IBOutlet NSButton* disclosure;

- (IBAction)switchTab:(id)sender;
- (IBAction)removeItem:(id)sender;

@end
