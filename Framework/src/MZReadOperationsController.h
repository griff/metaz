//
//  MZReadOperationsController.h
//  MetaZ
//
//  Created by Brian Olsen on 09/04/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZOperationsController.h>

@interface MZReadOperationsController : MZOperationsController
{
    id<MZDataReadDelegate> delegate;
    MZDataProviderPlugin* provider;
    NSString* fileName;
    NSMutableDictionary* tagdict;
}
@property(readonly) NSMutableDictionary* tagdict;

+ (id)controllerWithProvider:(MZDataProviderPlugin *)provider
                fromFileName:(NSString *)fileName
                    delegate:(id<MZDataReadDelegate>)delegate
                       extra:(NSDictionary *)extra;

- (id)initWithProvider:(MZDataProviderPlugin *)provider
          fromFileName:(NSString *)fileName
              delegate:(id<MZDataReadDelegate>)delegate
                 extra:(NSDictionary *)extra;

- (void)operationsFinished;

@end
