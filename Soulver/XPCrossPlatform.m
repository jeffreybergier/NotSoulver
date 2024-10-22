/* SVRCrossPlatform.m created by me on Fri 06-Sep-2024 */

#import "XPCrossPlatform.h"
#import "NSUserDefaults+Soulver.h"

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

-(XPInteger)XP_integerValue;
{
#if OS_OPENSTEP
  return [self intValue];
#else
  return [self integerValue];
#endif
}

-(NSString*)SVR_descriptionForDrawing;
{
  if ([self isKindOfClass:[NSDecimalNumber class]]) {
    return [(NSDecimalNumber*)self SVR_description];
  } else {
    return [self description];
  }
}
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
XPAlertReturn XPRunQuitAlert(void)
{
  return NSRunAlertPanel(@"Quit",
                         @"There are edited windows.",
                         @"Review Unsaved",
                         @"Quit Anyway",
                         @"Cancel");
}

NSArray* XPRunOpenPanel(void)
{
  // This method was occasionally causing a crash with NSOpenPanel,
  // thus I added the additional memory management.
  // I think the reason was just passing [ud SVR_savePanelLastDirectory]
  // directly into the open panel. But I added memory
  // protection around everything just in case.
  XPInteger result;
  NSArray *output;
  
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSOpenPanel *panel = [[NSOpenPanel openPanel] retain];
  NSString *lastDirectory = [[ud SVR_savePanelLastDirectory] retain];
  
  [panel setAllowsMultipleSelection:YES];
  result = [panel runModalForDirectory:lastDirectory
                                  file:nil
                                 types:[NSArray arrayWithObject:@"solv"]];
  [ud SVR_setSavePanelLastDirectory:[panel directory]];
  
  switch (result) {
    case NSOKButton:
      output = [[panel filenames] retain];
      break;
    case NSCancelButton:
      output = [NSArray new];
      break;
    default:
      [XPLog error:@"Impossible NSOpenPanel result: %lu", result];
      output = nil;
      break;
  }
  
  [lastDirectory autorelease];
  [panel autorelease];
  return [output autorelease];
}
#pragma clang diagnostic pop

@implementation NSAttributedString (CrossPlatform)

-(XPAttributeEnumerator*)SVR_enumeratorForAttribute:(XPAttributedStringKey)key;
{
  return [self SVR_enumeratorForAttribute:key usingLongestEffectiveRange:NO];
}

-(XPAttributeEnumerator*)SVR_enumeratorForAttribute:(XPAttributedStringKey)key
                         usingLongestEffectiveRange:(BOOL)usesLongest;
{
  return [XPAttributeEnumerator enumeratorWithAttributedString:self
                                               forAttributeKey:key
                                    usingLongestEffectiveRange:usesLongest];
}
@end

@implementation XPAttributeEnumerator
-(id)initWithAttributedString:(NSAttributedString*)attributedString
              forAttributeKey:(XPAttributedStringKey)key
   usingLongestEffectiveRange:(BOOL)usesLongest;
{
  self = [super init];
  _key = [key retain];
  _string = [attributedString copy];
  _index = 0;
  _usesLongestEffectiveRange = usesLongest;
  return self;
}

+(id)enumeratorWithAttributedString:(NSAttributedString*)attributedString
                    forAttributeKey:(XPAttributedStringKey)key
         usingLongestEffectiveRange:(BOOL)usesLongest;
{
  return [[[XPAttributeEnumerator alloc] initWithAttributedString:attributedString
                                                  forAttributeKey:key
                                       usingLongestEffectiveRange:usesLongest] autorelease];
}

-(id)nextObject;
{
  return [self nextObjectEffectiveRange:NULL];
}

