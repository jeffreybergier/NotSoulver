/* NSUserDefaults+Soulver.m created by me on Sat 12-Oct-2024 */

#import "NSUserDefaults+Soulver.h"

NSString * const SVRThemeDidChangeNotificationName = @"kSVRThemeDidChangeNotificationNameKey";

NSString *XPUserDefaultsSavePanelLastDirectory    = @"kSavePanelLastDirectory";
NSString *XPUserDefaultsWaitTimeForRendering      = @"kWaitTimeForRendering";
NSString *XPUserDefaultsLegacyDecimalNumberLocale = @"kLegacyDecimalNumberLocale";

NSString *SVRAccessoryWindowSettingsFrame         = @"kSVRAccessoryWindowSettingsFrameKey";
NSString *SVRAccessoryWindowAboutFrame            = @"kSVRAccessoryWindowAboutFrameKey";
NSString *SVRAccessoryWindowKeypadFrame           = @"kSVRAccessoryWindowKeypadFrameKey";
NSString *SVRAccessoryWindowSettingsVisibility    = @"kSVRAccessoryWindowSettingsVisibilityKey";
NSString *SVRAccessoryWindowAboutVisibility       = @"kSVRAccessoryWindowAboutVisibilityKey";
NSString *SVRAccessoryWindowKeypadVisibility      = @"kSVRAccessoryWindowKeypadVisibilityKey";

NSString *SVRThemeLightOperandColor               = @"kSVRThemeLightOperandColorKey";
NSString *SVRThemeLightOperatorColor              = @"kSVRThemeLightOperatorColorKey";
NSString *SVRThemeLightBracketColor               = @"kSVRThemeLightBracketColorKey";
NSString *SVRThemeLightSolutionColor              = @"kSVRThemeLightSolutionColorKey";
NSString *SVRThemeLightSolutionSecondaryColor     = @"kSVRThemeLightSolutionSecondaryColorKey";
NSString *SVRThemeLightErrorTextColor             = @"kSVRThemeLightErrorTextColorKey";
NSString *SVRThemeLightOtherTextColor             = @"kSVRThemeLightOtherTextColorKey";
NSString *SVRThemeLightBackgroundColor            = @"kSVRThemeLightBackgroundColorKey";
NSString *SVRThemeLightInsertionPoint             = @"kSVRThemeLightInsertionPointKey";

NSString *SVRThemeDarkOperandColor                = @"kSVRThemeDarkOperandColorKey";
NSString *SVRThemeDarkOperatorColor               = @"kSVRThemeDarkOperatorColorKey";
NSString *SVRThemeDarkBracketColor                = @"kSVRThemeDarkBracketColorKey";
NSString *SVRThemeDarkSolutionColor               = @"kSVRThemeDarkSolutionColorKey";
NSString *SVRThemeDarkSolutionSecondaryColor      = @"kSVRThemeDarkSolutionSecondaryColorKey";
NSString *SVRThemeDarkErrorTextColor              = @"kSVRThemeDarkErrorTextColorKey";
NSString *SVRThemeDarkOtherTextColor              = @"kSVRThemeDarkOtherTextColorKey";
NSString *SVRThemeDarkBackgroundColor             = @"kSVRThemeDarkBackgroundColorKey";
NSString *SVRThemeDarkInsertionPoint              = @"kSVRThemeDarkInsertionPointKey";

NSString *SVRThemeOtherFont                       = @"kSVRThemeOtherFontKey";
NSString *SVRThemeMathFont                        = @"kSVRThemeMathFontKey";
NSString *SVRThemeErrorFont                       = @"kSVRThemeErrorFontKey";

NSString *SVRThemeUserInterfaceStyle              = @"kSVRThemeUserInterfaceStyleKey";

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
  if (newValue < 0) {
    [self removeObjectForKey:XPUserDefaultsWaitTimeForRendering];
  } else {
    [self setFloat:(float)newValue forKey:XPUserDefaultsWaitTimeForRendering];
  }
  return [self synchronize];
}

