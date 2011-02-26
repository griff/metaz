//
//  NSString+MZNumberConversion.h
//  MetaZ
//
//  Created by Brian Olsen on 26/02/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (MZNumberConversion)
- (NSString *)mz_convertAllRomans2IntWithPrefix:(NSString *)prefix andPostfix:(NSString *)postfix;
- (NSString *)mz_convertAllRomans2Int;

- (NSString *)mz_convertAllNumbers2IntWithPrefix:(NSString *)prefix andPostfix:(NSString *)postfix;
- (NSString *)mz_convertAllNumbers2Int;

- (NSUInteger)mz_convertNumber2Int;
- (NSUInteger)mz_convertRoman2Int;

- (BOOL)mz_isRoman;

@end
