//
//  MZMetaDataDocument.h
//  MetaZ
//
//  Created by Brian Olsen on 15/07/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZTimeCode.h>

@class MZMetaDataDocument;

@interface MZTagItem : NSObject {
    MZTag* tag;
    MZMetaDataDocument* document;
}
+ (id)itemWithTag:(MZTag*)tag document:(MZMetaDataDocument *)document;
- (id)initWithTag:(MZTag*)tag document:(MZMetaDataDocument *)document;

@property(readonly) NSString* name;
@property(readwrite,retain) id value;

@end


@interface MZMetaDataDocument : NSObject {
    MetaEdits *data;
    NSArray* tags;
}
@property(readonly) MetaEdits *data;

+ (id)documentWithEdit:(MetaEdits *)edit;
- (id)initWithEdit:(MetaEdits *)edit;
- (NSArray *)tags;
- (NSString *)lastComponentOfFileName;
- (NSString *)displayName;
- (MZTimeCode *)duration;

@end
