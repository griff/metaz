//
//  MZLogger.h
//  MetaZ
//
//  Created by Brian Olsen on 24/12/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/GTMLogger.h>

@interface MZNSLogWriter : NSObject <GTMLogWriter>
{
}

+ (id)logWriter;

@end


// A log formatter that formats the log string like the basic formatter, but
// also prepends a timestamp and some basic process info to the message, as
// shown in the following sample output.
//   2007-12-30 10:29:24.177 myapp[4588/0xa07d0f60] [lvl=1] log mesage here
@interface MZLogStandardFormatter : GTMLogBasicFormatter
{
}
@end  // MZLogStandardFormatter
