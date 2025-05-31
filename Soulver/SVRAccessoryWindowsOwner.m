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

#import "SVRAccessoryWindowsOwner.h"
#import "SVRAccessoryWindowViews.h"

NSString * const SVRAccessoryWindowFrameAutosaveNameSettings = @"kSVRAccessoryWindowFrameAutosaveNameSettings";
NSString * const SVRAccessoryWindowFrameAutosaveNameAbout    = @"kSVRAccessoryWindowFrameAutosaveNameAbout";
NSString * const SVRAccessoryWindowFrameAutosaveNameKeypad   = @"kSVRAccessoryWindowFrameAutosaveNameKeypad";

@implementation SVRFontManager

-(SVRThemeFont)themeFont;
{
  return _themeFont;
}
-(void)setThemeFont:(SVRThemeFont)themeFont;
{
  _themeFont = themeFont;
}

@end

@implementation SVRAccessoryWindowsOwner

// MARK: IBOutlets
-(NSPanel *)keypadPanel;
{
  if (!_windowsLoaded) {
    [self loadWindows];
    XPParameterRaise(_keypadPanel);
  }
  return [[_keypadPanel retain] autorelease];
}

-(NSWindow*)aboutWindow;
{
  if (!_windowsLoaded) {
    [self loadWindows];
    XPParameterRaise(_aboutWindow);
  }
  return [[_aboutWindow retain] autorelease];
}

-(NSWindow*)settingsWindow;
{
  if (!_windowsLoaded) {
    [self loadWindows];
    XPParameterRaise(_settingsWindow);
  }
  return [[_settingsWindow retain] autorelease];
}

-(NSTextView*)aboutTextView;
{
  XPLogRaise(@"No text view");
  return nil;
}

// MARK: Init
-(id)init;
{
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  self = [super init];
  XPParameterRaise(self);
  _windowsLoaded = NO;
  [nc addObserver:self
         selector:@selector(__windowDidBecomeKey:)
             name:NSWindowDidBecomeKeyNotification
           object:nil];
  [nc addObserver:self
         selector:@selector(__windowWillCloseNotification:)
             name:NSWindowWillCloseNotification
           object:nil];
  [nc addObserver:self
         selector:@selector(__applicationWillTerminate:)
             name:NSApplicationWillTerminateNotification
           object:nil];
  [nc addObserver:self
         selector:@selector(overrideWindowAppearance)
             name:SVRThemeDidChangeNotificationName
           object:nil];
  
  return self;
}

-(void)loadWindows;
{
  Class appDelegateClass = [[[NSApplication sharedApplication] delegate] class];
  NSRect keypadRect = NSMakeRect(200, 200, 300, 300);
  NSPanel *keypadPanel = [[NSPanel alloc] initWithContentRect:keypadRect
                                                     styleMask:(NSWindowStyleMaskTitled |
                                                                NSWindowStyleMaskClosable |
                                                                NSWindowStyleMaskUtilityWindow |
                                                                NSWindowStyleMaskHUDWindow)
                                                       backing:NSBackingStoreBuffered
                                                         defer:YES];
  
  XPLogAssrt(!_windowsLoaded, @"Windows Already Loaded");
  _keypadPanel = keypadPanel;
  _windowsLoaded = YES;
  
  [keypadPanel setContentView:[[[SVRAccessoryWindowKeypadView alloc] init] autorelease]];
  [keypadPanel setFrameAutosaveName:@"CCC"];
  [keypadPanel XP_setIdentifier:SVRAccessoryWindowFrameAutosaveNameKeypad];
  [keypadPanel XP_setRestorationClass:appDelegateClass];
  [keypadPanel center];
  
  
  /*
  NSTextStorage *textStorage = [[self aboutTextView] textStorage];
  NSWindow *keypadPanel    = [self keypadPanel];
  NSWindow *aboutWindow    = [self aboutWindow];
  NSWindow *settingsWindow = [self settingsWindow];
  NSRect keypadRect   = [keypadPanel    frame];
  NSRect aboutRect    = [aboutWindow    frame];
  NSRect settingsRect = [settingsWindow frame];
  
  // Set the about text from the strings file
  // TODO: Figure out why the text color does not change in dark mode
  [ textStorage beginEditing];
  [[textStorage mutableString] setString:[Localized aboutParagraph]];
  [ textStorage endEditing];

  // Set autosave names
  [aboutWindow        XP_setIdentifier:SVRAccessoryWindowFrameAutosaveNameAbout   ];
  [settingsWindow     XP_setIdentifier:SVRAccessoryWindowFrameAutosaveNameSettings];
  [aboutWindow    setFrameAutosaveName:SVRAccessoryWindowFrameAutosaveNameAbout   ];
  [settingsWindow setFrameAutosaveName:SVRAccessoryWindowFrameAutosaveNameSettings];
   // Configure Accessory Windows for state restoration
   [[_accessoryWindowsOwner aboutWindow   ] XP_setRestorationClass:myClass];
   [[_accessoryWindowsOwner settingsWindow] XP_setRestorationClass:myClass];
  
  // Setting the frameAutosaveName immediate changes the frame
  // of the window if its been moved already.
  // This code checks if the windows have never been
  // positioned by the user before. If so, it centers them.
  if (NSEqualRects(aboutRect, [aboutWindow frame])) {
    [aboutWindow center];
  }
  if (NSEqualRects(settingsRect, [settingsWindow frame])) {
    [settingsWindow center];
  }
  
  // Set appearance
  [self overrideWindowAppearance];
  
  // Announce
  XPLogDebug(@"");
   */
}

