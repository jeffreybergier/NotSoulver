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

@implementation NSNumber (CrossPlatform)

+(NSNumber*)XP_numberWithInteger:(XPInteger)integer;
{
#ifdef NSIntegerMax
  return [NSNumber numberWithInteger:integer];
#else
  return [NSNumber numberWithInt:integer];
#endif
}

-(XPInteger)XP_integerValue;
{
#ifdef NSIntegerMax
  return [self integerValue];
#else
  return [self intValue];
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
      XPLogRaise1(@"Impossible NSOpenPanel result: %lu", result);
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

-(id)nextObjectEffectiveRange:(XPRangePointer)rangePtr;
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
      if (rangePtr != NULL) { *rangePtr = loopRange; }
      _index = NSMaxRange(loopRange);
      return output;
    } else {
      _index += 1;
    }
  }
  if (rangePtr != NULL) { *rangePtr = XPNotFoundRange; }
  return nil;
}

- (void)dealloc
{
  XPLogExtra1(@"DEALLOC: %@", self);
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
  NSString *leading  = @">>";
  NSString *trailing = @"<<";
  NSMutableString *output = [[self mutableCopy] autorelease];
  [output insertString:trailing atIndex:NSMaxRange(range)];
  [output insertString:leading atIndex:range.location];
  return [[output copy] autorelease];
}

-(const char*)XP_UTF8String;
{
  if ([self respondsToSelector:@selector(UTF8String)]) {
    return [self UTF8String];
  } else {
    return [self cString];
  }
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
    XPLogRaise(@"Precondition Failure: searchString and replaceString must be same length");
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
  
  XPLogAlwys(@"XPTEST_replaceOccurrencesOfStringWithString: Start");
  
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
  
  XPLogAlwys(@"XPTEST_replaceOccurrencesOfStringWithString: Pass");
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
-(NSDecimalNumber*)SVR_decimalNumberByRaisingToPower:(NSDecimalNumber*)power
                                        withBehavior:(id<NSDecimalNumberBehaviors>)behavior;
{
  NSDecimalNumber *output = nil;
  BOOL powerIsNegative = ([power compare:[NSDecimalNumber zero]] == NSOrderedAscending);
  BOOL selfIsNegative = ([self compare:[NSDecimalNumber zero]] == NSOrderedAscending);
  
  if (powerIsNegative) {
    output = [[NSDecimalNumber one] decimalNumberByDividingBy:
                          [self decimalNumberByRaisingToPower:(XPUInteger)abs([power intValue])
                                                 withBehavior:behavior]
                                                 withBehavior:behavior];
  } else {
    output = [self decimalNumberByRaisingToPower:(XPUInteger)[power unsignedIntValue]
                                    withBehavior:behavior];
  }
  
  if (selfIsNegative) {
    output = [output decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]
                                     withBehavior:behavior];
  }
  
  return output;
}

@end

@implementation NSFont (CrossPlatform)

-(NSData*)XP_data;
{
  id forArchiving = nil;
  if ([self respondsToSelector:@selector(fontDescriptor)]) {
    forArchiving = [self fontDescriptor];
  } else {
    forArchiving = self;
  }
  return [XPKeyedArchiver XP_archivedDataWithRootObject:forArchiving];
}

+(id)XP_fontWithData:(NSData*)data;
{
  NSFont *output = nil;
  id unarchived = nil;
  Class descriptorClass = nil;
  if (!data) { return nil; }
  descriptorClass = NSClassFromString(@"NSFontDescriptor");
  if (descriptorClass) {
    unarchived = [XPKeyedUnarchiver XP_unarchivedObjectOfClass:descriptorClass
                                                      fromData:data];
    output = [self fontWithDescriptor:unarchived size:0];
  } else {
    unarchived = [XPKeyedUnarchiver XP_unarchivedObjectOfClass:[NSFont class]
                                                      fromData:data];
    output = unarchived;
  }
  return output;
}

@end

@implementation NSColor (CrossPlatform)

-(NSData*)XP_data;
{
  return [XPKeyedArchiver XP_archivedDataWithRootObject:self];
}