-(XPLocale*)SVR_decimalNumberLocale;
{
  Class Locale = NSClassFromString(@"NSLocale");
  if (Locale) {
    return [Locale currentLocale];
  } else {
    return [self objectForKey:XPUserDefaultsLegacyDecimalNumberLocale];
  }
}

// MARK: Accessory Window Visibility

+(NSString*)SVR_frameKeyForWindow:(SVRAccessoryWindow)window;
{
  switch (window) {
    case SVRAccessoryWindowSettings: return SVRAccessoryWindowSettingsFrame;
    case SVRAccessoryWindowAbout:    return SVRAccessoryWindowAboutFrame;
    case SVRAccessoryWindowKeypad:   return SVRAccessoryWindowKeypadFrame;
    case SVRAccessoryWindowNone:     return nil;
  }
  return nil;
}

-(BOOL)SVR_visibilityForWindow:(SVRAccessoryWindow)window;
{
  switch (window) {
    case SVRAccessoryWindowSettings: return [self boolForKey:SVRAccessoryWindowSettingsVisibility];
    case SVRAccessoryWindowAbout:    return [self boolForKey:SVRAccessoryWindowAboutVisibility];
    case SVRAccessoryWindowKeypad:   return [self boolForKey:SVRAccessoryWindowKeypadVisibility];
    case SVRAccessoryWindowNone:     return NO;
  }
  return NO;
}

-(BOOL)SVR_setVisibility:(BOOL)isVisible forWindow:(SVRAccessoryWindow)window;
{
  switch (window) {
    case SVRAccessoryWindowSettings:
      [self setBool:isVisible forKey:SVRAccessoryWindowSettingsVisibility];
      break;
    case SVRAccessoryWindowAbout:
      [self setBool:isVisible forKey:SVRAccessoryWindowAboutVisibility];
      break;
    case SVRAccessoryWindowKeypad:
      [self setBool:isVisible forKey:SVRAccessoryWindowKeypadVisibility];
      break;
    case SVRAccessoryWindowNone:
      break;
  }
  return [self synchronize];
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
  return (XPUserInterfaceStyle)[self integerForKey:SVRThemeUserInterfaceStyle];
}

-(BOOL)SVR_setUserInterfaceStyle:(XPUserInterfaceStyle)style;
{
  BOOL success = NO;
  XPUserInterfaceStyle oldStyle = [self SVR_userInterfaceStyle];
  if (oldStyle == style) { return YES; }
  [self setInteger:style forKey:SVRThemeUserInterfaceStyle];
  success = [self synchronize];
  if (success) { [self __postChangeNotification]; }
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
  if (!output) { [XPLog error:@"Color Not Found"]; return nil; }
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
  if (success) { [self __postChangeNotification]; }
  return success;
}

-(NSFont*)SVR_fontForTheme:(SVRThemeFont)theme;
{
  NSData *data = [self dataForKey:[self __SVR_keyForThemeFont:theme]];
  NSFont *font = [NSFont XP_fontWithData:data];
  if (!font) { [XPLog error:@"Font Not Found"]; return nil; }
  return font;
}

-(BOOL)SVR_setFont:(NSFont*)font
          forTheme:(SVRThemeFont)theme;
{
  BOOL success = NO;
  NSString *key = [self __SVR_keyForThemeFont:theme];
  NSFont *oldFont = [self SVR_fontForTheme:theme];
  if ([oldFont isEqual:font]) { return YES; }
  if (font) {
    [self setObject:[font XP_data] forKey:key];
  } else {
    [self removeObjectForKey:key];
  }
  success = [self synchronize];
  if (success) { [self __postChangeNotification]; }
  return success;
}

