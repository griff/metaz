//
//  SearchProfile.h
//  MetaZ
//
//  Created by Brian Olsen on 15/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchProfile : NSObject {
    NSString* mainTag;
    NSArray* tags;
}
+ (SearchProfile*)unknownTypeProfile;
+ (SearchProfile*)tvShowProfile;
+ (SearchProfile*)movieProfile;

@end
