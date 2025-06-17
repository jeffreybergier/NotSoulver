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
static NSRect SVRAccessoryWindowKeypadWindowRect   = {{0, 0}, {0, 0}}; // Configured in Initialize
static NSRect SVRAccessoryWindowAboutWindowRect    = {{0, 0}, {480, 320}};
static NSSize SVRAccessoryWindowAboutWindowMaxSize = {480*1.5, 320*1.5};
static NSRect SVRAccessoryWindowSettingsWindowRect = {{0, 0}, {320, 340}}; // Configured in Initialize

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
  if (!_keypadPanel) {
    [self loadWindows];
    XPParameterRaise(_keypadPanel);
  }
  return [[_keypadPanel retain] autorelease];
}

-(NSWindow*)aboutWindow;
{
  if (!_aboutWindow) {
    [self loadWindows];
    XPParameterRaise(_aboutWindow);
  }
  return [[_aboutWindow retain] autorelease];
}

-(NSWindow*)settingsWindow;
{
  if (!_settingsWindow) {
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

+(void)initialize;
{
  SVRAccessoryWindowKeypadWindowRect = NSMakeRect(0,0,
   (SVRAccessoryWindowKeypadWindowPadding * 2) + (SVRAccessoryWindowKeypadWindowButtonSize.width  * 3) + (SVRAccessoryWindowKeypadWindowButtonHPadding * 2),
   (SVRAccessoryWindowKeypadWindowPadding * 2) + (SVRAccessoryWindowKeypadWindowButtonSize.height * 8) + (SVRAccessoryWindowKeypadWindowButtonVPadding * 7) + (SVRAccessoryWindowKeypadWindowGroupSpacing * 2));
}

-(id)init;
{
  self = [super init];
  XPParameterRaise(self);
  _keypadPanel    = nil;
  _aboutWindow    = nil;
  _settingsWindow = nil;
  _settingsViewController = nil;
  return self;
}

-(void)loadWindows;
{
  Class appDelegateClass = [[[NSApplication sharedApplication] delegate] class];
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  NSWindow *window = nil;
  
  // MARK: SVRAccessoryWindowKeypad
  
  window = [[NSPanel alloc] initWithContentRect:SVRAccessoryWindowKeypadWindowRect
                                      styleMask:SVR_windowMaskForKeypadWindow()
                                        backing:NSBackingStoreBuffered
                                          defer:YES];
  _keypadPanel = (NSPanel*)window;
  [window center];
  [window setTitle:[Localized titleKeypad]];
  [window setContentView:[[[SVRAccessoryWindowKeypadView alloc] initWithFrame:SVRAccessoryWindowKeypadWindowRect] autorelease]];
  [window setInitialFirstResponder:[[window contentView] equalButton]];
  [window setFrameAutosaveName:SVRAccessoryWindowFrameAutosaveNameKeypad];
  [window XP_setIdentifier:SVRAccessoryWindowFrameAutosaveNameKeypad];
  [window XP_setRestorationClass:appDelegateClass];
  
  // MARK: SVRAccessoryWindowAbout
  
  window = [[NSWindow alloc] initWithContentRect:SVRAccessoryWindowAboutWindowRect
                                       styleMask:SVR_windowMaskForAboutWindow()
                                         backing:NSBackingStoreBuffered
                                           defer:YES];
  
  _aboutWindow = window;

  [window center];
  [window setTitle:[Localized titleAbout]];
  [window setReleasedWhenClosed:NO];
  [window setMinSize:[NSWindow frameRectForContentRect:SVRAccessoryWindowAboutWindowRect
                                             styleMask:SVR_windowMaskForAboutWindow()].size];
  [window setMaxSize:SVRAccessoryWindowAboutWindowMaxSize];
  [window XP_setCollectionBehavior:XPWindowCollectionBehaviorFullScreenNone];
  [window setContentView:[[[SVRAccessoryWindowAboutView alloc] initWithFrame:SVRAccessoryWindowAboutWindowRect] autorelease]];
  [window setFrameAutosaveName:SVRAccessoryWindowFrameAutosaveNameAbout];
  [window XP_setIdentifier:SVRAccessoryWindowFrameAutosaveNameAbout];
  [window XP_setRestorationClass:appDelegateClass];
//[window setInitialFirstResponder:[[window contentView] viewSourceButton]];
  [[[window contentView] textView] setString:[Localized aboutParagraph]];
  [[[window contentView] viewSourceButton] setTarget:self];
  [[[window contentView] viewSourceButton] setAction:@selector(openSourceRepository:)];
  
  // MARK: SVRAccessoryWindowSettings
  
  window = [[NSWindow alloc] initWithContentRect:SVRAccessoryWindowSettingsWindowRect
                                       styleMask:SVR_windowMaskForSettingsWindow()
                                         backing:NSBackingStoreBuffered
                                           defer:YES];
  
  _settingsWindow = window;
  _settingsViewController = [[SVRAccessoryWindowsSettingsViewController alloc] init];

  [window center];
  [window setTitle:[Localized titleSettings]];
  [window setReleasedWhenClosed:NO];
  [window setFrameAutosaveName:SVRAccessoryWindowFrameAutosaveNameSettings];
  [window XP_setIdentifier:SVRAccessoryWindowFrameAutosaveNameSettings];
  [window XP_setRestorationClass:appDelegateClass];
  [window XP_setContentViewController:_settingsViewController];
  
  XPParameterRaise(_keypadPanel);
  XPParameterRaise(_aboutWindow);
  XPParameterRaise(_settingsWindow);
  XPParameterRaise(_settingsViewController);
  
  // Register for Notifications
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
  
  // Set appearance
  [self overrideWindowAppearance];
  
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
  BOOL isOwnedWindow = window == [self keypadPanel]
                    || window == [self aboutWindow]
                    || window == [self settingsWindow];
  XPLogAssrt1([window isKindOfClass:[NSWindow class]], @"%@ not a window", window);
  if (!isOwnedWindow) { XPLogExtra1(@"%@ not an AccessoryWindow", window); return; }
  [[NSUserDefaults standardUserDefaults] SVR_setVisibility:YES forWindowWithFrameAutosaveName:[window frameAutosaveName]];
}

-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
{
  NSWindow *window = [aNotification object];
  BOOL isOwnedWindow = window == [self keypadPanel]
                    || window == [self aboutWindow]
                    || window == [self settingsWindow];
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
  [_settingsViewController release];
  _keypadPanel     = nil;
  _aboutWindow     = nil;
  _settingsWindow  = nil;
  _settingsViewController = nil;
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

@implementation SVRAccessoryWindowsSettingsViewController

// MARK: Init
-(void)loadView;
{
  XPFloat kWindowPadding  = 8;
  XPFloat kSelectorHeight = 26;
  NSRect  kContentFrame   = SVRAccessoryWindowSettingsWindowRect;
  NSRect  kSelectorFrame  = NSMakeRect(kWindowPadding,
                                       kContentFrame.size.height-kWindowPadding-kSelectorHeight,
                                       kContentFrame.size.width-kWindowPadding*2,
                                       kSelectorHeight);
  NSRect kBoxFrame = NSMakeRect(kWindowPadding,
                                kWindowPadding,
                                kContentFrame.size.width-kWindowPadding*2,
                                kContentFrame.size.height-kSelectorFrame.size.height-kWindowPadding*2.5);
  NSRect settingViewFrame = NSZeroRect;
  SVRSettingSelection selectionKind = -1;
  
  NSView *contentView = [[[NSView alloc] initWithFrame:kContentFrame] autorelease];
  
  _settingsBoxSelector = [[[NSPopUpButton alloc] initWithFrame:kSelectorFrame pullsDown:NO] autorelease];
  for (selectionKind=SVRSettingSelectionGeneral;
       selectionKind<=SVRSettingSelectionFonts;
       selectionKind++)
  {
    [_settingsBoxSelector addItemWithTitle:SVR_localizedStringForSettingsSelection(selectionKind)];
  }
  [_settingsBoxSelector setAction:@selector(writeSettingsSelection:)];
  [contentView addSubview:_settingsBoxSelector];
  
  _settingsBoxParent = [[[NSBox alloc] initWithFrame:kBoxFrame] autorelease];
  [_settingsBoxParent setTitle:[Localized titleSettings]];
  [_settingsBoxParent setTitlePosition:NSNoTitle];
  [contentView addSubview:_settingsBoxParent];
  
  // These get added to the view in -settingsBoxSelectionChanged:
  settingViewFrame = [[_settingsBoxParent contentView] bounds];
  _generalView = [[SVRAccessoryWindowsSettingsGeneralView alloc] initWithFrame:settingViewFrame];
  _colorsView  = [[SVRAccessoryWindowsSettingsColorsView  alloc] initWithFrame:settingViewFrame];
  _fontsView   = [[SVRAccessoryWindowsSettingsFontsView   alloc] initWithFrame:settingViewFrame];
   
  XPParameterRaise(_settingsBoxSelector);
  XPParameterRaise(_settingsBoxParent);
  XPParameterRaise(_generalView);
  XPParameterRaise(_colorsView);
  XPParameterRaise(_fontsView);
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(themeDidChangeNotification:)
                                               name:SVRThemeDidChangeNotificationName
                                             object:nil];
  
  [self setView:contentView];
  [self readSettingsSelection];
  [self themeDidChangeNotification:nil];
}

// MARK: Initial Load

-(void)readSettingsSelection;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  SVRSettingSelection selectionKind = [ud SVR_settingsSelection];
  XPParameterRaise(_settingsBoxParent);
  switch (selectionKind) {
    case SVRSettingSelectionGeneral:
      [_settingsBoxParent setContentView:_generalView];
      break;
    case SVRSettingSelectionColors:
      [_settingsBoxParent setContentView:_colorsView];
      break;
    case SVRSettingSelectionFonts:
      [_settingsBoxParent setContentView:_fontsView];
      break;
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] SVRSettingSelection(%d)", (int)selectionKind);
  }
  [_settingsBoxSelector selectItemAtIndex:selectionKind];
}

