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

#import "NSUserDefaults+Soulver.h"

// Implementation in AccessoryWindowsOwner.m
extern NSString * const SVRAccessoryWindowFrameAutosaveNameKeypad;

NSString * const SVRThemeDidChangeNotificationName = @"kSVRThemeDidChangeNotificationNameKey";

NSString *XPUserDefaultsSavePanelLastDirectory    = @"kSavePanelLastDirectory";
NSString *XPUserDefaultsWaitTimeForRendering      = @"kWaitTimeForRendering";

NSString *SVRThemeLightOperandTextColor           = @"kSVRThemeLightOperandTextColor";
NSString *SVRThemeLightOperatorTextColor          = @"kSVRThemeLightOperatorTextColor";
NSString *SVRThemeLight_UNUSED_                   = @"kSVRThemeLight_UNUSED_";
NSString *SVRThemeLightSolutionColor              = @"kSVRThemeLightSolutionColorKey";
NSString *SVRThemeLightSolutionSecondaryColor     = @"kSVRThemeLightSolutionSecondaryColorKey";
NSString *SVRThemeLightErrorTextColor             = @"kSVRThemeLightErrorTextColorKey";
NSString *SVRThemeLightOtherTextColor             = @"kSVRThemeLightOtherTextColorKey";
NSString *SVRThemeLightBackgroundColor            = @"kSVRThemeLightBackgroundColorKey";
NSString *SVRThemeLightInsertionPoint             = @"kSVRThemeLightInsertionPointKey";

NSString *SVRThemeDarkOperandTextColor            = @"kSVRThemeDarkOperandTextColor";
NSString *SVRThemeDarkOperatorTextColor           = @"kSVRThemeDarkOperatorTextColor";
NSString *SVRThemeDark_UNUSED_                    = @"kSVRThemeDark_UNUSED_";
NSString *SVRThemeDarkSolutionColor               = @"kSVRThemeDarkSolutionColorKey";
NSString *SVRThemeDarkSolutionSecondaryColor      = @"kSVRThemeDarkSolutionSecondaryColorKey";
NSString *SVRThemeDarkErrorTextColor              = @"kSVRThemeDarkErrorTextColorKey";
NSString *SVRThemeDarkOtherTextColor              = @"kSVRThemeDarkOtherTextColorKey";
NSString *SVRThemeDarkBackgroundColor             = @"kSVRThemeDarkBackgroundColorKey";
NSString *SVRThemeDarkInsertionPoint              = @"kSVRThemeDarkInsertionPointKey";

NSString *SVRThemeOtherFontKey                    = @"kSVRThemeOtherFontKey";
NSString *SVRThemeMathFontKey                     = @"kSVRThemeMathFontKey";
NSString *SVRThemeErrorFontKey                    = @"kSVRThemeErrorFontKey";

NSString *SVRThemeUserInterfaceStyle              = @"kSVRThemeUserInterfaceStyleKey";
NSString *SVRSettingsSelection                    = @"kSVRSettingsSelectionKey";

@implementation NSUserDefaults (Soulver)

// MARK: Basics

-(NSString*)SVR_savePanelLastDirectory;
{
  return [self objectForKey:XPUserDefaultsSavePanelLastDirectory];
}

-(BOOL)SVR_setSavePanelLastDirectory:(NSString*)newValue;
{
  [self setObject:newValue forKey:XPUserDefaultsSavePanelLastDirectory];
  return [self synchronize];
}

-(NSTimeInterval)SVR_waitTimeForRendering;
{
  return (NSTimeInterval)[self floatForKey:XPUserDefaultsWaitTimeForRendering];
}

-(BOOL)SVR_setWaitTimeForRendering:(NSTimeInterval)newValue;
{
  BOOL success = NO;
  if (newValue < 0) {
    [self removeObjectForKey:XPUserDefaultsWaitTimeForRendering];
  } else {
    [self setFloat:(float)newValue forKey:XPUserDefaultsWaitTimeForRendering];
  }
  success = [self synchronize];
  XPLogAssrt(success, @"[FAIL]");
  return success;
}

