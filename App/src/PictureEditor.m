//
//  PictureEditor.m
//  MetaZ
//
//  Created by Brian Olsen on 20/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "PictureEditor.h"


@implementation PictureEditor

+ (void)initialize
{
    [self exposeBinding:@"picture"];
}

+ (NSSet *)keyPathsForValuesAffectingChanged
{
    return [NSSet setWithObjects:@"picture", nil];
}

+ (NSSet *)keyPathsForValuesAffectingChangedEditable
{
    return [NSSet setWithObjects:@"picture", @"dataChanged", @"data", nil];
}

- (void)dealloc
{
    if([picture isKindOfClass:[MZRemoteData class]])
    {
        MZRemoteData* remote = picture;
        if(!remote.isLoaded)
            [remote removeObserver:self forKeyPath:@"isLoaded"];
    }
    [observerFix removeObserver:self forKeyPath:@"selection.pictureChanged"];
    [picture release];
    [indicator release];
    [retryButton release];
    [observerFix release];
    [super dealloc];
}


- (void)awakeFromNib
{
    observerFix = [[MZPriorObserverFix alloc] initWithOther:filesController];
    [retryButton setHidden:YES];
    /*
    NSArray* keys = [NSArray arrayWithObjects:
        NSMultipleValuesPlaceholderBindingOption,
        NSNoSelectionPlaceholderBindingOption,
        NSNotApplicablePlaceholderBindingOption,
        NSAllowsEditingMultipleValuesSelectionBindingOption,
        NSAllowsNullArgumentBindingOption,
        NSRaisesForNotApplicableKeysBindingOption,
        nil];
    NSArray* values = [NSArray arrayWithObjects:
        NSMultipleValuesMarker,
        NSNoSelectionMarker,
        NSNotApplicableMarker,
        [NSNumber numberWithBool:YES],
        [NSNumber numberWithBool:YES],
        [NSNumber numberWithBool:NO],
        nil];
    NSDictionary* dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [self bind:@"picture" toObject:filesController withKeyPath:@"selection.picture" options:dict];
    */
    [filesController addObserver:self forKeyPath:@"selection.picture" options:0 context:NULL];
    [observerFix addObserver:self forKeyPath:@"selection.pictureChanged" options:NSKeyValueObservingOptionPrior context:NULL];
}

@synthesize filesController;
@synthesize indicator;
@synthesize retryButton;
@synthesize posterView;
@dynamic picture;


- (NSData *)data
{
    if([picture isKindOfClass:[MZRemoteData class]])
    {
        MZRemoteData* remote = picture;
        if(!remote.isLoaded)
            return nil;
        return remote.data;
    }
    return picture;
}

- (void)setData:(NSData *)newData
{
    //[self willChangeValueForKey:@"picture"];
    self.picture = newData;
    //[self didChangeValueForKey:@"picture"];
    [filesController setValue:newData forKeyPath:@"selection.picture"];
}

- (void)updateRemoteData
{
    MZRemoteData* remote = self.picture;
    if(remote.isLoaded)
    {
        [indicator stopAnimation:self];
        [indicator setHidden:YES];
        if(remote.error != nil)
        {
            [retryButton setHidden:NO];
            [posterView reportError:remote.error];
        }
        else {
            [posterView setStatus:MZOKPosterImage];
        }
    }
    else
    {
        [retryButton setHidden:YES];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == picture && [keyPath isEqual:@"isLoaded"])
    {
        [self willChangeValueForKey:@"data"];
        [self updateRemoteData];
        [self didChangeValueForKey:@"data"];
    } else if(object == filesController && [keyPath isEqual:@"selection.picture"])
    {
        id status = [filesController protectedValueForKeyPath:@"selection.picture"];
        self.picture = status;
        if([status isKindOfClass:[MZRemoteData class]])
            return;
        if(status == NSMultipleValuesMarker)
            [posterView setStatus:MZMultiplePosterImage];
        else if(status == NSNotApplicableMarker)
            [posterView setStatus:MZNotApplicablePosterImage];
        else if(status == NSNoSelectionMarker || !status || status==[NSNull null])
            [posterView setStatus:MZEmptyPosterImage];
        else
            [posterView setStatus:MZOKPosterImage];
    } else if(object == observerFix && [keyPath isEqual:@"selection.pictureChanged"])
    {
        NSNumber* prior = [change objectForKey:NSKeyValueChangeNotificationIsPriorKey];
        if([prior boolValue])
            [self willChangeValueForKey:@"dataChanged"];
        else 
            [self didChangeValueForKey:@"dataChanged"];
    }
}

