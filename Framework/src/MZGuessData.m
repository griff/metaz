//
//  MZGuessData.m
//  MetaZ
//
//  This file contains code proted from perl Video::Filename which is copyright
//  Behan Webster.
//

#import "MZGuessData.h"
#import <CocoaOniguruma/OnigRegexp.h>
#import <MetaZKit/NSString+MZNumberValue.h>
#import <MetaZKit/NSString+MZNumberConversion.h>
#import <MetaZKit/NSString+MZRemoveString.h>
#import <MetaZKit/MZLogger.h>
#import <MetaZKit/MZTag.h>

@interface MZGuessData ()
- (NSArray *)_makeRegularExpressions;
- (NSDictionary *)_parse:(NSString *)str;
@end

@implementation MZGuessData

+ (id)guessWithDictionary:(NSDictionary *)dict
{
    return [[[[self class] alloc] initWithDictionary:dict] autorelease];
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if(self) {
        values = [self _parse:[dict objectForKey:MZFileNameTagIdent]];
    }
    return self;
}

- (void)dealloc {
    [values release];
    [super dealloc];
}

- (NSArray *)_makeRegularExpressions
{
    NSMutableArray* ret = [NSMutableArray array];
            // DVD Episode Support - DddEee
    [ret addObject:[OnigRegexp compileIgnorecase:
            @"^(?:(?<name>.*?)[\\/\\s._-]+)?(?:d|dvd|disc|disk)[\\s._]?(?<dvd>\\d{1,2})[x\\/\\s._-]*(?:e|ep|episode)[\\s._]?(?<episode>\\d{1,2}(?:\\.\\d{1,2})?)(?:-?(?:(?:e|ep)[\\s._]*)?(?<endep>\\d{1,2}))?(?:[\\s._]?(?:p|part)[\\s._]?(?<part>\\d+))?(?<subep>[a-z])?(?:[\\/\\s._-]*(?<epname>[^˜\\/]+?))?$"]
    ];
    
            // TV Show Support - SssEee or Season_ss_Episode_ss
    [ret addObject:[OnigRegexp compileIgnorecase:
            @"^(?:(?<name>.*?)[\\/\\s._-]+)?(?:s|se|season|series)[\\s._-]?(?<season>\\d{1,2})[x\\/\\s._-]*(?:e|ep|episode|[\\/\\s._-]+)[\\s._-]?(?<episode>\\d{1,2})(?:-?(?:(?:e|ep)[\\s._]*)?(?<endep>\\d{1,2}))?(?:[\\s._]?(?:p|part)[\\s._]?(?<part>\\d+))?(?<subep>[a-z])?(?:[\\/\\s._-]*(?<epname>[^\\/]+?))?$"]
    ];
    
            // Movie IMDB Support
    [ret addObject:[OnigRegexp compileIgnorecase:
            @"(?<movie>.*?)?(?:[\\/\\s._-]*\\[?(?<year>(?:19|20)\\d{2})\\]?)?(?:[\\/\\s._-]*\\[?(?:(?:imdb|tt)[\\s._-]*)*(?<imdb>\\d{7})\\]?)(?:[\\s._-]*(?<title>[^\\/]+?))?$"]
    ];
    
            // Movie + Year Support
    [ret addObject:[OnigRegexp compileIgnorecase:
            @"^(?:(?<movie>.*?)[\\/\\s._-]*)?\\[?(?<year>(?:19|20)\\d{2})\\]?(?:[\\s._-]*(?<title>[^\\/]+?))?$"]
    ];
    
            // TV Show Support - see
    [ret addObject:[OnigRegexp compileIgnorecase:
            @"^(?:(?<name>.*?)[\\/\\s._-]*)?(?<season>\\d{1,2}?)(?<episode>\\d{2})(?:[\\s._-]*(?<epname>.+?))?$"]
    ];
    
            // TV Show Support - sxee
    [ret addObject:[OnigRegexp compileIgnorecase:
            @"^(?:(?<name>.*?)[\\/\\s._-]*)?\\[?(?<season>\\d{1,2})[x\\/](?<episode>\\d{1,2})(?:-(?:\\k<season>x)?(?<endep>\\d{1,2}))?\\]?(?:[\\s._-]*(?<epname>[^\\/]+?))?$"]
    ];
    
            // TV Show Support - season only
    [ret addObject:[OnigRegexp compileIgnorecase:
            @"^(?:(?<name>.*?)[\\/\\s._-]+)?(?:s|se|season|series)[\\s._]?(?<season>\\d{1,2})(?:[\\/\\s._-]*(?<epname>[^\\/]+?))?$"]
    ];
    
            // TV Show Support - episode only
    [ret addObject:[OnigRegexp compile:
            @"^(?:(?<name>.*?)[\\/\\s._-]*)?(?:(?:e|ep|episode)[\\s._]?)?(?<episode>\\d{1,2})(?:-(?:e|ep)?(?<endep>\\d{1,2}))?(?:(?:p|part)(?<part>\\d+))?(?<subep>[a-z])?(?:[\\/\\s._-]*(?<epname>[^\\/]+?))?$"]
    ];
    
            // Default Movie Support
    [ret addObject:[OnigRegexp compileIgnorecase:
            @"^(?<movie>.*)$"]
    ];
    return ret;
}

