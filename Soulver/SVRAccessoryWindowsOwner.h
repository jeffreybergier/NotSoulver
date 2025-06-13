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
#import "SVRAccessoryWindowViews.h"

@class SVRAccessoryWindowsSettingsViewController;

@interface SVRAccessoryWindowsOwner: NSObject
{
  mm_new NSPanel  *_keypadPanel;
  mm_new NSWindow *_aboutWindow;
  mm_new NSWindow *_settingsWindow;
  mm_new SVRAccessoryWindowsSettingsViewController *_settingsViewController;
}

// MARK: Lazy-Loading Properties
-(NSPanel *)keypadPanel;
-(NSWindow*)aboutWindow;
-(NSWindow*)settingsWindow;
-(NSTextView*)aboutTextView;

// MARK: Init
+(void)initialize;
-(id)init;
-(void)loadWindows;

// MARK: IBActions
-(IBAction)toggleKeypadPanel:(id)sender;
-(IBAction)showSettingsWindow:(id)sender;
-(IBAction)showAboutWindow:(id)sender;
-(IBAction)openSourceRepository:(id)sender;

// MARK: Restore Window State
/// Is only effective on systems that do not support state restoration
-(void)legacy_restoreWindowVisibility;

// MARK: Notifications (Save window state)
/// Set the User Defaults to YES for this Window
-(void)__windowDidBecomeKey:(NSNotification*)aNotification;
/// Set the User Defaults to NO for this Window
-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
/// Unsubscribe from Notifications so that windowWillCloseNotification is not called
-(void)__applicationWillTerminate:(NSNotification*)aNotification;

@end

@interface SVRAccessoryWindowsOwner (DarkMode)
-(void)overrideWindowAppearance;
@end

@interface SVRAccessoryWindowsOwner (StateRestoration)
-(void)__restoreWindowWithIdentifier:(NSString*)identifier
                               state:(NSCoder*)state
                   completionHandler:(XPWindowRestoreCompletionHandler)completionHandler;
@end

@interface SVRFontManager: NSFontManager
{
  SVRThemeFont _themeFont;
}

-(SVRThemeFont)themeFont;
-(void)setThemeFont:(SVRThemeFont)themeFont;

@end

@interface SVRAccessoryWindowsSettingsViewController: XPViewController
{
  mm_new NSView *_view_42; // Used only in OpenStep
  mm_retain SVRAccessoryWindowsSettingsGeneralView *_generalView;
  mm_retain SVRAccessoryWindowsSettingsColorsView  *_colorsView;
  mm_retain SVRAccessoryWindowsSettingsFontsView   *_fontsView;
  mm_unretain NSPopUpButton *_settingsBoxSelector;
  mm_unretain NSBox *_settingsBoxParent;
}

// MARK: Init
-(void)loadView;

// MARK: Initial Load
-(void)readSettingsSelection;
-(void)readUserInterfaceStyle;
-(void)readWaitTime;
-(void)readColors;

// MARK: IBActions
-(IBAction)writeSettingsSelection:(NSPopUpButton*)sender;
-(IBAction)writeUserInterfaceStyle:(NSPopUpButton*)sender;
-(IBAction)writeWaitTime:(NSTextField*)sender;
-(IBAction)writeColor:(NSColorWell*)sender;
-(IBAction)presentFontPanel:(NSButton*)sender;
-(IBAction)changeFont:(NSFontManager*)sender;
-(IBAction)reset:(NSButton*)sender;

// MARK: Notifications
-(void)themeDidChangeNotification:(NSNotification*)aNotification;

@end

#ifndef XPSupportsNSViewController
@interface SVRAccessoryWindowsSettingsViewController (CrossPlatform)
-(NSView*)view;
-(void)setView:(NSView*)view;
@end
#endif

NSString *SVR_localizedStringForSettingsSelection(SVRSettingSelection selection);
