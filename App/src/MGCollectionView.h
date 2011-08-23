//
//  MuhMa.h
//  MetaZ
//
//  Created by Brian Olsen on 16/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MGViewAnimation.h"

@class MGCollectionViewItem;
@class MGCollectionView;

/*
enum {
    MGCollectionViewDropOn = 0,
    MGCollectionViewDropBefore = 1,
};
typedef NSInteger MGCollectionViewDropOperation;

@protocol NSCollectionViewDelegate

- (BOOL)collectionView:(MGCollectionView *)collectionView
   writeItemsAtIndexes:(NSIndexSet *)indexes
          toPasteboard:(NSPasteboard *)pasteboard;

@optional
- (BOOL)collectionView:(MGCollectionView *)collectionView
 canDragItemsAtIndexes:(NSIndexSet *)indexes
             withEvent:(NSEvent *)event;
             
- (NSDragOperation)collectionView:(MGCollectionView *)collectionView
                     validateDrop:(id < NSDraggingInfo >)draggingInfo
                    proposedIndex:(NSInteger *)proposedDropIndex
                    dropOperation:(MGCollectionViewDropOperation *)proposedDropOperation;

@end
*/

@interface MGCollectionView : NSView {
    MGCollectionViewItem* itemPrototype;
    NSArray* content;
    NSMutableArray* _targetItems;
    MGViewAnimation* _animation;
    NSRect _targetViewFrameRect;
    BOOL needsLayout;
    NSArray* backgroundColors;
    BOOL usesAlternatingRowBackgroundColors;
    NSArray* items;
}
@property(nonatomic, retain) IBOutlet MGCollectionViewItem* itemPrototype;
@property(copy) NSArray* content;
@property(copy) NSArray* backgroundColors;
@property(readwrite) BOOL usesAlternatingRowBackgroundColors;
@property(readonly) NSArray* items;

+ (void)initialize;

- (MGCollectionViewItem *)newItemForRepresentedObject:(id)object;

- (void)setNeedsLayout:(BOOL)flag;

- (id)representedObjectForView:(NSView *)view;

@end


@interface MGCollectionViewItem : NSViewController <NSCoding, NSCopying> {
    BOOL selected;
    MGCollectionView* _itemOwnerView;
    NSData* archived;
    BOOL _removalNeeded;
    NSRect _targetViewFrameRect;
}
@property(readonly) MGCollectionView* collectionView;
@property(readwrite) BOOL selected;

@end