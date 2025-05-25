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
  mm_new NSMutableSet *_openDocuments;
  mm_new SVRAccessoryWindowsOwner *_accessoryWindowsOwner;
}

// MARK: Init
-(id)init;

// MARK: Properties
-(SVRAccessoryWindowsOwner*)accessoryWindowsOwner;

// MARK: IBActions
-(IBAction)toggleKeypadPanel:(id)sender;
-(IBAction)showSettingsWindow:(id)sender;
-(IBAction)showAboutWindow:(id)sender;

@end

@interface SVRAppDelegate (NSApplicationDelegate)
-(void)applicationWillFinishLaunching:(NSNotification*)aNotification;
-(void)applicationWillTerminate:(NSNotification *)aNotification;
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
-(BOOL)__applicationOpenUntitledFile:(NSApplication *)sender;
-(void)__windowWillCloseNotification:(NSNotification*)aNotification;

// MARK: Pre-NSDocument Stubs
#if XPSupportsNSDocument == 0
-(IBAction)newDocument:(id)sender;
-(IBAction)openDocument:(id)sender;
-(BOOL)applicationShouldTerminate:(NSApplication *)sender;
-(BOOL)application:(NSApplication *)sender openFile:(NSString *)filename;
-(BOOL)applicationOpenUntitledFile:(NSApplication *)sender;
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
                 completionHandler:(XPWindowStationCompletionHandler)completionHandler;
@end