-(void)readUserInterfaceStyle;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPUserInterfaceStyle style = [ud SVR_userInterfaceStyleSetting];
  [[_generalView themeSelector] selectItemAtIndex:style];
}

-(void)readWaitTime;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSString *string = [NSString stringWithFormat:@"%g", [ud SVR_waitTimeForRendering]];
  [[_generalView timeField] setStringValue:string];
}

-(void)readColors;
{
  NSUserDefaults  *ud = [NSUserDefaults standardUserDefaults];
  NSColorWell     *well = nil;
  SVRColorWellKind kind = SVRColorWellKindUnknown;
  for (kind =SVRColorWellKindOperandLight;
       kind<=SVRColorWellKindBackgroundDark;
       kind++)
  {
    well = [_colorsView colorWellOfKind:kind];
    switch (kind) {
      case SVRColorWellKindOperandLight:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorOperandText
                                   withStyle:XPUserInterfaceStyleLight]];
        break;
      case SVRColorWellKindOperandDark:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorOperandText
                                   withStyle:XPUserInterfaceStyleDark]];
        break;
      case SVRColorWellKindOperatorLight:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorOperatorText
                                   withStyle:XPUserInterfaceStyleLight]];
        break;
      case SVRColorWellKindOperatorDark:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorOperatorText
                                   withStyle:XPUserInterfaceStyleDark]];
        break;
      case SVRColorWellKindSolutionLight:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorSolution
                                   withStyle:XPUserInterfaceStyleLight]];
        break;
      case SVRColorWellKindSolutionDark:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorSolution
                                   withStyle:XPUserInterfaceStyleDark]];
        break;
      case SVRColorWellKindSolutionSecondaryLight:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorSolutionSecondary
                                   withStyle:XPUserInterfaceStyleLight]];
        break;
      case SVRColorWellKindSolutionSecondaryDark:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorSolutionSecondary
                                   withStyle:XPUserInterfaceStyleDark]];
        break;
      case SVRColorWellKindOtherTextLight:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorOtherText
                                   withStyle:XPUserInterfaceStyleLight]];
        break;
      case SVRColorWellKindOtherTextDark:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorOtherText
                                   withStyle:XPUserInterfaceStyleDark]];
        break;
      case SVRColorWellKindErrorTextLight:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorErrorText
                                   withStyle:XPUserInterfaceStyleLight]];
        break;
      case SVRColorWellKindErrorTextDark:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorErrorText
                                   withStyle:XPUserInterfaceStyleDark]];
        break;
      case SVRColorWellKindInsertionPointLight:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorInsertionPoint
                                   withStyle:XPUserInterfaceStyleLight]];
        break;
      case SVRColorWellKindInsertionPointDark:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorInsertionPoint
                                   withStyle:XPUserInterfaceStyleDark]];
        break;
      case SVRColorWellKindBackgroundLight:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorBackground
                                   withStyle:XPUserInterfaceStyleLight]];
        break;
      case SVRColorWellKindBackgroundDark:
        [well setColor:[ud SVR_colorForTheme:SVRThemeColorBackground
                                   withStyle:XPUserInterfaceStyleDark]];
        break;
      default:
        XPLogAssrt1(NO, @"[UNKNOWN] SVRColorWellKind(%d)", (int)kind);
        break;
    }
  }
}