-(id)nextObjectEffectiveRange:(XPRangePointer)range;
{
  XPUInteger length = [_string length];
  id output = nil;
  NSRange loopRange = XPNotFoundRange;
  
  while (_index < length) {
    if (_usesLongestEffectiveRange) {
      output = [_string attribute:_key
                          atIndex:_index
            longestEffectiveRange:&loopRange
                          inRange:NSMakeRange(0, length)];
    } else {
      output = [_string attribute:_key
                          atIndex:_index
                   effectiveRange:&loopRange];
    }
    if (output) {
      if (range != NULL) { *range = loopRange; }
      _index = NSMaxRange(loopRange);
      return output;
    } else {
      _index += 1;
    }
  }
  if (range != NULL) { *range = XPNotFoundRange; }
  return nil;
}

- (void)dealloc
{
  [XPLog extra:@"DEALLOC: %@", self];
  [_key release];
  [_string release];
  _key = nil;
  _string = nil;
  [super dealloc];
}

@end

@implementation NSString (CrossPlatform)

-(NSString*)SVR_descriptionHighlightingRange:(NSRange)range;
{
#if OS_OPENSTEP
  NSString *trailing = @"«";
  NSString *leading  = @"»";
#else
  NSString *trailing = @"ã€";
  NSString *leading  = @"ã€Œ";
#endif
  NSMutableString *output = [[self mutableCopy] autorelease];
  [output insertString:trailing atIndex:NSMaxRange(range)];
  [output insertString:leading atIndex:range.location];
  return [[output copy] autorelease];
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

@implementation NSMutableString (CrossPlatform)
-(void)XP_replaceOccurrencesOfString:(NSString*)searchString
                          withString:(NSString*)replaceString;
{
  XPUInteger length = [self length];
  NSRange searchRange = NSMakeRange(0, length);
  NSRange foundRange = XPNotFoundRange;
  
  if ([searchString length] != [replaceString length]) {
    [XPLog error:@"Precondition Failure: searchString and replaceString must be same length"];
    return;
  }
  
  while (searchRange.location < length) {
    foundRange = [self rangeOfString:searchString options:0 range:searchRange];
    if (XPIsNotFoundRange(foundRange)) { break; }
    [self replaceCharactersInRange:foundRange withString:replaceString];
    searchRange = NSMakeRange(NSMaxRange(foundRange), length-NSMaxRange(foundRange));
  }
}

+(void)XPTEST_replaceOccurrencesOfStringWithString;
{
  NSMutableString *string = [[NSMutableString new] autorelease];
  NSString *expected = nil;
  
  [XPLog alwys:@"XPTEST_replaceOccurrencesOfStringWithString: Start"];
  
  [string setString:@"0a0b0c0d0e0f0g0h0i0j0"];
  [string XP_replaceOccurrencesOfString:@"0" withString:@"+"];
  expected = @"+a+b+c+d+e+f+g+h+i+j+";
  NSAssert([expected isEqualToString:string], @"");
  
  [string setString:@"00a00b00c00d00e00f00g00h00i00j00"];
  [string XP_replaceOccurrencesOfString:@"00" withString:@"++"];
  expected = @"++a++b++c++d++e++f++g++h++i++j++";
  NSAssert([expected isEqualToString:string], @"");
  
  [string setString:@"00a00b00c00d00e00f00g00h00ijklmnop"];
  [string XP_replaceOccurrencesOfString:@"00" withString:@"++"];
  expected = @"++a++b++c++d++e++f++g++h++ijklmnop";
  NSAssert([expected isEqualToString:string], @"");
  
  [XPLog alwys:@"XPTEST_replaceOccurrencesOfStringWithString: Pass"];
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
@implementation XPError (XPError)

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
  return [NSDecimalNumber
          decimalNumberWithString:string
          locale:[[NSUserDefaults standardUserDefaults]
                  SVR_decimalNumberLocale]];
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

@implementation CrossPlatform
+(void)executeUnitTests;
{
  [XPLog alwys:@"XPTESTS: Start"];
  [NSMutableString XPTEST_replaceOccurrencesOfStringWithString];
  [XPLog alwys:@"XPTESTS: Pass"];
}
@end