- (BOOL)dataChangedEditable
{
    if([picture isKindOfClass:[MZRemoteData class]])
    {
        MZRemoteData* remote = picture;
        return remote.isLoaded && remote.error == nil;
    }
    id changed = [observerFix valueForKeyPath:@"selection.pictureChanged"];
    return changed != NSMultipleValuesMarker &&
        changed != NSNotApplicableMarker && 
        changed != NSNoSelectionMarker;
}

- (void)setDataChanged:(NSNumber*)newValue
{
    if([picture isKindOfClass:[MZRemoteData class]])
    {
        MZRemoteData* remote = picture;
        if(!remote.isLoaded)
            return;
        [filesController setValue:remote.data forKeyPath:@"selection.picture"];
        return;
    }
    [filesController setValue:newValue forKeyPath:@"selection.pictureChanged"];
}

- (NSNumber*)dataChanged
{
    id changed = [observerFix valueForKeyPath:@"selection.pictureChanged"];
    /*
    if(changed == NSMultipleValuesMarker)
        MZLoggerDebug(@"Multiple");
    */
    return changed;
}

- (id)picture
{
    return picture;
}

- (void)setPicture:(id)newPicture
{
    [self willChangeValueForKey:@"data"];
    if([picture isKindOfClass:[MZRemoteData class]])
    {
        MZRemoteData* remote = picture;
        if(!remote.isLoaded)
        {
            [indicator stopAnimation:self];
            [indicator setHidden:YES];
            [remote removeObserver:self forKeyPath:@"isLoaded"];
        }
        [retryButton setHidden:YES];
    }
    [picture release];
    picture = [newPicture retain];
    if([picture isKindOfClass:[MZRemoteData class]])
    {
        MZRemoteData* remote = picture;
        if(!remote.isLoaded)
        {
            [remote addObserver:self forKeyPath:@"isLoaded" options:0 context:NULL];
            [indicator setHidden:NO];
            [indicator startAnimation:self];
        }
        [self updateRemoteData];
    } else
    {
        if(newPicture == NSMultipleValuesMarker)
            [posterView setStatus:MZMultiplePosterImage];
        else if(newPicture == NSNotApplicableMarker)
            [posterView setStatus:MZNotApplicablePosterImage];
        else if(newPicture == NSNoSelectionMarker)
            [posterView setStatus:MZEmptyPosterImage];
        else
            [posterView setStatus:MZOKPosterImage];
        /*
        if(!newPicture)
        {
            id status = [filesController protectedValueForKeyPath:@"selection.picture"];
            if(status == NSMultipleValuesMarker)
                [posterView setStatus:MZMultiplePosterImage];
            else if(status == NSNotApplicableMarker)
                [posterView setStatus:MZNotApplicablePosterImage];
            else //if(status == NSNoSelectionMarker)
                [posterView setStatus:MZEmptyPosterImage];
        }
        else
            [posterView setStatus:MZOKPosterImage];
        */
    }

    [self didChangeValueForKey:@"data"];
}

- (IBAction)retryLoad:(id)sender
{
    if([picture isKindOfClass:[MZRemoteData class]])
    {
        MZRemoteData* remote = picture;
        if(remote.isLoaded && remote.error != nil)
        {
            [indicator setHidden:NO];
            [indicator startAnimation:self];
            [remote addObserver:self forKeyPath:@"isLoaded" options:0 context:NULL];
            [remote loadData];
        }
    }
}

@end