-(void)readFonts;
{
  NSTextField *field = nil;
  NSFont *font = nil;
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  SVRAccessoryWindowsSettingsFontsView *box = _fontsView;
  SVRThemeFont kind = SVRThemeFontUnknown;
  
  for (kind =SVRThemeFontMath;
       kind<=SVRThemeFontError;
       kind++)
  {
    field = [box textFieldOfKind:kind];
    font = [ud SVR_fontForTheme:kind];
    [field setAttributedStringValue:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %g", [font displayName], [font pointSize]]
                                                                     attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]] autorelease]];
  }
}

// MARK: IBActions

-(IBAction)writeSettingsSelection:(NSPopUpButton*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  SVRSettingSelection newSelection = [sender indexOfSelectedItem];
  switch (newSelection) {
    case SVRSettingSelectionGeneral:
    case SVRSettingSelectionColors:
    case SVRSettingSelectionFonts:
      [ud SVR_setSettingsSelection:newSelection];
      break;
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] SVRSettingSelection(%d)", (int)newSelection);
      break;
  }
  [self readSettingsSelection];
}

-(IBAction)writeUserInterfaceStyle:(NSPopUpButton*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPUserInterfaceStyle newStyle = [sender indexOfSelectedItem];
  switch (newStyle) {
    case XPUserInterfaceStyleUnspecified:
    case XPUserInterfaceStyleLight:
    case XPUserInterfaceStyleDark:
      [ud SVR_setUserInterfaceStyleSetting:newStyle];
      break;
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] XPUserInterfaceStyle(%d)", (int)newStyle);
      break;
  }
  XPLogDebug(@"[SUCCESS]");
}

