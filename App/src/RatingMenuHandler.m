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
@synthesize filesController;

- (void)dealloc
{
    NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
    [d removeObserver:self forKeyPath:@"ratingUK"];
    [d removeObserver:self forKeyPath:@"ratingDE"];
    [d removeObserver:self forKeyPath:@"ratingIE"];
    [d removeObserver:self forKeyPath:@"ratingCA"];
    [d removeObserver:self forKeyPath:@"ratingAU"];
    [d removeObserver:self forKeyPath:@"ratingNZ"];
    [observerFix removeObserver:self forKeyPath:@"selection.rating"];
    [ratingButton release];
    [menuUK release];
    [menuDE release];
    [menuIE release];
    [menuCA release];
    [menuAU release];
    [menuNZ release];
    [filesController release];
    [observerFix release];
    [super dealloc];
}

- (void)awakeFromNib
{
    [self makeMenu];
    observerFix = [[MZPriorObserverFix alloc] initWithOther:filesController];
    NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
    [d addObserver:self forKeyPath:@"ratingUK" options:0 context:NULL];
    [d addObserver:self forKeyPath:@"ratingDE" options:0 context:NULL];
    [d addObserver:self forKeyPath:@"ratingIE" options:0 context:NULL];
    [d addObserver:self forKeyPath:@"ratingCA" options:0 context:NULL];
    [d addObserver:self forKeyPath:@"ratingAU" options:0 context:NULL];
    [d addObserver:self forKeyPath:@"ratingNZ" options:0 context:NULL];
    [observerFix addObserver:self
                      forKeyPath:@"selection.rating"
                         options:NSKeyValueObservingOptionPrior
                         context:NULL];
}

NSString* findItem(NSMenu* menu, MZRating rating)
{
    NSMenuItem* item = [menu itemWithTag:rating];
    if(!item)
        return nil;
    return [item title];
}

- (NSString *)ratingName
{
    id value = [filesController protectedValueForKeyPath:@"selection.rating"];
    if(value == NSMultipleValuesMarker || value == NSNoSelectionMarker || value == NSNotApplicableMarker)
        return (NSString*)value;

    MZTag* tag = [MZTag tagForIdentifier:MZRatingTagIdent];
    MZRating rating;
    [tag convertObject:value toValue:&rating];
    NSString* ret;
    NSLog(@"Getting rating %d", rating);
    if(ret = findItem([ratingButton menu], rating)) return ret;
    if(ret = findItem(menuUK, rating)) return ret;
    if(ret = findItem(menuDE, rating)) return ret;
    if(ret = findItem(menuIE, rating)) return ret;
    if(ret = findItem(menuCA, rating)) return ret;
    if(ret = findItem(menuAU, rating)) return ret;
    if(ret = findItem(menuNZ, rating)) return ret;
    return nil;
}

MZRating findRating(MZRating found, NSMenu* menu, NSString* title)
{
    if(found!=NSNotFound)
        return found;
    NSMenuItem* item = [menu itemWithTitle:title];
    if(!item || [item tag] < 0)
        return NSNotFound;
    return [item tag];
}

- (void)setRatingName:(NSString *)newRating
{
    id value = [filesController protectedValueForKeyPath:@"selection.rating"];
    if(value == NSNoSelectionMarker || value == NSNotApplicableMarker)
        return;

    MZRating rating = findRating(NSNotFound, [ratingButton menu], newRating);
    rating = findRating(rating, menuUK, newRating);
    rating = findRating(rating, menuDE, newRating);
    rating = findRating(rating, menuIE, newRating);
    rating = findRating(rating, menuCA, newRating);
    rating = findRating(rating, menuAU, newRating);
    rating = findRating(rating, menuNZ, newRating);
    if(rating == NSNotFound)
        rating = MZNoRating;
        
    MZTag* tag = [MZTag tagForIdentifier:MZRatingTagIdent];
    id obj = [tag convertValueToObject:&rating];
    [filesController setValue:obj forKeyPath:@"selection.rating"];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == [NSUserDefaults standardUserDefaults])
    {
        [self makeMenu];
    }
    if(object == filesController || object == observerFix)
    {
        NSNumber * prior = [change objectForKey:NSKeyValueChangeNotificationIsPriorKey];
        if([prior boolValue])
            [self willChangeValueForKey:@"ratingName"];
        else
            [self didChangeValueForKey:@"ratingName"];
    }
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
