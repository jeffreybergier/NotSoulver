/* SVRCrossPlatform.m created by me on Fri 06-Sep-2024 */

#import "SVRCrossPlatform.h"
#import "SVRMathString.h"

const NSRange XPNotFoundRange = {NSNotFound, 0};
BOOL XPIsNotFoundRange(NSRange range)
{
  return range.location == NSNotFound;
}

BOOL XPIsFoundRange(NSRange range)
{
  return range.location != NSNotFound;
}

BOOL XPContainsRange(NSRange lhs, NSRange rhs) {
  return (lhs.location <= rhs.location) && (NSMaxRange(lhs) >= NSMaxRange(rhs));
}

@implementation NSValue (CrossPlatform)
-(id)XP_initWithRange:(NSRange)range;
{
  if (XPIsNotFoundRange(range)) { return nil; }
  return [self initWithBytes:&range objCType:@encode(NSRange)];
}
+(id)XP_valueWithRange:(NSRange)range;
{
  if (XPIsNotFoundRange(range)) { return nil; }
  return [self valueWithBytes:&range objCType:@encode(NSRange)];
}
-(NSRange)XP_rangeValue;
{
  NSRange range;
  [self getValue:&range];
  return range;
}
@end

@implementation XPLog

+(void)alwys:(NSString*)_formatString, ...;
{
  va_list args;
  NSString *formatString = (_formatString) ? _formatString : @"NO MESSAGE PROVIDED";
  va_start(args, _formatString);
  formatString = [@"LOG-ALWYS: " stringByAppendingString:formatString];
  NSLogv(formatString, args);
  va_end(args);
}

+(void)debug:(NSString*)_formatString, ...;
{
#if DEBUG || EXTRA
  va_list args;
  NSString *formatString = (_formatString) ? _formatString : @"NO MESSAGE PROVIDED";
  va_start(args, _formatString);
  formatString = [@"LOG-DEBUG: " stringByAppendingString:formatString];
  NSLogv(formatString, args);
  va_end(args);
#endif
}

+(void)extra:(NSString*)_formatString, ...;
{
#if DEBUG && EXTRA
  va_list args;
  NSString *formatString = (_formatString) ? _formatString : @"NO MESSAGE PROVIDED";
  va_start(args, _formatString);
  formatString = [@"LOG-EXTRA: " stringByAppendingString:formatString];
  NSLogv(formatString, args);
  va_end(args);
#endif
}

+(void)pause:(NSString*)_formatString, ...;
{
  va_list args;
  NSString *formatString = (_formatString) ? _formatString : @"NO MESSAGE PROVIDED";
  va_start(args, _formatString);
  formatString = [@"LOG-PAUSE: " stringByAppendingString:formatString];
  NSLogv(formatString, args);
  va_end(args);
}

+(void)error:(NSString*)_formatString, ...;
{
  va_list args;
  NSString *formatString = (_formatString) ? _formatString : @"NO ERROR PROVIDED";
  va_start(args, _formatString);
  formatString = [@"LOG-ERROR: " stringByAppendingString:formatString];
  NSLogv(formatString, args);
  [NSException raise:@"SVRException" format:formatString arguments:args];
  va_end(args);
}

@end

@implementation NSNumber (CrossPlatform)
+(NSNumber*)XP_numberWithInteger:(XPInteger)integer;
{
#if OS_OPENSTEP
  return [NSNumber numberWithInt:integer];
#else
  return [NSNumber numberWithInteger:integer];
#endif
}
@end

@implementation XPAlert
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wformat-security"
+(XPAlertReturn)runAppModalWithTitle:(NSString*)title
                             message:(NSString*)message
                       defaultButton:(NSString*)defaultButton
                     alternateButton:(NSString*)alternateButton
                         otherButton:(NSString*)otherButton;
{
  return NSRunAlertPanel(title,
                         message,
                         defaultButton,
                         alternateButton,
                         otherButton);
}

+(XPAlertReturn)runSheetModalForWindow:(NSWindow*)window
                             withTitle:(NSString*)title
                               message:(NSString*)message
                         defaultButton:(NSString*)defaultButton
                       alternateButton:(NSString*)alternateButton
                           otherButton:(NSString*)otherButton;
{
  // TODO: Update to use sheets in Mac OS X
  return NSRunAlertPanel(title,
                         message,
                         defaultButton,
                         alternateButton,
                         otherButton);
}
#pragma clang diagnostic pop