-(IBAction)writeWaitTime:(NSTextField*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPFloat userTime = [sender floatValue];
  [ud SVR_setWaitTimeForRendering:userTime];
}

-(IBAction)writeColor:(NSColorWell*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  SVRColorWellKind kind = SVRColorWellKindUnknown;
  XPParameterRaise(sender);
  kind = [sender tag];
  switch (kind) {
    case SVRColorWellKindOperandLight:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorOperandText
             withStyle:XPUserInterfaceStyleLight];
      break;
    case SVRColorWellKindOperandDark:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorOperandText
             withStyle:XPUserInterfaceStyleDark];
      break;
    case SVRColorWellKindOperatorLight:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorOperatorText
             withStyle:XPUserInterfaceStyleLight];
      break;
    case SVRColorWellKindOperatorDark:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorOperatorText
             withStyle:XPUserInterfaceStyleDark];
      break;
    case SVRColorWellKindSolutionLight:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorSolution
             withStyle:XPUserInterfaceStyleLight];
      break;
    case SVRColorWellKindSolutionDark:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorSolution
             withStyle:XPUserInterfaceStyleDark];
      break;
    case SVRColorWellKindSolutionSecondaryLight:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorSolutionSecondary
             withStyle:XPUserInterfaceStyleLight];
      break;
    case SVRColorWellKindSolutionSecondaryDark:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorSolutionSecondary
             withStyle:XPUserInterfaceStyleDark];
      break;
    case SVRColorWellKindOtherTextLight:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorOtherText
             withStyle:XPUserInterfaceStyleLight];
      break;
    case SVRColorWellKindOtherTextDark:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorOtherText
             withStyle:XPUserInterfaceStyleDark];
      break;
    case SVRColorWellKindErrorTextLight:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorErrorText
             withStyle:XPUserInterfaceStyleLight];
      break;
    case SVRColorWellKindErrorTextDark:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorErrorText
             withStyle:XPUserInterfaceStyleDark];
      break;
    case SVRColorWellKindInsertionPointLight:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorInsertionPoint
             withStyle:XPUserInterfaceStyleLight];
      break;
    case SVRColorWellKindInsertionPointDark:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorInsertionPoint
             withStyle:XPUserInterfaceStyleDark];
      break;
    case SVRColorWellKindBackgroundLight:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorBackground
             withStyle:XPUserInterfaceStyleLight];
      break;
    case SVRColorWellKindBackgroundDark:
      [ud SVR_setColor:[sender color]
              forTheme:SVRThemeColorBackground
             withStyle:XPUserInterfaceStyleDark];
      break;
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] SVRColorWellKind(%d)", (int)kind);
      break;
  }
}

