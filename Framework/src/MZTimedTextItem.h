//
//  MZTimedTextItem.h
//  MetaZ
//
//  Created by Brian Olsen on 09/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZTimeCode.h>

@interface MZTimedTextItem : NSObject <NSCoding,NSCopying,NSMutableCopying> {
    MZTimeCode* start;
    MZTimeCode* duration;
    NSString* text;
}
@property (readonly) MZTimeCode* start;
@property (readonly) MZTimeCode* duration;

+ (id)textItemWithStart:(MZTimeCode *)start duration:(MZTimeCode *)duration text:(NSString *)text;
- (id)initWithStart:(MZTimeCode *)start duration:(MZTimeCode *)duration text:(NSString *)text;

- (NSString *)text;

@end


@interface MZMutableTimedTextItem : MZTimedTextItem {
}

- (void)setText:(NSString *)text;

@end