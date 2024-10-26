/* NSUserDefaults+Soulver.m created by me on Sat 12-Oct-2024 */

#import "NSUserDefaults+Soulver.h"

NSString *XPUserDefaultsSavePanelLastDirectory            = @"kSavePanelLastDirectory";
NSString *XPUserDefaultsColorForSolutionPrimary           = @"kColorForSolutionPrimary";
NSString *XPUserDefaultsColorForError                     = @"kColorForError";
NSString *XPUserDefaultsColorForSolutionSecondary         = @"kColorForSolutionSecondary";
NSString *XPUserDefaultsColorForBracket                   = @"kColorForBracket";
NSString *XPUserDefaultsColorForOperator                  = @"kColorForOperator";
NSString *XPUserDefaultsColorForNumeral                   = @"kColorForNumeral";
NSString *XPUserDefaultsColorForText                      = @"kColorForText";
NSString *XPUserDefaultsFontDescriptor                    = @"kFontDescriptor";
NSString *XPUserDefaultsWaitTimeForRendering              = @"kWaitTimeForRendering";
NSString *XPUserDefaultsLegacyDecimalNumberLocale         = @"kLegacyDecimalNumberLocale";

@implementation NSUserDefaults (Soulver)

-(NSString*)SVR_savePanelLastDirectory;
{
  return [self objectForKey:XPUserDefaultsSavePanelLastDirectory];
}

-(BOOL)SVR_setSavePanelLastDirectory:(NSString*)newValue;
{
  [self setObject:newValue forKey:XPUserDefaultsSavePanelLastDirectory];
  return [self synchronize];
}

-(XPColor*)SVR_colorForSolutionPrimary;
{
  return [self objectForKey:XPUserDefaultsColorForSolutionPrimary];
}

-(BOOL)SVR_setColorForSolutionPrimary:(XPColor*)newValue;
{
  [self setObject:newValue forKey:XPUserDefaultsColorForSolutionPrimary];
  return [self synchronize];
}

-(XPColor*)SVR_colorForSolutionSecondary;
{
  return [self objectForKey:XPUserDefaultsColorForSolutionSecondary];
}

-(BOOL)SVR_setColorForSolutionSecondary:(XPColor*)newValue;
{
  [self setObject:newValue forKey:XPUserDefaultsColorForSolutionSecondary];
  return [self synchronize];
}

-(XPColor*)SVR_colorForError;
{
  return [self objectForKey:XPUserDefaultsColorForError];
}

-(BOOL)SVR_setColorForError:(XPColor*)newValue;
{
  if (!newValue) { return NO; }
  [self setObject:newValue forKey:XPUserDefaultsColorForError];
  return [self synchronize];
}

-(XPColor*)SVR_colorForBracket;
{
  return [self objectForKey:XPUserDefaultsColorForBracket];
}

-(BOOL)SVR_setColorForBracket:(XPColor*)newValue;
{
  if (!newValue) { return NO; }
  [self setObject:newValue forKey:XPUserDefaultsColorForBracket];
  return [self synchronize];
}

-(XPColor*)SVR_colorForOperator;
{
  return [self objectForKey:XPUserDefaultsColorForOperator];
}

-(BOOL)SVR_setColorForOperator:(XPColor*)newValue;
{
  [self setObject:newValue forKey:XPUserDefaultsColorForOperator];
  return [self synchronize];
}

-(XPColor*)SVR_colorForNumeral;
{
  return [self objectForKey:XPUserDefaultsColorForNumeral];
}

-(BOOL)SVR_setColorForNumeral:(XPColor*)newValue;
{
  [self setObject:newValue forKey:XPUserDefaultsColorForNumeral];
  return [self synchronize];
}

-(XPColor*)SVR_colorForText;
{
  return [self objectForKey:XPUserDefaultsColorForText];
}

-(BOOL)SVR_setColorForText:(XPColor*)newValue;
{
  [self setObject:newValue forKey:XPUserDefaultsColorForText];
  return [self synchronize];
}

-(NSFont*)SVR_fontForText;
{
  NSData *data = [self dataForKey:XPUserDefaultsFontDescriptor];
  id descriptor = [XPKeyedUnarchiver unarchiveObjectWithData:data];
  NSFont *font = [NSFont XP_fontWithDescriptor:descriptor];
  if (font) {
    return font;
  } else {
    [XPLog debug:@"-[NSFont fontDescriptor]: Not implemented", self];
    return [NSFont userFixedPitchFontOfSize:16];
  }
}
-(BOOL)SVR_setFontForText:(NSFont*)newValue;
{
  id descriptor = [newValue XP_fontDescriptor];
  if (descriptor) {
    NSData *data = [XPKeyedArchiver archivedDataWithRootObject:descriptor];
    [self setObject:data forKey:XPUserDefaultsFontDescriptor];
    return [self synchronize];
  } else {
    [XPLog alwys:@"-[NSFont fontDescriptor]: Not implemented", self];
    return NO;
  }
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

-(void)SVR_configure;
{
  return [self registerDefaults:[NSUserDefaults __SVR_standardDictionary]];
}

+(NSDictionary*)__SVR_standardDictionary;
{
  NSArray *keys;
  NSArray *vals;
  
  keys = [NSArray arrayWithObjects:
          XPUserDefaultsSavePanelLastDirectory,
          XPUserDefaultsColorForSolutionPrimary,
          XPUserDefaultsColorForSolutionSecondary,
          XPUserDefaultsColorForError,
          XPUserDefaultsColorForBracket,
          XPUserDefaultsColorForOperator,
          XPUserDefaultsColorForNumeral,
          XPUserDefaultsColorForText,
          XPUserDefaultsFontDescriptor,
          XPUserDefaultsWaitTimeForRendering,
          XPUserDefaultsLegacyDecimalNumberLocale,
          nil];
  vals = [NSArray arrayWithObjects:
          NSHomeDirectory(),
          [XPColor SVR_colorWithRed:  4/255.0 green: 51/255.0 blue:255/255.0 alpha:1.0],
          [XPColor SVR_colorWithRed:184/255.0 green:197/255.0 blue:255/255.0 alpha:1.0],
          [XPColor SVR_colorWithRed:148/255.0 green: 17/255.0 blue:  0/255.0 alpha:1.0],
          [XPColor SVR_colorWithRed:148/255.0 green: 82/255.0 blue:  0/255.0 alpha:1.0],
          [XPColor SVR_colorWithRed:255/255.0 green:147/255.0 blue:  0/255.0 alpha:1.0],
          [XPColor SVR_colorWithRed:  0/255.0 green:  0/255.0 blue:  0/255.0 alpha:1.0],
          [XPColor SVR_colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0],
          [XPKeyedArchiver archivedDataWithRootObject:[[NSFont userFixedPitchFontOfSize:16] XP_fontDescriptor]],
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