// MARK: Accessory Window Visibility

-(SVRSettingSelection)SVR_settingsSelection;
{
  return (SVRSettingSelection)[self integerForKey:SVRSettingsSelection];
}

-(BOOL)SVR_setSettingsSelection:(SVRSettingSelection)newValue;
{
  [self setInteger:newValue forKey:SVRSettingsSelection];
  return [self synchronize];
}

-(BOOL)SVR_visibilityForWindowWithFrameAutosaveName:(NSString*)frameAutosaveName;
{
#ifdef XPSupportsStateRestoration
  XPLogDebug(@"[IGNORE] System supports state restoration");
  return NO;
#else
  return [self boolForKey:frameAutosaveName];
#endif
}

-(BOOL)SVR_setVisibility:(BOOL)isVisible forWindowWithFrameAutosaveName:(NSString*)frameAutosaveName;
{
#ifdef XPSupportsStateRestoration
  XPLogDebug(@"[IGNORE] System supports state restoration");
  return YES;
#else
  [self setBool:isVisible forKey:frameAutosaveName];
  return [self synchronize];
#endif
}

// MARK: Theming

-(void)__postChangeNotification;
{
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:SVRThemeDidChangeNotificationName
                    object:self];
}

-(XPUserInterfaceStyle)SVR_userInterfaceStyle;
{
#ifdef XPSupportsDarkMode
  NSAppearance *appearance = [[NSApplication sharedApplication] effectiveAppearance];
  NSArray *names = [NSArray arrayWithObjects:NSAppearanceNameAqua, NSAppearanceNameDarkAqua, nil];
  NSAppearanceName bestMatch = [appearance bestMatchFromAppearancesWithNames:names];
  XPUserInterfaceStyle setting = [self SVR_userInterfaceStyleSetting];
  switch (setting) {
    case XPUserInterfaceStyleUnspecified:
      if ([bestMatch isEqualToString:NSAppearanceNameDarkAqua]) {
        return XPUserInterfaceStyleDark;
      } else {
        return XPUserInterfaceStyleLight;
      }
    case XPUserInterfaceStyleLight:
      return XPUserInterfaceStyleLight;
    case XPUserInterfaceStyleDark:
      return XPUserInterfaceStyleDark;
    default:
      XPLogAssrt1(NO, @"INVALID XPUserInterfaceStyle(%d)", (int)setting);
      return -1;
  }
#else
  XPUserInterfaceStyle setting = [self SVR_userInterfaceStyleSetting];
  switch (setting) {
    case XPUserInterfaceStyleDark:
      return XPUserInterfaceStyleDark;
    case XPUserInterfaceStyleUnspecified:
    case XPUserInterfaceStyleLight:
      return XPUserInterfaceStyleLight;
    default:
      XPLogAssrt1(NO, @"INVALID XPUserInterfaceStyle(%d)", (int)setting);
      return -1;
  }
#endif
}

-(XPUserInterfaceStyle)SVR_userInterfaceStyleSetting;
{
  return (XPUserInterfaceStyle)[self integerForKey:SVRThemeUserInterfaceStyle];
}

-(BOOL)SVR_setUserInterfaceStyleSetting:(XPUserInterfaceStyle)style;
{
  BOOL success = NO;
  XPUserInterfaceStyle oldStyle = [self SVR_userInterfaceStyleSetting];
  if (oldStyle == style) { return YES; }
  [self setInteger:style forKey:SVRThemeUserInterfaceStyle];
  success = [self synchronize];
  XPLogAssrt(success, @"[FAIL]");
  [self __postChangeNotification];
  return success;
}

-(NSColor*)SVR_colorForTheme:(SVRThemeColor)theme;
{
  return [self SVR_colorForTheme:theme withStyle:[self SVR_userInterfaceStyle]];
}

