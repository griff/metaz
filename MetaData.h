//
//  MetaData.h
//  MetaZ
//
//  Created by Brian Olsen on 24/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol MetaData <NSObject>

@optional
-(NSString *)fileName;
-(NSString *)title;
-(NSString *)artist;
-(NSString *)genre;
-(NSString *)album;
-(NSString *)albumArtist;
-(NSString *)shortDescription;
-(NSString *)longDescription;

-(NSArray *)providedKeys;

@end
