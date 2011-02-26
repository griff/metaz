//
//  NSString+MZNumberConversion.m
//  MetaZ
//
//  Created by Brian Olsen on 26/02/11.
//  Copyright 2011 Maven-Group. All rights reserved.
//

#import "NSString+MZNumberConversion.h"
#import <CocoaOniguruma/OnigRegexp.h>
#import <MetaZKit/MZLogger.h>
#import <MetaZKit/NSString+MZRemoveString.h>

@implementation NSString (MZNumberConversion)

- (NSString *)_mz_convertRomanNumber2Int:(OnigResult *)result
{
    NSString* pre = [result stringAt:1];
    return [pre stringByAppendingFormat:@"%d",[[result stringAt:2] mz_convertRoman2Int]];
}


- (NSString *)_mz_convertNumber2Int:(OnigResult *)result
{
    NSString* pre = [result stringAt:1];
    return [pre stringByAppendingFormat:@"%d",[[result stringAt:2] mz_convertNumber2Int]];
}


- (NSString *)mz_convertAllRomans2Int;
{
    return [self mz_convertAllRomans2IntWithPrefix:nil andPostfix:nil];
}

- (NSString *)mz_convertAllRomans2IntWithPrefix:(NSString *)prefix andPostfix:(NSString *)postfix
{
	NSString* roman = @"([MC]*[DC]*[CX]*[LX]*[XI]*[VI]*)";

    if(!prefix) prefix = @"";
    OnigRegexp* first = [OnigRegexp compileIgnorecase:[NSString stringWithFormat:@"(%@)\b%@\b", 
        prefix, roman]];
    
    NSString* ret = [self replaceByRegexp:first withCallback:self selector:@selector(_mz_convertRomanNumber2Int:)];
    if(postfix) {
        OnigRegexp* second = [OnigRegexp compileIgnorecase:[NSString stringWithFormat:@"(%@)\b%@", 
            prefix, roman]];
        ret = [ret replaceByRegexp:second withCallback:self selector:@selector(_mz_convertRomanNumber2Int:)];
    }
    return ret;
}

- (NSString *)mz_convertAllNumbers2IntWithPrefix:(NSString *)prefix andPostfix:(NSString *)postfix
{
	NSString* single = @"zero|one|two|three|five|(?:twen|thir|four|fif|six|seven|nine)(?:|teen|ty)|eight(?:|een|y)|ten|eleven|twelve";
	NSString* mult = @"hundred|thousand|(?:m|b|tr)illion";
	NSString* regex = [NSString stringWithFormat:
        @"((?:(?:%@|%@)(?:%@|%@|\\s|,|and|&)+)?(?:%@|%@))",
        single, mult, single, mult, single, mult];

    if(!prefix) prefix = @"";
    OnigRegexp* first = [OnigRegexp compileIgnorecase:[NSString stringWithFormat:@"(%@)\b%@\b", 
        prefix, regex]];
    
    NSString* ret = [self replaceByRegexp:first withCallback:self selector:@selector(_mz_convertNumber2Int:)];
    if(postfix) {
        OnigRegexp* second = [OnigRegexp compileIgnorecase:[NSString stringWithFormat:@"(%@)\b%@", 
            prefix, regex]];
        ret = [ret replaceByRegexp:second withCallback:self selector:@selector(_mz_convertNumber2Int:)];
    }
    return ret;
}

- (NSString *)mz_convertAllNumbers2Int;
{
    return [self mz_convertAllNumbers2IntWithPrefix:nil andPostfix:nil];
}

- (NSUInteger)mz_convertNumber2Int;
{
    NSUInteger n = 0, c = 0, sum = 0;

    NSString *str = self;
	while ([str length] > 0) {
        str = [str replaceByRegexp:@"^[\\s,]+" with:@""];
        MZLoggerDebug(@"STR=%@ NUM=%d", str, n); 

        [str rangeOfString:@""];
        NSRange r;
        if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^(zero|and|&)"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            continue;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^(one)"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            n += 1;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^tw(o|en)"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            n += 2;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^th(ree|ir)"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            n += 3;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^four"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            n += 4;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^fi(ve|f)"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            n += 5;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^six"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            n += 6;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^seven"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            n += 7;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^eight"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            n += 8;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^nine"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            n += 9;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^(t|te|e)en"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            n += 10;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^eleven"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            n += 11;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^twelve"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            n += 12;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^t?y"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            n *= 10;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^hundred"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            c += n * 100; n = 0;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^thousand"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            sum += (c+n) * 1000; c=0; n=0;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^million"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            sum += (c+n) * 1000000; c=0; n=0;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^billion"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            sum += (c+n) * 1000000000; c=0; n=0;
        } else if ((r = [str rangeOfRegexp:[OnigRegexp compileIgnorecase:@"^trillion"]]).location != NSNotFound) {
            str = [str mz_stringByRemovingSubstringInRange:r];
            sum += (c+n) * 1000000000000; c=0; n=0;
        }
	}
	sum += (c+n);
    MZLoggerDebug(@"STR=%@ SUM=%d", str, sum); 
	return sum;
}


- (NSUInteger)mz_convertRoman2Int;
{
    return 0;
    /*
    sub roman2int {
    local $_ = uc(shift || $_);    # roman algarism

    return unless isroman();

    my ($r, $ret, $_ret) = ($_, 0, 0);
    while ($r) {
        $r =~ s/^$_// && ($ret += $R2A{$&}, last) for @RCN, @RSN;
        return unless $ret > $_ret;
        $_ret = $ret;
        }
    $ret;
    }
    */
}

- (BOOL)mz_isRoman;
{
    /*
    local $_ = shift || $_;                             # roman algarism
    
    return if ! /^[@RSN]+$/;
    return if /([IXCM])\1{3,}|([VLD])\2+/i;             # tests repeatability
    my @re = qw/IXI|XCX|CMC/;
    for (1 .. $#RSN) {
        push @re, "$RSN[$_ - 1]$RSN[$_]$RSN[$_ - 1]";   # tests IVI
        push @re, "$RSN[$_]$RSN[$_ - 1]$RSN[$_]";       # and VIV conditions
        }
    my $re = join "|", @re;
    !/$re/;
    */
    return YES;
}

@end
