//
//  MZFileNameTextStorage.m
//  MetaZ
//
//  Created by Brian Olsen on 17/05/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import "MZFileNameTextStorage.h"


@implementation MZFileNameTextStorage

#pragma mark -
#pragma mark NSTextStorage Overrides

// All of these methods are necessary to create a concrete subclass of NSTextStorage

- (id)init
{
	if (self = [super init])
	{
		text = [[NSMutableAttributedString alloc] init];
	}
	return self;
}

- (id)initWithString:(NSString *)aString
{
	if (self = [super init])
	{
		text = [[NSMutableAttributedString alloc] initWithString:aString];
	}
	return self;
}

- (id)initWithString:(NSString *)aString attributes:(NSDictionary *)attributes
{
	if (self = [super init])
	{
		text = [[NSMutableAttributedString alloc] initWithString:aString attributes:attributes];
	}
	return self;
}

- (id)initWithAttributedString:(NSAttributedString *)aString
{
	if (self = [super init])
	{
		text = [aString mutableCopy];
	}
	return self;
}

- (void)dealloc
{
	[text release];
	[super dealloc];
}

- (NSString *)string
{
	return [text string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange
{
	return [text attributesAtIndex:index effectiveRange:aRange];
}

- (void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString
{
	int strlen = [aString length];
	
	[text replaceCharactersInRange:aRange withString:aString];

	int lengthChange = strlen - aRange.length;
	[self edited:NSTextStorageEditedCharacters
		   range:aRange
  changeInLength:lengthChange];
	
}

- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)aRange
{
	[text setAttributes:attributes range:aRange];
	
	[self edited:NSTextStorageEditedAttributes
		   range:aRange
  changeInLength:0];
}

- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)aRange
{
	[text addAttribute:name value:value range:aRange];
	[self edited:NSTextStorageEditedAttributes
		   range:aRange
  changeInLength:0];
}

#pragma mark -
#pragma mark Word boundary methods

- (NSRange)doubleClickAtIndex:(NSUInteger)index
{
    NSRange result = [super doubleClickAtIndex:index];
    NSRange range = NSMakeRange(0,index == 0 ? 0 : index-1);
    NSRange found = [[text string]
        rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet]
                        options:NSBackwardsSearch
                          range:range];
                              
    if(found.location != NSNotFound)
    {
        if(found.location+found.length > result.location)
        {   
            NSUInteger nextIdx = found.location+found.length;
            result.length = result.length-(nextIdx-result.location);
            result.location = nextIdx;
        }
    }

    range = NSMakeRange(index, [[text string] length]-index);
    found = [[text string]
        rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet]
                        options:0
                          range:range];
    if(found.location != NSNotFound)
    {
        if(found.location < result.location+result.length)
        {   
            result.length = found.location - result.location;
        }
    }
    return result;
}

- (NSUInteger)nextWordFromIndex:(NSUInteger)index forward:(BOOL)isForward
{
    NSUInteger next = [super nextWordFromIndex:index forward:isForward];
    if(isForward)
    {
        NSRange range = NSMakeRange(index, [[text string] length]-index);
        NSRange found = [[text string]
            rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet]
                            options:0
                              range:range];
                              
        if(found.location != NSNotFound)
        {
            if(found.location == index)
            {
                range = NSMakeRange(index+found.length, range.length-found.length);
                found = [[text string]
                        rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet]
                                        options:0
                                          range:range];
            }
            if(found.location != NSNotFound && found.location < next)
                return found.location;
        }
    }
    else
    {
        NSRange range = NSMakeRange(0,index-1);
        NSRange found = [[text string]
            rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet]
                            options:NSBackwardsSearch
                              range:range];
                              
        if(found.location != NSNotFound)
        {
            if(found.location+found.length == index-1)
            {
                range = NSMakeRange(0, index-found.length-1);
                found = [[text string]
                        rangeOfCharacterFromSet:[NSCharacterSet punctuationCharacterSet]
                                        options:NSBackwardsSearch
                                          range:range];
            }
            if(found.location != NSNotFound && found.location > next)
                return found.location+found.length;
        }
    }
    return next;
}


@end
