/* SVRAccessoryWindowsOwner.h created by me on Sun 27-Oct-2024 */

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"
#import "NSUserDefaults+Soulver.h"

@interface SVRAccessoryWindowsOwner : NSObject
{
  mm_retain IBOutlet NSPanel  *_keypadPanel;
  mm_retain IBOutlet NSWindow *_aboutWindow;
  mm_retain IBOutlet NSWindow *_settingsWindow;
}

// MARK: IBOutlets
-(NSPanel *)keypadPanel;
-(NSWindow*)aboutWindow;
-(NSWindow*)settingsWindow;

// MARK: Init
-(id)init;

// MARK: IBActions
-(IBAction)toggleKeypadPanel:(id)sender;
-(IBAction)showSettingsWindow:(id)sender;
-(IBAction)showAboutWindow:(id)sender;

// MARK: Restore Window State
-(void)__restoreWindowState;
-(SVRAccessoryWindow)__accessoryWindowForWindow:(NSWindow*)window;

// MARK: Notifications (Save window state)
/// Set the User Defaults to YES for this Window
-(void)__windowDidBecomeKey:(NSNotification*)aNotification;
/// Set the User Defaults to NO for this Window
-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
/// Save the Frame in User Defaults
-(void)__windowDidResize:(NSNotification*)aNotification;
/// Save the Frame in User Defaults
-(void)__windowDidMove:(NSNotification*)aNotification;
/// Unsubscribe from Notifications so that windowWillCloseNotification is not called
-(void)__applicationWillTerminate:(NSNotification*)aNotification;

@end
