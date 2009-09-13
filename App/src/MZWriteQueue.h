//
//  MZWriteQueue.h
//  MetaZ
//
//  Created by Brian Olsen on 07/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MetaEdits.h"

@interface MZWriteQueue : NSObject {
    NSString* fileName;
    NSMutableArray* queue;
}

-(id)init;

-(BOOL)loadQueueWithError:(NSError **)error;
-(BOOL)saveQueueWithError:(NSError **)error;
-(void)addArrayToQueue:(NSArray *)anArray;
-(void)addObjectToQueue:(MetaEdits *)anEdit;

@end
