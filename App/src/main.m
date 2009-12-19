//
//  main.m
//  MetaZ
//
//  Created by Brian Olsen on 20/08/09.
//  Copyright Maven-Group 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <RubyCocoa/RBRuntime.h>
#import "GTMLogger.h"

int main(int argc, const char *argv[])
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    // Create array of GTMLogWriters
    NSArray* writers;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    if([paths count] > 0)
    {
        NSString* path = [[[paths objectAtIndex:0] 
            stringByAppendingPathComponent:@"Logs"] 
            stringByAppendingPathComponent:@"MetaZ.log"];
        
        writers = [NSArray arrayWithObjects:
            [NSFileHandle fileHandleForLoggingAtPath:path mode:0644],
            [NSFileHandle fileHandleWithStandardOutput], nil];
    }
    else
        writers = [NSArray arrayWithObject:[NSFileHandle fileHandleWithStandardOutput]];

    GTMLogger *logger = [GTMLogger sharedLogger];
    [logger setWriter:writers];
    [logger setFilter:[[[GTMLogNoFilter alloc] init] autorelease]];
    
    //RBApplicationInit("rb_main.rb", argc, argv, nil);
    [pool release];
    return NSApplicationMain(argc,  argv);
}
