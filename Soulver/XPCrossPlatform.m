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
#ifdef MAC_OS_X_VERSION_10_0
  return [self valueWithRange:range];
#else
  return [self valueWithBytes:&range objCType:@encode(NSRange)];
#endif
}
-(NSRange)XP_rangeValue;
{
#ifdef MAC_OS_X_VERSION_10_0
  return [self rangeValue];
#else
  NSRange range;
  [self getValue:&range];
  return range;
#endif
}
@end

@implementation NSNumber (CrossPlatform)

+(NSNumber*)XP_numberWithInteger:(XPInteger)integer;
{
#ifdef NSIntegerMax
  return [self numberWithInteger:integer];
#else
  return [self numberWithInt:integer];
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

XPAlertReturn XPRunCopyWebURLToPasteboardAlert(NSString* webURL)
{
  return NSRunAlertPanel([Localized titleAlert],
                         [Localized phraseCopyWebURLToClipboard],
                         [Localized verbCopyToClipboard],
                         [Localized verbDontCopy],
                         nil,
                         webURL);
}

NSArray* XPRunOpenPanel(NSString *extension)
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
                                 types:[NSArray arrayWithObject:extension]];
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

@implementation XPAttributeEnumerator
-(id)initWithAttributedString:(NSAttributedString*)attributedString
              forAttributeKey:(XPAttributedStringKey)key
   usingLongestEffectiveRange:(BOOL)usesLongest;
{
  self = [super init];
  NSCParameterAssert(self);
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

@implementation XPCharacterSetEnumerator
-(id)initWithString:(NSString*)string characterSet:(NSCharacterSet*)aSet options:(XPStringCompareOptions)mask;
{
  self = [super init];
  NSCParameterAssert(self);
  _string = [string retain];
  _set = [aSet retain];
  _options = mask;
  _index = NSMakeRange(0, [string length]);
  return self;
}

+(id)enumeratorWithString:(NSString*)string characterSet:(NSCharacterSet*)aSet options:(XPStringCompareOptions)mask;
{
  return [[[XPCharacterSetEnumerator alloc] initWithString:string
                                              characterSet:aSet
                                                   options:mask] autorelease];
}

-(NSValue*)nextObject;
{
  NSRange output = XPNotFoundRange;
  output = [_string rangeOfCharacterFromSet:_set options:_options range:_index];
  if (XPIsNotFoundRange(output)) { return nil; }
  if (_options & NSBackwardsSearch) {
    _index = NSMakeRange(0, output.location);
  } else {
    _index = NSMakeRange(NSMaxRange(output), [_string length] - NSMaxRange(output));
  }
  return [NSValue XP_valueWithRange:output];
}

- (void)dealloc
{
  XPLogExtra1(@"DEALLOC:%@", self);
  [_string release];
  [_set release];
  [super dealloc];
}

@end

@implementation NSString (CrossPlatform)

+(NSString*)SVR_rootDisplayString;
{
  // This breaks the regex engine because its shit
  unichar sqrtChar = 0x221A;
  return [NSString stringWithCharacters:&sqrtChar length:1];
}

+(NSString*)SVR_rootRawString;
{
  return @"R";
}

+(NSString*)SVR_logRawString;
{
  return @"L";
}

+(NSString*)SVR_logDisplayString;
{
  return @"log";
}

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
#ifdef MAC_OS_X_VERSION_10_0
  return [self UTF8String];
#else
  return [self cString];
#endif
}

-(NSEnumerator*)XP_enumeratorForCharactersInSet:(NSCharacterSet*)aSet;
{
  return [XPCharacterSetEnumerator enumeratorWithString:self
                                           characterSet:aSet
                                                options:0];
}
-(NSEnumerator*)XP_enumeratorForCharactersInSet:(NSCharacterSet*)aSet
                                        options:(XPStringCompareOptions)mask;
{
  return [XPCharacterSetEnumerator enumeratorWithString:self
                                           characterSet:aSet
                                                options:mask];
}

@end

@implementation NSFont (CrossPlatform)

