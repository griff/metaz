//
//  ChapterEditor.m
//  MetaZ
//
//  Created by Brian Olsen on 11/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "ChapterEditor.h"
#import "ChapterItemWrapper.h"

@interface ChapterEditor (Private)

- (void)makeEditorChapters;

@end


@implementation ChapterEditor
@synthesize slider;
@synthesize filesController;
@synthesize editorChapters;
@synthesize slideMin;
@synthesize slideMax;

+ (void)initialize
{
    if(self != [ChapterEditor class])
        return;
    [self exposeBinding:@"chapters"];
    [self exposeBinding:@"chapterNames"];
}

+ (NSSet *)keyPathsForValuesAffectingHideSlider
{
    return [NSSet setWithObjects:@"slideMin", @"slideMax", nil];
}


- (void)awakeFromNib
{
    NSDictionary* dict = [NSDictionary 
        dictionaryWithObject:[NSNumber numberWithBool:YES]
        forKey:NSContinuouslyUpdatesValueBindingOption];
    [self bind:@"chapters" toObject:filesController withKeyPath:@"selection.chapters" options:dict];
    [self bind:@"chapterNames" toObject:filesController withKeyPath:@"selection.chapterNames" options:dict];
    [filesController addObserver:self forKeyPath:@"selection.chaptersChanged" options:0 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual:@"selection.chaptersChanged"] && object == filesController)
    {
        useCachedChanged = YES;
        [self willChangeValueForKey:@"changed"];
        useCachedChanged = NO;
        [self didChangeValueForKey:@"changed"];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }

}

- (NSArray *)chapters
{
    return chapters;
}

- (void)setChapters:(NSArray *)newChapters
{
    chapters = [newChapters retain];
    [self makeEditorChapters];
}

- (BOOL)chaptersChanged
{
    id changed = [filesController valueForKeyPath:@"selection.chaptersChanged"];
    return [changed isKindOfClass:[NSNumber class]] &&
        [changed boolValue];
}

- (NSNumber *)changed
{
    if(useCachedChanged)
        return cachedChanged;
    return cachedChanged = [filesController valueForKeyPath:@"selection.chaptersChanged"];
}

- (void)setChanged:(NSNumber *)value
{
    BOOL change = [value boolValue];
    if(change)
        [self itemChanged:nil];
    else
        [filesController setValue:[NSNumber numberWithBool:NO] forKeyPath:@"selection.chaptersChanged"];
}

- (NSArray *)chapterNames
{
    return chapterNames;
}

- (void)setChapterNames:(NSArray *)newChapterNames
{
    chapterNames = [newChapterNames retain];
    if(!self.chaptersChanged)
        [self makeEditorChapters];
}

- (void)itemChanged:(ChapterItemWrapper*)item
{
    if(self.chaptersChanged)
        return;
    NSMutableArray* nextEdits = [NSMutableArray array];
    for(ChapterItemWrapper* wrap in editorChapters)
    {
        MZMutableTimedTextItem* item = [wrap item];
        if(item)
        {
            [item setText:[wrap text]];
            [nextEdits addObject:item];
        }
    }
    [filesController setValue:nextEdits forKeyPath:@"selection.chapters"];
}

- (NSInteger)slide
{
    return slide;
}

- (void)setSlide:(NSInteger)newSlide
{
    BOOL makeEdits = slide!=newSlide;
    slide = newSlide;
    if(makeEdits)
        [self makeEditorChapters];
}

- (BOOL)hideSlider
{
    return slideMin == slideMax;
}


