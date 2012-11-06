//
//  MZMultiGrowlWrapper.h
//  MetaZ
//
//  Created by Brian Olsen on 17/01/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MZMultiGrowlWrapper : NSObject {
    Class GrowlApplicationBridge;
}

+ (MZMultiGrowlWrapper *)shared;
+ (void) notifyWithTitle:(NSString *)title
			 description:(NSString *)description
		notificationName:(NSString *)notifName
				iconData:(NSData *)iconData
				priority:(signed int)priority
				isSticky:(BOOL)isSticky
			clickContext:(id)clickContext;
+ (BOOL)isGrowlSupported;
+ (void)setGrowlDelegate:(id)delegate;
+ (BOOL)isGrowlRunning;
+ (BOOL)isMistEnabled;

- (id)init;
- (BOOL)isGrowlSupported;
- (BOOL)isGrowlRunning;
- (BOOL)isMistEnabled;
- (void)setGrowlDelegate:(id)delegate;
- (void) notifyWithTitle:(NSString *)title
			 description:(NSString *)description
		notificationName:(NSString *)notifName
				iconData:(NSData *)iconData
				priority:(signed int)priority
				isSticky:(BOOL)isSticky
			clickContext:(id)clickContext;

@end
