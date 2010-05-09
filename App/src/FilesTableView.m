//
//  MyTableView.m
//  MetaZ
//
//  Created by Brian Olsen on 02/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MetaZKit.h>
#import "FilesTableView.h"
#import "MZMetaLoader.h"

#define MZFilesTableRows @"MZFilesTableRows"


@interface FilesTableView (Private)

- (BOOL)writeSelectionUncheckedToPasteboard:(NSPasteboard *)pboard
                                      types:(NSArray *)types;

- (void)registerUndoName:(NSUndoManager *)manager;

@end

@implementation FilesTableView
@synthesize undoController;
@synthesize filesController;

+ (void)initialize
{
    if(self != [FilesTableView class])
        return;
    NSArray* sendTypes = [NSArray arrayWithObjects:NSFilenamesPboardType,
                                NSStringPboardType, nil];
    NSArray* returnTypes = [NSArray arrayWithObjects:NSFilenamesPboardType,
                                NSStringPboardType, nil];
    [NSApp registerServicesMenuSendTypes:sendTypes
                    returnTypes:returnTypes];
    
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self registerForDraggedTypes:
                [NSArray arrayWithObjects:MZFilesTableRows,
                    MZMetaEditsDataType, NSFilenamesPboardType,
                    NSStringPboardType, nil] ];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    if(self)
    {
        [self registerForDraggedTypes:
                [NSArray arrayWithObjects:MZFilesTableRows,
                    MZMetaEditsDataType, NSFilenamesPboardType,
                    NSStringPboardType, nil] ];
    }
    return self;
}

-(void)dealloc {
    [undoController release];
    [filesController release];
    [super dealloc];
}

#pragma mark - actions
-(IBAction)delete:(id)sender
{
    if([self selectedRow] >= 0)
    {
        NSRect rowRect = [self rectOfRow:[self selectedRow]];
        NSPoint point = NSMakePoint(
            rowRect.origin.x + rowRect.size.width/2,
            rowRect.origin.y + rowRect.size.height/2);
        point = [[self window] convertBaseToScreen:[self convertPointToBase:point]];
        NSShowAnimationEffect(NSAnimationEffectDisappearingItemDefault,point,NSZeroSize,nil,Nil,NULL);
    }
    [filesController remove:sender];
}

-(IBAction)copy:(id)sender
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    if([self numberOfSelectedRows] == 0)
        return;
        
    NSMutableArray* types = [NSMutableArray array];
    if([self numberOfSelectedRows] == 1)
    {
        [types addObject:MZMetaEditsDataType];
        [types addObject:NSStringPboardType];
    }
    [types addObject:NSFilenamesPboardType];
    [self writeSelectionUncheckedToPasteboard:pb types:types];
}

-(IBAction)paste:(id)sender
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *types = [NSArray arrayWithObjects:MZMetaEditsDataType,
            NSFilenamesPboardType, NSStringPboardType, nil];
    NSString *bestType = [pb availableTypeFromArray:types];
    if (bestType != nil)
    {
        /*
        if([bestType isEqualToString:MZFilesTableRows])
        {
            NSData* data = [pb dataForType:MZFilesTableRows];
            NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            // TODO Support rowIndex paste??
        }
        */
        if([bestType isEqualToString:MZMetaEditsDataType])
        {
            NSData* data = [pb dataForType:MZMetaEditsDataType];
            MetaEdits* pasted = [NSKeyedUnarchiver unarchiveObjectWithData:data];

            NSArray* edits = [filesController selectedObjects];
            NSInteger count = [edits count];
            
            for(MetaEdits* edit in edits)
                [self registerUndoName:edit.undoManager];
            
            for(MetaEdits* edit in edits)
            {
                for(MZTag* tag in [pasted providedTags])
                {
                    id value = [pasted pure];
                    value = [value valueForKey:[tag identifier]];
                    if( count == 1 || ![edit getterChangedForKey:[tag identifier]])
                    {
                        [edit setValue:value forKey:[tag identifier]];
                    }
                }
            }
            
            for(MetaEdits* edit in edits)
                [self registerUndoName:edit.undoManager];
        }
        if([bestType isEqualToString:NSFilenamesPboardType])
        {
            NSArray* filenames = [pb propertyListForType:NSFilenamesPboardType];
            [[MZMetaLoader sharedLoader] loadFromFiles:filenames];
        }
        if([bestType isEqualToString:NSStringPboardType])
        {
            NSString* filename = [pb stringForType:NSStringPboardType];
            NSFileManager* mgr = [NSFileManager manager];
            BOOL dir = NO;
            if([mgr fileExistsAtPath:[filename stringByExpandingTildeInPath]
                        isDirectory:&dir] && !dir)
                [[MZMetaLoader sharedLoader] loadFromFile:filename];
        }
    }
}