-(NSColor*)SVR_colorForTheme:(SVRThemeColor)theme
                   withStyle:(XPUserInterfaceStyle)style;
{
  NSData *data = [self objectForKey:[self __SVR_keyForThemeColor:theme withStyle:style]];
  NSColor *output = [NSColor XP_colorWithData:data];
  XPLogAssrt(output, @"Color was NIL");
  return output;
}

-(BOOL)SVR_setColor:(NSColor*)color
           forTheme:(SVRThemeColor)theme
          withStyle:(XPUserInterfaceStyle)style;
{
  BOOL success = NO;
  NSString *key = [self __SVR_keyForThemeColor:theme withStyle:style];
  NSColor *oldColor = [self SVR_colorForTheme:theme withStyle:style];
  if ([oldColor isEqual:color]) { return YES; }
  if (color) {
    [self setObject:[color XP_data] forKey:key];
  } else {
    [self removeObjectForKey:key];
  }
  success = [self synchronize];
  [self __postChangeNotification];
  XPLogAssrt(success, @"[FAIL]");
  return success;
}

-(NSFont*)SVR_fontForTheme:(SVRThemeFont)theme;
{
  NSData *data = [self dataForKey:[self __SVR_keyForThemeFont:theme]];
  NSFont *font = [NSFont XP_fontWithData:data];
  XPLogAssrt(font, @"Font was NIL");
  return font;
}

-(BOOL)SVR_setFont:(NSFont*)font
          forTheme:(SVRThemeFont)theme;
{
  BOOL success = NO;
  NSString *key = [self __SVR_keyForThemeFont:theme];
  if (font) {
    [self setObject:[font XP_data] forKey:key];
  } else {
    [self removeObjectForKey:key];
  }
  success = [self synchronize];
  XPLogAssrt(success, @"[FAIL]");
  [self __postChangeNotification];
  return success;
}

-(NSString*)__SVR_keyForThemeColor:(SVRThemeColor)theme
                         withStyle:(XPUserInterfaceStyle)style;
{
  switch (style) {
    case XPUserInterfaceStyleDark:
      switch (theme) {
        case SVRThemeColorOperandText:       return SVRThemeDarkOperandTextColor;
        case SVRThemeColorOperatorText:      return SVRThemeDarkOperatorTextColor;
        case SVRThemeColor_UNUSED_:          return SVRThemeDark_UNUSED_;
        case SVRThemeColorSolution:          return SVRThemeDarkSolutionColor;
        case SVRThemeColorSolutionSecondary: return SVRThemeDarkSolutionSecondaryColor;
        case SVRThemeColorErrorText:         return SVRThemeDarkErrorTextColor;
        case SVRThemeColorOtherText:         return SVRThemeDarkOtherTextColor;
        case SVRThemeColorBackground:        return SVRThemeDarkBackgroundColor;
        case SVRThemeColorInsertionPoint:    return SVRThemeDarkInsertionPoint;
      }
    case XPUserInterfaceStyleLight:
    default:
      switch (theme) {
        case SVRThemeColorOperandText:       return SVRThemeLightOperandTextColor;
        case SVRThemeColorOperatorText:      return SVRThemeLightOperatorTextColor;
        case SVRThemeColor_UNUSED_:          return SVRThemeLight_UNUSED_;
        case SVRThemeColorSolution:          return SVRThemeLightSolutionColor;
        case SVRThemeColorSolutionSecondary: return SVRThemeLightSolutionSecondaryColor;
        case SVRThemeColorErrorText:         return SVRThemeLightErrorTextColor;
        case SVRThemeColorOtherText:         return SVRThemeLightOtherTextColor;
        case SVRThemeColorBackground:        return SVRThemeLightBackgroundColor;
        case SVRThemeColorInsertionPoint:    return SVRThemeLightInsertionPoint;
      }
    case XPUserInterfaceStyleUnspecified:
      XPLogAssrt1(NO, @"[FAIL] XPUserInterfaceStyleUnspecified(%d)", (int)style);
  }
  return nil;
}

