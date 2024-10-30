/* NSUserDefaults+Soulver.m created by me on Sat 12-Oct-2024 */

#import "NSUserDefaults+Soulver.h"

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

NSString *SVRThemeDarkOperandColor               = @"kSVRThemeDarkOperandColorKey";
NSString *SVRThemeDarkOperatorColor              = @"kSVRThemeDarkOperatorColorKey";
NSString *SVRThemeDarkBracketColor               = @"kSVRThemeDarkBracketColorKey";
NSString *SVRThemeDarkSolutionColor              = @"kSVRThemeDarkSolutionColorKey";
NSString *SVRThemeDarkSolutionSecondaryColor     = @"kSVRThemeDarkSolutionSecondaryColorKey";
NSString *SVRThemeDarkErrorTextColor             = @"kSVRThemeDarkErrorTextColorKey";
NSString *SVRThemeDarkOtherTextColor             = @"kSVRThemeDarkOtherTextColorKey";
NSString *SVRThemeDarkBackgroundColor            = @"kSVRThemeDarkBackgroundColorKey";

NSString *SVRThemeOtherTextFont                  = @"kSVRThemeOtherTextFontKey";
NSString *SVRThemeMathTextFont                   = @"kSVRThemeMathTextFontKey";

NSString *SVRThemeUserInterfaceStyle             = @"kSVRThemeUserInterfaceStyleKey";

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
  NSNumber *value = [self objectForKey:XPUserDefaultsWaitTimeForRendering];
  return [value doubleValue];
}

-(BOOL)SVR_setWaitTimeForRendering:(NSTimeInterval)newValue;
{
  NSNumber *value = [NSNumber numberWithDouble:newValue];
  [self setObject:value forKey:XPUserDefaultsWaitTimeForRendering];
  return [self synchronize];
}

