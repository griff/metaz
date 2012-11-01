//
//  MetaData.h
//  MetaZ
//
//  Created by Brian Olsen on 24/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//
#import <MetaZKit/MZConstants.h>
#import <MetaZKit/TagData.h>

/*! @protocol MetaData
 @abstract Informal protocol for all objects that store meta data
 @discussion An IOCommandGate instance is an extremely light weight mechanism that
 executes an action on the driver's work-loop...
 @see MetaEdits MetaEdits
 @see MetaLoaded MetaLoaded
 @availability 1.0
*/
@protocol MetaData <TagData>

@required
- (NSString *)loadedFileName;
- (NSArray *)providedTags;
- (void)prepareForQueue;
- (void)prepareFromQueue;
@property(readonly) id<TagData> pure;

@optional
- (NSString *)fileName;
- (void)setFileName:(NSString *)aFileName;
- (void)setTitle:(NSString *)aTitle;
- (void)setVideoType:(MZVideoType)aVideoType;
- (void)setRating:(MZRating)aRating;
- (MZTimeCode *)duration;

@end


@interface NSObject (ChangeNotification)

-(void)willStoreValueForKey:(NSString *)key;
-(void)didStoreValueForKey:(NSString *)key;

@end
