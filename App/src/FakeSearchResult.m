//
//  FakeSearchResult.m
//  MetaZ
//
//  Created by Brian Olsen on 16/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "FakeSearchResult.h"
#import "Resources.h"

@implementation FakeSearchResult

+ (id)resultWithController:(NSArrayController *)controller
{
    return [[[self alloc] initWithController:controller] autorelease];
}

- (id)initWithController:(NSArrayController *)controller
{
    self = [super init];
    if(self)
    {
        filesController = [controller retain];
        [filesController addObserver:self forKeyPath:@"selection.pure.title" options:0 context:NULL];
        [filesController addObserver:self forKeyPath:@"selection.pure.chapters" options:0 context:NULL];

        [self updateTitle];
        [self updateChapters];
    }
    return self;
}

- (void)dealloc
{
    [filesController removeObserver:self forKeyPath:@"selection.pure.title"];
    [filesController removeObserver:self forKeyPath:@"selection.pure.chapters"];
    [filesController release];
    [super dealloc];
}

@synthesize searchResultTitle;
@synthesize hasChapters;

- (NSImage *)icon
{
    return [NSImage imageNamed:MZSmallIcon];
}

- (NSMenu*)menu
{
    return nil;
}

- (void)updateTitle
{
    id newValue = [filesController protectedValueForKeyPath:@"selection.pure.title"];

    NSString* newTitle;
    if( newValue == nil || newValue == [NSNull null] )
        newTitle = NSLocalizedString(@"Empty title", @"Value for search result");
    else if( newValue == NSNotApplicableMarker )
        newTitle = NSLocalizedString(@"Title not applicable", @"Value for search result");
    else if( newValue == NSMultipleValuesMarker )
        newTitle = NSLocalizedString(@"Editing multiple", @"Value for search result");
    else if( newValue == NSNoSelectionMarker )
        newTitle = NSLocalizedString(@"No Selection", @"Value for search result");
    else
        newTitle = newValue;
    if( ![newTitle isEqual:searchResultTitle] )
    {
        [self willChangeValueForKey:@"searchResultTitle"];
        searchResultTitle = newTitle;
        [self didChangeValueForKey:@"searchResultTitle"];
    }
}

- (void)updateChapters
{
    id newValue = [filesController protectedValueForKeyPath:@"selection.pure.chapters"];
    BOOL newChapters = newValue != nil && newValue != [NSNull null] &&
        newValue != NSNoSelectionMarker && newValue != NSNotApplicableMarker;
    if(newChapters != hasChapters)
    {
        [self willChangeValueForKey:@"hasChapters"];
        hasChapters = newChapters;
        [self didChangeValueForKey:@"hasChapters"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqual:@"selection.pure.title"])
    {
        [self updateTitle];
    }
    if([keyPath isEqual:@"selection.pure.chapters"])
    {
        [self updateChapters];
    }
    
}

@end
