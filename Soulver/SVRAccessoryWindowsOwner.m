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
#import "NSUserDefaults+Soulver.h"

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
#ifdef MAC_OS_X_VERSION_10_6
  NSString *nibName = @"AccessoryWindows_X6";
#elif defined(MAC_OS_X_VERSION_10_2)
  NSString *nibName = @"AccessoryWindows_X2";
#else
  NSString *nibName = @"AccessoryWindows_42";
#endif
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  
  self = [super init];
  NSCParameterAssert(self);
  
  _topLevelObjects = nil;
  [[NSBundle mainBundle] XP_loadNibNamed:nibName
                                   owner:self
                         topLevelObjects:&_topLevelObjects];
  [_topLevelObjects retain];
  
  [self __restoreWindowState];
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
  
  return self;
}

-(void)awakeFromNib;
{
  // Set the about text from the strings file
  NSTextStorage *textStorage = [[self aboutTextView] textStorage];
  [ textStorage beginEditing];
  [[textStorage mutableString] setString:[Localized aboutParagraph]];
  [ textStorage endEditing];

  // Set autosave names
  [[self keypadPanel   ] setFrameAutosaveName:SVRAccessoryWindowFrameAutosaveNameKeypad  ];
  [[self aboutWindow   ] setFrameAutosaveName:SVRAccessoryWindowFrameAutosaveNameAbout   ];
  [[self settingsWindow] setFrameAutosaveName:SVRAccessoryWindowFrameAutosaveNameSettings];
  
  // Announce
  XPLogDebug1(@"%@ awakeFromNib", self);
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
  XPLogDebug1(@"[Failed] [NSWorkspace openURL:%@]", webURLToOpen);
  copyToClipboard = XPRunCopyWebURLToPasteboardAlert(webURLToOpen);
  switch (copyToClipboard) {
    case XPAlertReturnDefault:
      [pb declareTypes:[NSArray arrayWithObject:XPPasteboardTypeString] owner:self];
      success = [pb setString:webURLToOpen forType:XPPasteboardTypeString];
      if (success) {
        XPLogDebug1(@"[Success] [NSPasteboard setString:%@", webURLToOpen);
      } else {
        XPLogPause1(@"[Failed] [NSPasteboard setString:%@", webURLToOpen);
      }
      return;
    case XPAlertReturnAlternate:
    case XPAlertReturnOther:
    case XPAlertReturnError:
      XPLogDebug1(@"[Cancelled] [NSPasteboard setString:%@", webURLToOpen);
      return;
  }
}

// MARK: Restore Window State
-(void)__restoreWindowState;
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
  NSCAssert2([window isKindOfClass:[NSWindow class]], @"%@ __windowDidBecomeKey: %@ not NSWindow", self, window);
  if (window != [self keypadPanel] && window != [self aboutWindow] && window != [self settingsWindow]) {
    XPLogDebug2(@"%@ __windowDidBecomeKey: %@ not an AccessoryWindow", self, window);
    return;
  }
  [[NSUserDefaults standardUserDefaults] SVR_setVisibility:YES forWindowWithFrameAutosaveName:[window frameAutosaveName]];
}

-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
{
  NSWindow *window = [aNotification object];
  NSCAssert2([window isKindOfClass:[NSWindow class]], @"%@ __windowWillCloseNotification: %@ not NSWindow", self, window);
  if (window != [self keypadPanel] && window != [self aboutWindow] && window != [self settingsWindow]) {
    XPLogDebug2(@"%@ __windowWillCloseNotification: %@ not an AccessoryWindow", self, window);
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
  XPLogDebug1(@"DEALLOC: %@", self);
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
