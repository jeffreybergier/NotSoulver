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

#import "MATHAccessoryWindowsOwner.h"

NSString * const MATHAccessoryWindowFrameAutosaveNameSettings = @"kMATHAccessoryWindowFrameAutosaveNameSettings";
NSString * const MATHAccessoryWindowFrameAutosaveNameAbout    = @"kMATHAccessoryWindowFrameAutosaveNameAbout";
NSString * const MATHAccessoryWindowFrameAutosaveNameKeypad   = @"kMATHAccessoryWindowFrameAutosaveNameKeypad";
static NSRect MATHAccessoryWindowKeypadWindowRect   = {{0, 0}, {0, 0}}; // Configured in Initialize
static NSRect MATHAccessoryWindowAboutWindowRect    = {{0, 0}, {480, 320}};
static NSSize MATHAccessoryWindowAboutWindowMaxSize = {480*1.5, 320*1.5};
static NSRect MATHAccessoryWindowSettingsWindowRect = {{0, 0}, {320, 340}}; // Configured in Initialize

@implementation MATHFontManager

-(MATHThemeFont)themeFont;
{
  return _themeFont;
}
-(void)setThemeFont:(MATHThemeFont)themeFont;
{
  _themeFont = themeFont;
}

@end

@implementation MATHAccessoryWindowsOwner

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
  MATHAccessoryWindowKeypadWindowRect = NSMakeRect(0,0,
   (MATHAccessoryWindowKeypadWindowPadding * 2) + (MATHAccessoryWindowKeypadWindowButtonSize.width  * 3) + (MATHAccessoryWindowKeypadWindowButtonHPadding * 2),
   (MATHAccessoryWindowKeypadWindowPadding * 2) + (MATHAccessoryWindowKeypadWindowButtonSize.height * 8) + (MATHAccessoryWindowKeypadWindowButtonVPadding * 7) + (MATHAccessoryWindowKeypadWindowGroupSpacing * 2));
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
  
  // MARK: MATHAccessoryWindowKeypad
  
  window = [[NSPanel alloc] initWithContentRect:MATHAccessoryWindowKeypadWindowRect
                                      styleMask:MATH_windowMaskForKeypadWindow()
                                        backing:NSBackingStoreBuffered
                                          defer:YES];
  _keypadPanel = (NSPanel*)window;
  [window center];
  [window setTitle:[Localized titleKeypad]];
  [window setContentView:[[[MATHAccessoryWindowKeypadView alloc] initWithFrame:MATHAccessoryWindowKeypadWindowRect] autorelease]];
  [window setInitialFirstResponder:[[window contentView] equalButton]];
  [window setFrameAutosaveName:MATHAccessoryWindowFrameAutosaveNameKeypad];
  [window XP_setIdentifier:MATHAccessoryWindowFrameAutosaveNameKeypad];
  [window XP_setRestorationClass:appDelegateClass];
  
  // MARK: MATHAccessoryWindowAbout
  
  window = [[NSWindow alloc] initWithContentRect:MATHAccessoryWindowAboutWindowRect
                                       styleMask:MATH_windowMaskForAboutWindow()
                                         backing:NSBackingStoreBuffered
                                           defer:YES];
  
  _aboutWindow = window;

  [window center];
  [window setTitle:[Localized titleAbout]];
  [window setReleasedWhenClosed:NO];
  [window setMinSize:[NSWindow frameRectForContentRect:MATHAccessoryWindowAboutWindowRect
                                             styleMask:MATH_windowMaskForAboutWindow()].size];
  [window setMaxSize:MATHAccessoryWindowAboutWindowMaxSize];
  [window XP_setCollectionBehavior:XPWindowCollectionBehaviorFullScreenNone];
  [window setContentView:[[[MATHAccessoryWindowAboutView alloc] initWithFrame:MATHAccessoryWindowAboutWindowRect] autorelease]];
  [window setFrameAutosaveName:MATHAccessoryWindowFrameAutosaveNameAbout];
  [window XP_setIdentifier:MATHAccessoryWindowFrameAutosaveNameAbout];
  [window XP_setRestorationClass:appDelegateClass];
  [window setInitialFirstResponder:[[window contentView] viewSourceButton]];
  [[[window contentView] textView] setString:[Localized phraseAboutParagraph]];
  [[[window contentView] viewSourceButton] setAction:@selector(openSourceRepository:)];
  
  // MARK: MATHAccessoryWindowSettings
  
  window = [[NSWindow alloc] initWithContentRect:MATHAccessoryWindowSettingsWindowRect
                                       styleMask:MATH_windowMaskForSettingsWindow()
                                         backing:NSBackingStoreBuffered
                                           defer:YES];
  
  _settingsWindow = window;
  _settingsViewController = [[MATHAccessoryWindowsSettingsViewController alloc] init];

  [window center];
  [window setTitle:[Localized titleSettings]];
  [window setReleasedWhenClosed:NO];
  [window setFrameAutosaveName:MATHAccessoryWindowFrameAutosaveNameSettings];
  [window XP_setIdentifier:MATHAccessoryWindowFrameAutosaveNameSettings];
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
           object:_keypadPanel];
  [nc addObserver:self
         selector:@selector(__windowWillCloseNotification:)
             name:NSWindowWillCloseNotification
           object:_keypadPanel];
  [nc addObserver:self
         selector:@selector(__applicationWillTerminate:)
             name:NSApplicationWillTerminateNotification
           object:nil];
  [nc addObserver:self
         selector:@selector(overrideWindowAppearance)
             name:MATHThemeDidChangeNotificationName
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
  NSWindow *settingsWindow = [self settingsWindow];
  [settingsWindow makeKeyAndOrderFront:sender];
}

