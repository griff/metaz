//
//  FileViewBox.m
//  MetaZ
//
//  Created by Brian Olsen on 14/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "FileViewBox.h"
#import "BtnStuff.h"

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
        if(disclosure)
        {
            NSLog(@"self %@", self);
            NSLog(@"TabView %@", tabView);
            NSLog(@"Label %@", label);
            NSLog(@"Button %@\n\n", disclosure);
        }
        if(disclosure)
        {
            [disclosure setTarget:self];
            [disclosure setAction:@selector(switchTab:)];
            /*
            BtnStuff * prox = [[BtnStuff alloc] initWithProxy:self];
            [self release];
            return prox;
            */
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    NSLog(@"Prototype %@", self);
    NSLog(@"TabView %@", tabView);
    NSLog(@"Label %@", label);
    NSLog(@"Button %@\n\n", disclosure);
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
    {
        NSCollectionView * parent = (NSCollectionView*)[self superview];
        NSCollectionViewItem * proto = [parent itemPrototype];
        NSMethodSignature * sig = [proto methodSignatureForSelector:@selector(_applyTargetConfigurationWithoutAnimation:)];
        NSLog(@"resize %d %s%s%s%s", [sig numberOfArguments], [sig methodReturnType], [sig getArgumentTypeAtIndex:0], [sig getArgumentTypeAtIndex:1], [sig getArgumentTypeAtIndex:2]);
        newSize.height = 43;
    }
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

- (IBAction)switchTab:(id)sender
{
    NSTabViewItem * item = [tabView selectedTabViewItem];
    NSString* value = [label stringValue];
    if([[item identifier] isEqual:@"pending"])
        [tabView selectTabViewItemWithIdentifier:@"action"];
    else
        [tabView selectTabViewItemWithIdentifier:@"pending"];
}

@end
