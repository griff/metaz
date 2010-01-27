//
//  MZErrorOperation.h
//  MetaZ
//
//  Created by Brian Olsen on 19/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MZErrorOperation : NSOperation
{
    NSError* error;
}
@property(retain) NSError* error;

- (void)dependency:(NSOperation *)op failedWithError:(NSError*)error;

@end