-(IBAction)showAboutWindow:(id)sender;
{
  NSWindow *aboutWindow = [self aboutWindow];
  [aboutWindow center];
  [aboutWindow makeKeyAndOrderFront:sender];
}

// MARK: Restore Keypad Visibility
-(void)legacy_restoreWindowVisibility;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  BOOL keypadVisible = [ud MATH_visibilityForWindowWithFrameAutosaveName:MATHAccessoryWindowFrameAutosaveNameKeypad];
  if (keypadVisible) { 
    [self toggleKeypadPanel:ud];
	}
}

// MARK: Notifications (Save window state)

-(void)__windowDidBecomeKey:(NSNotification*)aNotification;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSWindow *window = [aNotification object];
  [ud MATH_setVisibility:YES forWindowWithFrameAutosaveName:[window frameAutosaveName]];
}

-(void)__windowWillCloseNotification:(NSNotification*)aNotification;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSWindow *window = [aNotification object];
  [ud MATH_setVisibility:NO forWindowWithFrameAutosaveName:[window frameAutosaveName]];
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

@implementation MATHAccessoryWindowsOwner (DarkMode)
-(void)overrideWindowAppearance;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPUserInterfaceStyle style = [ud MATH_userInterfaceStyle];
  [_keypadPanel    XP_setAppearanceWithUserInterfaceStyle:style];
  [_aboutWindow    XP_setAppearanceWithUserInterfaceStyle:style];
  [_settingsWindow XP_setAppearanceWithUserInterfaceStyle:style];
}
@end

@implementation MATHAccessoryWindowsOwner (StateRestoration)
-(void)__restoreWindowWithIdentifier:(NSString*)identifier
                               state:(NSCoder*)state
                   completionHandler:(XPWindowRestoreCompletionHandler)completionHandler;
{
  XPLogAssrt1(completionHandler, @"Completion Handler missing for identifier(%@)", identifier);
  if (       [identifier isEqualToString:MATHAccessoryWindowFrameAutosaveNameAbout   ]) {
    completionHandler([self aboutWindow],    nil);
  } else if ([identifier isEqualToString:MATHAccessoryWindowFrameAutosaveNameKeypad  ]) {
    completionHandler([self keypadPanel],    nil);
  } else if ([identifier isEqualToString:MATHAccessoryWindowFrameAutosaveNameSettings]) {
    completionHandler([self settingsWindow], nil);
  } else {
    completionHandler(nil, nil);
    XPLogAssrt1(NO, @"[UNKNOWN] NSUserInterfaceItemIdentifier(%@)", identifier);
  }
}
@end

