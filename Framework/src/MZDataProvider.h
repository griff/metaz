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

@protocol MZDataWriteDelegate <NSObject>
- (void)writeCanceled:(int)status;
- (void)writeFinishedPercent:(int)percent;
- (void)writeFinished;
@end

@protocol MZDataWriteController <NSObject>
- (BOOL)isRunning;
- (void)terminate;
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
-(NSArray *)types;

/*!
 @abstract Returns keys provided by this provider.
 */
-(NSArray *)providedKeys;

/*!
 @abstract Loads the supplied file and return the meta data loaded.
 */
-(MetaLoaded *)loadFromFile:(NSString *)fileName;


/*!
 @abstract Saves any changes to the meta data.
 */
-(id<MZDataWriteController>)saveChanges:(MetaEdits *)data
          delegate:(id<MZDataWriteDelegate>)delegate;

@end
