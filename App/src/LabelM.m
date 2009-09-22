//
//  LabelM.m
//  MetaZ
//
//  Created by Brian Olsen on 16/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "LabelM.h"


@implementation LabelM

- (void)bind:(NSString *)binding toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options
{
    NSLog(@"Binding %@ to observer %@ with keypath %@ self %@", binding, observableController, keyPath, [observableController valueForKeyPath:@"self"]);
    [super bind:binding toObject:observableController withKeyPath:keyPath options:options];
}

@end
