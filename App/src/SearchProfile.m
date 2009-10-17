//
//  SearchProfile.m
//  MetaZ
//
//  Created by Brian Olsen on 15/10/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import "SearchProfile.h"

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
            MZChaptersTagIdent, nil]];
}

+ (SearchProfile*)tvShowProfile
{
    return [self profileWithIdentifier:@"tvShow" mainTag:MZTitleTagIdent
        tag:[NSArray arrayWithObjects:
            MZVideoTypeTagIdent, MZTVShowTagIdent, 
            MZTVSeasonTagIdent, MZTVEpisodeTagIdent, MZChaptersTagIdent, nil]];
}

+ (SearchProfile*)movieProfile
{
    return [self profileWithIdentifier:@"movie" mainTag:MZTitleTagIdent
        tag:[NSArray arrayWithObjects:
            MZVideoTypeTagIdent, MZChaptersTagIdent, nil]];
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
        NSMutableArray* arr = [NSMutableArray array];
        NSDictionary* states = [[NSUserDefaults standardUserDefaults] dictionaryForKey:[@"profiles." stringByAppendingString:ident]];        
        for(NSString* tag in theTags)
        {
            ProfileState* state = [ProfileState stateWithTag:tag];
            if(states)
            {
                NSNumber* num = [states objectForKey:tag];
                if(num)
                    state.state = [num boolValue];
            }
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

    NSString* defaultKey = [@"profiles." stringByAppendingString:identifier];
    NSMutableDictionary* states = [NSMutableDictionary dictionaryWithDictionary:
        [[NSUserDefaults standardUserDefaults] dictionaryForKey:
            defaultKey]];
    for(ProfileState* myState in tags)
        [states setObject:[NSNumber numberWithBool:myState.state] forKey:myState.tag];
    [[NSUserDefaults standardUserDefaults] setObject:states forKey:defaultKey];
}

- (void)alterState:(NSMenuItem *)sender
{
    NSInteger tag = [sender tag];
    ProfileState* state = [tags objectAtIndex:tag];
    [sender setState:(state.state ? NSOnState : NSOffState)];
}

- (NSMutableDictionary *)searchTerms
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    for(ProfileState* state in tags)
    {
        if(state.state)
        {
            id value = [self valueForUndefinedKey:state.tag];
            if(value != nil && value != [NSNull null] && value != NSNoSelectionMarker &&
                value != NSMultipleValuesMarker && value != NSNotApplicableMarker)
            {
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
    [menuItem setState:(state.state ? NSOnState : NSOffState)];
    id value = [self valueForUndefinedKey:state.tag];
    return value != nil && value != [NSNull null] && value != NSNoSelectionMarker &&
                value != NSMultipleValuesMarker && value != NSNotApplicableMarker;
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

