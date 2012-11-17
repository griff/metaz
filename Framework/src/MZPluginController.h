//
//  MZPluginController.h
//  MetaZ
//
//  Created by Brian Olsen on 26/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZPlugin.h>
#import <MetaZKit/MZDataProvider.h>
#import <MetaZKit/MZSearchProvider.h>

MZKIT_EXTERN const NSInteger errMZPluginMissingInstallLocation;
MZKIT_EXTERN const NSInteger errMZPluginAlreadyExists;
MZKIT_EXTERN const NSInteger errMZPluginFailedToCreateBundle;
MZKIT_EXTERN const NSInteger errMZPluginUnknownPluginType;
MZKIT_EXTERN const NSInteger errMZPluginAlreadyLoaded;
MZKIT_EXTERN const NSInteger errMZPluginFailedToLoadSource;
MZKIT_EXTERN const NSInteger errMZPluginFailedToLoadPrincipalClass;
MZKIT_EXTERN const NSInteger errMZPluginFailedToCreatePrincipalClass;

@class MZPluginController;

@protocol MZPluginControllerDelegate <NSObject>

@optional
- (id<MetaData>)pluginController:(MZPluginController *)controller
        extraMetaDataForProvider:(id<MZDataProvider>)provider
                          loaded:(MetaLoaded*)loaded;

- (void)pluginController:(MZPluginController *)controller
            loadedPlugin:(MZPlugin *)plugin;
- (void)pluginController:(MZPluginController *)controller
          unloadedPlugin:(NSString *)identifier;

@end


@protocol MZEditsReadDelegate <NSObject>
- (void)dataProvider:(id<MZDataProvider>)provider
          controller:(id<MZDataController>)controller
         loadedEdits:(MetaEdits *)edits
            fromFile:(NSString *)fileName
               error:(NSError *)error;
@end


@interface MZPluginController : NSObject {
    NSMutableArray* plugins;
    NSMutableArray* loadedPlugins;
    NSMutableArray* activePlugins;
    NSMutableSet* loadedBundles;
    id<MZPluginControllerDelegate> delegate;
    NSOperationQueue* loadQueue;
    NSOperationQueue* saveQueue;
    NSOperationQueue* searchQueue;
}

+ (NSString *)extractTitleFromFilename:(NSString *)fileName;
+ (NSArray *)pluginPaths;
+ (MZPluginController *)sharedInstance;

@property(assign) id<MZPluginControllerDelegate> delegate;
@property(readonly) NSOperationQueue* loadQueue;
@property(readonly) NSOperationQueue* saveQueue;
@property(readonly) NSOperationQueue* searchQueue;

- (BOOL)installPlugin:(NSURL *)thePlugin force:(BOOL)force error:(NSError **)error;
- (NSArray *)actionsPlugins;
- (NSArray *)plugins;
- (NSArray *)loadedPlugins;
- (NSArray *)dataProviderTypes;
- (MZPlugin *)pluginWithIdentifier:(NSString *)identifier;
- (MZPlugin *)pluginWithPath:(NSString *)path;
- (id<MZDataProvider>)dataProviderWithIdentifier:(NSString *)identifier;
- (id<MZDataProvider>)dataProviderForPath:(NSString *)path;
- (id<MZDataProvider>)dataProviderForType:(NSString *)uti;
- (id<MZSearchProvider>)searchProviderWithIdentifier:(NSString *)identifier;
- (id<MZDataController>)loadFromFile:(NSString *)fileName
                            delegate:(id<MZEditsReadDelegate>)deledate
                               extra:(NSDictionary *)extra;
- (id<MZDataController>)saveChanges:(MetaEdits *)data
                           delegate:(id<MZDataWriteDelegate>)delegate;
- (void)searchAllWithData:(NSDictionary *)data
                 delegate:(id<MZSearchProviderDelegate>)delegate;
- (BOOL)unloadPlugin:(MZPlugin *)plugin;

@end