-(XPLocale*)SVR_decimalNumberLocale;
{
#if OS_OPENSTEP
  return [self objectForKey:XPUserDefaultsLegacyDecimalNumberLocale];
#else
  return [NSLocale currentLocale];
#endif
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

-(XPUserInterfaceStyle)SVR_userInterfaceStyle;
{
  return (XPUserInterfaceStyle)[self integerForKey:SVRThemeUserInterfaceStyle];
}

-(NSColor*)SVR_colorForTheme:(SVRThemeColor)theme;
{
  return [self SVR_colorForTheme:theme withStyle:[self SVR_userInterfaceStyle]];
}

-(NSColor*)SVR_colorForTheme:(SVRThemeColor)theme
                   withStyle:(XPUserInterfaceStyle)style;
{
  NSColor *output = [self objectForKey:[self __SVR_keyForThemeColor:theme withStyle:style]];
  if (!output) { [XPLog error:@"Color Not Found"]; return nil; }
  return output;
}

-(BOOL)SVR_setColor:(NSColor*)color
           forTheme:(SVRThemeColor)theme
          withStyle:(XPUserInterfaceStyle)style;
{
  [self setObject:color forKey:[self __SVR_keyForThemeColor:theme withStyle:style]];
  return [self synchronize];
}

-(NSFont*)SVR_fontForTheme:(SVRThemeFont)theme;
{
  id descriptor = nil;
  NSFont *font = nil;
  NSData *data = [self dataForKey:[self __SVR_keyForThemeFont:theme]];
  if (!data) { [XPLog error:@"Font Not Found"]; return nil; }
  descriptor = [XPKeyedUnarchiver unarchiveObjectWithData:data];
  font = [NSFont XP_fontWithDescriptor:descriptor];
  if (!font) { [XPLog error:@"Font Not Found"]; return nil; }
  return font;
}

-(BOOL)SVR_setFont:(NSFont*)font
          forTheme:(SVRThemeFont)theme;
{
  id descriptor = [font XP_fontDescriptor];
  NSData *data = [XPKeyedArchiver archivedDataWithRootObject:descriptor];
  [self setObject:data forKey:[self __SVR_keyForThemeFont:theme]];
  return [self synchronize];
}

-(NSString*)__SVR_keyForThemeColor:(SVRThemeColor)theme
                         withStyle:(XPUserInterfaceStyle)style;
{
  switch (style) {
    case XPUserInterfaceStyleDark:
      switch (theme) {
        case SVRThemeColorOperand:           return SVRThemeLightOperandColor;
        case SVRThemeColorOperator:          return SVRThemeLightOperatorColor;
        case SVRThemeColorBracket:           return SVRThemeLightBracketColor;
        case SVRThemeColorSolution:          return SVRThemeLightSolutionColor;
        case SVRThemeColorSolutionSecondary: return SVRThemeLightSolutionSecondaryColor;
        case SVRThemeColorErrorText:         return SVRThemeLightErrorTextColor;
        case SVRThemeColorOtherText:         return SVRThemeLightOtherTextColor;
        case SVRThemeColorBackground:        return SVRThemeLightBackgroundColor;
      }
    case XPUserInterfaceStyleUnspecified:
    case XPUserInterfaceStyleLight:
    default:
      switch (theme) {
        case SVRThemeColorOperand:           return SVRThemeDarkOperandColor;
        case SVRThemeColorOperator:          return SVRThemeDarkOperatorColor;
        case SVRThemeColorBracket:           return SVRThemeDarkBracketColor;
        case SVRThemeColorSolution:          return SVRThemeDarkSolutionColor;
        case SVRThemeColorSolutionSecondary: return SVRThemeDarkSolutionSecondaryColor;
        case SVRThemeColorErrorText:         return SVRThemeDarkErrorTextColor;
        case SVRThemeColorOtherText:         return SVRThemeDarkOtherTextColor;
        case SVRThemeColorBackground:        return SVRThemeDarkBackgroundColor;
      }
  }
  return nil;
}

-(NSString*)__SVR_keyForThemeFont:(SVRThemeFont)theme;
{
  switch (theme) {
    case SVRThemeFontMathText: return SVRThemeMathTextFont;
    case SVRThemeFontOtherText:
    default: return SVRThemeOtherTextFont;
  }
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
          // Dark Theme
          SVRThemeDarkOperandColor,
          SVRThemeDarkOperatorColor,
          SVRThemeDarkBracketColor,
          SVRThemeDarkSolutionColor,
          SVRThemeDarkSolutionSecondaryColor,
          SVRThemeDarkErrorTextColor,
          SVRThemeDarkOtherTextColor,
          SVRThemeDarkBackgroundColor,
          // Fonts
          SVRThemeOtherTextFont,
          SVRThemeMathTextFont,
          // Other
          XPUserDefaultsSavePanelLastDirectory,
          SVRAccessoryWindowKeypadVisibility,
          XPUserDefaultsWaitTimeForRendering,
          XPUserDefaultsLegacyDecimalNumberLocale,
          nil];
  vals = [NSArray arrayWithObjects:
          // Light Theme
          [NSColor colorWithCalibratedRed:  0/255.0 green:  0/255.0 blue:  0/255.0 alpha:1.0],
          [NSColor colorWithCalibratedRed:255/255.0 green:147/255.0 blue:  0/255.0 alpha:1.0],
          [NSColor colorWithCalibratedRed:148/255.0 green: 82/255.0 blue:  0/255.0 alpha:1.0],
          [NSColor colorWithCalibratedRed:  4/255.0 green: 51/255.0 blue:255/255.0 alpha:1.0],
          [NSColor colorWithCalibratedRed:184/255.0 green:197/255.0 blue:255/255.0 alpha:1.0],
          [NSColor colorWithCalibratedRed:148/255.0 green: 17/255.0 blue:  0/255.0 alpha:1.0],
          [NSColor colorWithCalibratedRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0],
          [NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0],
          // Dark Theme
          [NSColor colorWithCalibratedRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0],
          [NSColor colorWithCalibratedRed:255/255.0 green:147/255.0 blue:  0/255.0 alpha:1.0],
          [NSColor colorWithCalibratedRed:255/255.0 green:142/255.0 blue:  0/255.0 alpha:1.0],
          [NSColor colorWithCalibratedRed:118/255.0 green:214/255.0 blue:255/255.0 alpha:1.0],
          [NSColor colorWithCalibratedRed:192/255.0 green:236/255.0 blue:255/255.0 alpha:1.0],
          [NSColor colorWithCalibratedRed:255/255.0 green: 89/255.0 blue: 68/255.0 alpha:1.0],
          [NSColor colorWithCalibratedRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0],
          [NSColor colorWithCalibratedRed:  0/255.0 green:  0/255.0 blue:  0/255.0 alpha:1.0],
          // Fonts
          [XPKeyedArchiver archivedDataWithRootObject:[[NSFont userFontOfSize:16] XP_fontDescriptor]],
          [XPKeyedArchiver archivedDataWithRootObject:[[NSFont userFixedPitchFontOfSize:16] XP_fontDescriptor]],
          // Other
          NSHomeDirectory(),
          [NSNumber numberWithBool:YES],
          [NSNumber numberWithDouble:2.0],
          [self __SVR_legacyDecimalNumberLocale],
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
