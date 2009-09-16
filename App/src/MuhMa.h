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
    IBOutlet NSArrayController* queues;
    IBOutlet MGCollectionView* collectionView;
    MuhMaItem* itemPrototype;
    NSArray* content;
}
@property(retain) IBOutlet MuhMaItem* itemPrototype;
@property(retain) NSArray* content;

+ (void)initialize;

- (MuhMaItem *)newItemForRepresentedObject:(id)object;

@end

@interface MuhMaItem : NSViewController <NSCoding, NSCopying> {
    BOOL selected;
    MuhMa* parent;
    NSData* archived;
}

- (void)setSelected:(BOOL)flag;
- (BOOL)isSelected;

@end