// MARK: IBActions
// Invoked by AppDelegate
-(IBAction)toggleKeypadPanel:(id)sender;
{
  NSPanel *panel = [self keypadPanel];
  if ([panel isVisible]) {
    [panel performClose:sender];
  } else {
    [panel makeKeyAndOrderFront:sender];
  }
}

-(IBAction)showSettingsWindow:(id)sender;
{
  [[self settingsWindow] makeKeyAndOrderFront:sender];
}

-(IBAction)showAboutWindow:(id)sender;
{
  [[self aboutWindow] makeKeyAndOrderFront:sender];
}

-(IBAction)openSourceRepository:(id)sender;
{
  BOOL success = NO;
  XPAlertReturn copyToClipboard = XPAlertReturnError;
  NSPasteboard *pb = [NSPasteboard generalPasteboard];
  NSWorkspace *ws = [NSWorkspace sharedWorkspace];
  NSString *webURLToOpen = [Localized phraseSourceRepositoryURL];
  success = [ws XP_openWebURL:webURLToOpen];
  if (success) { return; }
  NSBeep();
  copyToClipboard = XPRunCopyWebURLToPasteboardAlert(webURLToOpen);
  switch (copyToClipboard) {
    case XPAlertReturnDefault:
      [pb declareTypes:[NSArray arrayWithObject:XPPasteboardTypeString] owner:self];
      success = [pb setString:webURLToOpen forType:XPPasteboardTypeString];
      XPLogAssrt1(success, @"[NSPasteboard setString:%@", webURLToOpen);
      return;
    default:
      XPLogDebug1(@"[Cancelled] [NSPasteboard setString:%@", webURLToOpen);
      return;
  }
}

// MARK: Restore Window State
-(void)legacy_restoreWindowVisibility;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  BOOL keypadVisible    = [ud SVR_visibilityForWindowWithFrameAutosaveName:SVRAccessoryWindowFrameAutosaveNameKeypad  ];
  BOOL aboutVisible     = [ud SVR_visibilityForWindowWithFrameAutosaveName:SVRAccessoryWindowFrameAutosaveNameAbout   ];
  BOOL settingsVisible  = [ud SVR_visibilityForWindowWithFrameAutosaveName:SVRAccessoryWindowFrameAutosaveNameSettings];
  
  if (keypadVisible)   { [self  toggleKeypadPanel:ud]; }
  if (aboutVisible)    { [self    showAboutWindow:ud]; }
  if (settingsVisible) { [self showSettingsWindow:ud]; }
}

// MARK: Notifications (Save window state)

-(void)__windowDidBecomeKey:(NSNotification*)aNotification;
{
  NSWindow *window = [aNotification object];
  BOOL isOwnedWindow = _windowsLoaded && (window == [self keypadPanel]
                                       || window == [self aboutWindow]
                                       || window == [self settingsWindow]);
  XPLogAssrt1([window isKindOfClass:[NSWindow class]], @"%@ not a window", window);
  if (!isOwnedWindow) { XPLogExtra1(@"%@ not an AccessoryWindow", window); return; }
  [[NSUserDefaults standardUserDefaults] SVR_setVisibility:YES forWindowWithFrameAutosaveName:[window frameAutosaveName]];
}

-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
{
  NSWindow *window = [aNotification object];
  BOOL isOwnedWindow = _windowsLoaded && (window == [self keypadPanel]
                                       || window == [self aboutWindow]
                                       || window == [self settingsWindow]);
  XPLogAssrt1([window isKindOfClass:[NSWindow class]], @"%@ not a window", window);
  if (!isOwnedWindow) { XPLogExtra1(@"%@ not an AccessoryWindow", window); return; }
  [[NSUserDefaults standardUserDefaults] SVR_setVisibility:NO forWindowWithFrameAutosaveName:[window frameAutosaveName]];
}

-(void)__applicationWillTerminate:(NSNotification*)aNotification;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
  XPLogDebug1(@"<%@>", XPPointerString(self));
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_keypadPanel     autorelease];
  [_aboutWindow     autorelease];
  [_settingsWindow  autorelease];
  _keypadPanel     = nil;
  _aboutWindow     = nil;
  _settingsWindow  = nil;
  [super dealloc];
}

@end

@implementation SVRAccessoryWindowsOwner (DarkMode)
-(void)overrideWindowAppearance;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPUserInterfaceStyle style = [ud SVR_userInterfaceStyle];
  [_keypadPanel    XP_setAppearanceWithUserInterfaceStyle:style];
  [_aboutWindow    XP_setAppearanceWithUserInterfaceStyle:style];
  [_settingsWindow XP_setAppearanceWithUserInterfaceStyle:style];
}
@end

@implementation SVRAccessoryWindowsOwner (StateRestoration)
-(void)__restoreWindowWithIdentifier:(NSString*)identifier
                               state:(NSCoder*)state
                   completionHandler:(XPWindowRestoreCompletionHandler)completionHandler;
{
  XPLogAssrt1(completionHandler, @"Completion Handler missing for identifier(%@)", identifier);
  if (       [identifier isEqualToString:SVRAccessoryWindowFrameAutosaveNameAbout   ]) {
    completionHandler([self aboutWindow],    nil);
  } else if ([identifier isEqualToString:SVRAccessoryWindowFrameAutosaveNameKeypad  ]) {
    completionHandler([self keypadPanel],    nil);
  } else if ([identifier isEqualToString:SVRAccessoryWindowFrameAutosaveNameSettings]) {
    completionHandler([self settingsWindow], nil);
  } else {
    XPLogAssrt1(NO, @"[UNKNOWN] NSUserInterfaceItemIdentifier(%@)", identifier);
  }
}
@end
