//
//  PosterView.h
//  MetaZ
//
//  Created by Brian Olsen on 25/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    MZOKPosterImage,
    MZEmptyPosterImage,
    MZErrorPosterImage,
    MZFatalErrorPosterImage,
    MZMultiplePosterImage,
    MZNotApplicablePosterImage
} PosterImageStatus;

@interface PosterView : NSImageView {
    SEL actionHack;
    NSError* error;
    PosterImageStatus status;
}
@property (readonly) NSString* imageSize;

- (void)awakeFromNib;

- (void)mouseDown:(NSEvent *)theEvent;
- (void)keyDown:(NSEvent *)theEvent;

- (void)setStatus:(PosterImageStatus)status;
- (void)reportError:(NSError *)error;

- (void)setObjectValue:(id < NSCopying >)object;
- (NSImage *)objectValue;
- (void)setImage:(NSImage*)image;

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender;
- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender;
- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender;
- (BOOL)prepareForDragOperation:(id < NSDraggingInfo >)sender;

@end
