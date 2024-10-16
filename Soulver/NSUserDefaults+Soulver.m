/* NSUserDefaults+Soulver.m created by me on Sat 12-Oct-2024 */

#import "NSUserDefaults+Soulver.h"

NSString *XPUserDefaultsSavePanelLastDirectory            = @"kSavePanelLastDirectory";
NSString *XPUserDefaultsColorForSolutionPrimary           = @"kColorForSolutionPrimary";
NSString *XPUserDefaultsBackgroundColorForSolutionPrimary = @"kBackgroundColorForSolutionPrimary";
NSString *XPUserDefaultsColorForSolutionSecondary         = @"kColorForSolutionSecondary";
NSString *XPUserDefaultsColorForOperator                  = @"kColorForOperator";
NSString *XPUserDefaultsColorForNumeral                   = @"kColorForNumeral";
NSString *XPUserDefaultsColorForText                      = @"kColorForText";
NSString *XPUserDefaultsNumberErrorMismatchedBrackets     = @"kNumberErrorMismatchedBrackets";
NSString *XPUserDefaultsNumberErrorInvalidCharacter       = @"kNumberErrorInvalidCharacter";
NSString *XPUserDefaultsNumberErrorMissingNumber          = @"kNumberErrorMissingNumber";
NSString *XPUserDefaultsNumberErrorPatching               = @"kNumberErrorPatching";
NSString *XPUserDefaultsLegacyDecimalNumberLocale         = @"kLegacyDecimalNumberLocale";

@implementation NSUserDefaults (Soulver)

-(NSString*)SVR_savePanelLastDirectory;
{
  return [self objectForKey:XPUserDefaultsSavePanelLastDirectory];
}

-(BOOL)SVR_setSavePanelLastDirectory:(NSString*)newValue;
{
  if (!newValue) { return NO; }
  [self setObject:newValue forKey:XPUserDefaultsSavePanelLastDirectory];
  return [self synchronize];
}

-(XPColor*)SVR_colorForSolutionPrimary;
{
  return [self objectForKey:XPUserDefaultsColorForSolutionPrimary];
}

-(BOOL)SVR_setColorForSolutionPrimary:(XPColor*)newValue;
{
  if (!newValue) { return NO; }
  [self setObject:newValue forKey:XPUserDefaultsColorForSolutionPrimary];
  return [self synchronize];
}

-(XPColor*)SVR_backgroundColorForSolutionPrimary;
{
  return [self objectForKey:XPUserDefaultsBackgroundColorForSolutionPrimary];
}

-(BOOL)SVR_setBackgroundColorForSolutionPrimary:(XPColor*)newValue;
{
  if (!newValue) { return NO; }
  [self setObject:newValue forKey:XPUserDefaultsBackgroundColorForSolutionPrimary];
  return [self synchronize];
}

-(XPColor*)SVR_colorForSolutionSecondary;
{
  return [self objectForKey:XPUserDefaultsColorForSolutionSecondary];
}

-(BOOL)SVR_setColorForSolutionSecondary:(XPColor*)newValue;
{
  if (!newValue) { return NO; }
  [self setObject:newValue forKey:XPUserDefaultsColorForSolutionSecondary];
  return [self synchronize];
}

-(XPColor*)SVR_colorForBracket;
{
  // TODO: Make separate color for brackets
  return [self objectForKey:XPUserDefaultsColorForOperator];
}

-(BOOL)SVR_setColorForBracket:(XPColor*)newValue;
{
  if (!newValue) { return NO; }
  [self setObject:newValue forKey:XPUserDefaultsColorForOperator];
  return [self synchronize];
}

-(XPColor*)SVR_colorForOperator;
{
  return [self objectForKey:XPUserDefaultsColorForOperator];
}

-(BOOL)SVR_setColorForOperator:(XPColor*)newValue;
{
  if (!newValue) { return NO; }
  [self setObject:newValue forKey:XPUserDefaultsColorForOperator];
  return [self synchronize];
}

-(XPColor*)SVR_colorForNumeral;
{
  return [self objectForKey:XPUserDefaultsColorForNumeral];
}

-(BOOL)SVR_setColorForNumeral:(XPColor*)newValue;
{
  if (!newValue) { return NO; }
  [self setObject:newValue forKey:XPUserDefaultsColorForNumeral];
  return [self synchronize];
}

-(XPColor*)SVR_colorForText;
{
  return [self objectForKey:XPUserDefaultsColorForText];
}

-(BOOL)SVR_setColorForText:(XPColor*)newValue;
{
  if (!newValue) { return NO; }
  [self setObject:newValue forKey:XPUserDefaultsColorForText];
  return [self synchronize];
}

-(NSFont*)SVR_fontForText;
{
  return [NSFont userFixedPitchFontOfSize:16];
}
-(BOOL)SVR_setFontForText:(NSFont*)newValue;
{
  if (!newValue) { return NO; }
  [XPLog error:@"NSUnimplemented"];
  return NO;
}

-(NSNumber*)SVR_errorMismatchedBrackets;
{
  return [self objectForKey:XPUserDefaultsNumberErrorMismatchedBrackets];
}

-(NSNumber*)SVR_errorInvalidCharacter;
{
  return [self objectForKey:XPUserDefaultsNumberErrorInvalidCharacter];
}

-(NSNumber*)SVR_errorMissingNumber;
{
  return [self objectForKey:XPUserDefaultsNumberErrorMissingNumber];
}

-(NSNumber*)SVR_errorPatching;
{
  return [self objectForKey:XPUserDefaultsNumberErrorPatching];
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
          XPUserDefaultsBackgroundColorForSolutionPrimary,
          XPUserDefaultsColorForSolutionSecondary,
          XPUserDefaultsColorForOperator,
          XPUserDefaultsColorForNumeral,
          XPUserDefaultsColorForText,
          XPUserDefaultsNumberErrorMismatchedBrackets,
          XPUserDefaultsNumberErrorInvalidCharacter,
          XPUserDefaultsNumberErrorMissingNumber,
          XPUserDefaultsNumberErrorPatching,
          XPUserDefaultsLegacyDecimalNumberLocale,
          nil];
  vals = [NSArray arrayWithObjects:
          NSHomeDirectory(),
          [XPColor SVR_colorWithRed:004/255.0 green:051/255.0 blue:255/255.0 alpha:1.0],
          [XPColor SVR_colorWithRed:184/255.0 green:197/255.0 blue:255/255.0 alpha:1.0],
          [XPColor SVR_colorWithRed:004/255.0 green:051/255.0 blue:255/255.0 alpha:1.0],
          [XPColor SVR_colorWithRed:255/255.0 green:147/255.0 blue:000/255.0 alpha:1.0],
          [XPColor SVR_colorWithRed:000/255.0 green:000/255.0 blue:000/255.0 alpha:1.0],
          [XPColor SVR_colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0],
          [NSNumber numberWithInt:-1003],
          [NSNumber numberWithInt:-1002],
          [NSNumber numberWithInt:-1004],
          [NSNumber numberWithInt:-1005],
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
