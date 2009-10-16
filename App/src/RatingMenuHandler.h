//
//  RatingMenu.h
//  MetaZ
//
//  Created by Brian Olsen on 07/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RatingMenuHandler : NSObject {
    NSPopUpButton* ratingButton;
    NSMenu* menuUK;
    NSMenu* menuDE;
    NSMenu* menuIE;
    NSMenu* menuCA;
    NSMenu* menuAU;
    NSMenu* menuNZ;
    NSArrayController* filesController;
    MZPriorObserverFix* observerFix;
}
@property (nonatomic, retain) IBOutlet NSPopUpButton* ratingButton;
@property (nonatomic, retain) IBOutlet NSMenu* menuUK;
@property (nonatomic, retain) IBOutlet NSMenu* menuDE;
@property (nonatomic, retain) IBOutlet NSMenu* menuIE;
@property (nonatomic, retain) IBOutlet NSMenu* menuCA;
@property (nonatomic, retain) IBOutlet NSMenu* menuAU;
@property (nonatomic, retain) IBOutlet NSMenu* menuNZ;
@property (nonatomic, retain) IBOutlet NSArrayController* filesController;
@property (retain) NSString* ratingName;

- (void)makeMenu;

@end