+(id)XP_colorWithData:(NSData*)data;
{
  NSColor *output = nil;
  if (!data) { return nil; }
  output = [XPKeyedUnarchiver XP_unarchivedObjectOfClass:[NSColor class]
                                                fromData:data];
  if (![output isKindOfClass:[NSColor class]]) { XPLogRaise(@""); return nil; }
  return output;
}

@end

@implementation CrossPlatform
+(void)executeUnitTests;
{
  XPLogAlwys(@"XPTESTS: Start");
  [NSMutableString XPTEST_replaceOccurrencesOfStringWithString];
  [XPLog executeUnitTests];
  XPLogAlwys(@"XPTESTS: Pass");
}
@end

@implementation XPKeyedArchiver (CrossPlatform)
+(NSData*)XP_archivedDataWithRootObject:(id)object;
{
  if ([self respondsToSelector:@selector(archivedDataWithRootObject:requiringSecureCoding:error:)]) {
    return [self archivedDataWithRootObject:object requiringSecureCoding:YES error:NULL];
  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [self archivedDataWithRootObject:object];
#pragma clang diagnostic pop
  }
}
@end

@implementation XPKeyedUnarchiver (CrossPlatform)
+(id)XP_unarchivedObjectOfClass:(Class)cls fromData:(NSData*)data;
{
  id output = nil;
  if ([self respondsToSelector:@selector(unarchivedObjectOfClass:fromData:error:)]) {
    return [self unarchivedObjectOfClass:cls fromData:data error:NULL];
  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    output = [self unarchiveObjectWithData:data];
#pragma clang diagnostic pop
    if (!output) { return nil; }
    if ([output isKindOfClass:cls]) {
      return output;
    } else {
      XPLogRaise2(@"XP_unarchivedObject:%@ notKindOfClass %@", output, cls);
      return nil;
    }
  }
}
@end

@implementation NSBundle (CrossPlatform)
-(BOOL)XP_loadNibNamed:(NSString*)nibName
                 owner:(id)owner
       topLevelObjects:(NSArray**)topLevelObjects;
{
  if ([self respondsToSelector:@selector(loadNibNamed:owner:topLevelObjects:)]) {
    return [self loadNibNamed:nibName owner:owner topLevelObjects:topLevelObjects];
  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [[self class] loadNibNamed:nibName owner:owner];
#pragma clang diagnostic pop
  }
}
@end

@implementation XPLog

+(void)pause {}

+(void)executeUnitTests;
{
  XPLogAlwys (@"XPLogAlwys");
  XPLogAlwys1(@"XPLogAlwys1: %d", 1);
  XPLogAlwys2(@"XPLogAlwys2: %d, %d", 1, 2);
  XPLogAlwys3(@"XPLogAlwys3: %d, %d, %d", 1, 2, 3);
  XPLogAlwys4(@"XPLogAlwys4: %d, %d, %d, %d", 1, 2, 3, 4);
  XPLogDebug (@"XPLogDebug");
  XPLogDebug1(@"XPLogDebug1: %d", 1);
  XPLogDebug2(@"XPLogDebug2: %d, %d", 1, 2);
  XPLogDebug3(@"XPLogDebug3: %d, %d, %d", 1, 2, 3);
  XPLogDebug4(@"XPLogDebug4: %d, %d, %d, %d", 1, 2, 3, 4);
  /*
  XPLogPause (@"XPLogPause");
  XPLogPause1(@"XPLogPause1: %d", 1);
  XPLogPause2(@"XPLogPause2: %d, %d", 1, 2);
  XPLogPause3(@"XPLogPause3: %d, %d, %d", 1, 2, 3);
  XPLogPause4(@"XPLogPause4: %d, %d, %d, %d", 1, 2, 3, 4);
  XPLogRaise(@"XPLogRaise");
  XPLogRaise1(@"XPLogRaise1: %d", 1);
  XPLogRaise2(@"XPLogRaise2: %d, %d", 1, 2);
  XPLogRaise3(@"XPLogRaise3: %d, %d, %d", 1, 2, 3);
  XPLogRaise4(@"XPLogRaise4: %d, %d, %d, %d", 1, 2, 3, 4);
  */
}

@end