-(NSString*)__SVR_keyForThemeColor:(SVRThemeColor)theme
                         withStyle:(XPUserInterfaceStyle)style;
{
  switch (style) {
    case XPUserInterfaceStyleDark:
      switch (theme) {
        case SVRThemeColorOperand:           return SVRThemeDarkOperandColor;
        case SVRThemeColorOperator:          return SVRThemeDarkOperatorColor;
        case SVRThemeColorBracket:           return SVRThemeDarkBracketColor;
        case SVRThemeColorSolution:          return SVRThemeDarkSolutionColor;
        case SVRThemeColorSolutionSecondary: return SVRThemeDarkSolutionSecondaryColor;
        case SVRThemeColorErrorText:         return SVRThemeDarkErrorTextColor;
        case SVRThemeColorOtherText:         return SVRThemeDarkOtherTextColor;
        case SVRThemeColorBackground:        return SVRThemeDarkBackgroundColor;
        case SVRThemeColorInsertionPoint:    return SVRThemeDarkInsertionPoint;
      }
    case XPUserInterfaceStyleUnspecified:
    case XPUserInterfaceStyleLight:
    default:
      switch (theme) {
        case SVRThemeColorOperand:           return SVRThemeLightOperandColor;
        case SVRThemeColorOperator:          return SVRThemeLightOperatorColor;
        case SVRThemeColorBracket:           return SVRThemeLightBracketColor;
        case SVRThemeColorSolution:          return SVRThemeLightSolutionColor;
        case SVRThemeColorSolutionSecondary: return SVRThemeLightSolutionSecondaryColor;
        case SVRThemeColorErrorText:         return SVRThemeLightErrorTextColor;
        case SVRThemeColorOtherText:         return SVRThemeLightOtherTextColor;
        case SVRThemeColorBackground:        return SVRThemeLightBackgroundColor;
        case SVRThemeColorInsertionPoint:    return SVRThemeLightInsertionPoint;
      }
  }
  return nil;
}

-(NSString*)__SVR_keyForThemeFont:(SVRThemeFont)theme;
{
  switch (theme) {
    case SVRThemeFontMath:  return SVRThemeMathFont;
    case SVRThemeFontError: return SVRThemeErrorFont;
    case SVRThemeFontOther: return SVRThemeOtherFont;
  }
  return nil;
}

// MARK: Configuration

-(void)SVR_configure;
{
  return [self registerDefaults:[NSUserDefaults __SVR_standardDictionary]];
}

