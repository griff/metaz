//
//  AppController.h
//  NSViewAnimation Test
//
//  Created by Matt Gemmell on 08/11/2006.
//  Copyright 2006 Magic Aubergine.
//

#import <Cocoa/Cocoa.h>
#import "MGViewAnimation.h"

@interface AppController : NSObject {
    IBOutlet NSWindow *window;
    IBOutlet NSButton *checkbox;
    BOOL moved;
    NSViewAnimation *animation;
}

- (IBAction)animate:(id)sender;

@end
