//
//  APReadDataTask.h
//  MetaZ
//
//  Created by Brian Olsen on 19/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>
#import "AtomicParsleyPlugin.h"

@interface APReadDataTask : MZParseTaskOperation
{
    AtomicParsleyPlugin* provider;
    NSMutableDictionary* tagdict;
    NSString* fileName;
}
+ (id)taskWithProvider:(AtomicParsleyPlugin*)provider fromFileName:(NSString *)fileName dictionary:(NSMutableDictionary *)tagdict;
- (id)initWithProvider:(AtomicParsleyPlugin*)provider fromFileName:(NSString *)fileName dictionary:(NSMutableDictionary *)tagdict;

@end


@interface APPictureReadDataTask : MZTaskOperation
{
    NSMutableDictionary* tagdict;
    NSString* file;
}
@property(readonly) NSString* file;

+ (id)taskWithDictionary:(NSMutableDictionary *)tagdict;
- (id)initWithDictionary:(NSMutableDictionary *)tagdict;

@end


@interface APChapterReadDataTask : MZParseTaskOperation
{
    NSMutableDictionary* tagdict;
}

+ (id)taskWithFileName:(NSString*)fileName dictionary:(NSMutableDictionary *)tagdict;
- (id)initWithFileName:(NSString*)fileName dictionary:(NSMutableDictionary *)tagdict;

@end

