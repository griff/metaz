//
//  ChapterItemWrapper
//  MetaZ
//
//  Created by Brian Olsen on 11/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "ChapterItemWrapper.h"

@implementation ChapterItemWrapper
@synthesize no;
@synthesize item;

+ (id)wrapperWithEditor:(ChapterEditor *)editor
{
    return [[[self alloc] initWithEditor:editor] autorelease];
}

+ (id)wrapperWithEditor:(ChapterEditor *)editor no:(NSInteger)no text:(NSString *)text item:(MZTimedTextItem *)item
{
    return [[[self alloc] initWithEditor:editor no:no text:text item:item] autorelease];
}

- (id)initWithEditor:(ChapterEditor *)theEditor no:(NSInteger)aNo text:(NSString *)theText item:(MZTimedTextItem *)theItem
{
    self = [super init];
    if(self)
    {
        editor = [theEditor retain];
        if(aNo >= 0)
            no = [[NSNumber alloc] initWithInteger:aNo];

        text = [theText retain];
        item = [theItem mutableCopy];
    }
    return self;
}

- (id)initWithEditor:(ChapterEditor *)theEditor
{
    self = [super init];
    if(self)
    {
        editor = [theEditor retain];
    }
    return self;
}

- (void)dealloc
{
    [editor release];
    [item release];
    [super dealloc];
}

- (NSColor*)itemColor
{
    if(no)
        return [NSColor controlTextColor];
    return [NSColor disabledControlTextColor];
}

- (void)updateText:(NSString *)newText
{
    [self willChangeValueForKey:@"text"];
    text = [newText copy];
    [self didChangeValueForKey:@"text"];
}

- (void)setItem:(MZTimedTextItem *)theItem
{
    MZTimeCode* oldDuration = [item duration];
    if(![oldDuration isEqual:[theItem duration]])
        [self willChangeValueForKey:@"duration"];
    item = [theItem mutableCopy];
    if(![oldDuration isEqual:[theItem duration]])
        [self didChangeValueForKey:@"duration"];
}

- (MZTimeCode *)duration
{
    return [item duration];
}

- (NSString *)text
{
    return text;
}

- (void)setText:(NSString *)newText
{
    text = [newText copy];
    [item setText:text];
    [editor itemChanged:self];
}

- (NSInteger)num
{
    if(!no)
        return -1;
    return [no integerValue];
}

- (void)setNum:(NSInteger)newValue
{
    [self willChangeValueForKey:@"no"];
    [no release];
    if(newValue<=0)
        no = nil;
    else
        no = [[NSNumber alloc] initWithInteger:newValue];
    [self didChangeValueForKey:@"no"];
}

@end
