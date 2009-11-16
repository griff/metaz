//
//  NSDate+UTC.h
//  MetaZ
//
//  Created by Brian Olsen on 16/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSDate (UTC)

+ (NSDate *)dateWithUTCString:(NSString *)timestamp;
- (NSString *)utcTimestamp;

@end