- (BOOL)pasteboardHasTypes {
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *types = [NSArray arrayWithObjects:MZMetaEditsDataType,
            NSFilenamesPboardType, NSStringPboardType, nil];
    NSString *bestType = [pb availableTypeFromArray:types];
    if(bestType != nil && [bestType isEqualToString:MZMetaEditsDataType])
        return [self numberOfSelectedRows] > 0;
    if(bestType != nil && [bestType isEqualToString:NSStringPboardType])
    {
        NSString* str = [pb stringForType:NSStringPboardType];
        NSFileManager* mgr = [NSFileManager manager];
        BOOL dir = NO;
        str = [str stringByExpandingTildeInPath];
        return [mgr fileExistsAtPath:str isDirectory:&dir] && !dir &&
            [[MZPluginController sharedInstance] dataProviderForPath:str] != nil;
    }
    if(bestType != nil && [bestType isEqualToString:NSFilenamesPboardType])
    {
        NSArray* filenames = [pb propertyListForType:NSFilenamesPboardType];
        for(NSString* str in filenames)
        {
            if(![[MZPluginController sharedInstance] dataProviderForPath:str])
                return NO;
        }
    }
    return bestType != nil;
}

#pragma mark - user interface validation
- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem {
    SEL action = [anItem action];
    if(action == @selector(delete:))
        return [self numberOfSelectedRows] > 0;
    if(action == @selector(copy:))
        return [self numberOfSelectedRows] == 1;
    if(action == @selector(paste:))
        return [self pasteboardHasTypes];
    return [super validateUserInterfaceItem:anItem];
}

#pragma mark - services support 
- (id)validRequestorForSendType:(NSString *)sendType
                     returnType:(NSString *)returnType
{
    if((sendType && [self selectedRow] >= 0) &&
        ([sendType isEqual:NSStringPboardType] ||
            [sendType isEqual:NSFilenamesPboardType]) &&
        (!returnType || [returnType length] == 0))
    {
            return self;
    }
    /*
    if(returnType &&
        ([returnType isEqual:NSStringPboardType] ||
            [returnType isEqual:NSFilenamesPboardType]))
    {
            return self;
    }
    */
    return [super validRequestorForSendType:sendType
                                 returnType:returnType];
}

- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pboard
                             types:(NSArray *)types
{
    if(![types containsObject:NSStringPboardType] &&
        ![types containsObject:NSFilenamesPboardType] &&
        ![types containsObject:MZMetaEditsDataType])
    {
        return NO;
    }
    if([self selectedRow] < 0)
        return NO;

    
    NSMutableArray* returnTypes = [NSMutableArray array];
    if([types containsObject:MZMetaEditsDataType])
        [returnTypes addObject:MZMetaEditsDataType];
    if([types containsObject:NSFilenamesPboardType])
        [returnTypes addObject:NSFilenamesPboardType];
    if([types containsObject:NSStringPboardType])
        [returnTypes addObject:NSStringPboardType];
    return [self writeSelectionUncheckedToPasteboard:pboard types:returnTypes];
}

