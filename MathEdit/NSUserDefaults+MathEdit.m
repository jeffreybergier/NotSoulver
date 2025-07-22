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

#import "NSUserDefaults+MathEdit.h"

// Implementation in AccessoryWindowsOwner.m
extern NSString * const MATHAccessoryWindowFrameAutosaveNameKeypad;

NSString * const MATHThemeDidChangeNotificationName = @"kMATHThemeDidChangeNotificationNameKey";

NSString *XPUserDefaultsSavePanelLastDirectory      = @"kSavePanelLastDirectory";
NSString *XPUserDefaultsWaitTimeForRendering        = @"kWaitTimeForRendering";

NSString *MATHThemeLightOperandTextColor            = @"kMATHThemeLightOperandTextColor";
NSString *MATHThemeLightOperatorTextColor           = @"kMATHThemeLightOperatorTextColor";
NSString *MATHThemeLight_UNUSED_                    = @"kMATHThemeLight_UNUSED_";
NSString *MATHThemeLightSolutionColor               = @"kMATHThemeLightSolutionColorKey";
NSString *MATHThemeLightSolutionSecondaryColor      = @"kMATHThemeLightSolutionSecondaryColorKey";
NSString *MATHThemeLightErrorTextColor              = @"kMATHThemeLightErrorTextColorKey";
NSString *MATHThemeLightOtherTextColor              = @"kMATHThemeLightOtherTextColorKey";
NSString *MATHThemeLightBackgroundColor             = @"kMATHThemeLightBackgroundColorKey";
NSString *MATHThemeLightInsertionPoint              = @"kMATHThemeLightInsertionPointKey";

NSString *MATHThemeDarkOperandTextColor             = @"kMATHThemeDarkOperandTextColor";
NSString *MATHThemeDarkOperatorTextColor            = @"kMATHThemeDarkOperatorTextColor";
NSString *MATHThemeDark_UNUSED_                     = @"kMATHThemeDark_UNUSED_";
NSString *MATHThemeDarkSolutionColor                = @"kMATHThemeDarkSolutionColorKey";
NSString *MATHThemeDarkSolutionSecondaryColor       = @"kMATHThemeDarkSolutionSecondaryColorKey";
NSString *MATHThemeDarkErrorTextColor               = @"kMATHThemeDarkErrorTextColorKey";
NSString *MATHThemeDarkOtherTextColor               = @"kMATHThemeDarkOtherTextColorKey";
NSString *MATHThemeDarkBackgroundColor              = @"kMATHThemeDarkBackgroundColorKey";
NSString *MATHThemeDarkInsertionPoint               = @"kMATHThemeDarkInsertionPointKey";

NSString *MATHThemeOtherFontKey                     = @"kMATHThemeOtherFontKey";
NSString *MATHThemeMathFontKey                      = @"kMATHThemeMathFontKey";
NSString *MATHThemeErrorFontKey                     = @"kMATHThemeErrorFontKey";

NSString *MATHThemeUserInterfaceStyle               = @"kMATHThemeUserInterfaceStyleKey";
NSString *MATHSettingsSelection                     = @"kMATHSettingsSelectionKey";

@implementation NSUserDefaults (MathEdit)

// MARK: Basics

-(NSString*)MATH_savePanelLastDirectory;
{
  return [self objectForKey:XPUserDefaultsSavePanelLastDirectory];
}

-(BOOL)MATH_setSavePanelLastDirectory:(NSString*)newValue;
{
  [self setObject:newValue forKey:XPUserDefaultsSavePanelLastDirectory];
  return [self synchronize];
}

-(NSTimeInterval)MATH_waitTimeForRendering;
{
  return (NSTimeInterval)[self floatForKey:XPUserDefaultsWaitTimeForRendering];
}

-(BOOL)MATH_setWaitTimeForRendering:(NSTimeInterval)newValue;
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

-(MATHSettingSelection)MATH_settingsSelection;
{
  return (MATHSettingSelection)[self integerForKey:MATHSettingsSelection];
}

-(BOOL)MATH_setSettingsSelection:(MATHSettingSelection)newValue;
{
  [self setInteger:newValue forKey:MATHSettingsSelection];
  return [self synchronize];
}

-(BOOL)MATH_visibilityForWindowWithFrameAutosaveName:(NSString*)frameAutosaveName;
{
#ifdef AFF_StateRestorationNone
  return [self boolForKey:frameAutosaveName];
#else
  return NO;
#endif
}

-(BOOL)MATH_setVisibility:(BOOL)isVisible forWindowWithFrameAutosaveName:(NSString*)frameAutosaveName;
{
#ifdef AFF_StateRestorationNone
  [self setBool:isVisible forKey:frameAutosaveName];
  return [self synchronize];
#else
  return YES;
#endif
}

// MARK: Theming

-(void)__postChangeNotification;
{
  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
  [nc postNotificationName:MATHThemeDidChangeNotificationName
                    object:self];
}

