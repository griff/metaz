//
//  RatingMenu.m
//  MetaZ
//
//  Created by Brian Olsen on 07/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "RatingMenuHandler.h"


@implementation RatingMenuHandler
@synthesize ratingButton;
@synthesize menuUK;
@synthesize menuDE;
@synthesize menuIE;
@synthesize menuCA;
@synthesize menuAU;
@synthesize menuNZ;

- (void)dealloc
{
    [ratingButton release];
    [menuUK release];
    [menuDE release];
    [menuIE release];
    [menuCA release];
    [menuAU release];
    [menuNZ release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [self makeMenu];
    NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
    [d addObserver:self forKeyPath:@"ratingUK" options:0 context:NULL];
    [d addObserver:self forKeyPath:@"ratingDE" options:0 context:NULL];
    [d addObserver:self forKeyPath:@"ratingIE" options:0 context:NULL];
    [d addObserver:self forKeyPath:@"ratingCA" options:0 context:NULL];
    [d addObserver:self forKeyPath:@"ratingAU" options:0 context:NULL];
    [d addObserver:self forKeyPath:@"ratingNZ" options:0 context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self makeMenu];
}

- (void)makeMenu
{
    NSMenu* menu = [ratingButton menu];
    for(NSInteger i=[menu numberOfItems]-1; i>14;i--)
        [menu removeItemAtIndex:i];
    
    NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
    if([d boolForKey:@"ratingUK"])
    {
        [menu addItem:[NSMenuItem separatorItem]];
        for(NSMenuItem* item in [menuUK itemArray])
            [menu addItem:[item copy]];
    }
    if([d boolForKey:@"ratingDE"])
    {
        [menu addItem:[NSMenuItem separatorItem]];
        for(NSMenuItem* item in [menuDE itemArray])
            [menu addItem:[item copy]];
    }
    if([d boolForKey:@"ratingIE"])
    {
        [menu addItem:[NSMenuItem separatorItem]];
        for(NSMenuItem* item in [menuIE itemArray])
            [menu addItem:[item copy]];
    }
    if([d boolForKey:@"ratingCA"])
    {
        [menu addItem:[NSMenuItem separatorItem]];
        for(NSMenuItem* item in [menuCA itemArray])
            [menu addItem:[item copy]];
    }
    if([d boolForKey:@"ratingAU"])
    {
        [menu addItem:[NSMenuItem separatorItem]];
        for(NSMenuItem* item in [menuAU itemArray])
            [menu addItem:[item copy]];
    }
    if([d boolForKey:@"ratingNZ"])
    {
        [menu addItem:[NSMenuItem separatorItem]];
        for(NSMenuItem* item in [menuNZ itemArray])
            [menu addItem:[item copy]];
    }
}

@end
