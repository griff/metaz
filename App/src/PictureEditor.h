//
//  PictureEditor.h
//  MetaZ
//
//  Created by Brian Olsen on 20/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PosterView.h"

@interface PictureEditor : NSObject {
    NSArrayController* filesController;
    NSProgressIndicator* indicator;
    NSButton* retryButton;
    PosterView* posterView;
    id picture;
    MZPriorObserverFix* observerFix;
}
@property(nonatomic,retain) IBOutlet NSArrayController* filesController; 
@property(nonatomic,retain) IBOutlet NSProgressIndicator* indicator;
@property(nonatomic,retain) IBOutlet NSButton* retryButton;
@property(nonatomic,retain) IBOutlet PosterView* posterView;
@property(retain) id picture;
@property(retain) NSData* data;
@property(assign) NSNumber* changed;

- (IBAction)retryLoad:(id)sender;

@end
