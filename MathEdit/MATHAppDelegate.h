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
#import "MATHDocument.h"
#import "MATHAccessoryWindowsOwner.h"

#ifdef AFF_FormalProtocolsNone
@interface MATHAppDelegate: NSObject
#else
@interface MATHAppDelegate: NSObject <NSApplicationDelegate>
#endif
{
  // This menus array is because OpenStep does not retain
  // the main menu or the top level menus on its own.
  // I assume this was handled by some magical NIB based
  // memory mangement before. So this will replace that.
  mm_new NSMutableArray *_menus;
  mm_new NSMutableSet *_openDocuments;
  mm_new MATHAccessoryWindowsOwner *_accessoryWindowsOwner;
}

// MARK: Init

+(id)sharedDelegate;
-(id)init;

// MARK: Properties
-(MATHAccessoryWindowsOwner*)accessoryWindowsOwner;

// MARK: IBActions
-(IBAction)toggleKeypadPanel:(id)sender;
-(IBAction)showSettingsWindow:(id)sender;
-(IBAction)showAboutWindow:(id)sender;
-(IBAction)openSourceRepository:(id)sender;
@end

@interface MATHAppDelegate (NSApplicationDelegate)
-(void)applicationWillFinishLaunching:(NSNotification*)aNotification;
-(void)applicationDidFinishLaunching:(NSNotification*)notification;
-(void)applicationWillTerminate:(NSNotification*)aNotification;
@end

@interface MATHAppDelegate (PreDocument)

// MARK: Properties
-(NSMutableSet*)openDocuments;

// MARK: IBActions
-(IBAction)__newDocument:(id)sender;
-(IBAction)__openDocument:(id)sender;

// MARK: Handle Application Events
-(BOOL)__applicationShouldTerminate:(NSApplication *)sender;
-(BOOL)__applicationShouldTerminateAfterReviewingAllDocuments:(NSApplication*)sender;
-(BOOL)__application:(NSApplication *)sender openFile:(NSString *)filename;
-(BOOL)__applicationOpenUntitledFile:(NSApplication*)sender;
-(void)__windowWillCloseNotification:(NSNotification*)aNotification;

// MARK: Pre-NSDocument AppDelegate Methods
#ifdef AFF_NSDocumentNone
-(IBAction)newDocument:(id)sender;
-(IBAction)openDocument:(id)sender;
-(BOOL)applicationShouldTerminate:(NSApplication *)sender;
-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;
-(BOOL)applicationOpenUntitledFile:(NSApplication*)sender;
#endif

@end

@interface MATHAppDelegate (DarkModeObserving)
-(void)beginObservingEffectiveAppearance:(NSApplication*)app;
-(void)endObservingEffectiveAppearance:(NSApplication*)app;
-(void)observeValueForKeyPath:(NSString*)keyPath
                     ofObject:(id)object
                       change:(NSDictionary*)change
                      context:(void*)context;
@end

#ifdef XPSupportsStateRestoration
@interface MATHAppDelegate (StateRestoration) <NSWindowRestoration>
#else
@interface MATHAppDelegate (StateRestoration)
#endif
-(void)applicationDidFinishRestoringWindows:(NSNotification*)aNotification;
-(BOOL)applicationSupportsSecureRestorableState:(NSApplication*)app;
+(void)restoreWindowWithIdentifier:(NSString*)identifier
                             state:(NSCoder*)state
                 completionHandler:(XPWindowRestoreCompletionHandler)completionHandler;
@end

@interface NSMenu (AppDelegate)
+(NSMenu*)MATH_mainMenuWithApp:(NSApplication*)app
                       storage:(NSMutableArray*)storage;
+(void)__buildAppMenuInMainMenu:(NSMenu*)mainMenu
                    application:(NSApplication*)app
                        storage:(NSMutableArray*)storage;
+(void)__buildInfoMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
+(void)__buildFileMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
+(void)__buildEditMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
+(void)__buildViewMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
+(void)__buildWindowsMenuInMainMenu:(NSMenu*)mainMenu
                                app:(NSApplication*)app
                            storage:(NSMutableArray*)storage;
+(void)__buildHelpMenuInMainMenu:(NSMenu*)mainMenu storage:(NSMutableArray*)storage;
+(void)__buildTrailingMenuInMainMenu:(NSMenu*)mainMenu
                                 app:(NSApplication*)app
                             storage:(NSMutableArray*)storage;
@end

@interface NSMenu (CrossPlatform)
-(void)XP_addSeparatorItem;
@end

@interface NSString (MATHMainMenu)
-(NSString*)MATH_stringByAppendingEllipsis;
@end