-(NSData*)XP_data;
{
  id forArchiving = nil;
#ifdef MAC_OS_X_VERSION_10_3
  forArchiving = [self fontDescriptor];
#else
  forArchiving = self;
#endif
  return [XPKeyedArchiver XP_archivedDataWithRootObject:forArchiving];
}

+(id)XP_fontWithData:(NSData*)data;
{
#ifdef MAC_OS_X_VERSION_10_3
  id descriptor = [XPKeyedUnarchiver XP_unarchivedObjectOfClass:[NSFontDescriptor class]
                                                       fromData:data];
  return [self fontWithDescriptor:descriptor size:0];
#else
  return [XPKeyedUnarchiver XP_unarchivedObjectOfClass:[NSFont class]
                                              fromData:data];
#endif
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

@implementation XPKeyedArchiver (CrossPlatform)
+(NSData*)XP_archivedDataWithRootObject:(id)object;
{
#ifdef MAC_OS_X_VERSION_10_13
  return [self archivedDataWithRootObject:object
                    requiringSecureCoding:YES
                                    error:NULL];
#else
  return [self archivedDataWithRootObject:object];
#endif
}
@end

@implementation XPKeyedUnarchiver (CrossPlatform)
// someData used because data conflicts with instance variable
// and causes warning in OpenStep
+(id)XP_unarchivedObjectOfClass:(Class)cls fromData:(NSData*)someData;
{
#ifdef MAC_OS_X_VERSION_10_13
  return [self unarchivedObjectOfClass:cls fromData:someData error:NULL];
#else
  id output = [self unarchiveObjectWithData:someData];
  if (!output) { return nil; }
  if ([output isKindOfClass:cls]) { return output; }
  XPLogRaise2(@"XP_unarchivedObject:%@ notKindOfClass %@", output, cls);
  return nil;
#endif
}
@end

@implementation NSBundle (CrossPlatform)
-(BOOL)XP_loadNibNamed:(NSString*)nibName
                 owner:(id)owner
       topLevelObjects:(NSArray**)topLevelObjects;
{
#ifdef MAC_OS_X_VERSION_10_8
  return [self loadNibNamed:nibName
                      owner:owner
            topLevelObjects:topLevelObjects];
#else
  return [[self class] loadNibNamed:nibName
                              owner:owner];
#endif
}
@end

@implementation NSWorkspace (CrossPlatform)
-(BOOL)XP_openFile:(NSString*)file;
{
#ifdef MAC_OS_X_VERSION_10_0
  return [self openURL:[NSURL fileURLWithPath:file]];
#else
  return [self openFile:file];
#endif
}
@end

@implementation XPLog

+(void)pause {}

+(void)logCheckedPoundDefines;
{
  XPLogAlwys (@"<XPLog> Start: logCheckedPoundDefines");
  XPLogAlwys1(@"LOGLEVEL...............(%d)", LOGLEVEL);
  XPLogAlwys1(@"DEBUG..................(%d)", DEBUG);
  XPLogAlwys1(@"TESTING................(%d)", TESTING);
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
#ifdef MAC_OS_X_VERSION_10_3
  XPLogAlwys1(@"MAC_OS_X_VERSION_10_3..(%d)", MAC_OS_X_VERSION_10_3);
#else
  XPLogAlwys (@"MAC_OS_X_VERSION_10_3..(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_4
  XPLogAlwys1(@"MAC_OS_X_VERSION_10_4..(%d)", MAC_OS_X_VERSION_10_4);
#else
  XPLogAlwys (@"MAC_OS_X_VERSION_10_4..(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_5
  XPLogAlwys1(@"MAC_OS_X_VERSION_10_5..(%d)", MAC_OS_X_VERSION_10_5);
#else
  XPLogAlwys (@"MAC_OS_X_VERSION_10_5..(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_6
  XPLogAlwys1(@"MAC_OS_X_VERSION_10_6..(%d)", MAC_OS_X_VERSION_10_6);
#else
  XPLogAlwys (@"MAC_OS_X_VERSION_10_6..(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_8
  XPLogAlwys1(@"MAC_OS_X_VERSION_10_8..(%d)", MAC_OS_X_VERSION_10_8);
#else
  XPLogAlwys (@"MAC_OS_X_VERSION_10_8..(ND)");
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
