//
//  MZActionsPlugin.h
//  MetaZ
//
//  Created by Brian Olsen on 05/11/12.
//  Copyright 2012 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MetaZKit/MZPlugin.h>

/*! @class MZActionsPlugin
 @abstract Base class for plugins that only respond and take action on events
 */
@interface MZActionsPlugin : MZPlugin {
}

/*!
 @abstract Notifies your plug-in that it should register observers
    environment.
 @discussion You can override this method to register for any notifications
    you might be interested in. This method is called as part of didLoad if it
    is enabled and will also be called when this plugin is enabled.
  @see didLoad didLoad
  @see unregisterObservers unregisterObservers
 */
- (void)registerObservers;

/*!
 @abstract Notifies your plug-in that it should unregister observers
 @discussion You can override this method to unregister for any notifications
    you are setup to receive. This method is called from both willUnload and
    dealloc as well as when this plugin is disabled. If you do override this
    method, you must call super at some point in your implementation.
  @see didLoad didLoad
 */
- (void)unregisterObservers;

@end
