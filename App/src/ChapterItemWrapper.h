//
//  ChapterItemWrapper.h
//  MetaZ
//
//  Created by Brian Olsen on 11/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ChapterEditor.h"

@interface ChapterItemWrapper : NSObject {
    ChapterEditor* editor;
    MZMutableTimedTextItem* item;
    NSNumber* no;
    NSString* text;
}
@property (retain)   NSNumber* no;
@property (readonly) MZMutableTimedTextItem* item;
@property (assign)   NSInteger num;
@property (readonly) MZTimeCode* duration;
@property (readonly) MZTimeCode* start;
@property (copy,nonatomic)     NSString* text;
@property (readonly) NSColor* itemColor;

+ (id)wrapperWithEditor:(ChapterEditor *)editor;
+ (id)wrapperWithEditor:(ChapterEditor *)editor no:(NSInteger)no text:(NSString *)text item:(MZTimedTextItem *)item;
- (id)initWithEditor:(ChapterEditor *)editor no:(NSInteger)no text:(NSString *)text item:(MZTimedTextItem *)item;
- (id)initWithEditor:(ChapterEditor *)editor;

//- (NSColor*)itemColor;
- (void)setItem:(MZTimedTextItem *)item;
- (void)updateText:(NSString *)text;
//- (NSString *)text;
//- (void)setText:(NSString *)text;

@end