- (NSDictionary *)_parse:(NSString *)str
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    // Translate appropriate roman/english numbers to numerals
	NSString* prefix = @"(?:d|dvd|disc|disk|s|se|season|e|ep|episode)[\\s._-]+";
	NSString* end = @"(?:day|part)[\\s._-]+";
	//str = [str mz_convertAllRomans2IntWithPrefix:prefix andPostfix:end];
	str = [str mz_convertAllNumbers2IntWithPrefix:prefix andPostfix:end];
 
    NSArray* regs = [self _makeRegularExpressions];   
    for( OnigRegexp* reg in regs)
    {
        OnigResult* res = [reg match:str];
        if(res)
        {
            if([res stringForName:@"name"])
                [dict setObject:[res stringForName:@"name"] forKey:@"name"];
            if([res stringForName:@"dvd"])
                [dict setObject:[[res stringForName:@"dvd"] mz_numberIntValue] forKey:@"dvd"];
            if([res stringForName:@"season"])
                [dict setObject:[[res stringForName:@"season"] mz_numberIntValue] forKey:@"season"];
            if([res stringForName:@"episode"])
                [dict setObject:[[res stringForName:@"episode"] mz_numberIntValue] forKey:@"episode"];
            if([res stringForName:@"endep"])
                [dict setObject:[[res stringForName:@"endep"] mz_numberIntValue] forKey:@"endep"];
            if([res stringForName:@"part"])
                [dict setObject:[[res stringForName:@"part"] mz_numberIntValue] forKey:@"part"];
            if([res stringForName:@"subep"])
                [dict setObject:[res stringForName:@"subep"] forKey:@"subep"];
            if([res stringForName:@"epname"])
                [dict setObject:[res stringForName:@"epname"] forKey:@"epname"];
            if([res stringForName:@"movie"])
                [dict setObject:[res stringForName:@"movie"] forKey:@"movie"];
            if([res stringForName:@"year"])
                [dict setObject:[[res stringForName:@"year"] mz_numberIntValue] forKey:@"year"];
            if([res stringForName:@"imdb"])
                [dict setObject:[res stringForName:@"imdb"] forKey:@"imdb"];
            if([res stringForName:@"title"])
                [dict setObject:[res stringForName:@"title"] forKey:@"title"];
            break;
        }
    }
    
    // Perhaps a movie is really a name with default season or episode
    if(([dict objectForKey:@"name"] || [dict objectForKey:@"season"] || [dict objectForKey:@"episode"]) && 
        [dict objectForKey:@""])
    {
        if(![dict objectForKey:@"name"])
            [dict setObject:[dict objectForKey:@"name"] forKey:@"movie"];
        [dict removeObjectForKey:@"movie"];
    }
    
    //Process Series/Movie
	for( NSString* key in [NSArray arrayWithObjects:@"name", @"movie", @"epname", @"title", nil])
    {
        NSString* value = [dict objectForKey:key];
		if( value )
        {
            OnigResult* res = [[OnigRegexp compile:@"^.*\\/(.*?)$"] match:value];
			if(res)
            {
				// Get rid of any directory 
                [dict setObject:value forKey:[@"guess-" stringByAppendingString:key]];
				// Keep the original name without '/' just in case the name contains a subdir
                [dict setObject:[res stringAt:1] forKey:key];

                /*
                [dict setObject:[value replaceAllByRegexp:@"[\\/\\s._-]+" with:@" "] forKey:[@"guess-" stringByAppendingString:key]];
				$self->{"guess-$key"} =~ s/[\/\s._-]+/ /;
                */
                value = [dict objectForKey:key];
			}
            /*
			$self->{$key} =~ s/[$self->{spaces}]+/ /g if defined $self->{spaces};
            NSString* spaces = [dict objectForKey:@"spaces"];
            if(spaces)
            {
                [dict setObject:(value = [value replaceAllByRegexp:
                    [NSString stringWithFormat:@"[%@]+", spaces] with:@" "]) forKey:key];
            }
            */
            
            // Remove leading/trailing separators
            [dict setObject:[value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] forKey:key];
			//$self->{$key} =~ s/^\s*(.+?)\s*$/$1/;	# Remove leading/trailing separators
		}
	}

	// Guess part from epname
    if( [dict objectForKey:@"epname"] && ![dict objectForKey:@"part"] )
	{
        NSString* epname = [[dict objectForKey:@"epname"] mz_convertAllNumbers2Int]; // Make letters into integers
        // Remove "Part #" from episode name
        OnigResult* res = nil;
		if ((res = [[OnigRegexp compileIgnorecase:@"(?:Episode|Part|PT) (\\d+)"] match:epname])
			|| (res = [[OnigRegexp compileIgnorecase:@"(\\d+)\\s*(?:of|-)\\s*\\d+"] match:epname])
			|| (res = [[OnigRegexp compile:@"^(\\d+)"] match:epname])
			|| (res = [[OnigRegexp compile:@"[\\s._-](\\d+)$"] match:epname])
		) {
            [dict setObject:[res stringAt:0] forKey:@"part"];
		}
	}

	// Cosmetics
    if( [[dict objectForKey:@"endep"] isEqualTo: [dict objectForKey:@"episode"]] )
        [dict removeObjectForKey:@"endep"];

	// Convenience for some developpers
    /*
	if( [dict objectForKey:@"season"] ) {
		[dict setObject:[NSString] forKey:@"seasonepisode" = sprintf("S%02dE%02d", $self->{season}, $self->{episode});
	} else if( [[dict objectForKey:@"dvd"] ) {
		$self->{seasonepisode} = sprintf("D%02dE%02.1f", $self->{dvd}, $self->{episode});
	}
    */
    
    MZLoggerDebug(@"Guess result:");
    for(NSString* key in [dict allKeys])
    {
        MZLoggerDebug(@"   %@ -> %@", key, [dict objectForKey:key]);
    }
    
    return dict;
}

