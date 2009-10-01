//
//  FileViewBox.m
//  MetaZ
//
//  Created by Brian Olsen on 14/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "FileViewBox.h"
#import "MyQueueCollectionView.h"
#import "MZWriteQueueStatus.h"

@implementation FileViewBox
@synthesize tabView;
@synthesize label;
@synthesize disclosure;

-(void)dealloc
{
    [tabView release];
    [label release];
    [disclosure release];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if(self)
    {
        if([decoder allowsKeyedCoding])
        {
            tabView = [[decoder decodeObjectForKey:@"tabView"] retain];
            label = [[decoder decodeObjectForKey:@"label"] retain];
            disclosure = [[decoder decodeObjectForKey:@"disclosure"] retain];
        }
        else
        {
            tabView = [[decoder decodeObject] retain];
            label = [[decoder decodeObject] retain];
            disclosure = [[decoder decodeObject] retain];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    if([encoder allowsKeyedCoding])
    {
        [encoder encodeObject:tabView forKey:@"tabView"];
        [encoder encodeObject:label forKey:@"label"];
        [encoder encodeObject:disclosure forKey:@"disclosure"];
    }
    else
    {
        [encoder encodeObject:tabView];
        [encoder encodeObject:label];
        [encoder encodeObject:disclosure];
    }
}

/*
- (void)removeFromSuperviewWithoutNeedingDisplay
{
    [super removeFromSuperviewWithoutNeedingDisplay];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
}

- (void)bind:(NSString *)binding toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
    [super bind:binding toObject:observableController withKeyPath:keyPath options:options];
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize
{
    NSString* tab = [[tabView selectedTabViewItem] identifier];
    if([tab isEqual:@"pending"])
    {
        NSLog(@"resize %@", self);
    }
    [super resizeWithOldSuperviewSize:oldBoundsSize];
}

-(void)setFrameSize:(NSSize)newSize
{
    NSString* tab = [[tabView selectedTabViewItem] identifier];
    if([tab isEqual:@"pending"])
        newSize.height = 43;
    [super setFrameSize:newSize];
}

-(void)setFrame:(NSRect)newFrame
{
    [super setFrame:newFrame];
}

- (void)setFrameOrigin:(NSPoint)newOrigin
{
    [super setFrameOrigin:newOrigin];
}

- (void)setFrameRotation:(CGFloat)angle
{
    [super setFrameRotation:angle];
}
*/

- (IBAction)switchDetails:(id)sender
{
    /*
    NSTabViewItem * item = [tabView selectedTabViewItem];
    if([[item identifier] isEqual:@"pending"])
        [tabView selectTabViewItemWithIdentifier:@"action"];
    else
        [tabView selectTabViewItemWithIdentifier:@"pending"];
    */
}

- (IBAction)removeItem:(id)sender
{
    MyQueueCollectionView* colview = (MyQueueCollectionView*)[self superview];
    id object = [colview representedObjectForView:self];
    if(object)
        [colview removeObject:object];
}

- (IBAction)revealItem:(id)sender
{
    MyQueueCollectionView* colview = (MyQueueCollectionView*)[self superview];
    MZWriteQueueStatus* object = [colview representedObjectForView:self];
    NSString* fileName = [[object edits] loadedFileName];
    if([object completed])
        fileName = [[object edits] savedFileName];
    [[NSWorkspace sharedWorkspace]
                      selectFile:fileName
        inFileViewerRootedAtPath:@""];
}

@end
