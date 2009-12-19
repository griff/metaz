//
//  MZTimedTextItem.h
//  MetaZ
//
//  Created by Brian Olsen on 09/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZTimeCode.h>

@interface MZTimedTextItem : NSObject <NSCoding,NSCopying,NSMutableCopying>
{
    MZTimeCode* start;
    MZTimeCode* duration;
    NSString* text;
}
+ (NSArray *)parseChapters:(NSString *)str duration:(MZTimeCode *)duration;
+ (NSArray *)parseOggChapters:(NSString *)str duration:(MZTimeCode *)duration;
+ (NSArray *)parseMP4Chapters:(NSString *)str duration:(MZTimeCode *)duration;
+ (NSArray *)parseWebChapters:(NSString *)str duration:(MZTimeCode *)duration;

+ (id)textItemWithStart:(MZTimeCode *)start duration:(MZTimeCode *)duration text:(NSString *)text;
- (id)initWithStart:(MZTimeCode *)start duration:(MZTimeCode *)duration text:(NSString *)text;

@property (readonly) MZTimeCode* start;
@property (readonly) MZTimeCode* duration;

- (NSString *)text;

@end


@interface MZMutableTimedTextItem : MZTimedTextItem {
}

- (void)setText:(NSString *)text;

@end