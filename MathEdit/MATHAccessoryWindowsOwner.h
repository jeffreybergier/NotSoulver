//
// GPLv3 License Notice
//
// Copyright (c) 2025 Jeffrey Bergier
//
// This file is part of MathEdit.
// MathEdit is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
// MathEdit is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with MathEdit. If not, see <https://www.gnu.org/licenses/>.
//

#import <AppKit/AppKit.h>
#import "XPCrossPlatform.h"
#import "NSUserDefaults+MathEdit.h"
#import "MATHAccessoryWindowViews.h"

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
-(IBAction)writeUserInterfaceStyle:(XPSegmentedControl*)sender;
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

NSString *MATH_localizedStringForSettingsSelection(SVRSettingSelection selection);
XPWindowStyleMask MATH_windowMaskForKeypadWindow(void);
XPWindowStyleMask MATH_windowMaskForSettingsWindow(void);
XPWindowStyleMask MATH_windowMaskForAboutWindow(void);
