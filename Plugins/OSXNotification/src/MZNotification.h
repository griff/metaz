//
//  MZNotification.h
//  MetaZ
//
//  Created by Brian Olsen on 24/11/13.
//
//

#import <Cocoa/Cocoa.h>

@interface MZNotification : NSObject {
    id center;
    Class OSXNotification;
}

+ (MZNotification *)shared;
+(void)setDelegate:(id)delegate;
+(id)delegate;

+ (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description
                   path:(NSString *)path;

- (void)setDelegate:(id)delegate;
- (id)delegate;
- (void)notifyWithTitle:(NSString *)title
            description:(NSString *)description
                   path:(NSString *)path;


@end
