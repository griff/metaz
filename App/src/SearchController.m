//
//  SearchController.m
//  MetaZ
//
//  Created by Brian Olsen on 07/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "SearchController.h"
#import "MZMetaSearcher.h"
#import "FakeSearchResult.h"
#import "SearchMeta.h"

@interface SearchController ()
- (void)updateSearchMenu;
- (void)doSearch:(BOOL)force;
@end


@implementation SearchController
@synthesize arrayController;
@synthesize filesController;
@synthesize searchField;
@synthesize searchIndicator;
@synthesize placeholder;

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if(self)
    {
        activeProfile = [[SearchProfile unknownTypeProfile] retain];
        [activeProfile gtm_addObserver:self
                            forKeyPath:@"searchTerms"
                              selector:@selector(changedSearchTerms:)
                              userInfo:nil
                               options:0];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        activeProfile = [[SearchProfile unknownTypeProfile] retain];
        [activeProfile gtm_addObserver:self
                            forKeyPath:@"searchTerms"
                              selector:@selector(changedSearchTerms:)
                              userInfo:nil
                               options:0];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        activeProfile = [[SearchProfile unknownTypeProfile] retain];
        [activeProfile gtm_addObserver:self
                            forKeyPath:@"searchTerms"
                              selector:@selector(changedSearchTerms:)
                              userInfo:nil
                               options:0];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [filesController gtm_removeObserver:self
                             forKeyPath:@"selection.pure.videoType"
                               selector:@selector(changedVideoType:)];
    [activeProfile gtm_removeObserver:self
                           forKeyPath:@"searchTerms"
                             selector:@selector(changedSearchTerms:)];
    [arrayController release];
    [filesController release];
    [searchField release];
    [searchIndicator release];
    [activeProfile release];
    [super dealloc];
}

-(void)awakeFromNib
{   
    if(!searchField)
    {
        [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(finishedSearch:)
                   name:MZSearchFinishedNotification
                 object:nil];

        [[MZPluginController sharedInstance] setDelegate:self];
    
        [[MZMetaSearcher sharedSearcher] setFakeResult:[FakeSearchResult resultWithController:filesController]];

        [filesController gtm_addObserver:self
                              forKeyPath:@"selection.pure.videoType"
                                selector:@selector(changedVideoType:)
                                userInfo:nil
                                 options:0];
                      
        NSView* view = [self view];
        [placeholder addSubview:view];
        [view setFrame: [placeholder bounds]];
        [view setNeedsDisplay:YES];
    }
    else
        [self updateSearchMenu];
}

- (NSString *)nibName
{
    return @"SearchView";
}

- (IBAction)selectNextResult:(id)sender {
    if(![filesController commitEditing])
        [filesController discardEditing];
    [arrayController selectNext:sender];
}

- (IBAction)selectPreviousResult:(id)sender {
    if(![filesController commitEditing])
        [filesController discardEditing];
    [arrayController selectPrevious:sender];
}

- (IBAction)startSearch:(id)sender;
{
    [self doSearch:YES];
}

- (IBAction)applyResult:(id)sender;
{
    id selection = [arrayController valueForKeyPath:@"selection.self"];
    if(![selection isKindOfClass:[MZSearchResult class]])
        return;
        
    [filesController apply:[selection values]];
}

- (void)doSearch:(BOOL)force
{
    if(![filesController commitEditing])
        [filesController discardEditing];
        
    NSString* term = [[searchField stringValue] 
        stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceCharacterSet]];
    NSMutableDictionary* dict = [activeProfile searchTerms:term];
    
    if(!force && currentSearchTerms && [dict isEqualToDictionary:currentSearchTerms])
        return;
        
    [currentSearchTerms release];
    currentSearchTerms = [dict retain];
    
    [searchIndicator startAnimation:searchField];
    [arrayController setSortDescriptors:nil];
    searches++;
    MZLoggerInfo(@"Starting search %d", searches);
    [[MZMetaSearcher sharedSearcher] startSearchWithData:dict];
}

