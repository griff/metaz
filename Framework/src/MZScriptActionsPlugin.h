//
//  MZScriptActionsPlugin.h
//  MetaZ
//
//  Created by Brian Olsen on 05/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZActionsPlugin.h>

@interface MZScriptActionsPlugin : MZActionsPlugin {
    NSString* identifier;
    NSURL* url;
    NSAppleScript* script;
}
@property(readonly) NSURL* url;
@property(readonly) NSAppleScript* script;

+ (id)pluginWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url;
- (NSString *)label;
- (BOOL)loadAndReturnError:(NSError **)error;
- (id)objectForInfoDictionaryKey:(NSString *)key;

@end