@end

@implementation XPSavePanel

+(NSString*)lastDirectory;
{
  return [[NSUserDefaults standardUserDefaults] SVR_savePanelLastDirectory];
}

+(void)setLastDirectory:(NSString*)lastDirectory;
{
  [[NSUserDefaults standardUserDefaults] SVR_setSavePanelLastDirectory:lastDirectory];
}

+(NSString*)filenameByRunningSheetModalSavePanelForWindow:(NSWindow*)window;
{
  return [self filenameByRunningSheetModalSavePanelForWindow:window
                                        withExistingFilename:nil];
}

+(NSString*)filenameByRunningSheetModalSavePanelForWindow:(NSWindow*)window
                                     withExistingFilename:(NSString*)_filename;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  XPInteger result;
  // OpenStep documentation clearly states that empty string is OK but NIL is not
  NSString *filename = (_filename) ? _filename : @"";
  NSSavePanel *panel = [NSSavePanel savePanel];
  [panel setRequiredFileType:@"solv"];
  result = [panel runModalForDirectory:[self lastDirectory] file:filename];
  [self setLastDirectory:[panel directory]];
  switch (result) {
    case NSOKButton:     return [panel filename];
    case NSCancelButton: return nil;
    default: [XPLog error:@"Impossible NSSavePanel result: %lu", result]; return nil;
  }
#pragma clang diagnostic pop
}
@end

@implementation XPOpenPanel
+(NSArray*)filenamesByRunningAppModalOpenPanel;
{
  return [self filenamesByRunningAppModalOpenPanelWithExistingFilename:nil];
}

+(NSArray*)filenamesByRunningAppModalOpenPanelWithExistingFilename:(NSString*)filename;
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  XPInteger result;
  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setAllowsMultipleSelection:YES];
  result = [panel runModalForDirectory:[self lastDirectory]
                                  file:filename // Unlike NSSavePanel, this can be NIL
                                 types:[NSArray arrayWithObject:@"solv"]];
  [self setLastDirectory:[panel directory]];
  switch (result) {
    case NSOKButton:     return [panel filenames];
    case NSCancelButton: return [[NSArray new] autorelease];
    default: [XPLog error:@"Impossible NSOpenPanel result: %lu", result]; return nil;
  }
#pragma clang diagnostic pop
}
@end


NSString *XPUserDefaultsSavePanelLastDirectory            = @"kSavePanelLastDirectory";
NSString *XPUserDefaultsColorForSolutionPrimary           = @"kColorForSolutionPrimary";
NSString *XPUserDefaultsBackgroundColorForSolutionPrimary = @"kBackgroundColorForSolutionPrimary";
NSString *XPUserDefaultsColorForSolutionSecondary         = @"kColorForSolutionSecondary";
NSString *XPUserDefaultsColorForOperator                  = @"kColorForOperator";
NSString *XPUserDefaultsColorForNumeral                   = @"kColorForNumeral";
NSString *XPUserDefaultsColorForText                      = @"kColorForText";
NSString *XPUserDefaultsDictionaryOperatorDecodeMap       = @"kDictionaryOperatorDecodeMap";
NSString *XPUserDefaultsDictionaryOperatorEncodeMap       = @"kDictionaryOperatorEncodeMap";
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

-(XPColor*)SVR_backgroundColorForSolutionPrimary;
{
  return [self objectForKey:XPUserDefaultsBackgroundColorForSolutionPrimary];
}