#pragma mark - drag'n'drop support
- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint operation:(NSDragOperation)operation
{
    [super draggedImage:anImage endedAt:aPoint operation:operation];
}

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes
     toPasteboard:(NSPasteboard*)pboard
{
    [pboard declareTypes:[NSArray arrayWithObjects:MZFilesTableRows,
            MZMetaEditsDataType, NSFilenamesPboardType,
            NSStringPboardType,nil] owner:nil];

    NSData *rowdata = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    if(![pboard setData:rowdata forType:MZFilesTableRows])
        return NO;

    NSArray* edits = [[filesController arrangedObjects] objectsAtIndexes:rowIndexes];
    NSData *editsdata = [NSKeyedArchiver archivedDataWithRootObject:edits];
    if(![pboard setData:editsdata forType:MZMetaEditsDataType])
        return NO;

    NSArray* filenames = [edits arrayByPerformingSelector:@selector(loadedFileName)];
    if(![pboard setPropertyList:filenames forType:NSFilenamesPboardType])
        return NO;
    if(![pboard setString:[filenames objectAtIndex:0] forType:NSStringPboardType])
        return NO;
    return YES;
}


- (NSDragOperation)tableView:(NSTableView*)tv
                validateDrop:(id <NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)op
{
    if(op==NSTableViewDropOn)
        [self setDropRow:row dropOperation:NSTableViewDropAbove];

    NSPasteboard* pboard = [info draggingPasteboard];
    NSArray *types = [NSArray arrayWithObjects:MZFilesTableRows,
            MZMetaEditsDataType, NSFilenamesPboardType,
            NSStringPboardType, nil];
    //NSDragOperation operation = [info draggingSourceOperationMask];        
    NSString *bestType = [pboard availableTypeFromArray:types];
    if(bestType != nil)
    {
        if([bestType isEqualToString:NSStringPboardType])
        {
            NSString* str = [pboard stringForType:NSStringPboardType];
            NSFileManager* mgr = [NSFileManager manager];
            BOOL dir = NO;
            str = [str stringByExpandingTildeInPath];
            if([mgr fileExistsAtPath:str isDirectory:&dir] && !dir &&
                [[MZPluginController sharedInstance] dataProviderForPath:str])
            {
                return NSDragOperationGeneric;
            }
            return NSDragOperationNone;
        }
        if([bestType isEqualToString:NSFilenamesPboardType])
        {
            NSArray* filenames = [pboard propertyListForType:NSFilenamesPboardType];
            for(NSString* str in filenames)
            {
                if(![[MZPluginController sharedInstance] dataProviderForPath:str])
                    return NSDragOperationNone;
            }
            return NSDragOperationGeneric;
        }
        return NSDragOperationMove;
    }
    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info
            row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard* pboard = [info draggingPasteboard];
    NSArray *types = [NSArray arrayWithObjects:MZFilesTableRows,
            MZMetaEditsDataType, NSFilenamesPboardType,
            NSStringPboardType, nil];
    NSString *bestType = [pboard availableTypeFromArray:types];
    if (bestType != nil)
    {
        if([bestType isEqualToString:MZFilesTableRows])
        {
            NSData* data = [pboard dataForType:MZFilesTableRows];
            NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            NSArray* edits = [[filesController arrangedObjects] objectsAtIndexes:rowIndexes];
            [filesController setSortDescriptors:nil];
            [[MZMetaLoader sharedLoader] moveObjects:edits toIndex:row];
            return YES;
        }
        /*
        if([bestType isEqualToString:MZMetaEditsDataType])
        {
            NSData* data = [pb dataForType:MZMetaEditsDataType];
            NSArray* edits = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
        */
        if([bestType isEqualToString:NSFilenamesPboardType])
        {
            NSArray* filenames = [pboard propertyListForType:NSFilenamesPboardType];
            for(NSString* file in filenames)
            {
                if(![[MZPluginController sharedInstance] dataProviderForPath:file])
                    return NO;
            }
            /* Doesn't work
            NSWindow* window = [self window];
            [window orderFront:self];
            [window makeMainWindow];
            */
            if(![filesController commitEditing])
                return NO;
            NSArray* params = [NSArray arrayWithObjects:filenames, [NSNumber numberWithInteger:row], nil];
            [self performSelector:@selector(loadFiles:) withObject:params afterDelay:1];
            return YES;
        }
        if([bestType isEqualToString:NSStringPboardType])
        {
            NSString* filename = [pboard stringForType:NSStringPboardType];
            NSFileManager* mgr = [NSFileManager manager];
            BOOL dir = NO;
            filename = [filename stringByExpandingTildeInPath];
            if([mgr fileExistsAtPath:filename isDirectory:&dir] && !dir &&
                [[MZPluginController sharedInstance] dataProviderForPath:filename])
            {
                //[[self window] makeKeyAndOrderFront:self];
                if(![filesController commitEditing])
                    return NO;
                NSArray* params = [NSArray arrayWithObjects:filename, [NSNumber numberWithInteger:row], nil];
                [self performSelector:@selector(loadFiles:) withObject:params afterDelay:1];
                return YES;
            }
        }
    }
    return NO;
}

