//
//  AmazonRequest.m
//  MetaZ
//
//  Created by Brian Olsen on 18/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "AmazonRequest.h"
#import "GTMBase64.h"
#import "hmac_sha2.h"

@implementation AmazonRequest

@synthesize accessKeyId, secretAccessKey, associateTag;

- (NSDictionary *)preparedParameterDictionaryForInput:(NSDictionary *)inParams;
{
	NSMutableDictionary *params = [[inParams mutableCopy] autorelease];
	[params setValue:@"AWSECommerceService"  forKey:@"Service"];
	[params setValue:self.accessKeyId        forKey:@"AWSAccessKeyId"];
    NSString* aTag = self.associateTag;
    if(aTag && [aTag length] > 0)
    {
        [params setValue:aTag       forKey:@"AssociateTag"];
    }
    if(![params objectForKey:@"Timestamp"])
        [params setValue:[self utcTimestamp]     forKey:@"Timestamp"];
	return params;
}

- (NSString *)queryStringForParameterDictionary:(NSDictionary *)parameters withUrl:(NSURL *)url
{
	NSString *queryString = [super queryStringForParameterDictionary:parameters withUrl:url];
	NSString *signatureInput = [self signatureInputForQueryString:queryString withUrl:url];
	NSString *signature = [self hmacStringForString:signatureInput];
	NSString *escapedSignature = [signature gtm_stringByEscapingForURLArgument];

	return [NSString stringWithFormat:@"%@&Signature=%@", queryString, escapedSignature];
}

- (NSString *)signatureInputForQueryString:(NSString *)queryString withUrl:(NSURL *)url
{
	NSMutableString *si = [NSMutableString string];
	[si appendString:@"GET\n"];
	[si appendString:url.host];
	[si appendString:@"\n"];
	[si appendString:url.path];
	[si appendString:@"\n"];
	[si appendString:queryString];
	return si;
}

- (NSString *)utcTimestamp
{
	NSDateFormatter *outputFormatter = [[[NSDateFormatter alloc] init] autorelease];
	outputFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
	outputFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	return [outputFormatter stringFromDate:[NSDate date]];
}


- (NSString *)hmacStringForString:(NSString *)signatureInput
{
	unsigned char *signatureInputBytes = (unsigned char *)[signatureInput UTF8String];

	unsigned char mac[SHA256_DIGEST_SIZE];
	bzero(mac, SHA256_DIGEST_SIZE);

	unsigned char *keyBytes = (unsigned char *)[self.secretAccessKey UTF8String];
	int keyLength = [self.secretAccessKey length];
	hmac_sha256(keyBytes, keyLength, signatureInputBytes, [signatureInput length], mac, SHA256_DIGEST_SIZE);

	return [GTMBase64 stringByEncodingBytes:mac length:SHA256_DIGEST_SIZE];
}

- (NSString *)testQueryStringForParameterDictionary:(NSDictionary *)parameters;
{
    return [super queryStringForParameterDictionary:parameters withUrl:nil];
}

@end
