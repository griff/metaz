#import "NSString+NumericCompare.h"

@implementation NSString (MZNumericCompare)

-(NSComparisonResult)numericCompare:(NSString *)string
{
    return [self compare:string options:NSNumericSearch];
}

@end