-(BOOL)SVR_setBackgroundColorForSolutionPrimary:(XPColor*)newValue;
{
  [self setObject:newValue forKey:XPUserDefaultsBackgroundColorForSolutionPrimary];
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

-(XPColor*)SVR_colorForBrackets;
{
  // TODO: Make separate color for brackets
  return [self objectForKey:XPUserDefaultsColorForOperator];
}

-(BOOL)SVR_setColorForBrackets:(XPColor*)newValue;
{
  [self setObject:newValue forKey:XPUserDefaultsColorForOperator];
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
  return [NSFont userFixedPitchFontOfSize:16];
}
-(BOOL)SVR_setFontForText:(NSFont*)newValue;
{
  [XPLog error:@"NSUnimplemented"];
  return NO;
}

-(NSDictionary*)SVR_operatorDecodeMap;
{
  return [self objectForKey:XPUserDefaultsDictionaryOperatorDecodeMap];
}

-(NSDictionary*)SVR_operatorEncodeMap;
{
  return [self objectForKey:XPUserDefaultsDictionaryOperatorEncodeMap];
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
          XPUserDefaultsDictionaryOperatorDecodeMap,
          XPUserDefaultsDictionaryOperatorEncodeMap,
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
          [self __SVR_standardOperatorDecodeMap],
          [self __SVR_standardOperatorEncodeMap],
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

+(NSDictionary*)__SVR_standardOperatorDecodeMap;
{
  NSArray *keys   = [NSArray arrayWithObjects:@"a", @"s", @"d", @"m", @"e", nil];
  NSArray *values = [NSArray arrayWithObjects:@"+", @"-", @"/", @"*", @"^", nil];
  return [[[NSDictionary alloc] initWithObjects:values forKeys:keys] autorelease];
}

+(NSDictionary*)__SVR_standardOperatorEncodeMap;
{
  NSArray *keys   = [NSArray arrayWithObjects:@"+", @"-", @"/", @"*", @"^", nil];
  NSArray *values = [NSArray arrayWithObjects:@"a", @"s", @"d", @"m", @"e", nil];
  return [[[NSDictionary alloc] initWithObjects:values forKeys:keys] autorelease];
}

@end

@implementation NSAttributedString (Pasteboard)

-(NSData*)SVR_pasteboardRepresentation;
{
  NSDictionary *attribs = [NSDictionary dictionaryWithObject:XPRTFTextDocumentType
                                                      forKey:XPDocumentTypeDocumentAttribute];
  return [self RTFFromRange:NSMakeRange(0, [self length]) documentAttributes:attribs];
}
@end

@implementation XPPasteboard (Pasteboard)

-(BOOL)SVR_setAttributedString:(NSAttributedString*)aString;
{
  BOOL success = NO;
  NSData *data = [aString SVR_pasteboardRepresentation];
  if (!data) {
    [XPLog pause:@"%@ Fail: RTFRepresentation", self];
    return success;
  }
  [self declareTypes:[NSArray arrayWithObjects:XPPasteboardTypeRTF, XPPasteboardTypeString, nil] owner:nil];
  success = [self setData:data forType:XPPasteboardTypeRTF];
  success = success && [self setString:[aString string] forType:XPPasteboardTypeString];
  if (!success) {
    [XPLog pause:@"%@ Fail: PBSetData: %@", self, data];
  }
  return success;
}

-(BOOL)SVR_setMathString:(SVRMathString*)aString;
{
  NSString *toPboard;
  BOOL success = NO;
  
  toPboard = [aString stringValue];
  [self declareTypes:[NSArray arrayWithObjects:XPPasteboardTypeString, nil] owner:nil];
  success = [self setString:toPboard forType:XPPasteboardTypeString];
  
  if (!success) {
    [XPLog pause:@"%@ Fail: PBSetString: %@", self, toPboard];
  }
  return success;
}

-(SVRMathString*)SVR_mathString;
{
  NSString *type;
  NSString *fromPboard = nil;
  NSEnumerator *e = [[self types] objectEnumerator];
  
  while ((type = [e nextObject])) {
    fromPboard = [self stringForType:type];
    if (fromPboard) {
      [XPLog debug:@"%@ stringForType: %@: %@", self, type, fromPboard];
      break;
    }
  }
  
  if (!fromPboard) { return nil; }
  fromPboard = [fromPboard SVR_stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if ([fromPboard length] == 0) { return nil; }
  
  return [SVRMathString mathStringWithString:fromPboard];
}

@end

@implementation NSString (CrossPlatform)

-(NSString*)SVR_descriptionHighlightingRange:(NSRange)range;
{
#if OS_OPENSTEP
  NSString *trailing = @"´";
  NSString *leading  = @"ª";
#else
  NSString *trailing = @"„Äç";
  NSString *leading  = @"„Äå";
#endif
  NSMutableString *output = [[self mutableCopy] autorelease];
  [output insertString:trailing atIndex:NSMaxRange(range)];
  [output insertString:leading atIndex:range.location];
  return [[output copy] autorelease];
}

-(NSString*)SVR_stringByTrimmingCharactersInSet:(NSCharacterSet*)set;
{
#if OS_OPENSTEP
  // TOOD: Manual implementation?
  return self;
#else
  return [self stringByTrimmingCharactersInSet:set];
#endif
}

-(const char*)XP_UTF8String;
{
#if OS_OPENSTEP
  return [self cString];
#else
  return [self UTF8String];
#endif
}

@end

@implementation NSBundle (CrossPlatform)
-(BOOL)SVR_loadNibNamed:(NSString*)nibName
                  owner:(id)owner
        topLevelObjects:(NSArray**)topLevelObjects;
{
#if OS_OPENSTEP
  return [[self class] loadNibNamed:nibName owner:owner];
#else
  return [self loadNibNamed:nibName owner:owner topLevelObjects:topLevelObjects];
#endif
}
@end

@implementation XPColor (CrossPlatform)
+(XPColor*)SVR_colorWithRed:(XPFloat)red
                      green:(XPFloat)green
                       blue:(XPFloat)blue
                      alpha:(XPFloat)alpha;
{
  return [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
}
@end

// MARK: XPError
// OPENSTEP does not have NSError so I am just using NSNumber
@implementation XPError

+(NSNumber*)SVR_errorMismatchedBrackets;
{
  return [[NSUserDefaults standardUserDefaults] SVR_errorMismatchedBrackets];
}

+(NSNumber*)SVR_errorInvalidCharacter;
{
  return [[NSUserDefaults standardUserDefaults] SVR_errorInvalidCharacter];
}

+(NSNumber*)SVR_errorMissingNumber;
{
  return [[NSUserDefaults standardUserDefaults] SVR_errorMissingNumber];
}

+(NSNumber*)SVR_errorPatching;
{
  return [[NSUserDefaults standardUserDefaults] SVR_errorPatching];
}

+(NSString*)SVR_descriptionForError:(NSNumber*)error;
{
  if ([error isEqualToNumber:[XPError SVR_errorInvalidCharacter]]) {
    return [NSString stringWithFormat:@"<Error:%@> An incompatible character was found", error];
  } else if ([error isEqualToNumber:[XPError SVR_errorMismatchedBrackets]]) {
    return [NSString stringWithFormat:@"<Error:%@> Parentheses were unbalanced", error];
  } else if ([error isEqualToNumber:[XPError SVR_errorMissingNumber]]) {
    return [NSString stringWithFormat:@"<Error:%@> Operators around the numbers were unbalanced", error];
  } else if ([error isEqualToNumber:[XPError SVR_errorPatching]]) {
    return [NSString stringWithFormat:@"<Error:%@> Operators around the parentheses were missing", error];
  } else {
    return @"<Error> An Unknown Error Ocurred";
  }
}
@end

// MARK: NSDecimalNumber
@implementation NSDecimalNumber (Soulver)

-(BOOL)SVR_isNotANumber;
{
  NSString *lhsDescription = [self SVR_description];
  NSString *rhsDescription = [[NSDecimalNumber notANumber] SVR_description];
  return [lhsDescription isEqualToString:rhsDescription];
}

-(NSString*)SVR_description;
{
  return [self descriptionWithLocale:[[NSUserDefaults standardUserDefaults] SVR_decimalNumberLocale]];
}

+(id)SVR_decimalNumberWithString:(NSString*)string;
{
  return [NSDecimalNumber decimalNumberWithString:string locale:[[NSUserDefaults standardUserDefaults] SVR_decimalNumberLocale]];
}

// NSDecimalNumber handles exponents extremely strangely
// This provides a little wrapper around the oddities
-(NSDecimalNumber*)SVR_decimalNumberByRaisingToPower:(NSDecimalNumber*)power;
{
  NSDecimalNumber *output = nil;
  BOOL powerIsNegative = ([power compare:[NSDecimalNumber zero]] == NSOrderedAscending);
  BOOL selfIsNegative = ([self compare:[NSDecimalNumber zero]] == NSOrderedAscending);
  
  if (powerIsNegative) {
    output = [[NSDecimalNumber one] decimalNumberByDividingBy:[self decimalNumberByRaisingToPower:(XPUInteger)abs([power intValue])]];
  } else {
    output = [self decimalNumberByRaisingToPower:(XPUInteger)[power unsignedIntValue]];
  }
  
  if (selfIsNegative) {
    output = [output decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
  }
  
  return output;
}

@end