-(XPUserInterfaceStyle)MATH_userInterfaceStyle;
{
#ifdef AFF_UIStyleDarkModeNone
  XPUserInterfaceStyle setting = [self MATH_userInterfaceStyleSetting];
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
#else
  NSAppearance *appearance = [[NSApplication sharedApplication] effectiveAppearance];
  NSArray *names = [NSArray arrayWithObjects:NSAppearanceNameAqua, NSAppearanceNameDarkAqua, nil];
  NSAppearanceName bestMatch = [appearance bestMatchFromAppearancesWithNames:names];
  XPUserInterfaceStyle setting = [self MATH_userInterfaceStyleSetting];
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
#endif
}

-(XPUserInterfaceStyle)MATH_userInterfaceStyleSetting;
{
  return (XPUserInterfaceStyle)[self integerForKey:MATHThemeUserInterfaceStyle];
}

-(BOOL)MATH_setUserInterfaceStyleSetting:(XPUserInterfaceStyle)style;
{
  BOOL success = NO;
  XPUserInterfaceStyle oldStyle = [self MATH_userInterfaceStyleSetting];
  if (oldStyle == style) { return YES; }
  [self setInteger:style forKey:MATHThemeUserInterfaceStyle];
  success = [self synchronize];
  XPLogAssrt(success, @"[FAIL]");
  [self __postChangeNotification];
  return success;
}

-(NSColor*)MATH_colorForTheme:(MATHThemeColor)theme;
{
  return [self MATH_colorForTheme:theme withStyle:[self MATH_userInterfaceStyle]];
}

-(NSColor*)MATH_colorForTheme:(MATHThemeColor)theme
                   withStyle:(XPUserInterfaceStyle)style;
{
  NSData *data = [self objectForKey:[self __MATH_keyForThemeColor:theme withStyle:style]];
  NSColor *output = [NSColor XP_colorWithData:data];
  XPLogAssrt(output, @"Color was NIL");
  return output;
}