- (void)updateSearchMenu
{
    SearchProfile* profile;
    
    id videoType = [filesController protectedValueForKeyPath:@"selection.pure.videoType"];
    MZVideoType vt;
    MZTag* tag = [MZTag tagForIdentifier:MZVideoTypeTagIdent];
    [tag convertObject:videoType toValue:&vt];
    switch (vt) {
        case MZMovieVideoType:
            if([[activeProfile identifier] isEqual:@"movie"])
                profile = [[activeProfile retain] autorelease];
            else
                profile = [SearchProfile movieProfile];
            break;
        case MZTVShowVideoType:
            if([[activeProfile identifier] isEqual:@"tvShow"])
                profile = [[activeProfile retain] autorelease];
            else
                profile = [SearchProfile tvShowProfile];
            break;
        default:
            if([[activeProfile identifier] isEqual:@"unknown"])
                profile = [[activeProfile retain] autorelease];
            else
                profile = [SearchProfile unknownTypeProfile];
            break;
    }
    [activeProfile gtm_removeObserver:self
                           forKeyPath:@"searchTerms"
                             selector:@selector(changedSearchTerms:)];
    [activeProfile release];
    activeProfile = [profile retain];
    [activeProfile setCheckObject:filesController withPrefix:@"selection.pure."];
    [activeProfile gtm_addObserver:self
                        forKeyPath:@"searchTerms"
                          selector:@selector(changedSearchTerms:)
                          userInfo:nil
                           options:0];

    NSMenu* menu = [[NSMenu alloc] initWithTitle:
        NSLocalizedString(@"Search terms", @"Search menu title")];
    [menu addItemWithTitle:[menu title] action:nil keyEquivalent:@""];
    NSInteger i = 0;
    for(NSString* tagId in [profile tags])
    {
        if(![tagId isEqual:MZVideoTypeTagIdent])
        {
            MZTag* tag = [MZTag tagForIdentifier:tagId];
            NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:[tag localizedName]
                action:@selector(switchItem:) keyEquivalent:@""];
            [item setTarget:profile];
            [item setTag:i];
            [item setState:NSOnState];
            [item setIndentationLevel:1];
            [menu addItem:item];
            [item release];
        }
        i++;
    }
    id searchCell = [searchField cell];
    [searchCell setSearchMenuTemplate:menu];
    [menu release];
        
    NSString* prefix = @"selection.pure.";
    id mainValue = @"";
    if([profile mainTag])
    {
        mainValue = [filesController protectedValueForKeyPath:
            [prefix stringByAppendingString:[profile mainTag]]];
    
        if(mainValue == nil || mainValue == [NSNull null] || mainValue == NSMultipleValuesMarker ||
            mainValue == NSNoSelectionMarker || mainValue == NSNotApplicableMarker)
        {
            mainValue = @"";
        }
    }
    [searchField setStringValue:mainValue];

    if([[NSUserDefaults standardUserDefaults] boolForKey:@"autoSearch"])
    {
        [self doSearch:NO];
    }
}

- (void)changedSearchTerms:(GTMKeyValueChangeNotification *)notification
{
    if([notification object] == activeProfile)
        [self startSearch:self];
}

- (void)changedVideoType:(GTMKeyValueChangeNotification *)notification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(updateSearchMenu) object:nil];
    [self performSelector:@selector(updateSearchMenu) withObject:nil afterDelay:0.001];
}

- (void)finishedSearch:(NSNotification *)note
{
    searches--;
    MZLoggerDebug(@"Finished search %d", searches);
    if(searches <= 0)
        [searchIndicator stopAnimation:self];
}

#pragma mark - user interface validation

- (BOOL)validateUserInterfaceItem:(id < NSValidatedUserInterfaceItem >)anItem
{
    SEL action = [anItem action];
    if(action == @selector(applyResult:))
    {
        id selection = [arrayController protectedValueForKeyPath:@"selection.self"];
        if(![selection isKindOfClass:[MZSearchResult class]])
            return NO;
        
        if(![filesController canApply:[selection values]])
            return NO;
        return [[[self view] window] isKeyWindow];
    }
    if(action == @selector(startSearch:))
        return [filesController selectionIndex] != NSNotFound;
    if(action == @selector(selectNextResult:))
        return [arrayController canSelectNext];
    if(action == @selector(selectPreviousResult:))
        return [arrayController canSelectPrevious];
    return YES;
}

#pragma mark - as MZPluginControllerDelegate

- (id<MetaData>)pluginController:(MZPluginController *)controller
        extraMetaDataForProvider:(MZDataProviderPlugin *)provider
                          loaded:(MetaLoaded*)loaded
{
    return [[[SearchMeta alloc] initWithProvider:loaded controller:arrayController] autorelease];
}

@end
