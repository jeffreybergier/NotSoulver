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
  return [[_keypadPanel retain] autorelease];
}

-(NSWindow*)aboutWindow;
{
  return [[_aboutWindow retain] autorelease];
}

-(NSWindow*)settingsWindow;
{
  return [[_settingsWindow retain] autorelease];
}

-(NSTextView*)aboutTextView;
{
  return [[_aboutTextView retain] autorelease];
}

// MARK: Init
-(id)init;
{
#ifdef MAC_OS_X_VERSION_10_15
  NSString *nibName = @"AccessoryWindows_X15";
#elif defined(MAC_OS_X_VERSION_10_6)
  NSString *nibName = @"AccessoryWindows_X6";
#elif defined(MAC_OS_X_VERSION_10_2)
  NSString *nibName = @"AccessoryWindows_X2";
#else
  NSString *nibName = @"AccessoryWindows_42";
#endif
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  self = [super init];
  XPParameterRaise(self);
  
  // Load NIB
  _topLevelObjects = nil;
  [[NSBundle mainBundle] XP_loadNibNamed:nibName
                                   owner:self
                         topLevelObjects:&_topLevelObjects];
  [_topLevelObjects retain];
  
  // Restore state on older systems
  [self __legacy_restoreWindowVisibility];
  
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
         selector:@selector(__overrideAppearance:)
             name:SVRThemeDidChangeNotificationName
           object:nil];
  
  return self;
}

-(void)awakeFromNib;
{
  NSWindow *keypadPanel    = [self keypadPanel];
  NSWindow *aboutWindow    = [self aboutWindow];
  NSWindow *settingsWindow = [self settingsWindow];
  NSTextStorage *textStorage = [[self aboutTextView] textStorage];
  
  // Set the about text from the strings file
  [ textStorage beginEditing];
  [[textStorage mutableString] setString:[Localized aboutParagraph]];
  [ textStorage endEditing];

  // Set autosave names
  [keypadPanel        XP_setIdentifier:SVRAccessoryWindowFrameAutosaveNameKeypad  ];
  [aboutWindow        XP_setIdentifier:SVRAccessoryWindowFrameAutosaveNameAbout   ];
  [settingsWindow     XP_setIdentifier:SVRAccessoryWindowFrameAutosaveNameSettings];
  [keypadPanel    setFrameAutosaveName:SVRAccessoryWindowFrameAutosaveNameKeypad  ];
  [aboutWindow    setFrameAutosaveName:SVRAccessoryWindowFrameAutosaveNameAbout   ];
  [settingsWindow setFrameAutosaveName:SVRAccessoryWindowFrameAutosaveNameSettings];
  
  // Set appearance
  [self __overrideAppearance:nil];
  
  // Announce
  XPLogDebug(@"");
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
-(void)__legacy_restoreWindowVisibility;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  
  BOOL keypadVisible    = [ud SVR_visibilityForWindowWithFrameAutosaveName:[[self keypadPanel]    frameAutosaveName]];
  BOOL aboutVisible     = [ud SVR_visibilityForWindowWithFrameAutosaveName:[[self aboutWindow]    frameAutosaveName]];
  BOOL settingsVisible  = [ud SVR_visibilityForWindowWithFrameAutosaveName:[[self settingsWindow] frameAutosaveName]];
  
  if (keypadVisible)   { [self  toggleKeypadPanel:ud]; }
  if (aboutVisible)    { [self    showAboutWindow:ud]; }
  if (settingsVisible) { [self showSettingsWindow:ud]; }
}

// MARK: Notifications (Save window state)

-(void)__windowDidBecomeKey:(NSNotification*)aNotification;
{
  NSWindow *window = [aNotification object];
  if (window != [self keypadPanel] && window != [self aboutWindow] && window != [self settingsWindow]) {
    XPLogExtra1(@"%@ not an AccessoryWindow", window);
    XPLogAssrt1([window isKindOfClass:[NSWindow class]], @"%@ not a window", window);
    return;
  }
  [[NSUserDefaults standardUserDefaults] SVR_setVisibility:YES forWindowWithFrameAutosaveName:[window frameAutosaveName]];
}

-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
{
  NSWindow *window = [aNotification object];
  if (window != [self keypadPanel] && window != [self aboutWindow] && window != [self settingsWindow]) {
    XPLogExtra1(@"%@ not an AccessoryWindow", window);
    XPLogAssrt1([window isKindOfClass:[NSWindow class]], @"%@ not a window", window);
    return;
  }
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
  [_topLevelObjects release];
  _keypadPanel     = nil;
  _aboutWindow     = nil;
  _settingsWindow  = nil;
  _aboutTextView   = nil;
  _topLevelObjects = nil;
  [super dealloc];
}

@end

@implementation SVRAccessoryWindowsOwner (DarkMode)
-(void)__overrideAppearance:(NSNotification*)aNotification;
{
#ifdef XPSupportsDarkMode
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPUserInterfaceStyle style = [ud SVR_userInterfaceStyle];
  NSAppearance *appearance = nil;
  switch (style) {
    case XPUserInterfaceStyleUnspecified:
    case XPUserInterfaceStyleLight:
      appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
      break;
    case XPUserInterfaceStyleDark:
      appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
      break;
  }
  [_keypadPanel setAppearance:appearance];
  [_aboutWindow setAppearance:appearance];
  [_settingsWindow setAppearance:appearance];
#endif
}
@end

@implementation SVRAccessoryWindowsOwner (StateRestoration)
-(void)__restoreWindowWithIdentifier:(NSString*)identifier
                               state:(NSCoder*)state
                   completionHandler:(XPWindowStationCompletionHandler)completionHandler;
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
