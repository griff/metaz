//
//  MetaChangeNotification.h
//  MetaZ
//
//  Created by Brian Olsen on 12/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSObject (ChangeNotification)

-(void)willStoreValueForKey:(NSString *)key;
-(void)didStoreValueForKey:(NSString *)key;

@end
