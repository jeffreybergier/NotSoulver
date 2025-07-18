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
#import "SVRDocument.h"
#import "SVRAccessoryWindowsOwner.h"

#ifdef XPSupportsFormalProtocols
@interface SVRAppDelegate: NSObject <NSApplicationDelegate>
#else
@interface SVRAppDelegate: NSObject
#endif
{
  // This menus array is because OpenStep does not retain
  // the main menu or the top level menus on its own.
  // I assume this was handled by some magical NIB based
  // memory mangement before. So this will replace that.
  mm_new NSMutableArray *_menus;
  mm_new NSMutableSet *_openDocuments;
  mm_new SVRAccessoryWindowsOwner *_accessoryWindowsOwner;
}

// MARK: Init

+(id)sharedDelegate;
-(id)init;

// MARK: Properties
-(SVRAccessoryWindowsOwner*)accessoryWindowsOwner;

// MARK: IBActions
-(IBAction)toggleKeypadPanel:(id)sender;
-(IBAction)showSettingsWindow:(id)sender;
-(IBAction)showAboutWindow:(id)sender;
-(IBAction)openSourceRepository:(id)sender;
@end

@interface SVRAppDelegate (NSApplicationDelegate)
-(void)applicationWillFinishLaunching:(NSNotification*)aNotification;
-(void)applicationDidFinishLaunching:(NSNotification*)notification;
-(void)applicationWillTerminate:(NSNotification*)aNotification;
@end

@interface SVRAppDelegate (PreDocument)

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

// MARK: Pre-NSDocument Stubs
#if XPSupportsNSDocument == 0
-(IBAction)newDocument:(id)sender;
-(IBAction)openDocument:(id)sender;
-(BOOL)applicationShouldTerminate:(NSApplication *)sender;
-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;
-(BOOL)applicationOpenUntitledFile:(NSApplication*)sender;
#endif

@end

@interface SVRAppDelegate (DarkModeObserving)
-(void)beginObservingEffectiveAppearance:(NSApplication*)app;
-(void)endObservingEffectiveAppearance:(NSApplication*)app;
-(void)observeValueForKeyPath:(NSString*)keyPath
                     ofObject:(id)object
                       change:(NSDictionary*)change
                      context:(void*)context;
@end

#ifdef XPSupportsStateRestoration
@interface SVRAppDelegate (StateRestoration) <NSWindowRestoration>
#else
@interface SVRAppDelegate (StateRestoration)
#endif
-(void)applicationDidFinishRestoringWindows:(NSNotification*)aNotification;
-(BOOL)applicationSupportsSecureRestorableState:(NSApplication*)app;
+(void)restoreWindowWithIdentifier:(NSString*)identifier
                             state:(NSCoder*)state
                 completionHandler:(XPWindowRestoreCompletionHandler)completionHandler;
@end

@interface NSMenu (AppDelegate)
+(NSMenu*)SVR_mainMenuWithApp:(NSApplication*)app
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

@interface NSString (SVRMainMenu)
-(NSString*)SVR_stringByAppendingEllipsis;
@end
