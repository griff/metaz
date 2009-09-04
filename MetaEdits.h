//
//  MetaEdits.h
//  MetaZ
//
//  Created by Brian Olsen on 24/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MetaLoaded.h"
#import "MetaData.h"


@interface MetaEdits : MetaLoaded {
    id<MetaData> provider;
    NSMutableDictionary* lastCache;
}

-(id)initWithProvider:(id<MetaData>)aProvider;
-(BOOL)changed;

-(BOOL)getterChangedForKey:(NSString *)aKey;
-(void)setterChanged:(BOOL)aValue forKey:(NSString *)aKey;
-(void)setterValue:(id)aValue forKey:(NSString *)aKey;

@end
