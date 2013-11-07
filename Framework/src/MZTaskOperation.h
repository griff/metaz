//
//  MZTaskOperation.h
//  MetaZ
//
//  Created by Brian Olsen on 12/01/10.
//  Copyright 2010 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZErrorOperation.h>

@interface MZTaskOperation : MZErrorOperation
{
    NSTask* task;
    BOOL executing;
    BOOL finished;
}

+ (id)taskOperation;
+ (id)taskOperationWithTask:(NSTask *)task;

- (id)init;
- (id)initWithTask:(NSTask *)task;

@property(getter=isExecuting,assign) BOOL executing;
@property(getter=isFinished,assign) BOOL finished;

- (void)start;
- (void)startOnMainThread;
- (BOOL)isConcurrent;
- (void)cancel;


- (void)setupStandardInput;
- (void)setupStandardOutput;
- (void)setupStandardError;
- (void)setupBackgroundStandardError;
- (void)releaseStandardOutput;
- (void)releaseStandardError;
- (void)taskTerminatedWithStatus:(int)status;
- (void)setErrorFromStatus:(int)status;
- (void)setErrorString:(NSString *)err code:(int)status;
- (void)standardOutputGotData:(NSNotification *)note;
- (void)standardErrorGotData:(NSNotification *)note;


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


@interface MZParseTaskOperation : MZTaskOperation
{
    NSData* data;
    BOOL terminated;
}
@property(retain) NSData* data;
@property(getter=isTerminated,assign) BOOL terminated;

- (void)parseData;

@end