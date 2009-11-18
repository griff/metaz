//
//  MZRESTWrapper.h
//  MetaZ
//
//  Created by Adrian on 10/18/08.
//  Copyright 2008 Adrian Kosmaczewski. All rights reserved.
//
 
#import <Foundation/Foundation.h> 

@class MZRESTWrapper;
 
@protocol MZRESTWrapperDelegate
 
@required
- (void)wrapper:(MZRESTWrapper *)wrapper didRetrieveData:(NSData *)data;
 
@optional
- (void)wrapperHasBadCredentials:(MZRESTWrapper *)wrapper;
- (void)wrapper:(MZRESTWrapper *)wrapper didCreateResourceAtURL:(NSString *)url;
- (void)wrapper:(MZRESTWrapper *)wrapper didFailWithError:(NSError *)error;
- (void)wrapper:(MZRESTWrapper *)wrapper didReceiveStatusCode:(int)statusCode;
- (void)wrapperWasCanceled:(MZRESTWrapper *)wrapper;
 
@end 

@interface MZRESTWrapper : NSObject 
{
@private
    NSMutableData *receivedData;
    NSString *mimeType;
    NSURLConnection *connection;
    BOOL asynchronous;
    NSObject<MZRESTWrapperDelegate> *delegate;
    NSString *username;
    NSString *password;
}
 
@property (nonatomic, readonly) NSData *receivedData;
@property (nonatomic) BOOL asynchronous;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign) NSObject<MZRESTWrapperDelegate> *delegate; // Do not retain delegates!
@property (retain) NSURLConnection* connection;
 
- (void)sendRequestTo:(NSURL *)url usingVerb:(NSString *)verb withParameters:(NSDictionary *)parameters;
- (void)uploadData:(NSData *)data toURL:(NSURL *)url;
- (void)cancelConnection;
- (NSDictionary *)responseAsPropertyList;
- (NSString *)responseAsText;
- (NSXMLDocument *)responseAsXml;

- (NSDictionary *)preparedParameterDictionaryForInput:(NSDictionary *)inParams;
- (NSString *)queryStringForParameterDictionary:(NSDictionary *)parameters withUrl:(NSURL *)url;
 
@end