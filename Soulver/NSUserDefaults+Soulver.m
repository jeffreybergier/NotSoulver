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
  [self registerDefaults:[NSUserDefaults __SVR_standardDictionary]];
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

@implementation LocalizedProxy: NSProxy
+(LocalizedProxy*)sharedProxy;
{
  static LocalizedProxy *sharedInstance = nil;
#ifdef AFF_ObjCNoDispatch
  if (sharedInstance == nil) {
    sharedInstance = [LocalizedProxy alloc];
  }
#else
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [LocalizedProxy alloc];
  });
#endif
  XPParameterRaise(sharedInstance);
  return sharedInstance;
}
-(NSMethodSignature*)methodSignatureForSelector:(SEL)sel;
{
  return [NSMethodSignature signatureWithObjCTypes:"@@:"];
}
-(void)forwardInvocation:(NSInvocation*)invocation;
{
  SEL sel = [invocation selector];
  NSString *key = NSStringFromSelector(sel);
  NSString *value = NSLocalizedString(key, @"");
  XPParameterRaise(value);
  [invocation setReturnValue:&value];
}
@end