-(IBAction)presentFontPanel:(NSButton*)sender;
{
  SVRThemeFont theme = [sender tag];
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  SVRFontManager *fm = (SVRFontManager*)[NSFontManager sharedFontManager];
  XPLogAssrt1([fm isKindOfClass:[SVRFontManager class]], @"%@ is not SVRFontManager", fm);
  [fm setSelectedFont:[ud SVR_fontForTheme:theme] isMultiple:NO];
  [fm setThemeFont:theme];
  [fm orderFrontFontPanel:sender];
}

-(IBAction)changeFont:(NSFontManager*)sender;
{
  NSFont *font = nil;
  SVRThemeFont theme = -1;
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPLogAssrt1([sender isKindOfClass:[SVRFontManager class]], @"[UNKNOWN] %@", sender);
  font = [sender convertFont:[sender selectedFont]];
  theme = [(SVRFontManager*)sender themeFont];
  [ud SVR_setFont:font forTheme:theme];
  [self readFonts];
  XPLogDebug(@"[SUCCESS]");
}

-(IBAction)reset:(NSButton*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  SVRResetButtonKind kind = -1;
  XPParameterRaise(sender);
  kind = [sender tag];
  switch (kind) {
    case   SVRResetButtonKindUIStyle:
      [ud SVR_setUserInterfaceStyleSetting:XPUserInterfaceStyleUnspecified];
      break;
    case SVRResetButtonKindWaitTime:
      [ud SVR_setWaitTimeForRendering:-1];
      break;
    case SVRResetButtonKindMathFont:
      [ud SVR_setFont:nil forTheme:SVRThemeFontMath];
      break;
    case SVRResetButtonKindOtherFont:
      [ud SVR_setFont:nil forTheme:SVRThemeFontOther];
      break;
    case SVRResetButtonKindErrorFont:
      [ud SVR_setFont:nil forTheme:SVRThemeFontError];
      break;
    case SVRResetButtonKindOperandColor:
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorOperandText
             withStyle:XPUserInterfaceStyleLight];
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorOperandText
             withStyle:XPUserInterfaceStyleDark];
      break;
    case SVRResetButtonKindOperatorColor:
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorOperatorText
             withStyle:XPUserInterfaceStyleLight];
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorOperatorText
             withStyle:XPUserInterfaceStyleDark];
      break;
    case SVRResetButtonKindSolutionColor:
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorSolution
             withStyle:XPUserInterfaceStyleLight];
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorSolution
             withStyle:XPUserInterfaceStyleDark];
      break;
    case SVRResetButtonKindPreviousSolutionColor:
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorSolutionSecondary
             withStyle:XPUserInterfaceStyleLight];
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorSolutionSecondary
             withStyle:XPUserInterfaceStyleDark];
      break;
    case SVRResetButtonKindOtherTextColor:
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorOtherText
             withStyle:XPUserInterfaceStyleLight];
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorOtherText
             withStyle:XPUserInterfaceStyleDark];
      break;
    case SVRResetButtonKindErrorTextColor:
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorErrorText
             withStyle:XPUserInterfaceStyleLight];
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorErrorText
             withStyle:XPUserInterfaceStyleDark];
      break;
    case SVRResetButtonKindInsertionPointColor:
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorInsertionPoint
             withStyle:XPUserInterfaceStyleLight];
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorInsertionPoint
             withStyle:XPUserInterfaceStyleDark];
      break;
    case SVRResetButtonKindBackgroundColor:
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorBackground
             withStyle:XPUserInterfaceStyleLight];
      [ud SVR_setColor:nil
              forTheme:SVRThemeColorBackground
             withStyle:XPUserInterfaceStyleDark];
      break;
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] SVRResetButtonKind(%d)", (int)kind);
      break;
  }
}