- (void)loadFiles:(NSArray *)params
{
    id first = [params objectAtIndex:0];
    NSInteger row = [[params objectAtIndex:1] integerValue];
    if([first isKindOfClass:[NSArray class]])
        [[MZMetaLoader sharedLoader] loadFromFiles:first toIndex:row];
    else
        [[MZMetaLoader sharedLoader] loadFromFile:first toIndex:row];
}

#pragma mark - private

- (BOOL)writeSelectionUncheckedToPasteboard:(NSPasteboard *)pboard
                                      types:(NSArray *)types
{
    [pboard declareTypes:types owner:nil];

    if([types containsObject:MZMetaEditsDataType])
    {
        MetaEdits* selection = [[filesController arrangedObjects] objectAtIndex:[self selectedRow]];
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:selection];
        if(![pboard setData:data forType:MZMetaEditsDataType])
            return NO;
    }
    if([types containsObject:NSFilenamesPboardType])
    {
        NSArray* selection = [[filesController arrangedObjects] objectsAtIndexes:[self selectedRowIndexes]];
        selection = [selection arrayByPerformingSelector:@selector(loadedFileName)];
        if(![pboard setPropertyList:selection forType:NSFilenamesPboardType])
            return NO;
    }
    if([types containsObject:NSStringPboardType])
    {
        MetaEdits* selection = [[filesController arrangedObjects] objectAtIndex:[self selectedRow]];
        if(![pboard setString:[selection loadedFileName] forType:NSStringPboardType])
            return NO;
    }
    
    return YES;
}

- (void)registerUndoName:(NSUndoManager *)manager
{
    [manager setActionName:NSLocalizedString(@"Paste Tags", @"Paste tags undo name")];
    [manager registerUndoWithTarget:self 
                           selector:@selector(registerUndoName:)
                             object:manager];
}


#pragma mark - general

- (void)awakeFromNib
{
    [self setDataSource:self];
}

- (void)keyDown:(NSEvent *)theEvent {
    NSString* ns = [theEvent charactersIgnoringModifiers];
    NSUInteger modifierFlags = [theEvent modifierFlags]; 
    if([ns length] == 1)
    {
        unichar ch = [ns characterAtIndex:0];
        //MZLoggerDebug(@"keyDown %x %x", ch, NSNewlineCharacter);
        switch(ch) {
            case NSBackspaceCharacter:
            case NSDeleteCharacter:
                if([self numberOfSelectedRows] > 0 && (modifierFlags & NSCommandKeyMask) == NSCommandKeyMask )
                {
                    //MZLoggerDebug(@"Caught Cmd-Backspace");
                    [self delete:self];
                    return;
                }
        }
    }
    [super keyDown:theEvent];
}

-(NSUndoManager *)undoManager {
    NSUndoManager* man = [undoController undoManager];
    if(man != nil)
        return man;
    return [super undoManager];
}

@end