@implementation MATHAccessoryWindowsSettingsViewController

// MARK: Init
-(void)loadView;
{
  XPFloat kWindowPadding  = 8;
  XPFloat kSelectorHeight = 26;
  NSRect  kContentFrame   = MATHAccessoryWindowSettingsWindowRect;
  NSRect  kSelectorFrame  = NSMakeRect(kWindowPadding,
                                       kContentFrame.size.height-kWindowPadding-kSelectorHeight,
                                       kContentFrame.size.width-kWindowPadding*2,
                                       kSelectorHeight);
  NSRect kBoxFrame = NSMakeRect(kWindowPadding,
                                kWindowPadding,
                                kContentFrame.size.width-kWindowPadding*2,
                                kContentFrame.size.height-kSelectorFrame.size.height-kWindowPadding*2.5);
  NSRect settingViewFrame = NSZeroRect;
  MATHSettingSelection selectionKind = -1;
  
  NSView *contentView = [[[NSView alloc] initWithFrame:kContentFrame] autorelease];
  
  _settingsBoxSelector = [[[NSPopUpButton alloc] initWithFrame:kSelectorFrame pullsDown:NO] autorelease];
  for (selectionKind =MATHSettingSelectionGeneral;
       selectionKind<=MATHSettingSelectionFonts;
       selectionKind++)
  {
    [_settingsBoxSelector addItemWithTitle:MATH_localizedStringForSettingsSelection(selectionKind)];
  }
  [_settingsBoxSelector setAction:@selector(writeSettingsSelection:)];
  [contentView addSubview:_settingsBoxSelector];
  
  _settingsBoxParent = [[[NSBox alloc] initWithFrame:kBoxFrame] autorelease];
  [_settingsBoxParent setTitle:[Localized titleSettings]];
  [_settingsBoxParent setTitlePosition:NSNoTitle];
  [contentView addSubview:_settingsBoxParent];
  
  // These get added to the view in -settingsBoxSelectionChanged:
  settingViewFrame = [[_settingsBoxParent contentView] bounds];
  _generalView = [[MATHAccessoryWindowsSettingsGeneralView alloc] initWithFrame:settingViewFrame];
  _colorsView  = [[MATHAccessoryWindowsSettingsColorsView  alloc] initWithFrame:settingViewFrame];
  _fontsView   = [[MATHAccessoryWindowsSettingsFontsView   alloc] initWithFrame:settingViewFrame];
   
  XPParameterRaise(_settingsBoxSelector);
  XPParameterRaise(_settingsBoxParent);
  XPParameterRaise(_generalView);
  XPParameterRaise(_colorsView);
  XPParameterRaise(_fontsView);
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(themeDidChangeNotification:)
                                               name:MATHThemeDidChangeNotificationName
                                             object:nil];
  
  [self setView:contentView];
  [self readSettingsSelection];
  [self themeDidChangeNotification:nil];
}

// MARK: Initial Load

-(void)readSettingsSelection;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  MATHSettingSelection selectionKind = [ud MATH_settingsSelection];
  XPParameterRaise(_settingsBoxParent);
  switch (selectionKind) {
    case MATHSettingSelectionGeneral:
      [_settingsBoxParent setContentView:_generalView];
      break;
    case MATHSettingSelectionColors:
      [_settingsBoxParent setContentView:_colorsView];
      break;
    case MATHSettingSelectionFonts:
      [_settingsBoxParent setContentView:_fontsView];
      break;
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] MATHSettingSelection(%d)", (int)selectionKind);
  }
  [_settingsBoxSelector selectItemAtIndex:selectionKind];
}

-(void)readUserInterfaceStyle;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPUserInterfaceStyle style = [ud MATH_userInterfaceStyleSetting];
  [[_generalView themeSelector] setSelectedSegment:style];
}

