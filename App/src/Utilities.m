/*
 *  Utilities.c
 *  MetaZ
 *
 *  Created by Brian Olsen on 26/09/09.
 *  Copyright 2009 Maven-Group. All rights reserved.
 *
 */

#import "Utilities.h"
#import <objc/runtime.h>

void dumpMethods(Class clz)
{
    unsigned int count;
    Method* methods = class_copyMethodList(clz, &count);
    MZLoggerDebug(@"List of methods:");
    for(int i=0; i<count; i++)
    {
        MZLoggerDebug(@" - %@ - %s", NSStringFromSelector(method_getName(methods[i])), method_getTypeEncoding(methods[i]));
    }
    free(methods);
}
