//
//  MZTaskOperation.h
//  MetaZ
//
//  Created by Brian Olsen on 12/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MZTaskOperation : NSOperation
{
    NSTask* task;
    BOOL isExecuting;
    BOOL isFinished;
}

+ (id)taskOperation;
+ (id)taskOperationWithTask:(NSTask *)task;

- (id)init;
- (id)initWithTask:(NSTask *)task;

@property(assign) BOOL isExecuting;
@property(assign) BOOL isFinished;

- (void)start;
- (void)startOnMainThread;
- (void)setupIO;
- (BOOL)isConcurrent;
- (void)cancel;


- (void)setLaunchPath:(NSString *)path;
- (void)setArguments:(NSArray *)arguments;
- (void)setEnvironment:(NSDictionary *)dict;
	// if not set, use current
- (void)setCurrentDirectoryPath:(NSString *)path;
	// if not set, use current

// set standard I/O channels; may be either an NSFileHandle or an NSPipe
- (void)setStandardInput:(id)input;
- (void)setStandardOutput:(id)output;
- (void)setStandardError:(id)error;

// get parameters
- (NSString *)launchPath;
- (NSArray *)arguments;
- (NSDictionary *)environment;
- (NSString *)currentDirectoryPath;

// get standard I/O channels; could be either an NSFileHandle or an NSPipe
- (id)standardInput;
- (id)standardOutput;
- (id)standardError;

- (void)interrupt; // Not always possible. Sends SIGINT.
- (void)terminate; // Not always possible. Sends SIGTERM.

// status
- (int)processIdentifier; 
- (BOOL)isRunning;

- (int)terminationStatus;

@end
