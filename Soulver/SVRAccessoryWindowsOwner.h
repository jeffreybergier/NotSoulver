/* SVRAccessoryWindowsOwner.h created by me on Sun 27-Oct-2024 */

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"

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
-(NSString*)__stateRestorationKeyForWindow:(NSWindow*)window;

// MARK: Notifications (Save window state)
-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
-(void)__windowDidResize:(NSNotification*)aNotification;
-(void)__windowDidMove:(NSNotification*)aNotification;

@end
