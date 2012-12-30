//
//  MZHTTPRequest.m
//  MetaZ
//
//  Created by Brian Olsen on 15/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import "MZHTTPRequest.h"


@implementation MZHTTPRequest

- (id)initWithURL:(NSURL *)newURL
{
    self = [super initWithURL:newURL];
    if(self)
    {
        [self setDidFinishBackgroundSelector:@selector(requestFinishedBackground:)];
    }
    return self;
}

- (void)requestFinished
{
    [self reportRequestFinishedBackground];
    [super requestFinished];
}

- (void)reportRequestFinishedBackground;
{
	if (delegate && [delegate respondsToSelector:didFinishBackgroundSelector]) {
		[delegate performSelector:didFinishBackgroundSelector withObject:self];
	}
}

@synthesize didFinishBackgroundSelector;
@end