-(void)readWaitTime;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  double delay = [ud MATH_waitTimeForRendering];
  NSString *string = [NSString stringWithFormat:@"%.0f", delay];
  [[_generalView delayLabel] setStringValue:string];
  [[_generalView delaySlider] setDoubleValue:delay];
}

-(void)readColors;
{
  NSUserDefaults  *ud = [NSUserDefaults standardUserDefaults];
  NSColorWell     *well = nil;
  MATHColorWellKind kind = MATHColorWellKindUnknown;
  for (kind =MATHColorWellKindOperandLight;
       kind<=MATHColorWellKindBackgroundDark;
       kind++)
  {
    well = [_colorsView colorWellOfKind:kind];
    switch (kind) {
      case MATHColorWellKindOperandLight:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorOperandText
                                    withStyle:XPUserInterfaceStyleLight]];
        break;
      case MATHColorWellKindOperandDark:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorOperandText
                                    withStyle:XPUserInterfaceStyleDark]];
        break;
      case MATHColorWellKindOperatorLight:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorOperatorText
                                    withStyle:XPUserInterfaceStyleLight]];
        break;
      case MATHColorWellKindOperatorDark:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorOperatorText
                                    withStyle:XPUserInterfaceStyleDark]];
        break;
      case MATHColorWellKindSolutionLight:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorSolution
                                    withStyle:XPUserInterfaceStyleLight]];
        break;
      case MATHColorWellKindSolutionDark:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorSolution
                                    withStyle:XPUserInterfaceStyleDark]];
        break;
      case MATHColorWellKindSolutionSecondaryLight:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorSolutionSecondary
                                    withStyle:XPUserInterfaceStyleLight]];
        break;
      case MATHColorWellKindSolutionSecondaryDark:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorSolutionSecondary
                                    withStyle:XPUserInterfaceStyleDark]];
        break;
      case MATHColorWellKindOtherTextLight:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorOtherText
                                    withStyle:XPUserInterfaceStyleLight]];
        break;
      case MATHColorWellKindOtherTextDark:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorOtherText
                                    withStyle:XPUserInterfaceStyleDark]];
        break;
      case MATHColorWellKindErrorTextLight:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorErrorText
                                    withStyle:XPUserInterfaceStyleLight]];
        break;
      case MATHColorWellKindErrorTextDark:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorErrorText
                                    withStyle:XPUserInterfaceStyleDark]];
        break;
      case MATHColorWellKindInsertionPointLight:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorInsertionPoint
                                    withStyle:XPUserInterfaceStyleLight]];
        break;
      case MATHColorWellKindInsertionPointDark:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorInsertionPoint
                                    withStyle:XPUserInterfaceStyleDark]];
        break;
      case MATHColorWellKindBackgroundLight:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorBackground
                                    withStyle:XPUserInterfaceStyleLight]];
        break;
      case MATHColorWellKindBackgroundDark:
        [well setColor:[ud MATH_colorForTheme:MATHThemeColorBackground
                                    withStyle:XPUserInterfaceStyleDark]];
        break;
      default:
        XPLogAssrt1(NO, @"[UNKNOWN] MATHColorWellKind(%d)", (int)kind);
        break;
    }
  }
}

-(void)readFonts;
{
  NSTextField *field = nil;
  NSFont *font = nil;
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  MATHAccessoryWindowsSettingsFontsView *box = _fontsView;
  MATHThemeFont kind = MATHThemeFontUnknown;
  
  for (kind =MATHThemeFontMath;
       kind<=MATHThemeFontError;
       kind++)
  {
    field = [box textFieldOfKind:kind];
    font = [ud MATH_fontForTheme:kind];
    [field setAttributedStringValue:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %g", [font displayName], [font pointSize]]
                                                                     attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]] autorelease]];
  }
}

// MARK: IBActions

-(IBAction)writeSettingsSelection:(NSPopUpButton*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  MATHSettingSelection newSelection = [sender indexOfSelectedItem];
  switch (newSelection) {
    case MATHSettingSelectionGeneral:
    case MATHSettingSelectionColors:
    case MATHSettingSelectionFonts:
      [ud MATH_setSettingsSelection:newSelection];
      break;
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] MATHSettingSelection(%d)", (int)newSelection);
      break;
  }
  [self readSettingsSelection];
}