-(BOOL)MATH_setColor:(NSColor*)color
           forTheme:(MATHThemeColor)theme
          withStyle:(XPUserInterfaceStyle)style;
{
  BOOL success = NO;
  NSString *key = [self __MATH_keyForThemeColor:theme withStyle:style];
  NSColor *oldColor = [self MATH_colorForTheme:theme withStyle:style];
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

-(NSFont*)MATH_fontForTheme:(MATHThemeFont)theme;
{
  NSData *data = [self dataForKey:[self __MATH_keyForThemeFont:theme]];
  NSFont *font = [NSFont XP_fontWithData:data];
  XPLogAssrt(font, @"Font was NIL");
  return font;
}

-(BOOL)MATH_setFont:(NSFont*)font
           forTheme:(MATHThemeFont)theme;
{
  BOOL success = NO;
  NSString *key = [self __MATH_keyForThemeFont:theme];
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

-(NSString*)__MATH_keyForThemeColor:(MATHThemeColor)theme
                          withStyle:(XPUserInterfaceStyle)style;
{
  switch (style) {
    case XPUserInterfaceStyleDark:
      switch (theme) {
        case MATHThemeColorOperandText:       return MATHThemeDarkOperandTextColor;
        case MATHThemeColorOperatorText:      return MATHThemeDarkOperatorTextColor;
        case MATHThemeColor_UNUSED_:          return MATHThemeDark_UNUSED_;
        case MATHThemeColorSolution:          return MATHThemeDarkSolutionColor;
        case MATHThemeColorSolutionSecondary: return MATHThemeDarkSolutionSecondaryColor;
        case MATHThemeColorErrorText:         return MATHThemeDarkErrorTextColor;
        case MATHThemeColorOtherText:         return MATHThemeDarkOtherTextColor;
        case MATHThemeColorBackground:        return MATHThemeDarkBackgroundColor;
        case MATHThemeColorInsertionPoint:    return MATHThemeDarkInsertionPoint;
      }
    case XPUserInterfaceStyleLight:
    default:
      switch (theme) {
        case MATHThemeColorOperandText:       return MATHThemeLightOperandTextColor;
        case MATHThemeColorOperatorText:      return MATHThemeLightOperatorTextColor;
        case MATHThemeColor_UNUSED_:          return MATHThemeLight_UNUSED_;
        case MATHThemeColorSolution:          return MATHThemeLightSolutionColor;
        case MATHThemeColorSolutionSecondary: return MATHThemeLightSolutionSecondaryColor;
        case MATHThemeColorErrorText:         return MATHThemeLightErrorTextColor;
        case MATHThemeColorOtherText:         return MATHThemeLightOtherTextColor;
        case MATHThemeColorBackground:        return MATHThemeLightBackgroundColor;
        case MATHThemeColorInsertionPoint:    return MATHThemeLightInsertionPoint;
      }
    case XPUserInterfaceStyleUnspecified:
      XPLogAssrt1(NO, @"[FAIL] XPUserInterfaceStyleUnspecified(%d)", (int)style);
  }
  return nil;
}

-(NSString*)__MATH_keyForThemeFont:(MATHThemeFont)theme;
{
  switch (theme) {
    case MATHThemeFontMath:  return MATHThemeMathFontKey;
    case MATHThemeFontError: return MATHThemeErrorFontKey;
    case MATHThemeFontOther: return MATHThemeOtherFontKey;
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] MATHThemeFont(%d)", (int)theme);
      return nil;
  }
  return nil;
}

// MARK: Configuration

-(void)MATH_configure;
{
  [self registerDefaults:[NSUserDefaults __MATH_standardDictionary]];
}

+(NSDictionary*)__MATH_standardDictionary;
{
  NSArray *keys;
  NSArray *vals;
  
  keys = [NSArray arrayWithObjects:
          // Light Theme
          MATHThemeLightOperandTextColor,
          MATHThemeLightOperatorTextColor,
          MATHThemeLight_UNUSED_,
          MATHThemeLightSolutionColor,
          MATHThemeLightSolutionSecondaryColor,
          MATHThemeLightErrorTextColor,
          MATHThemeLightOtherTextColor,
          MATHThemeLightBackgroundColor,
          MATHThemeLightInsertionPoint,
          // Dark Theme
          MATHThemeDarkOperandTextColor,
          MATHThemeDarkOperatorTextColor,
          MATHThemeDark_UNUSED_,
          MATHThemeDarkSolutionColor,
          MATHThemeDarkSolutionSecondaryColor,
          MATHThemeDarkErrorTextColor,
          MATHThemeDarkOtherTextColor,
          MATHThemeDarkBackgroundColor,
          MATHThemeDarkInsertionPoint,
          // Fonts
          MATHThemeOtherFontKey,
          MATHThemeMathFontKey,
          MATHThemeErrorFontKey,
          // Other
          XPUserDefaultsSavePanelLastDirectory,
          MATHThemeUserInterfaceStyle,
          MATHSettingsSelection,
          MATHAccessoryWindowFrameAutosaveNameKeypad,
          XPUserDefaultsWaitTimeForRendering,
          nil];
  vals = [NSArray arrayWithObjects:
          // Light Theme
          [[NSColor colorWithCalibratedRed:  0/255.0 green:  0/255.0 blue:  0/255.0 alpha:1.0] XP_data], // MATHThemeLightOperandColor
          [[NSColor colorWithCalibratedRed:  0/255.0 green:  0/255.0 blue:255/255.0 alpha:1.0] XP_data], // MATHThemeLightOperatorColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:102/255.0 alpha:1.0] XP_data], // MATHThemeLightBracketColor
          [[NSColor colorWithCalibratedRed:166/255.0 green:218/255.0 blue:255/255.0 alpha:1.0] XP_data], // MATHThemeLightSolutionColor
          [[NSColor colorWithCalibratedRed: 45/255.0 green:122/255.0 blue:186/255.0 alpha:1.0] XP_data], // MATHThemeLightSolutionSecondaryColor
          [[NSColor colorWithCalibratedRed:128/255.0 green:  0/255.0 blue:  0/255.0 alpha:1.0] XP_data], // MATHThemeLightErrorTextColor
          [[NSColor colorWithCalibratedRed: 51/255.0 green: 51/255.0 blue: 51/255.0 alpha:1.0] XP_data], // MATHThemeLightOtherTextColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] XP_data], // MATHThemeLightBackgroundColor
          [[NSColor colorWithCalibratedRed:  0/255.0 green:  0/255.0 blue:  0/255.0 alpha:1.0] XP_data], // MATHThemeLightInsertionPoint
          // Dark Theme
          [[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] XP_data], // MATHThemeDarkOperandColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:  0/255.0 blue:255/255.0 alpha:1.0] XP_data], // MATHThemeDarkOperatorColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:102/255.0 alpha:1.0] XP_data], // MATHThemeDarkBracketColor
          [[NSColor colorWithCalibratedRed:161/255.0 green: 64/255.0 blue:161/255.0 alpha:1.0] XP_data], // MATHThemeDarkSolutionColor
          [[NSColor colorWithCalibratedRed:219/255.0 green: 89/255.0 blue:161/255.0 alpha:1.0] XP_data], // MATHThemeDarkSolutionSecondaryColor
          [[NSColor colorWithCalibratedRed:144/255.0 green:  0/255.0 blue:  2/255.0 alpha:1.0] XP_data], // MATHThemeDarkErrorTextColor
          [[NSColor colorWithCalibratedRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0] XP_data], // MATHThemeDarkOtherTextColor
          [[NSColor colorWithCalibratedRed:  0/255.0 green:  0/255.0 blue:  0/255.0 alpha:1.0] XP_data], // MATHThemeDarkBackgroundColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] XP_data], // MATHThemeDarkInsertionPoint
          // Fonts
          [[NSFont userFontOfSize:14] XP_data],           // MATHThemeOtherFont
          [[NSFont userFixedPitchFontOfSize:14] XP_data], // MATHThemeMathFont
          [[NSFont userFontOfSize:14] XP_data],           // MATHThemeErrorFont
          // Other
          NSHomeDirectory(), // XPUserDefaultsSavePanelLastDirectory
          @"0",   // MATHThemeUserInterfaceStyle
          @"0",   // MATHSettingsSelection
          @"YES", // MATHAccessoryWindowKeypadVisibility
          // TODO: Consider changing the default to 0 for "fast" systems
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
