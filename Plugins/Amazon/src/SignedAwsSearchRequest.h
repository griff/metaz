//
//  SignedAwsSearchRequest.h
//
//  Class to encapsulate the generation of a signed Amazon AWS search request URL.
//  Amazon started to require signed AWS requests in 2009. See these documents for
//  details about the signing mechanism:
//
//  http://docs.amazonwebservices.com/AWSECommerceService/latest/DG/index.html?RequestAuthenticationArticle.html
//  http://docs.amazonwebservices.com/AWSECommerceService/2008-06-26/DG/
//
//  For example usage see the unit test code in TestSignedAwsSearchRequest.m
//
//  Created as part of the Album Artwork Assistant Mac OS X application
//
//  Copyright 2009 Marc Liyanage <http://www.entropy.ch>.
// 
//  You are free to use this class if you give credit somewhere
//  in your application or documentation.
//
//  Uses code from Google Toolbox for Mac:   http://code.google.com/p/google-toolbox-for-mac/
//  Uses code from HMAC-SHA2 by Olivier Gay: http://www.ouah.org/ogay/hmac/
//

#import <Cocoa/Cocoa.h>

@interface SignedAwsSearchRequest : NSObject {
	NSString *accessKeyId, *secretAccessKey;
	NSString *awsHost, *awsPath, *associateTag;
}

@property (retain) NSString *accessKeyId, *secretAccessKey;
@property (retain) NSString *awsHost, *awsPath, *associateTag;

// These two are the public API
- (id)initWithAccessKeyId:(NSString *)accessKeyId secretAccessKey:(NSString *)secretAccessKey;
- (NSString *)searchUrlForParameterDictionary:(NSDictionary *)inParams;

@end
