//
//  SignedAwsSearchRequest.m
//

#import "SignedAwsSearchRequest.h"
#import "GTMNSString+URLArguments.h"
#import "GTMNSData+zlib.h"
#import "GTMBase64.h"
#import "hmac_sha2.h"

NSInteger stringByteSort(NSString *a, NSString *b, void *context);

@interface SignedAwsSearchRequest (Private)

// These are for internal use only
+ (NSString *)decodeKey:(char *)keyBytes length:(int)length;
- (NSString *)utcTimestamp;
- (NSString *)hmacStringForString:(NSString *)signatureInput;
- (NSString *)queryStringForParameterDictionary:(NSDictionary *)params;
- (NSString *)signatureInputForQueryString:(NSString *)queryString;
- (NSMutableDictionary *)preparedParameterDictionaryForInput:(NSDictionary *)inParams;

@end

@implementation SignedAwsSearchRequest

@synthesize accessKeyId, secretAccessKey;
@synthesize awsHost, awsPath, associateTag;

- (id)initWithAccessKeyId:(NSString *)id secretAccessKey:(NSString *)key {
	if (self = [super init]) {
		self.accessKeyId = id;
		self.secretAccessKey = key;
		self.awsHost = @"ecs.amazonaws.com";
		self.awsPath = @"/onca/xml";
		self.associateTag = @"";
	}
	return self;
}


- (void)dealloc {
	[accessKeyId release];
	[secretAccessKey release];
	[awsHost release];
	[awsPath release];
	[associateTag release];
	[super dealloc];
}


- (NSString *)searchUrlForParameterDictionary:(NSDictionary *)inParams {
	NSMutableDictionary *params = [self preparedParameterDictionaryForInput:inParams];
	NSString *queryString = [self queryStringForParameterDictionary:params];
	NSString *signatureInput = [self signatureInputForQueryString:queryString];
	NSString *signature = [self hmacStringForString:signatureInput];
	NSString *escapedSignature = [signature gtm_stringByEscapingForURLArgument];

	return [NSString stringWithFormat:@"http://%@%@?%@&Signature=%@", self.awsHost, self.awsPath, queryString, escapedSignature];
}


- (NSString *)signatureInputForQueryString:(NSString *)queryString {
	NSMutableString *si = [NSMutableString string];
	[si appendString:@"GET\n"];
	[si appendString:self.awsHost];
	[si appendString:@"\n"];
	[si appendString:self.awsPath];
	[si appendString:@"\n"];
	[si appendString:queryString];
	return si;
}


- (NSString *)queryStringForParameterDictionary:(NSDictionary *)params {
	NSArray *paramNames = [[params allKeys] sortedArrayUsingFunction:stringByteSort context:nil];
	NSMutableString *queryString = [NSMutableString string];
	int i, n = [paramNames count];
	for (i = 0; i < n; i++) {
		NSString *paramName = [paramNames objectAtIndex:i];
		[queryString appendFormat:@"%@=%@", paramName, [[params objectForKey:paramName] gtm_stringByEscapingForURLArgument]];
		if (i < n - 1) [queryString appendString:@"&"];
	}
	return queryString;
}


- (NSString *)utcTimestamp {
	NSDateFormatter *outputFormatter = [[[NSDateFormatter alloc] init] autorelease];
	outputFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
	outputFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	return [outputFormatter stringFromDate:[NSDate date]];
}


- (NSString *)hmacStringForString:(NSString *)signatureInput {
	unsigned char *signatureInputBytes = (unsigned char *)[signatureInput UTF8String];

	unsigned char mac[SHA256_DIGEST_SIZE];
	bzero(mac, SHA256_DIGEST_SIZE);

	unsigned char *keyBytes = (unsigned char *)[self.secretAccessKey UTF8String];
	int keyLength = [self.secretAccessKey length];
	hmac_sha256(keyBytes, keyLength, signatureInputBytes, [signatureInput length], mac, SHA256_DIGEST_SIZE);

	return [GTMBase64 stringByEncodingBytes:mac length:SHA256_DIGEST_SIZE];
}


- (NSMutableDictionary *)preparedParameterDictionaryForInput:(NSDictionary *)inParams {
	NSMutableDictionary *params = [[inParams mutableCopy] autorelease];
	[params setValue:@"AWSECommerceService"  forKey:@"Service"];
	[params setValue:self.accessKeyId        forKey:@"AWSAccessKeyId"];
    NSString* aTag = self.associateTag;
    if(aTag && [aTag length] > 0)
    {
        [params setValue:aTag       forKey:@"AssociateTag"];
    }
	[params setValue:[self utcTimestamp]     forKey:@"Timestamp"];
	return params;
}


+ (NSString *)decodeKey:(char *)keyBytes length:(int)length {
	NSData *data = [NSData gtm_dataByInflatingBytes:keyBytes length:length];
	return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

@end


NSInteger stringByteSort(NSString *a, NSString *b, void *context) {
	return strcmp([a UTF8String], [b UTF8String]);
}