// TODO: Add colors for all of the themes
+(NSDictionary*)__SVR_standardDictionary;
{
  NSArray *keys;
  NSArray *vals;
  
  keys = [NSArray arrayWithObjects:
          // Light Theme
          SVRThemeLightOperandColor,
          SVRThemeLightOperatorColor,
          SVRThemeLightBracketColor,
          SVRThemeLightSolutionColor,
          SVRThemeLightSolutionSecondaryColor,
          SVRThemeLightErrorTextColor,
          SVRThemeLightOtherTextColor,
          SVRThemeLightBackgroundColor,
          SVRThemeLightInsertionPoint,
          // Dark Theme
          SVRThemeDarkOperandColor,
          SVRThemeDarkOperatorColor,
          SVRThemeDarkBracketColor,
          SVRThemeDarkSolutionColor,
          SVRThemeDarkSolutionSecondaryColor,
          SVRThemeDarkErrorTextColor,
          SVRThemeDarkOtherTextColor,
          SVRThemeDarkBackgroundColor,
          SVRThemeDarkInsertionPoint,
          // Fonts
          SVRThemeOtherFont,
          SVRThemeMathFont,
          SVRThemeErrorFont,
          // Other
          XPUserDefaultsSavePanelLastDirectory,
          SVRThemeUserInterfaceStyle,
          SVRAccessoryWindowKeypadVisibility,
          XPUserDefaultsWaitTimeForRendering,
          XPUserDefaultsLegacyDecimalNumberLocale,
          nil];
  vals = [NSArray arrayWithObjects:
          // Light Theme
          [[NSColor colorWithCalibratedRed:  0/255.0 green:  0/255.0 blue:  0/255.0 alpha:1.0] XP_data], // SVRThemeLightOperandColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:147/255.0 blue:  0/255.0 alpha:1.0] XP_data], // SVRThemeLightOperatorColor
          [[NSColor colorWithCalibratedRed:148/255.0 green: 82/255.0 blue:  0/255.0 alpha:1.0] XP_data], // SVRThemeLightBracketColor
          [[NSColor colorWithCalibratedRed:  4/255.0 green: 51/255.0 blue:255/255.0 alpha:1.0] XP_data], // SVRThemeLightSolutionColor
          [[NSColor colorWithCalibratedRed:184/255.0 green:197/255.0 blue:255/255.0 alpha:1.0] XP_data], // SVRThemeLightSolutionSecondaryColor
          [[NSColor colorWithCalibratedRed:148/255.0 green: 17/255.0 blue:  0/255.0 alpha:1.0] XP_data], // SVRThemeLightErrorTextColor
          [[NSColor colorWithCalibratedRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0] XP_data], // SVRThemeLightOtherTextColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] XP_data], // SVRThemeLightBackgroundColor
          [[NSColor colorWithCalibratedRed:  0/255.0 green:  0/255.0 blue:  0/255.0 alpha:1.0] XP_data], // SVRThemeLightInsertionPoint
          // Dark Theme
          [[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] XP_data], // SVRThemeDarkOperandColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:147/255.0 blue:  0/255.0 alpha:1.0] XP_data], // SVRThemeDarkOperatorColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:142/255.0 blue:  0/255.0 alpha:1.0] XP_data], // SVRThemeDarkBracketColor
          [[NSColor colorWithCalibratedRed:  4/255.0 green: 51/255.0 blue:255/255.0 alpha:1.0] XP_data], // SVRThemeDarkSolutionColor
          [[NSColor colorWithCalibratedRed:192/255.0 green:236/255.0 blue:255/255.0 alpha:1.0] XP_data], // SVRThemeDarkSolutionSecondaryColor
          [[NSColor colorWithCalibratedRed:148/255.0 green: 17/255.0 blue:  0/255.0 alpha:1.0] XP_data], // SVRThemeDarkErrorTextColor
          [[NSColor colorWithCalibratedRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0] XP_data], // SVRThemeDarkOtherTextColor
          [[NSColor colorWithCalibratedRed:  0/255.0 green:  0/255.0 blue:  0/255.0 alpha:1.0] XP_data], // SVRThemeDarkBackgroundColor
          [[NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] XP_data], // SVRThemeDarkInsertionPoint
          // Fonts
          [[NSFont userFontOfSize:12] XP_data],           // SVRThemeOtherFont
          [[NSFont userFixedPitchFontOfSize:12] XP_data], // SVRThemeMathFont
          [[NSFont userFixedPitchFontOfSize:12] XP_data], // SVRThemeErrorFont
          // Other
          NSHomeDirectory(), // XPUserDefaultsSavePanelLastDirectory
          @"0",   // SVRThemeUserInterfaceStyle
          @"YES", // SVRAccessoryWindowKeypadVisibility
          @"2.0", // XPUserDefaultsWaitTimeForRendering
          [self __SVR_legacyDecimalNumberLocale], // XPUserDefaultsLegacyDecimalNumberLocale
          nil];
  
  return [NSDictionary dictionaryWithObjects:vals forKeys:keys];
}

+(NSDictionary*)__SVR_legacyDecimalNumberLocale;
{
  NSArray *keys   = [NSArray arrayWithObjects:@"kCFLocaleDecimalSeparatorKey", @"NSDecimalSeparator", nil];
  NSArray *values = [NSArray arrayWithObjects:@".", @".", nil];
  return [[[NSDictionary alloc] initWithObjects:values forKeys:keys] autorelease];
}

@end