-(NSString *)guessTitle:(NSString *)fileName
{
    NSString* basefile = [fileName lastPathComponent];
    NSString* newTitle = [basefile substringToIndex:[basefile length] - [[basefile pathExtension] length] - 1];
    newTitle = [newTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([newTitle hasSuffix:@"]"])
    {
        NSInteger len = [newTitle length];
        NSScanner* scanner = [NSScanner scannerWithString:newTitle];
        [scanner setCharactersToBeSkipped:nil];
        [scanner setScanLocation:len-6];
        NSString* temp;
        if([scanner scanString:@"[" intoString:&temp])
        {
            if([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&temp])
            {
                if([scanner scanString:@"]" intoString:&temp] && [scanner scanLocation]==len)
                    newTitle = [newTitle substringToIndex:len-6];
            }
        }
    }
    else if([newTitle hasSuffix:@")"])
    {
        NSInteger len = [newTitle length];
        NSScanner* scanner = [NSScanner scannerWithString:newTitle];
        [scanner setCharactersToBeSkipped:nil];
        [scanner setScanLocation:len-6];
        NSString* temp;
        if([scanner scanString:@"(" intoString:&temp])
        {
            if([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&temp])
            {
                if([scanner scanString:@")" intoString:&temp] && [scanner scanLocation]==len)
                    newTitle = [newTitle substringToIndex:len-6];
            }
        }
    }
    newTitle = [newTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return newTitle;
}

- (id)getterValueForKey:(NSString *)aKey
{
    id ret = [values objectForKey:aKey];
    MZTag* tag = [MZTag tagForIdentifier:aKey];
    return [tag convertObjectForRetrival:ret];
}

#pragma mark - MZDynamicObject handling

-(void)handleDataForKey:(NSString *)aKey ofType:(NSUInteger)aType forInvocation:(NSInvocation *)anInvocation 
{
    id ret = [self getterValueForKey:aKey];
    [anInvocation setReturnObject:ret];
}

-(id)handleDataForMethod:(NSString *)aMethod withKey:(NSString *)aKey ofType:(NSUInteger)aType
{
    return [self getterValueForKey:aKey];
}

@end
