//
//  MetaData.h
//  MetaZ
//
//  Created by Brian Olsen on 24/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*!
 @protocol MetaData
 @abstract Informal protocol for all objects that store meta data
 @discussion An IOCommandGate instance is an extremely light weight mechanism that
 executes an action on the driver's work-loop...
 @see MetaEdits MetaEdits
 @see MetaLoaded MetaLoaded
 @framework MetaZKit
 @availability 1.0
*/
@protocol MetaData <NSObject, NSCopying, NSCoding>

@required
- (NSString *)loadedFileName;
- (NSArray *)providedKeys;

@optional
- (NSString *)fileName;
- (NSString *)title;
- (NSString *)artist;
- (NSString *)genre;
- (NSString *)album;
- (NSString *)albumArtist;
- (NSString *)shortDescription;
- (NSString *)longDescription;

- (void)setFileName:(NSString *)aFileName;
- (void)setTitle:(NSString *)aTitle;

@end


@interface NSObject (ChangeNotification)

-(void)willStoreValueForKey:(NSString *)key;
-(void)didStoreValueForKey:(NSString *)key;

@end
