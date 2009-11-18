//
//  AmazonRequest.h
//  MetaZ
//
//  Created by Brian Olsen on 18/11/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MZRESTWrapper.h"

@interface AmazonRequest : MZRESTWrapper
{
	NSString *accessKeyId, *secretAccessKey, *associateTag;

}
@property (retain) NSString *accessKeyId, *secretAccessKey, *associateTag;

- (NSString *)utcTimestamp;
- (NSString *)hmacStringForString:(NSString *)signatureInput;
- (NSString *)signatureInputForQueryString:(NSString *)queryString withUrl:(NSURL *)url;
- (NSString *)testQueryStringForParameterDictionary:(NSDictionary *)parameters;

@end