- (void)makeEditorChapters
{
    if(!chapters)
    {
        [self willChangeValueForKey:@"editorChapters"];
        [editorChapters release];
        editorChapters = nil;
        [self didChangeValueForKey:@"editorChapters"];
        return;
    }
    NSUInteger chapterLen = [chapters count];
    NSUInteger chapterNamesLen = [chapterNames count];
    NSUInteger editsLen = [editorChapters count];
    NSMutableArray* nextEdits = [NSMutableArray array];
    NSInteger newSlide = -slide;
    NSInteger newSlideMin = slideMin;
    if(self.chaptersChanged)
    {
        newSlideMin = 0;
        BOOL changed = NO;
        for(int i=0; i<chapterLen; i++)
        {
            MZTimedTextItem* item = [chapters objectAtIndex:i];
            ChapterItemWrapper* wrapper = nil;
            NSString* name = [item text];
            if(i < editsLen)
            {
                wrapper = [editorChapters objectAtIndex:i];
                wrapper.num = i+1;
                if(![[wrapper text] isEqualToString:name])
                {
                    [wrapper updateText:name];
                    changed = YES;
                }
                if([wrapper item] != item)
                {
                    [wrapper setItem:item];
                    changed = YES;
                }
            }
            else
                changed = YES;

            if(!wrapper)
                wrapper = [ChapterItemWrapper wrapperWithEditor:self no:i+1 text:[item text] item:item];
            [nextEdits addObject:wrapper];
        }
        if(!changed && editsLen <= chapterLen)
            return;
    }
    else if(chapterLen > chapterNamesLen)
    {
        if(newSlide+chapterNamesLen > chapterLen)
            newSlide = chapterLen-chapterNamesLen;
        if(chapterNamesLen > 0)
            newSlideMin = chapterNamesLen-chapterLen;
        else
            newSlideMin = 0;

        NSRange namesRange = NSMakeRange(newSlide, chapterNamesLen);
        for(int i=0; i<chapterLen; i++)
        {
            MZTimedTextItem* item = [chapters objectAtIndex:i];
            NSString* name;
            if( NSLocationInRange(i, namesRange) )
                name = [chapterNames objectAtIndex:i-namesRange.location];
            else
                name = [item text];
            ChapterItemWrapper* wrapper = nil;
            if(i < editsLen)
            {
                wrapper = [editorChapters objectAtIndex:i];
                wrapper.num = i+1;
                if(![[wrapper text] isEqualToString:name])
                    [wrapper updateText:name];
                if([wrapper item] != item)
                    [wrapper setItem:item];
            }
            if(!wrapper)
                wrapper = [ChapterItemWrapper wrapperWithEditor:self no:i+1 text:name item:item];
                
            [nextEdits addObject:wrapper];
        }
    }
    else if(chapterNamesLen > chapterLen)
    {
        if(newSlide+chapterLen > chapterNamesLen)
            newSlide = chapterNamesLen - chapterLen;
        newSlideMin = chapterLen-chapterNamesLen;
        
        NSRange chaptersRange = NSMakeRange(newSlide, chapterLen);
        for(int i=0; i<chapterNamesLen; i++)
        {
            NSString* name = [chapterNames objectAtIndex:i];
            MZTimedTextItem* item = nil;
            NSInteger no = -1;
            if(NSLocationInRange(i, chaptersRange))
            {
                item = [chapters objectAtIndex:i-chaptersRange.location];
                no = i-chaptersRange.location+1;
            }
            ChapterItemWrapper* wrapper = nil;
            if(i < editsLen)
            {
                wrapper = [editorChapters objectAtIndex:i];
                wrapper.num = no;
                if(![[wrapper text] isEqualToString:name])
                    [wrapper updateText:name];
                if([wrapper item] != item)
                    [wrapper setItem:item];
            }
            if(!wrapper)
                wrapper = [ChapterItemWrapper wrapperWithEditor:self no:no text:name item:item];
                
            [nextEdits addObject:wrapper];
        }
    }
    else
    {
        newSlide = 0;
        newSlideMin = 0;
        for(int i=0; i<chapterLen; i++)
        {
            MZTimedTextItem* item = [chapters objectAtIndex:i];
            NSString* name = [chapterNames objectAtIndex:i];

            ChapterItemWrapper* wrapper = nil;
            if(i < editsLen)
            {
                wrapper = [editorChapters objectAtIndex:i];
                wrapper.num = i+1;
                if(![[wrapper text] isEqualToString:name])
                    [wrapper updateText:name];
                if([wrapper item] != item )
                    [wrapper setItem:item];
            }
            if(!wrapper)
                wrapper = [ChapterItemWrapper wrapperWithEditor:self no:i+1 text:name item:item];
            [nextEdits addObject:wrapper];
        }        
    }
    if(slide != -newSlide)
    {
        [self willChangeValueForKey:@"slide"];
        slide = -newSlide;
        [self didChangeValueForKey:@"slide"];
    }
    if(slideMin != newSlideMin)
    {
        [self willChangeValueForKey:@"slideMin"];
        slideMin = newSlideMin;
        [self didChangeValueForKey:@"slideMin"];
        [slider setNumberOfTickMarks:-newSlideMin+1];
        [slider setIntegerValue:slide];
    }
    [self willChangeValueForKey:@"editorChapters"];
    [editorChapters release];
    editorChapters = [nextEdits retain];
    [self didChangeValueForKey:@"editorChapters"];
}

@end
