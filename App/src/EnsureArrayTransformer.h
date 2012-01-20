//
//  EnsureArrayTransformer.h
//  MetaZ
//
//  Created by Brian Olsen on 18/12/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EnsureArrayTransformer : NSValueTransformer {

}

+ (Class)transformedValueClass;
+ (BOOL)allowsReverseTransformation;

@end
