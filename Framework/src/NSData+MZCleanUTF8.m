//
//  NSData+MZCleanUTF8.m
//  MetaZ
//
//  Created by Brian Olsen on 24/11/13.
//
//

#import "NSData+MZCleanUTF8.h"
#include "iconv.h"

@implementation NSData (MZCleanUTF8)

- (NSData *)mz_cleanUTF8 {
    iconv_t cd = iconv_open("UTF-8", "UTF-8"); // convert to UTF-8 from UTF-8
    int one = 1;
    iconvctl(cd, ICONV_SET_DISCARD_ILSEQ, &one); // discard invalid characters
    
    size_t inbytesleft, outbytesleft;
    inbytesleft = outbytesleft = self.length;
    char *inbuf  = (char *)self.bytes;
    char *outbuf = malloc(sizeof(char) * self.length);
    char *outptr = outbuf;
    if (iconv(cd, &inbuf, &inbytesleft, &outptr, &outbytesleft)
        == (size_t)-1) {
        NSLog(@"this should not happen, seriously");
        return nil;
    }
    NSData *result = [NSData dataWithBytes:outbuf length:self.length - outbytesleft];
    iconv_close(cd);
    free(outbuf);
    return result;
}

@end
