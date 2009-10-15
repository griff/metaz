//
//  MZTimeCode.h
//  MetaZ
//
//  Created by Brian Olsen on 09/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MZTimeCode : NSObject <NSCoding,NSCopying> {
    NSUInteger millis;
}
+ (id)timeCodeWithString:(NSString *)str;
+ (id)timeCodeWithMillis:(NSUInteger)millis;

@property (readonly) NSUInteger millis;
@property (readonly) NSUInteger ms;
@property (readonly) NSUInteger sec;
@property (readonly) NSUInteger min;
@property (readonly) NSUInteger hour;

- (id)initWithString:(NSString *)str;
- (id)initWithMillis:(NSUInteger)millis;

- (NSString *)description;
- (MZTimeCode *)addMillis:(NSUInteger)millis; 
- (MZTimeCode *)addTimeCode:(MZTimeCode *)timeCode; 

@end
