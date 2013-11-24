//
//  MZVersion.h
//  MetaZ
//
//  Created by Brian Olsen on 24/11/13.
//
//

#import <Foundation/Foundation.h>

@interface MZVersion : NSObject {
    NSUInteger major, minor, bugFix;
}
@property(readonly, nonatomic) NSUInteger major;
@property(readonly, nonatomic) NSUInteger minor;
@property(readonly, nonatomic) NSUInteger bugFix;

+ (id)systemVersion;
+ (id)versionWithString:(NSString *)systemVersion;
+ (id)versionWithMajor:(NSUInteger)major minor:(NSUInteger)minor bugFix:(NSUInteger)bugFix;
- (id)initWithMajor:(NSUInteger)major minor:(NSUInteger)minor bugFix:(NSUInteger)bugFix;
- (id)initWithString:(NSString *)systemVersion;

- (BOOL)isLessThan:(MZVersion *)aVersion;
- (BOOL)isLessThanOrEqualTo:(MZVersion *)aVersion;
- (BOOL)isGreaterThan:(MZVersion *)aVersion;
- (BOOL)isGreaterThanOrEqualTo:(MZVersion *)aVersion;
- (NSComparisonResult)compare:(MZVersion *)aVersion;

@end
