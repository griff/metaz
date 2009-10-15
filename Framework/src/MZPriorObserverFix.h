//
//  MZPriorObserverFix.h
//  MetaZ
//
//  Created by Brian Olsen on 15/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MZPriorObserverFix : NSObject
{
    NSMutableDictionary* oldData;
    NSMutableDictionary* keyPathCount;
    id other;
}

+ (id)fixWithOther:(id)other;
- (id)initWithOther:(id)other;

@end