-(IBAction)writeUserInterfaceStyle:(XPSegmentedControl*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPUserInterfaceStyle newStyle = [sender selectedSegment];
  switch (newStyle) {
    case XPUserInterfaceStyleUnspecified:
    case XPUserInterfaceStyleLight:
    case XPUserInterfaceStyleDark:
      [ud MATH_setUserInterfaceStyleSetting:newStyle];
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
  XPFloat userTime = rint([sender floatValue]);
  [ud MATH_setWaitTimeForRendering:userTime];
  [self readWaitTime];
}

-(IBAction)writeColor:(NSColorWell*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  MATHColorWellKind kind = MATHColorWellKindUnknown;
  XPParameterRaise(sender);
  kind = [sender tag];
  switch (kind) {
    case MATHColorWellKindOperandLight:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorOperandText
              withStyle:XPUserInterfaceStyleLight];
      break;
    case MATHColorWellKindOperandDark:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorOperandText
              withStyle:XPUserInterfaceStyleDark];
      break;
    case MATHColorWellKindOperatorLight:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorOperatorText
              withStyle:XPUserInterfaceStyleLight];
      break;
    case MATHColorWellKindOperatorDark:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorOperatorText
              withStyle:XPUserInterfaceStyleDark];
      break;
    case MATHColorWellKindSolutionLight:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorSolution
              withStyle:XPUserInterfaceStyleLight];
      break;
    case MATHColorWellKindSolutionDark:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorSolution
              withStyle:XPUserInterfaceStyleDark];
      break;
    case MATHColorWellKindSolutionSecondaryLight:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorSolutionSecondary
              withStyle:XPUserInterfaceStyleLight];
      break;
    case MATHColorWellKindSolutionSecondaryDark:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorSolutionSecondary
              withStyle:XPUserInterfaceStyleDark];
      break;
    case MATHColorWellKindOtherTextLight:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorOtherText
              withStyle:XPUserInterfaceStyleLight];
      break;
    case MATHColorWellKindOtherTextDark:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorOtherText
              withStyle:XPUserInterfaceStyleDark];
      break;
    case MATHColorWellKindErrorTextLight:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorErrorText
              withStyle:XPUserInterfaceStyleLight];
      break;
    case MATHColorWellKindErrorTextDark:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorErrorText
              withStyle:XPUserInterfaceStyleDark];
      break;
    case MATHColorWellKindInsertionPointLight:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorInsertionPoint
              withStyle:XPUserInterfaceStyleLight];
      break;
    case MATHColorWellKindInsertionPointDark:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorInsertionPoint
              withStyle:XPUserInterfaceStyleDark];
      break;
    case MATHColorWellKindBackgroundLight:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorBackground
              withStyle:XPUserInterfaceStyleLight];
      break;
    case MATHColorWellKindBackgroundDark:
      [ud MATH_setColor:[sender color]
               forTheme:MATHThemeColorBackground
              withStyle:XPUserInterfaceStyleDark];
      break;
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] MATHColorWellKind(%d)", (int)kind);
      break;
  }
}

-(IBAction)presentFontPanel:(NSButton*)sender;
{
  MATHThemeFont theme = [sender tag];
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  MATHFontManager *fm = (MATHFontManager*)[NSFontManager sharedFontManager];
  XPLogAssrt1([fm isKindOfClass:[MATHFontManager class]], @"%@ is not MATHFontManager", fm);
  [fm setSelectedFont:[ud MATH_fontForTheme:theme] isMultiple:NO];
  [fm setThemeFont:theme];
  [fm orderFrontFontPanel:sender];
}

-(IBAction)changeFont:(NSFontManager*)sender;
{
  NSFont *font = nil;
  MATHThemeFont theme = -1;
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  XPLogAssrt1([sender isKindOfClass:[MATHFontManager class]], @"[UNKNOWN] %@", sender);
  font = [sender convertFont:[sender selectedFont]];
  theme = [(MATHFontManager*)sender themeFont];
  [ud MATH_setFont:font forTheme:theme];
  [self readFonts];
  XPLogDebug(@"[SUCCESS]");
}

