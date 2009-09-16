//
//  BtnStuff.h
//  MetaZ
//
//  Created by Brian Olsen on 15/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BtnStuff : NSProxy {
    id proxy;
}

-(id)initWithProxy:(id)aProxy;

@end
