//
//  MetaLoadProvider.h
//  MetaZ
//
//  Created by Brian Olsen on 26/08/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <MetaZKit/MetaData.h>
#import <MetaZKit/MetaLoaded.h>
#import <MetaZKit/MetaEdits.h>

@protocol MZDataProvider;

@protocol MZDataController <NSObject>
- (BOOL)isFinished;
- (void)cancel;
@end

@protocol MZDataReadDelegate <NSObject>
@optional
- (void)dataProvider:(id<MZDataProvider>)provider
          controller:(id<MZDataController>)controller
          loadedMeta:(MetaLoaded *)loaded
            fromFile:(NSString *)fileName
               error:(NSError *)error;
@end

@protocol MZDataWriteDelegate <NSObject>
@optional
- (void)dataProvider:(id<MZDataProvider>)provider controller:(id<MZDataController>)controller writeStartedForEdits:(MetaEdits *)edits;
- (void)dataProvider:(id<MZDataProvider>)provider controller:(id<MZDataController>)controller writeCanceledForEdits:(MetaEdits *)edits error:(NSError *)error;
- (void)dataProvider:(id<MZDataProvider>)provider controller:(id<MZDataController>)controller writeFinishedForEdits:(MetaEdits *)edits percent:(int)percent;
- (void)dataProvider:(id<MZDataProvider>)provider controller:(id<MZDataController>)controller writeFinishedForEdits:(MetaEdits *)edits;
@end


/*!
 @abstract Data provider
 */
@protocol MZDataProvider <NSObject>
@required

- (NSString *)identifier;

/*!
 @abstract Returns array of UTIs supported by this provider.
 @result The UTIs supported by this provider.
 */
- (NSArray *)types;

/*!
 @abstract Returns tags supported by this provider.
 */
- (NSArray *)providedTags;

/*!
 @abstract Loads the supplied file and return the meta data loaded.
 */
- (id<MZDataController>)loadFromFile:(NSString *)fileName
                            delegate:(id<MZDataReadDelegate>)deledate
                               queue:(NSOperationQueue *)queue;


/*!
 @abstract Saves any changes to the meta data.
 */
- (id<MZDataController>)saveChanges:(MetaEdits *)data
                           delegate:(id<MZDataWriteDelegate>)delegate
                              queue:(NSOperationQueue *)queue;

@end

