//
//  MZScriptingEnums.h
//  MetaZ
//
//  Created by Brian Olsen on 01/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MZScriptingEnumerator : NSObject {
    NSString* name;
    OSType code;
    NSString* description;
    id objectValue;
}
+ (id)scriptingEnumeratorWithName:(NSString *)name code:(OSType)code description:(NSString *)description value:(id)value;
- (id)initWithName:(NSString *)name code:(OSType)code description:(NSString *)description value:(id)value;

@property(readonly,retain) NSString* name;
@property(readonly) OSType code;
@property(readonly,retain) NSString* description;
@property(readonly) id objectValue;

- (NSAppleEventDescriptor *)scriptingAnyDescriptor;

@end


@interface MZScriptingEnums : NSObject {
    NSBundle* bundle;
    NSDictionary* codeToEnumValue;
    NSDictionary* nameToEnum;
}
+ (id)scriptingEnumsForMainBundle;
+ (id)scriptingEnumsForBundle:(NSBundle *)bundle;

- (MZScriptingEnumerator *)enumValueWithCode:(OSType)code;
- (MZScriptingEnumerator *)enumValueForEnum:(NSString *)name withValue:(id)value;
- (NSArray *)valuesForEnum:(NSString *)name;
- (NSArray *)names;

@end
