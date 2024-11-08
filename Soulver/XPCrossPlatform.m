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

#import "XPCrossPlatform.h"
#import "NSUserDefaults+Soulver.h"

const NSRange XPNotFoundRange = {NSNotFound, 0};
BOOL XPIsNotFoundRange(NSRange range)
{
  return range.location == NSNotFound;
}

BOOL XPContainsRange(NSRange lhs, NSRange rhs) {
  return (lhs.location <= rhs.location) && (NSMaxRange(lhs) >= NSMaxRange(rhs));
}

@implementation NSValue (CrossPlatform)
+(id)XP_valueWithRange:(NSRange)range;
{
  if (XPIsNotFoundRange(range)) { return nil; }
  if ([self respondsToSelector:@selector(valueWithRange:)]) {
    return [self valueWithRange:range];
  } else {
    return [self valueWithBytes:&range objCType:@encode(NSRange)];
  }
}
-(NSRange)XP_rangeValue;
{
  NSRange range;
  if ([self respondsToSelector:@selector(rangeValue)]) {
    [self getValue:&range];
    return range;
    // TODO: Figure out how to restore this and have it still compile in OpenStep
    // return [self rangeValue];
  } else {
    [self getValue:&range];
    return range;
  }
}
@end

@implementation NSNumber (CrossPlatform)

+(NSNumber*)XP_numberWithInteger:(XPInteger)integer;
{
  if ([self respondsToSelector:@selector(numberWithInteger:)]) {
    return [self numberWithInteger:integer];
  } else {
    return [self numberWithInt:(int)integer];
  }
}

-(XPInteger)XP_integerValue;
{
  if ([self respondsToSelector:@selector(integerValue)]) {
    // TODO: Check if the pragma commands help in Jaguar
    // They don't silence warnings in OpenStep
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wundeclared-selector"
    return (XPInteger)[self integerValue];
#pragma GCC diagnostic pop
  } else {
    return [self intValue];
  }
}

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
XPAlertReturn XPRunQuitAlert(void)
{
  return NSRunAlertPanel([Localized titleQuit],
                         @"%@",  // dialogEditedWindows
                         [Localized verbReviewUnsaved],
                         [Localized verbQuitAnyway],
                         [Localized verbCancel],
                         [Localized phraseEditedWindows]);
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
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [self cString];
#pragma clang diagnostic pop
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
  NSString *lhsDescription = [self description];
  NSString *rhsDescription = [[NSDecimalNumber notANumber] description];
  return [lhsDescription isEqualToString:rhsDescription];
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
    if (!output) {
      return nil;
    }
    if ([output isKindOfClass:cls]) {
      return output;
    }
    XPLogRaise2(@"XP_unarchivedObject:%@ notKindOfClass %@", output, cls);
    return nil;
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

+(void)logCheckedPoundDefines;
{
  XPLogAlwys (@"<XPLog> Start: logCheckedPoundDefines");
#ifdef LOGLEVEL
  XPLogAlwys1(@"LOGLEVEL...............(%d)", LOGLEVEL);
#else
  XPLogAlwys (@"LOGLEVEL...............(ND)");
#endif
#ifdef DEBUG
  XPLogAlwys1(@"DEBUG..................(%d)", DEBUG);
#else
  XPLogAlwys (@"DEBUG..................(ND)");
#endif
#ifdef TESTING
  XPLogAlwys1(@"TESTING................(%d)", TESTING);
#else
  XPLogAlwys (@"TESTING................(ND)");
#endif
#ifdef NS_ENUM
  XPLogAlwys (@"NS_ENUM................(Defined)");
#else
  XPLogAlwys (@"NS_ENUM................(ND)");
#endif
#ifdef CGFLOAT_MAX
  XPLogAlwys1(@"CGFLOAT_MAX............(%g)", CGFLOAT_MAX);
#else
  XPLogAlwys (@"CGFLOAT_MAX............(ND)");
#endif
#ifdef NSIntegerMax
  XPLogAlwys1(@"NSIntegerMax...........(%ld)", NSIntegerMax);
#else
  XPLogAlwys (@"NSIntegerMax...........(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_0
  XPLogAlwys1(@"MAC_OS_X_VERSION_10_0..(%d)", MAC_OS_X_VERSION_10_0);
#else
  XPLogAlwys (@"MAC_OS_X_VERSION_10_0..(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_2
  XPLogAlwys1(@"MAC_OS_X_VERSION_10_2..(%d)", MAC_OS_X_VERSION_10_2);
#else
  XPLogAlwys (@"MAC_OS_X_VERSION_10_2..(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_4
  XPLogAlwys1(@"MAC_OS_X_VERSION_10_4..(%d)", MAC_OS_X_VERSION_10_4);
#else
  XPLogAlwys (@"MAC_OS_X_VERSION_10_4..(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_6
  XPLogAlwys1(@"MAC_OS_X_VERSION_10_6..(%d)", MAC_OS_X_VERSION_10_6);
#else
  XPLogAlwys (@"MAC_OS_X_VERSION_10_6..(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_9
  XPLogAlwys1(@"MAC_OS_X_VERSION_10_9..(%d)", MAC_OS_X_VERSION_10_9);
#else
  XPLogAlwys (@"MAC_OS_X_VERSION_10_9..(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_13
  XPLogAlwys1(@"MAC_OS_X_VERSION_10_13.(%d)", MAC_OS_X_VERSION_10_13);
#else
  XPLogAlwys (@"MAC_OS_X_VERSION_10_13.(ND)");
#endif
#ifdef __STDC_VERSION__
  XPLogAlwys1(@"__STDC_VERSION__.......(%ld)", __STDC_VERSION__);
#else
  XPLogAlwys (@"__STDC_VERSION__.......(ND)");
#endif
  XPLogAlwys (@"<XPLog> End: logCheckedPoundDefines");
}

@end
