//
//  main.m
//  MetaZ
//
//  Created by Brian Olsen on 20/08/09.
//  Copyright Maven-Group 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZLogger.h>
#import <MetaZKit/MZVersion.h>
#import <sys/stat.h>

int main(int argc, const char *argv[])
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    BOOL makeFileLog = YES;
    for(int i=0; i<argc; i++)
        if(strncmp(argv[i], "-l", 2)==0)
            makeFileLog = NO;
    
    if(makeFileLog)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        if([paths count] > 0)
        {
            NSString* path = [[[paths objectAtIndex:0] 
                stringByAppendingPathComponent:@"Logs"] 
                stringByAppendingPathComponent:@"MetaZ.log"];

            umask(022);
        
            // Send stderr & stdout to our file
            FILE* file = freopen([path fileSystemRepresentation], "a", stderr);
            dup2(fileno(file), fileno(stdout));
        }
    }

    GTMLogger *logger = [GTMLogger sharedLogger];
    [logger setFormatter:[[[MZLogStandardFormatter alloc] init] autorelease]];
    [logger setWriter:[MZNSLogWriter logWriter]];
    [logger setFilter:[[[GTMLogNoFilter alloc] init] autorelease]];
    
    NSNumber* versionObj = [[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
    NSInteger version;
    if(!versionObj)
    {
        version = 0;
        [[NSUserDefaults standardUserDefaults] setInteger:version forKey:@"version"];
    }
    else
        version = [versionObj integerValue];

    NSBundle* bundle = [NSBundle mainBundle];
    NSString* dictPath;
    if ((dictPath = [bundle pathForResource:@"FactorySettings" ofType:@"plist"]))
    {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithContentsOfFile:dictPath];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
        [dict release];
    }
    
    if(version == 0)
    {
        NSNumber* whenDoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"whenDoneAction"];
        if(whenDoneNum)
        {
            NSInteger whenDone = [whenDoneNum integerValue];
            if(whenDone < 0 || whenDone > 5)
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"enabledActionPlugins"];
            else
            {
                NSMutableArray* enabled = [NSMutableArray array];
                [enabled addObject:@"Update iTunes"];
                if(whenDone == 1 || whenDone == 3)
                    [enabled addObject:@"org.maven-group.metaz.plugin.AlertWindowPlugin"];
                if(whenDone == 4 || whenDone == 5)
                    [enabled addObject:@"Quit MetaZ"];
                if(whenDone == 2 || whenDone == 3 || whenDone == 5)
                    [enabled addObject:@"org.maven-group.metaz.plugin.OSXNotificationPlugin"];
                [[NSUserDefaults standardUserDefaults] setObject:enabled forKey:@"enabledActionPlugins"];
            }
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"whenDoneAction"];
        }
        version = 1;
        [[NSUserDefaults standardUserDefaults] setInteger:version forKey:@"version"];
    }
    
    if(version == 1)
    {
        NSNumber* incomingVideoType = [[NSUserDefaults standardUserDefaults] objectForKey:@"incomingVideoType"];
        if(incomingVideoType && [incomingVideoType intValue] == MZHomeMovieVideoType)
            [[NSUserDefaults standardUserDefaults] setInteger:MZMovieVideoType forKey:@"incomingVideoType"];
        version = 2;
        [[NSUserDefaults standardUserDefaults] setInteger:version forKey:@"version"];
    }

    if(version == 2 || version == 3)
    {
        NSArray* actions = [[NSUserDefaults standardUserDefaults] arrayForKey:@"enabledActionPlugins"];
        if([actions indexOfObject:@"org.maven-group.metaz.plugin.GrowlPlugin"] != NSNotFound)
        {
            NSMutableArray* enabled = [NSMutableArray arrayWithArray:actions];
            [enabled removeObject:@"org.maven-group.metaz.plugin.GrowlPlugin"];
            [enabled addObject:@"org.maven-group.metaz.plugin.OSXNotificationPlugin"];
            [[NSUserDefaults standardUserDefaults] setObject:enabled forKey:@"enabledActionPlugins"];
        }
        version = 4;
        [[NSUserDefaults standardUserDefaults] setInteger:version forKey:@"version"];
    }
    if(version == 4)
    {
        NSArray* actions = [[NSUserDefaults standardUserDefaults] arrayForKey:@"enabledActionPlugins"];
        NSMutableArray* enabled = [NSMutableArray array];
        for (NSString* key in actions) {
            if([key isEqualToString:@"org.maven-group.metaz.plugin.OSXNotificationPlugin"]) {
                [enabled addObject:@"io.metaz.plugin.OSXNotification"];
            } else if ([key isEqualToString:@"org.maven-group.metaz.plugin.AlertWindowPlugin"]) {
                [enabled addObject:@"io.metaz.plugin.AlertWindow"];
            } else if ([key isEqualToString:@"org.maven-group.metaz.plugin.GrowlPlugin"]) {
            } else {
                [enabled addObject:key];
            }
        }
        [[NSUserDefaults standardUserDefaults] setObject:enabled forKey:@"enabledActionPlugins"];

        NSArray* plugins = [[NSUserDefaults standardUserDefaults] arrayForKey:@"disabledPlugins"];
        NSMutableArray* disabled = [NSMutableArray array];
        for (NSString* key in plugins) {
            if([key isEqualToString:@"org.maven-group.metaz.TheTVDBPlugin"]) {
                [disabled addObject:@"io.metaz.plugin.TheTVDB"];
            } else if ([key isEqualToString:@"org.maven-group.metaz.TheTVDB"]) {
                [disabled addObject:@"io.metaz.plugin.TheTVDB"];
            } else if ([key isEqualToString:@"org.maven-group.metaz.TheMovieDb"]) {
                [disabled addObject:@"io.metaz.plugin.TheMovieDb"];
            } else if ([key isEqualToString:@"org.maven-group.metaz.TheMovieDbNG"]) {
                [disabled addObject:@"io.metaz.plugin.TheMovieDbNG"];
            } else if ([key isEqualToString:@"org.maven-group.metaz.TheTVDB3"]) {
                [disabled addObject:@"io.metaz.plugin.TheTVDB3"];
            } else if ([key isEqualToString:@"org.maven-group.metaz.TagChimp"]) {
            } else {
                [disabled addObject:key];
            }
        }
        version = 5;
        [[NSUserDefaults standardUserDefaults] setInteger:version forKey:@"version"];
    }

    [pool release];
    return NSApplicationMain(argc,  argv);
}