-(NSString*)__SVR_keyForThemeFont:(SVRThemeFont)theme;
{
  switch (theme) {
    case SVRThemeFontMath:  return SVRThemeMathFontKey;
    case SVRThemeFontError: return SVRThemeErrorFontKey;
    case SVRThemeFontOther: return SVRThemeOtherFontKey;
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] SVRThemeFont(%d)", (int)theme);
      return nil;
  }
  return nil;
}

// MARK: Configuration

-(void)SVR_configure;
{
  return [self registerDefaults:[NSUserDefaults __SVR_standardDictionary]];
}

+(NSDictionary*)__SVR_standardDictionary;
{
  NSArray *keys;
  NSArray *vals;
  
  keys = [NSArray arrayWithObjects:
          // Light Theme
          SVRThemeLightOperandTextColor,
          SVRThemeLightOperatorTextColor,
          SVRThemeLight_UNUSED_,
          SVRThemeLightSolutionColor,
          SVRThemeLightSolutionSecondaryColor,
          SVRThemeLightErrorTextColor,
          SVRThemeLightOtherTextColor,
          SVRThemeLightBackgroundColor,
          SVRThemeLightInsertionPoint,
          // Dark Theme
          SVRThemeDarkOperandTextColor,
          SVRThemeDarkOperatorTextColor,
          SVRThemeDark_UNUSED_,
          SVRThemeDarkSolutionColor,
          SVRThemeDarkSolutionSecondaryColor,
          SVRThemeDarkErrorTextColor,
          SVRThemeDarkOtherTextColor,
          SVRThemeDarkBackgroundColor,
          SVRThemeDarkInsertionPoint,
          // Fonts
          SVRThemeOtherFontKey,
          SVRThemeMathFontKey,
          SVRThemeErrorFontKey,
          // Other
          XPUserDefaultsSavePanelLastDirectory,
          SVRThemeUserInterfaceStyle,
          SVRSettingsSelection,
          SVRAccessoryWindowFrameAutosaveNameKeypad,
          XPUserDefaultsWaitTimeForRendering,
          nil];
  vals = [NSArray arrayWithObjects:
          // Light Theme
          [[NSColor colorWithCalibratedRed:  0/255.0 green:  0/255.0 blue:  0/255.0 alpha:1.0] XP_data], // SVRThemeLightOperandColor
          [[NSColor colorWithCalibratedRed:  0/255.0 green:  0/255.0 blue:255/255.0 alpha:1.0] XP_data], // SVRThemeLightOperatorColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:102/255.0 alpha:1.0] XP_data], // SVRThemeLightBracketColor
          [[NSColor colorWithCalibratedRed:166/255.0 green:218/255.0 blue:255/255.0 alpha:1.0] XP_data], // SVRThemeLightSolutionColor
          [[NSColor colorWithCalibratedRed: 45/255.0 green:122/255.0 blue:186/255.0 alpha:1.0] XP_data], // SVRThemeLightSolutionSecondaryColor
          [[NSColor colorWithCalibratedRed:128/255.0 green:  0/255.0 blue:  0/255.0 alpha:1.0] XP_data], // SVRThemeLightErrorTextColor
          [[NSColor colorWithCalibratedRed: 51/255.0 green: 51/255.0 blue: 51/255.0 alpha:1.0] XP_data], // SVRThemeLightOtherTextColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] XP_data], // SVRThemeLightBackgroundColor
          [[NSColor colorWithCalibratedRed:  0/255.0 green:  0/255.0 blue:  0/255.0 alpha:1.0] XP_data], // SVRThemeLightInsertionPoint
          // Dark Theme
          [[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] XP_data], // SVRThemeDarkOperandColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:  0/255.0 blue:255/255.0 alpha:1.0] XP_data], // SVRThemeDarkOperatorColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:102/255.0 alpha:1.0] XP_data], // SVRThemeDarkBracketColor
          [[NSColor colorWithCalibratedRed:161/255.0 green: 64/255.0 blue:161/255.0 alpha:1.0] XP_data], // SVRThemeDarkSolutionColor
          [[NSColor colorWithCalibratedRed:219/255.0 green: 89/255.0 blue:161/255.0 alpha:1.0] XP_data], // SVRThemeDarkSolutionSecondaryColor
          [[NSColor colorWithCalibratedRed:144/255.0 green:  0/255.0 blue:  2/255.0 alpha:1.0] XP_data], // SVRThemeDarkErrorTextColor
          [[NSColor colorWithCalibratedRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0] XP_data], // SVRThemeDarkOtherTextColor
          [[NSColor colorWithCalibratedRed:  0/255.0 green:  0/255.0 blue:  0/255.0 alpha:1.0] XP_data], // SVRThemeDarkBackgroundColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] XP_data], // SVRThemeDarkInsertionPoint
          // Fonts
          [[NSFont userFontOfSize:14] XP_data],           // SVRThemeOtherFont
          [[NSFont userFixedPitchFontOfSize:14] XP_data], // SVRThemeMathFont
          [[NSFont userFontOfSize:14] XP_data],           // SVRThemeErrorFont
          // Other
          NSHomeDirectory(), // XPUserDefaultsSavePanelLastDirectory
          @"0",   // SVRThemeUserInterfaceStyle
          @"0",   // SVRSettingsSelection
          @"YES", // SVRAccessoryWindowKeypadVisibility
          @"2.0", // XPUserDefaultsWaitTimeForRendering
          nil];
  
  return [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

@end

@implementation Localized

+(NSString*)titleAppName;
{ return NSLocalizedString(@"NEXT_T_AppName", @""); }
+(NSString*)titleQuit;
{ return NSLocalizedString(@"NEXT_T_Quit", @""); }
+(NSString*)titleUntitled;
{ return NSLocalizedString(@"NEXT_T_Untitled", @""); }
+(NSString*)titleAlert;
{ return NSLocalizedString(@"NEXT_T_Alert", @""); }
+(NSString*)titleClose;
{ return NSLocalizedString(@"NEXT_T_Close", @""); }
+(NSString*)titleAbout;
{ return NSLocalizedString(@"NEXT_T_About", @""); }
+(NSString*)titleKeypad;
{ return NSLocalizedString(@"NEXT_T_Keypad", @""); }
+(NSString*)titleSettings;
{ return NSLocalizedString(@"NEXT_T_Settings", @""); }
+(NSString*)titleGeneral;
{ return NSLocalizedString(@"NEXT_T_General", @""); }
+(NSString*)titleColors;
{ return NSLocalizedString(@"NEXT_T_Colors", @""); }
+(NSString*)titleFonts;
{ return NSLocalizedString(@"NEXT_T_Fonts", @""); }
+(NSString*)titleAutomatic;
{ return NSLocalizedString(@"NEXT_T_Automatic", @""); }
+(NSString*)titleLight;
{ return NSLocalizedString(@"NEXT_T_Light", @""); }
+(NSString*)titleDark;
{ return NSLocalizedString(@"NEXT_T_Dark", @""); }
+(NSString*)titleTheme;
{ return NSLocalizedString(@"NEXT_T_Theme", @""); }
+(NSString*)titleSolvingDelay;
{ return NSLocalizedString(@"NEXT_T_SolvingDelay", @""); }
+(NSString*)titleMathText;
{ return NSLocalizedString(@"NEXT_T_MathText", @""); }
+(NSString*)titleNormalText;
{ return NSLocalizedString(@"NEXT_T_NormalText", @""); }
+(NSString*)titleErrorText;
{ return NSLocalizedString(@"NEXT_T_ErrorText", @""); }
+(NSString*)titleOperand;
{ return NSLocalizedString(@"NEXT_T_Operand", @""); }
+(NSString*)titleOperator;
{ return NSLocalizedString(@"NEXT_T_Operator", @""); }
+(NSString*)titleSolution;
{ return NSLocalizedString(@"NEXT_T_Solution", @""); }
+(NSString*)titleCarryover;
{ return NSLocalizedString(@"NEXT_T_Carryover", @""); }
+(NSString*)titleInsertionPoint;
{ return NSLocalizedString(@"NEXT_T_InsertionPoint", @""); }
+(NSString*)titleBackground;
{ return NSLocalizedString(@"NEXT_T_Background", @""); }
+(NSString*)phraseEditedWindows;
{ return NSLocalizedString(@"NEXT_P_EditedWindows", @""); }
+(NSString*)phraseSaveChangesTo;
{ return NSLocalizedString(@"NEXT_P_SaveChangesTo%@", @""); }
+(NSString*)phraseRevertChangesTo;
{ return NSLocalizedString(@"NEXT_P_RevertChangesTo%@", @""); }
+(NSString*)phraseErrorInvalidCharacter;
{ return NSLocalizedString(@"NEXT_P_ErrorInvalidCharacter%d", @""); }
+(NSString*)phraseErrorMismatchedBrackets;
{ return NSLocalizedString(@"NEXT_P_ErrorMismatchedBrackets%d", @""); }
+(NSString*)phraseErrorMissingOperand;
{ return NSLocalizedString(@"NEXT_P_ErrorMissingOperand%d", @""); }
+(NSString*)phraseErrorDividByZero;
{ return NSLocalizedString(@"NEXT_P_ErrorDividByZero%d", @""); }
+(NSString*)phraseErrorNaN;
{ return NSLocalizedString(@"NEXT_P_ErrorNaN%d", @""); }
+(NSString*)phraseErrorInfinite;
{ return NSLocalizedString(@"NEXT_P_ErrorInfinite%d", @""); }
+(NSString*)phraseErrorImaginary;
{ return NSLocalizedString(@"NEXT_P_ErrorImaginary%d", @""); }
+(NSString*)phraseErrorIndexZero;
{ return NSLocalizedString(@"NEXT_P_ErrorIndexNegative%d", @""); }
+(NSString*)phraseErrorArgumentNegative;
{ return NSLocalizedString(@"NEXT_P_ErrorArgumentNegative%d", @""); }
+(NSString*)phraseErrorBaseNegative;
{ return NSLocalizedString(@"NEXT_P_ErrorBaseNegative%d", @""); }
+(NSString*)phraseErrorBaseOne;
{ return NSLocalizedString(@"NEXT_P_ErrorBaseOne%d", @""); }
+(NSString*)phraseSourceRepositoryURL;
{ return NSLocalizedString(@"NEXT_P_SourceRepositoryURL", @""); }
+(NSString*)phraseCopyWebURLToClipboard;
{ return NSLocalizedString(@"NEXT_P_CopyWebURLToClipboard%@", @""); }
+(NSString*)phraseAboutTagline;
{ return NSLocalizedString(@"NEXT_P_AboutTagline", @""); }
+(NSString*)phraseAboutDedication;
{ return NSLocalizedString(@"NEXT_P_AboutDedication", @""); }
+(NSString*)aboutParagraph;
{ return NSLocalizedString(@"NEXT_P_AboutParagraph", @""); }
+(NSString*)verbSet;
{ return NSLocalizedString(@"NEXT_V_Set", @""); }
+(NSString*)verbReset;
{ return NSLocalizedString(@"NEXT_V_Reset", @""); }
+(NSString*)verbViewSource;
{ return NSLocalizedString(@"NEXT_V_ViewSource", @""); }
+(NSString*)verbReviewUnsaved;
{ return NSLocalizedString(@"NEXT_V_ReviewUnsaved", @""); }
+(NSString*)verbQuitAnyway;
{ return NSLocalizedString(@"NEXT_V_QuitAnyway", @""); }
+(NSString*)verbCancel;
{ return NSLocalizedString(@"NEXT_V_Cancel", @""); }
+(NSString*)verbSave;
{ return NSLocalizedString(@"NEXT_V_Save", @""); }
+(NSString*)verbRevert;
{ return NSLocalizedString(@"NEXT_V_Revert", @""); }
+(NSString*)verbDontSave;
{ return NSLocalizedString(@"NEXT_V_DontSave", @""); }
+(NSString*)verbCopyToClipboard;
{ return NSLocalizedString(@"NEXT_P_CopyToClipboard", @""); }
+(NSString*)verbDontCopy;
{ return NSLocalizedString(@"NEXT_P_DontCopy", @""); }
+(NSString*)imageAboutPortrait;
{ return NSLocalizedString(@"NEXT_M_AboutPortrait", @""); }
+(NSString*)imageNeXTLogo;
{ return NSLocalizedString(@"NEXT_M_NeXTLogo", @""); }
+(NSString*)imageNeXTTagline;
{ return NSLocalizedString(@"NEXT_M_NeXTTagline", @""); }
+(NSString*)imageThemeAuto;
{ return NSLocalizedString(@"NEXT_M_ThemeAuto", @""); }
+(NSString*)imageThemeLight;
{ return NSLocalizedString(@"NEXT_M_ThemeLight", @""); }
+(NSString*)imageThemeDark;
{ return NSLocalizedString(@"NEXT_M_ThemeDark", @""); }
+(NSString*)menuAppAbout;
{ return NSLocalizedString(@"MENU_AppAbout", @""); }
+(NSString*)menuAppSettings;
{ return NSLocalizedString(@"MENU_AppSettings", @""); }
+(NSString*)menuAppServices;
{ return NSLocalizedString(@"MENU_AppServices", @""); }
+(NSString*)menuAppHideSelf;
{ return NSLocalizedString(@"MENU_AppHideSelf", @""); }
+(NSString*)menuAppHideOthers;
{ return NSLocalizedString(@"MENU_AppHideOthers", @""); }
+(NSString*)menuAppShowAll;
{ return NSLocalizedString(@"MENU_AppShowAll", @""); }
+(NSString*)menuAppQuit;
{ return NSLocalizedString(@"MENU_AppQuit", @""); }
+(NSString*)menuAppHideLegacy;
{ return NSLocalizedString(@"MENU_AppHideLegacy", @""); }
+(NSString*)menuAppQuitLegacy;
{ return NSLocalizedString(@"MENU_AppQuitLegacy", @""); }
+(NSString*)menuAppInfoLegacy;
{ return NSLocalizedString(@"MENU_AppInfoLegacy", @""); }
+(NSString*)menuHelp;
{ return NSLocalizedString(@"MENU_Help", @""); }
+(NSString*)menuFile;
{ return NSLocalizedString(@"MENU_File", @""); }
+(NSString*)menuFileNew;
{ return NSLocalizedString(@"MENU_FileNew", @""); }
+(NSString*)menuFileOpen;
{ return NSLocalizedString(@"MENU_FileOpen", @""); }
+(NSString*)menuFileClose;
{ return NSLocalizedString(@"MENU_FileClose", @""); }
+(NSString*)menuFileSave;
{ return NSLocalizedString(@"MENU_FileSave", @""); }
+(NSString*)menuFileSaveAll;
{ return NSLocalizedString(@"MENU_FileSaveAll", @""); }
+(NSString*)menuFileDuplicate;
{ return NSLocalizedString(@"MENU_FileDuplicate", @""); }
+(NSString*)menuFileSaveAs;
{ return NSLocalizedString(@"MENU_FileSaveAs", @""); }
+(NSString*)menuFileRename;
{ return NSLocalizedString(@"MENU_FileRename", @""); }
+(NSString*)menuFileMoveTo;
{ return NSLocalizedString(@"MENU_FileMoveTo", @""); }
+(NSString*)menuFileRevertTo;
{ return NSLocalizedString(@"MENU_FileRevertTo", @""); }
+(NSString*)menuFileLastSavedVersion;
{ return NSLocalizedString(@"MENU_FileLastSavedVersion", @""); }
+(NSString*)menuFileBrowseAllVersions;
{ return NSLocalizedString(@"MENU_FileBrowseAllVersions", @""); }

@end
