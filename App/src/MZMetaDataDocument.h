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
@property(readwrite,assign) id scriptValue;

@end


@interface MZMetaDataDocument : NSObject {
    MetaEdits *data;
    NSArray* tags;
    NSString* container;
    BOOL saved;
}
@property(readonly) MetaEdits *data;

+ (id)documentWithEdit:(MetaEdits *)edit;
+ (id)documentWithEdit:(MetaEdits *)edit container:(NSString *)container saved:(BOOL)saved;
- (id)initWithEdit:(MetaEdits *)edit;
- (id)initWithEdit:(MetaEdits *)edit container:(NSString *)container saved:(BOOL)saved;
- (NSURL *)fileURL;
- (NSString *)displayName;
- (MZTimeCode *)duration;
- (BOOL)isDocumentEdited;

- (NSArray *)tags;

- (id)handleCloseScriptCommand:(NSScriptCommand *)cmd;
- (id)handleSaveScriptCommand:(NSScriptCommand *)cmd;

@end
