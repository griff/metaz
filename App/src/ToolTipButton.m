//
//  ToolTipButton
//  MetaZ
//
//  Created by Brian Olsen on 16/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "ToolTipButton.h"


@implementation ToolTipButton
@synthesize label;
@synthesize tip;

-(void)dealloc
{
    [label release];
    [tip release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [[self cell] setHighlightsBy:NSContentsCellMask];
}

- (void)setToolTip:(NSString *)string
{
    tip = [string retain];
}

- (void)viewDidMoveToWindow
{
    [self addTrackingRect:[self bounds] owner:self userData:nil assumeInside:NO];
} 

- (void)mouseEntered:(NSEvent *)theEvent
{
    [label showToolTip:tip];
    orgImage = [[self image] retain];
    if([orgImage name])
    {
        NSImage* hoverImg = [NSImage imageNamed:[[orgImage name] stringByAppendingString:@"Hover"]];
        if(hoverImg)
            [self setImage:hoverImg];
    }
    [[self cell] setHighlightsBy:NSContentsCellMask];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [label clearToolTip];
    [self setImage:orgImage];
    [orgImage release];
    [[self cell] setHighlightsBy:NSContentsCellMask];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if(self)
    {
        if([decoder allowsKeyedCoding])
        {
            label = [[decoder decodeObjectForKey:@"label"] retain];
            tip = [[decoder decodeObjectForKey:@"tip"] retain];
        }
        else
        {
            label = [[decoder decodeObject] retain];
            tip = [[decoder decodeObject] retain];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    if([encoder allowsKeyedCoding])
    {
        [encoder encodeObject:label forKey:@"label"];
        [encoder encodeObject:tip forKey:@"tip"];
    }
    else
    {
        [encoder encodeObject:label];
        [encoder encodeObject:tip];
    }
}

@end
