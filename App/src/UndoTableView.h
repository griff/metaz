//
//  UndoTableView.h
//  MetaZ
//
//  Created by Brian Olsen on 11/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSObject (MenuForRow)
- (NSMenu *)tableView:(NSTableView *)aTableView menuForRow:(NSInteger)aRow;
@end

@interface UndoTableView : NSTableView
{
    NSString* editCancelHack;
}

@end
