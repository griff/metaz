//
//  SearchProfile.m
//  MetaZ
//
//  Created by Brian Olsen on 15/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "SearchProfile.h"
#import "NSUserDefaults+KeyPath.h"

@interface ProfileState : NSObject
{
    NSString* tag;
    BOOL state;
}
+ (id)stateWithTag:(NSString *)tag;
- (id)initWithTag:(NSString *)tag;

@property (readonly) NSString* tag;
@property (assign) BOOL state;

@end


@implementation SearchProfile

+ (SearchProfile*)unknownTypeProfile
{
    return [self profileWithIdentifier:@"unknown" mainTag:MZTitleTagIdent 
        tag:[NSArray arrayWithObjects:
            MZTitleTagIdent, MZChaptersTagIdent, nil]];
}

+ (SearchProfile*)tvShowProfile
{
    return [self profileWithIdentifier:@"tvShow" mainTag:MZTitleTagIdent
        tag:[NSArray arrayWithObjects:
            MZTitleTagIdent, MZVideoTypeTagIdent, MZTVShowTagIdent, 
            MZTVSeasonTagIdent, MZTVEpisodeTagIdent, MZChaptersTagIdent, nil]];
}

+ (SearchProfile*)movieProfile
{
    return [self profileWithIdentifier:@"movie" mainTag:MZTitleTagIdent
        tag:[NSArray arrayWithObjects:
            MZTitleTagIdent, MZVideoTypeTagIdent, MZChaptersTagIdent, nil]];
}

+ (id)profileWithIdentifier:(NSString *)ident mainTag:(NSString *)main tag:(NSArray *)tags;
{
    return [[[self alloc] initWithIdentifier:ident mainTag:main tag:tags] autorelease];
}

- (id)initWithIdentifier:(NSString *)ident mainTag:(NSString *)main tag:(NSArray *)theTags;
{
    self = [super init];
    if(self)
    {
        identifier = [ident retain];
        mainTag = [main retain];

        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        // Load old style preferences
        NSString* oldDefaultKey = [@"profiles." stringByAppendingString:ident];
        NSDictionary* states = [defaults dictionaryForKey:oldDefaultKey];
        if(states)
        {
            for(NSString* tag in [states allKeys])
            {
                NSString* key = [NSString stringWithFormat:@"profiles.%@.%@", ident, tag];
                NSNumber* val = [states objectForKey:tag];
                [defaults setBool:[val boolValue] forKeyPath:key];
            }
            [defaults removeObjectForKey:oldDefaultKey];
        }

        NSMutableArray* arr = [NSMutableArray array];
        for(NSString* tag in theTags)
        {
            NSString* key = [NSString stringWithFormat:@"profiles.%@.%@", ident, tag];
            ProfileState* state = [ProfileState stateWithTag:tag];
            state.state = [defaults boolForKeyPath:key default:YES];
            [arr addObject:state];
        }
        tags = [[NSArray alloc] initWithArray:arr];
    }
    return self;
}

- (void)dealloc
{
    [identifier release];
    [mainTag release];
    [tags release];
    [checkObj release];
    [checkPrefix release];
    [super dealloc];
}


@synthesize identifier;
@synthesize mainTag;

- (NSArray *)tags
{
    return [tags arrayByPerformingSelector:@selector(tag)];
}

- (void)setCheckObject:(id)obj withPrefix:(NSString *)prefix
{
    [checkObj release];
    [checkPrefix release];
    checkObj = [obj retain];
    checkPrefix = [prefix retain];
    if(!checkPrefix)
        checkPrefix = @"";
}

- (void)switchItem:(NSMenuItem *)sender
{
    NSInteger tag = [sender tag];
    ProfileState* state = [tags objectAtIndex:tag];
    state.state = !state.state;
    [sender setState:(state.state ? NSOnState : NSOffState)];
    
    [self willChangeValueForKey:@"searchTerms"];
    for(ProfileState* myState in tags)
    {
        NSString* key = [NSString stringWithFormat:@"profiles.%@.%@", identifier, myState.tag];
        [[NSUserDefaults standardUserDefaults] setBool:myState.state forKeyPath:key];
    }
    [self didChangeValueForKey:@"searchTerms"];
}

- (void)alterState:(NSMenuItem *)sender
{
    NSInteger tag = [sender tag];
    ProfileState* state = [tags objectAtIndex:tag];
    [sender setState:(state.state ? NSOnState : NSOffState)];
}

- (NSMutableDictionary *)searchTerms:(NSString *)mainTerm
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    for(ProfileState* state in tags)
    {
        if(state.state)
        {
            id value;
            if([state.tag isEqual:mainTag])
                value = mainTerm;
            else
                value = [self valueForUndefinedKey:state.tag];
            if(value != nil && value != [NSNull null] && value != NSNoSelectionMarker &&
                value != NSMultipleValuesMarker && value != NSNotApplicableMarker)
            {
                if([value isKindOfClass:[NSString class]])
                {
                    value = [value stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceCharacterSet]];
                }
                [dict setObject:value forKey:state.tag];
            }
        }
    }
    return dict;
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    NSInteger tag = [menuItem tag];
    ProfileState* state = [tags objectAtIndex:tag];
    id value = [self valueForUndefinedKey:state.tag];
    BOOL ret = value != nil && value != [NSNull null] && value != NSNoSelectionMarker &&
                value != NSMultipleValuesMarker && value != NSNotApplicableMarker;
    
    [menuItem setState:(state.state && ret ? NSOnState : NSOffState)];
    return ret;
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return [checkObj protectedValueForKeyPath:[checkPrefix stringByAppendingString:key]];
}

@end


@implementation ProfileState

+ (id)stateWithTag:(NSString *)tag
{
    return [[[self alloc] initWithTag:tag] autorelease];
}

- (id)initWithTag:(NSString *)theTag
{
    self = [super init];
    if(self)
    {
        tag = [theTag retain];
        state = YES;
    }
    return self;
}

@synthesize tag;
@synthesize state;

@end

