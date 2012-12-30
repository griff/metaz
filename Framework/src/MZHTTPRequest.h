//
//  MZHTTPRequest.h
//  MetaZ
//
//  Created by Brian Olsen on 15/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/ASIHTTPRequest.h>

@interface MZHTTPRequest : ASIHTTPRequest {
	// Called on the delegate (if implemented) when the request completes successfully. Default is requestFinishedBackground:
	SEL didFinishBackgroundSelector;
}
@property (assign) SEL didFinishBackgroundSelector;


- (void)reportRequestFinishedBackground;

@end
