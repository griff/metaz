//
//  PictureEditor.m
//  MetaZ
//
//  Created by Brian Olsen on 20/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "PictureEditor.h"

@interface PictureEditor()
@property(readonly) MZPriorObserverFix* observerFix;
@end

@implementation PictureEditor

+ (void)initialize
{
    if(self == [PictureEditor class])
        [self exposeBinding:@"picture"];
}

+ (NSSet *)keyPathsForValuesAffectingDataChanged
{
    return [NSSet setWithObjects:@"picture", @"data", nil];
}

+ (NSSet *)keyPathsForValuesAffectingDataChangedEditable
{
    return [NSSet setWithObjects:@"picture", @"dataChanged", @"data", nil];
}

- (void)dealloc
{
    if([picture isKindOfClass:[MZRemoteData class]])
    {
        MZRemoteData* remote = picture;
        if(!remote.isLoaded)
            [remote gtm_removeObserver:self forKeyPath:@"isLoaded" selector:@selector(pictureIsLoaded:)];
    }
    [observerFix removeObserver:self forKeyPath:@"selection.pictureChanged"];
    [picture release];
    [indicator release];
    [retryButton release];
    [observerFix release];
    [super dealloc];
}

- (MZPriorObserverFix* )observerFix
{
    if(!observerFix && filesController)
    {
        observerFix = [[MZPriorObserverFix alloc] initWithOther:filesController];
        [observerFix addObserver:self forKeyPath:@"selection.pictureChanged" options:NSKeyValueObservingOptionPrior context:NULL];
    }
    return observerFix;
}

- (void)awakeFromNib
{
    [retryButton setHidden:YES];
    [picturesController gtm_addObserver:self forKeyPath:@"selection" selector:@selector(picturesUpdated:) userInfo:nil options:0];
}

@synthesize filesController;
@synthesize picturesController;
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

- (void)picturesUpdated:(GTMKeyValueChangeNotification *)notification
{
    id status = [picturesController protectedValueForKeyPath:@"selection.self"];
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
}

- (void)pictureIsLoaded:(GTMKeyValueChangeNotification *)notification
{
    if([[notification object] isLoaded])
        [[notification object] gtm_removeObserver:self forKeyPath:@"isLoaded" selector:@selector(pictureIsLoaded:)];
    [self willChangeValueForKey:@"data"];
    [self updateRemoteData];
    [self didChangeValueForKey:@"data"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == self.observerFix && [keyPath isEqual:@"selection.pictureChanged"])
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
    id changed = [self.observerFix valueForKeyPath:@"selection.pictureChanged"];
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
    if([picture isKindOfClass:[MZRemoteData class]])
    {
        MZRemoteData* remote = picture;
        if(!remote.isLoaded || remote.error != nil)
            return NSNotApplicableMarker;
    }
    id changed = [self.observerFix valueForKeyPath:@"selection.pictureChanged"];
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
            [remote gtm_removeObserver:self forKeyPath:@"isLoaded" selector:@selector(pictureIsLoaded:)];
        }
        [retryButton setHidden:YES];
    }
    id oldPicture = picture;
    picture = [newPicture retain];
    [oldPicture release];
    if([picture isKindOfClass:[MZRemoteData class]])
    {
        MZRemoteData* remote = picture;
        if(!remote.isLoaded)
        {
            [remote gtm_addObserver:self forKeyPath:@"isLoaded" selector:@selector(pictureIsLoaded:) userInfo:nil options:0];
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
            [remote gtm_addObserver:self forKeyPath:@"isLoaded" selector:@selector(pictureIsLoaded:) userInfo:nil options:0];
            [remote loadData];
        }
    }
}

@end
