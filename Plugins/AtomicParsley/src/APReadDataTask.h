//
//  APReadDataTask.h
//  MetaZ
//
//  Created by Brian Olsen on 19/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MetaZKit.h>
#import "APDataProvider.h"

@interface APReadDataTask : MZParseTaskOperation
{
    APDataProvider* provider;
    NSMutableDictionary* tagdict;
    NSString* fileName;
}
+ (id)taskWithProvider:(APDataProvider*)provider fromFileName:(NSString *)fileName dictionary:(NSMutableDictionary *)tagdict;
- (id)initWithProvider:(APDataProvider*)provider fromFileName:(NSString *)fileName dictionary:(NSMutableDictionary *)tagdict;

@end


@interface APPictureReadDataTask : MZTaskOperation
{
    NSMutableDictionary* tagdict;
    NSString* file;
}
@property(readonly) NSString* file;

+ (id)taskWithDictionary:(NSMutableDictionary *)tagdict;
- (id)initWithDictionary:(NSMutableDictionary *)tagdict;

@end


@interface APChapterReadDataTask : MZParseTaskOperation
{
    NSMutableDictionary* tagdict;
}

+ (id)taskWithFileName:(NSString*)fileName dictionary:(NSMutableDictionary *)tagdict;
- (id)initWithFileName:(NSString*)fileName dictionary:(NSMutableDictionary *)tagdict;

@end

/*
@interface APReadOperationsController : MZOperationsController
{
    id<MZDataReadDelegate> delegate;
    id<MZDataProvider> provider;
    NSString* fileName;
    NSMutableDictionary* tagdict;
}
@property(readonly) NSMutableDictionary* tagdict;

+ (id)controllerWithProvider:(id<MZDataProvider>)provider
                fromFileName:(NSString *)fileName
                    delegate:(id<MZDataReadDelegate>)delegate;

- (id)initWithProvider:(id<MZDataProvider>)provider
          fromFileName:(NSString *)fileName
              delegate:(id<MZDataReadDelegate>)delegate;

- (void)operationsFinished;

@end
*/
