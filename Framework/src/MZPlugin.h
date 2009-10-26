//
//  MZPlugin.h
//  MetaZ
//
//  Created by Brian Olsen on 26/09/09.
//  Copyright 2009 Maven-Group. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*! @class MZPlugin
 @abstract Plugin
 */
@interface MZPlugin : NSObject
{
@private;
    IBOutlet NSView *preferencesView;
    NSNib* nib;
    NSArray* topLevelObjects;
}

/*!
 * @name Loading and Unloading Plug-in Resources
 * @methodgroup Loading and Unloading Plug-in Resources
 */
//@{
#pragma mark - Loading and Unloading Plug-in Resources 

/*!
 @abstract Notifies the receiver that it has been loaded into the MetaZ
    environment.
 @discussion You can override this method to initialize any variables or
    resources that your plug-in requires whenever it is loaded by MetaZ. If you
    do override this method, you must call super at some point in your
    implementation.

    If you implement this method, you should not rely on MetaZ calling
    the willUnload method to undo your plug-in object’s initialization. If your
    didLoad method acquires any resources that must be freed later, you should
    release those resources in your plug-in object’s dealloc or finalize method
    instead.
 @see willUnload willUnload
 */
- (void)didLoad;

/*!
 @abstract Notifies your plug-in that it has been removed from the MetaZ
    environment.
 @discussion You can override this method to handle any cleanup that might be
    required
    when your plug-in is removed from MetaZ by the user. This method is called
    only when the user removes your plug-in from the list of plug-ins in the
    preferences window. It is not called when MetaZ quits. If you do override
    this method, you must call super at some point in your implementation.
  @see didLoad didLoad
 */
- (void)willUnload;


/*! @name Getting the Plug-in’s Custom Providers
 */
//@{
#pragma mark - Getting the Plug-in’s Custom Providers

/*!
 */
- (NSArray *)dataProviders;

/*!
 */
- (NSArray *)searchProviders;
//@}

/*! @name Configuring Your Plug-in
 */
//@{
#pragma mark - Configuring Your Plug-in

/*!
 @abstract Returns the user-readable name displayed for your plug-in object in
    the MetaZ preferences window.
 @result A string containing the user-readable name of your plug-in.
 @discussion If you do not provide a name for your plug-in, the default
    implementation returns a formatted version of the receiver’s class name by
    default.
 */
- (NSString *)label;
//@}

/*! @name Setting Up the Preferences View
 */
//@{
#pragma mark - Setting Up the Preferences View

/*!
 @abstract Loads the receiver’s user interface into its preferences view.
 @discussion The default implementation loads the preferences nib file
    (identified by preferencesNibName). Returns the main preferences if
    successful, nil otherwise.

    Subclasses should rarely need to override this method. Override this
    method if you need to use a non-nib based technique for creating the
    preferences view. Call setPreferencesView: to set the preferences view.
 */
- (NSView *)loadPreferencesView;

/*!
 @brief Returns the name of the plugins nib file.
 @discussion The name should not include the .nib extension.

    The default implementation returns the value of the NSMainNibFile key in
    the bundle's information property list. If the key does not exist, it
    returns a default value of "Main".
 */
- (NSString *)preferencesNibName;

/*!
 @brief Returns the custom view used to display your plug-in’s preferences.
 @result The plug-ins custom preferences view.
 @discussion If your plug-in supports configurable preferences, you can
    override this method to return the view used to display those preferences.
    When your plug-in is selected in the MetaZ preferences window, your custom
    view replaces the list of plug-ins and frameworks normally displayed for
    plug-ins.
 */
- (NSView *)preferencesView;

/*!
 @abstract Sets the preferences view of the plugin.
 @discussion You should not need to call this directly unless you override
    loadPreferencesView.
 */
- (void)setPreferencesView:(NSView *)view;

//@}
@end
