//
//  MZVersion.m
//  MetaZ
//
//  Created by Brian Olsen on 24/11/13.
//
//

#import "MZVersion.h"

@implementation MZVersion

+ (id)systemVersion; {
    NSOperatingSystemVersion version = [[NSProcessInfo processInfo] operatingSystemVersion];
    return [self versionWithMajor:version.majorVersion
                            minor:version.minorVersion
                           bugFix:version.patchVersion];
}

+ (id)versionWithMajor:(NSUInteger)major minor:(NSUInteger)minor bugFix:(NSUInteger)bugFix;
{
    return [[[self alloc] initWithMajor:major minor:minor bugFix:bugFix] autorelease];
}

+ (id)versionWithString:(NSString *)systemVersion; {
    return [[[self alloc] initWithString:systemVersion] autorelease];
}


- (id)initWithMajor:(NSUInteger)aMajor minor:(NSUInteger)aMinor bugFix:(NSUInteger)aBugFix; {
    self = [super init];
    if(self) {
        major = aMajor;
        minor = aMinor;
        bugFix = aBugFix;
    }
    return self;
}

- (id)initWithString:(NSString *)version; {
    NSArray* components = [version componentsSeparatedByString:@"."];
    NSUInteger versMajor, versMinor, versBugFix;
    versMinor = versBugFix = 0;
    versMajor = [[components objectAtIndex:0] integerValue];
    if([components count] >= 2)
        versMinor = [[components objectAtIndex:1] integerValue];
    if([components count] >= 3)
        versBugFix = [[components objectAtIndex:2] integerValue];
    
    return [self initWithMajor:versMajor minor:versMinor bugFix:versBugFix];
}

@synthesize major;
@synthesize minor;
@synthesize bugFix;

- (NSComparisonResult)compare:(MZVersion *)aVersion;
{
    if(aVersion.major < self.major)
        return NSOrderedDescending;
    if(aVersion.major > self.major)
        return NSOrderedAscending;
    
    if(aVersion.minor < self.minor)
        return NSOrderedDescending;
    if(aVersion.minor > self.minor)
        return NSOrderedAscending;
    
    if(aVersion.bugFix < self.bugFix)
        return NSOrderedDescending;
    if(aVersion.bugFix > self.bugFix)
        return NSOrderedAscending;
    return NSOrderedSame;
}

- (BOOL)isLessThan:(MZVersion *)aVersion;
{
    return [self compare:aVersion] == NSOrderedAscending;
}

- (BOOL)isLessThanOrEqualTo:(MZVersion *)aVersion;
{
    return [self compare:aVersion] <= NSOrderedSame;
}

- (BOOL)isGreaterThan:(MZVersion *)aVersion;
{
    return [self compare:aVersion] == NSOrderedDescending;
}

- (BOOL)isGreaterThanOrEqualTo:(MZVersion *)aVersion;
{
    return [self compare:aVersion] >= NSOrderedSame;
}

- (BOOL)isEqual:(id)anObject
{
    if(![anObject isKindOfClass:[MZVersion class]])
        return NO;
    MZVersion* o = (MZVersion *)anObject;
    return o.major == self.major && o.minor == self.minor && o.bugFix == self.bugFix;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%lu.%lu.%lu",
                (unsigned long)major,
                (unsigned long)minor,
                (unsigned long)bugFix];
}

@end
