//
//  MuhMa.h
//  MetaZ
//
//  Created by Brian Olsen on 16/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MGCollectionView.h"

@class MuhMaItem;

@interface MuhMa : NSObject {
    NSArrayController* queues;
    MGCollectionView* collectionView;
    MuhMaItem* itemPrototype;
    NSArray* content;
    NSMutableArray* _targetItems;
    NSViewAnimation* _animation;
}
@property(nonatomic, retain) IBOutlet NSArrayController* queues;
@property(nonatomic, retain) IBOutlet MGCollectionView* collectionView;
@property(nonatomic, retain) IBOutlet MuhMaItem* itemPrototype;
@property(retain) NSArray* content;

+ (void)initialize;

- (MuhMaItem *)newItemForRepresentedObject:(id)object;

@end

@interface MuhMaItem : NSViewController <NSCoding, NSCopying> {
    BOOL selected;
    MuhMa* _itemOwnerView;
    NSData* archived;
    BOOL _removalNeeded;
    NSRect _targetViewFrameRect;
    MGCollectionViewItem* item;
}
@property(readonly) MuhMa* parent;
@property(readonly) MGCollectionViewItem* item;
//@property(nonatomic, retain) IBOutlet NSView* view;

- (void)setSelected:(BOOL)flag;
- (BOOL)isSelected;

@end