//
//  MGViewAnimation.h
//  Created by Matt Gemmell on 13/11/2006. http://mattgemmell.com/
//  Based on code by Todd Yandell http://tyandell.googlepages.com/
//

#import <Cocoa/Cocoa.h>

@interface MGViewAnimation : NSAnimation
{
    NSMutableArray *_viewAnimations;
    NSMutableArray *_views;
    NSMutableDictionary *_fadeViews;
    NSMutableDictionary *_fadeImages;
    BOOL _continuouslyUpdatesFadingViews;
    BOOL _ordersOutFadedWindows;
}

- (id)initWithViewAnimations:(NSArray*)viewAnimations;
- (NSArray *)viewAnimations;
- (void)setViewAnimations:(NSArray *)viewAnimations;
- (void)stopAnimation;

- (NSRect)frameForView:(NSView *)view atProgress:(float)progress;
- (NSRect)originalFrameForView:(NSView *)view;
- (NSRect)destinationFrameForView:(NSView *)view;

- (BOOL)continuouslyUpdatesFadingViews;
- (void)setContinuouslyUpdateFadingViews:(BOOL)value;
- (BOOL)ordersOutFadedWindows;
- (void)setOrdersOutFadedWindows:(BOOL)value;

@end
