//
//  MuhMa.m
//  MetaZ
//
//  Created by Brian Olsen on 16/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "MuhMa.h"

@interface MuhMaItem (Private) 
- (void)_copyConnectionsOfView:(NSView *)protoView referenceObject:(id)protoObject toView:(NSView *)view referenceObject:(id)object;
@end

@implementation MuhMa
@synthesize itemPrototype;
@synthesize content;

+ (void)initialize
{
    [[MuhMa class] exposeBinding:NSContentBinding];
}

-(void)awakeFromNib
{
    [self bind:NSContentBinding toObject:queues withKeyPath:@"arrangedObjects" options:nil];
}

- (MuhMaItem *)newItemForRepresentedObject:(id)object
{
    MuhMaItem* ret = [itemPrototype copy];
    ret.representedObject = object;
    return ret;
}


@end

@implementation MuhMaItem

- (void)setSelected:(BOOL)flag
{
    selected = flag;
}

- (BOOL)isSelected
{
    return selected;
}

- (id)copyWithZone:(NSZone *)zone
{
    if(!archived)
        archived = [NSKeyedArchiver archivedDataWithRootObject:self];
    MuhMaItem* ret = [NSKeyedUnarchiver unarchiveObjectWithData:archived];
    [ret setValue:parent forKey:@"parent"];
    [self _copyConnectionsOfView:[self view] referenceObject:self toView:[ret view] referenceObject:ret];
    return ret;
}

@end

@implementation MuhMaItem (Private)

- (void)_copyConnectionsOfView:(NSView *)protoView referenceObject:(id)protoObject toView:(NSView *)view referenceObject:(id)object
{
    if([protoView respondsToSelector:@selector(delegate)])
    {
        id delegate = [protoView delegate];
        if(delegate)
        {
            id newDelegate = [view delegate];
            if(delegate == protoObject)
                [view setDelegate:object];
            else if(!newDelegate) // Only set to proto delegate if external from the encoding ei. new delegate is nil
                [view setDelegate:delegate];
        }
    }
    if([protoView respondsToSelector:@selector(target)])
    {
        id target = [protoView target];
        if(target)
        {
            id newTarget = [view target];
            if(target == protoObject)
            {
                [view setTarget:object];
                if([protoView respondsToSelector:@selector(action)])
                    [view setAction:[protoView action]];
            }
            else if(!newTarget) // Only set to proto target if external from the encoding ei. new target is nil
            {
                [view setTarget:target];
                if([protoView respondsToSelector:@selector(action)])
                    [view setAction:[protoView action]];
            }
        }
    }
    
    for(NSString* binding in [protoView exposedBindings])
    {
        NSDictionary* dict = [protoView infoForBinding:binding];
        if(dict)
        {
            id target = [dict objectForKey:NSObservedObjectKey];
            NSDictionary* newDict = [view infoForBinding:binding];
            if(target == protoObject)
            {
                [view unbind:binding];
                [view      bind:binding
                       toObject:object 
                    withKeyPath:[dict objectForKey:NSObservedKeyPathKey]
                        options:[dict objectForKey:NSOptionsKey]];
            } else if(!newDict)
            {
                //id newTarget = [newDict objectForKey:NSObservedObjectKey];
                [view      bind:binding
                       toObject:target 
                    withKeyPath:[dict objectForKey:NSObservedKeyPathKey]
                        options:[dict objectForKey:NSOptionsKey]];
            }
        }
    }
    
    NSArray* protoSubviews = [protoView subviews];
    NSArray* subviews = [view subviews];
    NSAssert([protoSubviews count] == [subviews count], @"Proto and view must have same number of subviews");
    
    NSEnumerator* eProto = [protoSubviews objectEnumerator];
    NSEnumerator* eSub = [subviews objectEnumerator];
    
    NSView* nextView = nil;
    NSView* nextProto = nil;
    while( (nextView = [eSub nextObject]) && (nextProto = [eProto nextObject]) )
    {
        [self _copyConnectionsOfView:nextProto referenceObject:protoObject toView:nextView referenceObject:object];
    }
}

@end


