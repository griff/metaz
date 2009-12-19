//
//  ChaptersTableView.m
//  MetaZ
//
//  Created by Brian Olsen on 19/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "ChaptersTableView.h"
#import "ChapterItemWrapper.h"

@implementation ChaptersTableView

@synthesize editor;
@synthesize filesController;

- (void)dealloc
{
    [editor release];
    [filesController release];
    [super dealloc];
}

-(IBAction)copy:(id)sender
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray* chapters = editor.editorChapters;
    if([chapters count] == 0)
        return;

    NSMutableArray* items = [NSMutableArray array];;
    for(ChapterItemWrapper* item in chapters)
    {
        if(item.item)
            [items addObject:[item.item description]];
    }
    if([items count] == 0)
    {
        int i=1;
        for(ChapterItemWrapper* item in chapters)
        {
            [items addObject:[NSString stringWithFormat:@"%d.\t%@", i, item.text]];
            i++;
        }
    }
        
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pb setString:[items componentsJoinedByString:@"\r\n"] forType:NSStringPboardType];
}

-(IBAction)paste:(id)sender
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
    NSString *bestType = [pb availableTypeFromArray:types];
    if (bestType != nil)
    {
        if([bestType isEqualToString:NSStringPboardType])
        {
            NSString* str = [pb stringForType:NSStringPboardType];
            NSArray* chapters = [MZTimedTextItem parseChapters:str duration:nil];
            if(chapters)
            {
                if([[chapters objectAtIndex:0] isKindOfClass:[NSString class]])
                    editor.chapterNames = chapters;
                else
                {
                    for(MetaEdits* edits in [filesController selectedObjects])
                    {
                        MZTimeCode* duration = [edits valueForKey:MZDurationTagIdent];
                        chapters = [MZTimedTextItem parseChapters:str duration:duration];
                        [edits setValue:chapters forKey:MZChaptersTagIdent];
                    }
                }
            }
        }
    }
}

- (BOOL)pasteboardHasTypes {
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
    NSString *bestType = [pb availableTypeFromArray:types];
    if(bestType != nil && [bestType isEqualToString:NSStringPboardType])
    {
        NSString* str = [pb stringForType:NSStringPboardType];
        return [MZTimedTextItem parseChapters:str duration:nil] != nil;
    }
    return bestType != nil;
}

#pragma mark - user interface validation
- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
    SEL action = [anItem action];
    if(action == @selector(copy:))
        return [editor.editorChapters count] > 0;
    if(action == @selector(paste:))
        return [self pasteboardHasTypes];
    return [super validateUserInterfaceItem:anItem];
}

@end
