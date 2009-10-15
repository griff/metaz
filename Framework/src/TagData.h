//
//  TagData
//  MetaZ
//
//  Created by Brian Olsen on 13/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//



@protocol TagData <NSObject, NSCopying, NSCoding>

@required
- (id)owner;

@optional
- (NSString *)title;
- (NSString *)artist;
- (NSString *)genre;
- (NSString *)album;
- (NSString *)albumArtist;
- (NSString *)shortDescription;
- (NSString *)longDescription;
- (MZVideoType)videoType;
- (MZRating)rating;

- (NSString *)actors;
- (NSString *)director;
- (NSString *)producer;
- (NSString *)screenwriter;

@end
