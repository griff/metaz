//
//  NSXMLNode-Accessors.m
//  MetaZ
//
//  Created by Brian Olsen on 12/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "NSXMLNode+MZExtensions.h"
#import "NSArray+Mapping.h"

@implementation NSXMLNode (MZExtensions)

- (NSString *)stringForXPath:(NSString *)xpath error:(NSError **)error
{
    NSArray* nodes = [self nodesForXPath:xpath error:error];
    if(!nodes)
        return nil;
    return [[nodes arrayByPerformingSelector:@selector(stringValue)]
                componentsJoinedByString:@", "];
    
}

@end