// MARK: Notifications

-(void)themeDidChangeNotification:(NSNotification*)aNotification;
{
  [self readUserInterfaceStyle];
  [self readWaitTime];
  [self readColors];
  [self readFonts];
}

-(void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [_view_42     release];
  [_fontsView   release];
  [_colorsView  release];
  [_generalView release];
  _view_42     = nil;
  _fontsView   = nil;
  _colorsView  = nil;
  _generalView = nil;
  _settingsBoxParent = nil;
  _settingsBoxSelector = nil;
  [super dealloc];
}

@end

#ifndef XPSupportsNSViewController
@implementation SVRAccessoryWindowsSettingsViewController (CrossPlatform)
-(NSView*)view;
{
  if (!_view_42) {
    [self loadView];
    XPParameterRaise(_view_42);
  }
  return [[_view_42 retain] autorelease];
}

-(void)setView:(NSView*)view;
{
  XPParameterRaise(view);
  [_view_42 release];
  _view_42 = [view retain];
}
@end
#endif

NSString *SVR_localizedStringForSettingsSelection(SVRSettingSelection selection)
{
  switch (selection) {
    case SVRSettingSelectionGeneral:
      return [Localized titleGeneral];
    case SVRSettingSelectionColors:
      return [Localized titleColors];
    case SVRSettingSelectionFonts:
      return [Localized titleFonts];
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] SVRSettingSelection(%d)", (int)selection);
      return nil;
  }
}

XPWindowStyleMask SVR_windowMaskForKeypadWindow(void)
{
  XPWindowStyleMask mask = XPWindowStyleMaskTitled | XPWindowStyleMaskClosable;
#ifdef XPSupportsTexturedWindows
  mask |= NSTexturedBackgroundWindowMask;
#endif
#ifdef XPSupportsUtilityWindows
  mask |= XPWindowStyleMaskUtilityWindow;
#endif
  return mask;
}
XPWindowStyleMask SVR_windowMaskForSettingsWindow(void)
{
  return XPWindowStyleMaskTitled
       | XPWindowStyleMaskClosable
       | XPWindowStyleMaskMiniaturizable;
}
XPWindowStyleMask SVR_windowMaskForAboutWindow(void)
{
  return XPWindowStyleMaskTitled
       | XPWindowStyleMaskClosable
       | XPWindowStyleMaskResizable
       | XPWindowStyleMaskMiniaturizable;
}
