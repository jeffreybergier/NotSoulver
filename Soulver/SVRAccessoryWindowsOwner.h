//
// MIT License
//
// Copyright (c) 2024 Jeffrey Bergier
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// THIS SOFTWARE IS NOT RELATED TO THE APPLICATION CALLED 'Solver' by Zac Cohan,
// THIS SOFTWARE IS MERELY INSPIRED BY THAT APPLICATION AND WAS CREATED AS A
// LEARNING EXERCISE. YOU SHOULD PURCHASE AND USE 'Solver' by Zac Cohan
// AT https://soulver.app INSTEAD OF USING THIS SOFTWARE.
//

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"
#import "NSUserDefaults+Soulver.h"

@interface SVRFontManager: NSFontManager
{
  SVRThemeFont _themeFont;
}

-(SVRThemeFont)themeFont;
-(void)setThemeFont:(SVRThemeFont)themeFont;

@end

@interface SVRAccessoryWindowsOwner: NSObject
{
  mm_retain IBOutlet NSPanel  *_keypadPanel;
  mm_retain IBOutlet NSWindow *_aboutWindow;
  mm_retain IBOutlet NSWindow *_settingsWindow;
  mm_new NSArray *_topLevelObjects;
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
-(IBAction)openSourceRepository:(id)sender;

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