-(IBAction)reset:(NSButton*)sender;
{
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  MATHResetButtonKind kind = -1;
  XPParameterRaise(sender);
  kind = [sender tag];
  switch (kind) {
    case MATHResetButtonKindUIStyle:
      [ud MATH_setUserInterfaceStyleSetting:XPUserInterfaceStyleUnspecified];
      break;
    case MATHResetButtonKindWaitTime:
      [ud MATH_setWaitTimeForRendering:-1];
      [self readWaitTime];
      break;
    case MATHResetButtonKindMathFont:
      [ud MATH_setFont:nil forTheme:MATHThemeFontMath];
      break;
    case MATHResetButtonKindOtherFont:
      [ud MATH_setFont:nil forTheme:MATHThemeFontOther];
      break;
    case MATHResetButtonKindErrorFont:
      [ud MATH_setFont:nil forTheme:MATHThemeFontError];
      break;
    case MATHResetButtonKindOperandColor:
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorOperandText
              withStyle:XPUserInterfaceStyleLight];
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorOperandText
              withStyle:XPUserInterfaceStyleDark];
      break;
    case MATHResetButtonKindOperatorColor:
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorOperatorText
              withStyle:XPUserInterfaceStyleLight];
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorOperatorText
              withStyle:XPUserInterfaceStyleDark];
      break;
    case MATHResetButtonKindSolutionColor:
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorSolution
              withStyle:XPUserInterfaceStyleLight];
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorSolution
              withStyle:XPUserInterfaceStyleDark];
      break;
    case MATHResetButtonKindPreviousSolutionColor:
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorSolutionSecondary
              withStyle:XPUserInterfaceStyleLight];
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorSolutionSecondary
              withStyle:XPUserInterfaceStyleDark];
      break;
    case MATHResetButtonKindOtherTextColor:
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorOtherText
              withStyle:XPUserInterfaceStyleLight];
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorOtherText
              withStyle:XPUserInterfaceStyleDark];
      break;
    case MATHResetButtonKindErrorTextColor:
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorErrorText
              withStyle:XPUserInterfaceStyleLight];
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorErrorText
              withStyle:XPUserInterfaceStyleDark];
      break;
    case MATHResetButtonKindInsertionPointColor:
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorInsertionPoint
              withStyle:XPUserInterfaceStyleLight];
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorInsertionPoint
              withStyle:XPUserInterfaceStyleDark];
      break;
    case MATHResetButtonKindBackgroundColor:
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorBackground
              withStyle:XPUserInterfaceStyleLight];
      [ud MATH_setColor:nil
               forTheme:MATHThemeColorBackground
              withStyle:XPUserInterfaceStyleDark];
      break;
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] MATHResetButtonKind(%d)", (int)kind);
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
@implementation MATHAccessoryWindowsSettingsViewController (CrossPlatform)
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

NSString *MATH_localizedStringForSettingsSelection(MATHSettingSelection selection)
{
  switch (selection) {
    case MATHSettingSelectionGeneral:
      return [Localized titleGeneral];
    case MATHSettingSelectionColors:
      return [Localized titleColors];
    case MATHSettingSelectionFonts:
      return [Localized titleFonts];
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] MATHSettingSelection(%d)", (int)selection);
      return nil;
  }
}

XPWindowStyleMask MATH_windowMaskForKeypadWindow(void)
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
XPWindowStyleMask MATH_windowMaskForSettingsWindow(void)
{
  return XPWindowStyleMaskTitled
       | XPWindowStyleMaskClosable
       | XPWindowStyleMaskMiniaturizable;
}
XPWindowStyleMask MATH_windowMaskForAboutWindow(void)
{
  return XPWindowStyleMaskTitled
       | XPWindowStyleMaskClosable
       | XPWindowStyleMaskResizable
       | XPWindowStyleMaskMiniaturizable;
}
