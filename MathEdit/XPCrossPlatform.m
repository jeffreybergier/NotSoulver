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

#import "XPCrossPlatform.h"
#import "NSUserDefaults+MathEdit.h"

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
#ifdef MAC_OS_X_VERSION_10_2
  return [self valueWithRange:range];
#else
  return [self valueWithBytes:&range objCType:@encode(NSRange)];
#endif
}
-(NSRange)XP_rangeValue;
{
#ifdef MAC_OS_X_VERSION_10_2
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
  // I think the reason was just passing [ud MATH_savePanelLastDirectory]
  // directly into the open panel. But I added memory
  // protection around everything just in case.
  XPModalResponse result;
  NSArray *output;
  
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  NSOpenPanel *panel = [[NSOpenPanel openPanel] retain];
  NSString *lastDirectory = [[ud MATH_savePanelLastDirectory] retain];
  
  [panel setAllowsMultipleSelection:YES];
  result = [panel runModalForDirectory:lastDirectory
                                  file:nil
                                 types:[NSArray arrayWithObject:extension]];
  [ud MATH_setSavePanelLastDirectory:[panel directory]];
  
  switch (result) {
    case XPModalResponseOK:
      output = [[panel filenames] retain];
      break;
    case XPModalResponseCancel:
      output = [NSArray new];
      break;
    default:
      XPCLogAssrt1(NO, @"[UNKNOWN] NSModalResponse(%d)", (int)result);
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
  XPParameterRaise(self);
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
  XPLogExtra1(@"<%@>", XPPointerString(self));
  [_key release];
  [_string release];
  _key = nil;
  _string = nil;
  [super dealloc];
}

@end

@implementation NSAttributedString (CrossPlatform)

-(XPAttributeEnumerator*)MATH_enumeratorForAttribute:(XPAttributedStringKey)key;
{
  return [self MATH_enumeratorForAttribute:key usingLongestEffectiveRange:NO];
}

-(XPAttributeEnumerator*)MATH_enumeratorForAttribute:(XPAttributedStringKey)key
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
  XPParameterRaise(self);
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
  XPLogExtra1(@"<%@>", XPPointerString(self));
  [_string release];
  [_set release];
  [super dealloc];
}

@end

@implementation NSString (CrossPlatform)

+(NSString*)MATH_rootDisplayString;
{
  // This breaks the regex engine because its shit
  unichar sqrtChar = 0x221A;
  return [NSString stringWithCharacters:&sqrtChar length:1];
}

+(NSString*)MATH_rootRawString;
{
  return @"R";
}

+(NSString*)MATH_logRawString;
{
  return @"L";
}

+(NSString*)MATH_logDisplayString;
{
  return @"log";
}

-(NSString*)MATH_descriptionHighlightingRange:(NSRange)range;
{
  NSString *leading  = @">>";
  NSString *trailing = @"<<";
  NSMutableString *output = [[self mutableCopy] autorelease];
  [output insertString:trailing atIndex:NSMaxRange(range)];
  [output insertString:leading atIndex:range.location];
  return [[output copy] autorelease];
}

-(const char*)XP_cString;
{
#ifdef MAC_OS_X_VERSION_10_2
  return [self UTF8String];
#else
  if ([self canBeConvertedToEncoding:NSASCIIStringEncoding]) {
    return [self cString];
  }
  XPLogAssrt1(NO, @"[NON-ASCII] %@", self);
  return NULL;
#endif
}

-(XPUInteger)XP_cStringLength;
{
#ifdef MAC_OS_X_VERSION_10_4
  return [self lengthOfBytesUsingEncoding:NSASCIIStringEncoding];
#else
  if ([self canBeConvertedToEncoding:NSASCIIStringEncoding]) {
    return [self cStringLength];
  }
  return 0;
#endif
}

-(BOOL)XP_containsNonASCIICharacters;
{
  return [self length] != [self XP_cStringLength];
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
#ifdef MAC_OS_X_VERSION_10_4
  forArchiving = [self fontDescriptor];
#else
  forArchiving = self;
#endif
  return [XPKeyedArchiver XP_archivedDataWithRootObject:forArchiving];
}

+(id)XP_fontWithData:(NSData*)data;
{
#ifdef MAC_OS_X_VERSION_10_4
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
  return output;
}

@end

@implementation NSCoder (CrossPlatform)
-(id)XP_decodeObjectOfClass:(Class)aClass forKey:(NSString*)key;
{
#ifdef MAC_OS_X_VERSION_10_8
  id output = [self decodeObjectOfClass:aClass forKey:key];
  XPLogAssrt2(output, @"class:%@ key:%@", NSStringFromClass(aClass), key);
  return output;
#elif MAC_OS_X_VERSION_10_2
  return [self decodeObjectForKey:key];
#else
  return [self decodeObject];
#endif
}

-(void)XP_encodeObject:(id)object forKey:(NSString*)key;
{
#if MAC_OS_X_VERSION_10_2
  [self encodeObject:object forKey:key];
#else
  [self encodeObject:object];
#endif
}
@end

@implementation XPKeyedArchiver (CrossPlatform)
+(NSData*)XP_archivedDataWithRootObject:(id)object;
{
#ifdef AFF_NSSecureCodingNone
  return [self archivedDataWithRootObject:object];
#else
  NSError *error = nil;
  NSData *output = [self archivedDataWithRootObject:object
                              requiringSecureCoding:YES
                                              error:&error];
  XPLogAssrt1(!error, @"%@", error);
  return output;
#endif
}
@end

@implementation XPKeyedUnarchiver (CrossPlatform)
// someData used because data conflicts with instance variable
// and causes warning in OpenStep
+(id)XP_unarchivedObjectOfClass:(Class)cls fromData:(NSData*)someData;
{
#ifdef AFF_NSSecureCodingNone
  id output = [self unarchiveObjectWithData:someData];
  if (!output) { return nil; }
  if ([output isKindOfClass:cls]) { return output; }
  XPLogRaise2(@"[FAIL] [%@ isKindOfClass:%@]", output, cls);
  return nil;
#else
  NSError *error = nil;
  NSAttributedString *output = [self unarchivedObjectOfClass:cls
                                                    fromData:someData
                                                       error:&error];
  XPLogAssrt1(!error, @"%@", error);
  return output;
#endif
}
@end

@implementation NSWorkspace (CrossPlatform)

-(BOOL)XP_openWebURL:(NSString*)webURL;
{
#ifdef MAC_OS_X_VERSION_10_2
  XPParameterRaise(webURL);
  return [self openURL:[NSURL URLWithString:webURL]];
#else
  return NO;
#endif
}
@end

#ifndef AFF_NSBezierPathNone
@implementation NSBezierPath (CrossPlatform)

+(id)XP_bezierPathWithRoundedRect:(NSRect)rect
                          xRadius:(XPFloat)xRadius
                          yRadius:(XPFloat)yRadius;
{
#ifdef MAC_OS_X_VERSION_10_6
  return [NSBezierPath __REAL_bezierPathWithRoundedRect:rect
                                                xRadius:xRadius
                                                yRadius:yRadius];
#else
  return [NSBezierPath __MANUAL_bezierPathWithRoundedRect:rect
                                                  xRadius:xRadius
                                                  yRadius:yRadius];
#endif
}

+(id)__REAL_bezierPathWithRoundedRect:(NSRect)rect
                              xRadius:(XPFloat)xRadius
                              yRadius:(XPFloat)yRadius;
{
#ifdef MAC_OS_X_VERSION_10_6
  return [NSBezierPath bezierPathWithRoundedRect:rect
                                         xRadius:xRadius
                                         yRadius:yRadius];
#else
  XPLogRaise(@"System does not support NSBezierPath convenience initializer");
  return nil;
#endif
}

+(id)__MANUAL_bezierPathWithRoundedRect:(NSRect)rect
                                xRadius:(XPFloat)rx
                                yRadius:(XPFloat)ry;
{
  // Prepare variables
  XPFloat kappa;
  XPFloat ox;
  XPFloat oy;
  XPFloat x0;
  XPFloat x1;
  XPFloat x2;
  XPFloat x3;
  XPFloat y0;
  XPFloat y1;
  XPFloat y2;
  XPFloat y3;
  NSBezierPath *path = nil;
  
  // Sorry, this method was developed through a long conversation with ChatGPT
  // I don't have a good source for this, and my BezierPath skills are not so
  // strong. But it works, and thats all the matters.
  
  // Prepare path
  path = [NSBezierPath bezierPath];

  // Bail if the radius specified is invalid
  if (rx <= 0 || ry <= 0) {
      [path appendBezierPathWithRect:rect];
      return path;
  }

  // Clamp radii to half width/height
  rx = MIN(rx, NSWidth(rect) / 2.0);
  ry = MIN(ry, NSHeight(rect) / 2.0);

  // Magic number for approximating a quarter-circle with a Bézier curve
  kappa = 0.45;
  ox = rx * kappa; // control point offset horizontal
  oy = ry * kappa; // control point offset vertical

  // Calculate the points
  x0 = NSMinX(rect);
  x1 = x0 + rx;
  x2 = NSMaxX(rect) - rx;
  x3 = NSMaxX(rect);

  y0 = NSMinY(rect);
  y1 = y0 + ry;
  y2 = NSMaxY(rect) - ry;
  y3 = NSMaxY(rect);

  // Draw the path
  [path moveToPoint:NSMakePoint(x1, y3)];

  // Top edge + top-right corner
  [path lineToPoint:NSMakePoint(x2, y3)];
  [path curveToPoint:NSMakePoint(x3, y2)
       controlPoint1:NSMakePoint(x3 - ox, y3)
       controlPoint2:NSMakePoint(x3, y3 - oy)];

  // Right edge + bottom-right corner
  [path lineToPoint:NSMakePoint(x3, y1)];
  [path curveToPoint:NSMakePoint(x2, y0)
       controlPoint1:NSMakePoint(x3, y0 + oy)
       controlPoint2:NSMakePoint(x3 - ox, y0)];

  // Bottom edge + bottom-left corner
  [path lineToPoint:NSMakePoint(x1, y0)];
  [path curveToPoint:NSMakePoint(x0, y1)
       controlPoint1:NSMakePoint(x0 + ox, y0)
       controlPoint2:NSMakePoint(x0, y0 + oy)];

  // Left edge + top-left corner
  [path lineToPoint:NSMakePoint(x0, y2)];
  [path curveToPoint:NSMakePoint(x1, y3)
       controlPoint1:NSMakePoint(x0, y3 - oy)
       controlPoint2:NSMakePoint(x0 + ox, y3)];

  // Close the path and return
  [path closePath];
  return path;
}

@end
#endif

@implementation NSTextView (CrossPlatform)
-(void)XP_insertText:(id)string;
{
#ifdef MAC_OS_X_VERSION_10_6
  [self insertText:string replacementRange:[self selectedRange]];
#else
  [self insertText:string];
#endif
}

-(void)XP_setAllowsUndo:(BOOL)flag;
{
#ifndef AFF_NSDocumentNone
  [self setAllowsUndo:flag];
#endif
}

-(void)XP_setUsesFindPanel:(BOOL)flag;
{
#ifndef AFF_NSTextViewFindNone
  [self setUsesFindPanel:flag];
#endif
}

-(void)XP_setUsesFindBar:(BOOL)flag;
{
#ifndef AFF_NSTextViewFindNoInline
  [self setUsesFindBar:flag];
#endif
}

-(void)XP_setContinuousSpellCheckingEnabled:(BOOL)flag;
{
#ifndef AFF_NSTextViewGrammarNone
  [self setContinuousSpellCheckingEnabled:flag];
#endif
}

-(void)XP_setGrammarCheckingEnabled:(BOOL)flag;
{
#ifndef AFF_NSTextViewGrammarNone
  [self setGrammarCheckingEnabled:flag];
#endif
}

-(void)XP_setAutomaticSpellingCorrectionEnabled:(BOOL)flag;
{
#ifndef AFF_NSTextViewGrammarNone
  [self setAutomaticSpellingCorrectionEnabled:flag];
#endif
}

@end

@implementation NSTextField (CrossPlatform)
-(void)XP_setBezelStyle:(XPTextFieldBezelStyle)style;
{
#ifndef AFF_NSButtonStylesNone
  [self setBezelStyle:style];
#endif
}
@end

@implementation NSButton (CrossPlatform)
-(void)XP_setBezelStyle:(XPBezelStyle)style;
{
#ifndef AFF_NSButtonStylesNone
  [self setBezelStyle:style];
#endif
}
@end

@implementation NSBox (CrossPlatform)
-(void)XP_setBoxType:(XPBoxType)type;
{
#ifndef AFF_NSButtonStylesNone
  [self setBoxType:type];
#endif
}
@end

@implementation NSWindow (CrossPlatform)

-(void)XP_setRestorationClass:(Class)aClass;
{
#ifndef AFF_StateRestorationNone
  [self setRestorationClass:aClass];
#endif
}

-(void)XP_setIdentifier:(NSString*)anIdentifier;
{
#ifndef AFF_StateRestorationNone
  [self setIdentifier:anIdentifier];
#endif
}

-(void)XP_setAppearanceWithUserInterfaceStyle:(XPUserInterfaceStyle)aStyle;
{
#ifdef XPSupportsDarkMode
  switch (aStyle) {
    case XPUserInterfaceStyleLight:
      [self setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameAqua]];
      break;
    case XPUserInterfaceStyleDark:
      [self setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameDarkAqua]];
      break;
    default:
      XPLogAssrt1(NO, @"[UNKNOWN] XPUserInterfaceStyle(%d)", (int)aStyle);
  }
#else
  XPLogDebug(@"[IGNORE]");
#endif
}

-(void)XP_setCollectionBehavior:(XPWindowCollectionBehavior)collectionBehavior;
{
#ifndef AFF_NSWindowCollectionBehaviorNone
  [self setCollectionBehavior:collectionBehavior];
#endif
}

-(void)XP_setContentViewController:(XPViewController)viewController;
{
  SEL toPerform = @selector(setContentViewController:);
  SEL getView   = @selector(view);
  if ([self respondsToSelector:toPerform]) {
    [self performSelector:toPerform withObject:viewController];
  } else {
    XPLogAssrt1([viewController respondsToSelector:getView], @"%@ does not respond to -view", viewController);
    [self setContentView:[viewController performSelector:getView]];
    [self setNextResponder:viewController];
  }
}

@end

@implementation NSScrollView (CrossPlatform)

-(void)XP_setDrawsBackground:(BOOL)drawsBackground;
{
#ifdef MAC_OS_X_VERSION_10_2
  [self setDrawsBackground:drawsBackground];
#endif
}

-(void)XP_setAllowsMagnification:(BOOL)flag;
{
#ifndef AFF_ScrollViewNoMagnification
  [self setAllowsMagnification:flag];
#endif
}

-(void)XP_setMagnification:(XPFloat)newValue;
{
#ifndef AFF_ScrollViewNoMagnification
  [self setMagnification:newValue];
#endif
}

-(XPFloat)XP_magnification;
{
#ifdef AFF_ScrollViewNoMagnification
  return 1.0;
#else
  return [self magnification];
#endif
}

@end

@implementation XPLog

+(void)logCheckedPoundDefines;
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool allocWithZone:NULL] init];
  NSLog(@"<XPLog> Start: logCheckedPoundDefines");
  NSLog(@"LOGLEVEL...............(%d)", LOGLEVEL);
#ifdef DEBUG
  NSLog(@"DEBUG..................(%d)", DEBUG);
#else
  NSLog(@"DEBUG..................(ND)");
#endif
  NSLog(@"TESTING................(%d)", TESTING);
#ifdef NS_ENUM
  NSLog(@"NS_ENUM................(Defined)");
#else
  NSLog(@"NS_ENUM................(ND)");
#endif
#ifdef CGFLOAT_MAX
  NSLog(@"CGFLOAT_MAX............(%g)", CGFLOAT_MAX);
#else
  NSLog(@"CGFLOAT_MAX............(ND)");
#endif
#ifdef NSIntegerMax
  NSLog(@"NSIntegerMax...........(%ld)", NSIntegerMax);
#else
  NSLog(@"NSIntegerMax...........(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_2
  NSLog(@"MAC_OS_X_VERSION_10_2..(%d)", MAC_OS_X_VERSION_10_2);
#else
  NSLog(@"MAC_OS_X_VERSION_10_2..(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_4
  NSLog(@"MAC_OS_X_VERSION_10_4..(%d)", MAC_OS_X_VERSION_10_4);
#else
  NSLog(@"MAC_OS_X_VERSION_10_4..(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_6
  NSLog(@"MAC_OS_X_VERSION_10_6..(%d)", MAC_OS_X_VERSION_10_6);
#else
  NSLog(@"MAC_OS_X_VERSION_10_6..(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_8
  NSLog(@"MAC_OS_X_VERSION_10_8..(%d)", MAC_OS_X_VERSION_10_8);
#else
  NSLog(@"MAC_OS_X_VERSION_10_8..(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_13
  NSLog(@"MAC_OS_X_VERSION_10_13.(%d)", MAC_OS_X_VERSION_10_13);
#else
  NSLog(@"MAC_OS_X_VERSION_10_13.(ND)");
#endif
#ifdef MAC_OS_X_VERSION_10_15
  NSLog(@"MAC_OS_X_VERSION_10_15.(%d)", MAC_OS_X_VERSION_10_15);
#else
  NSLog(@"MAC_OS_X_VERSION_10_15.(ND)");
#endif
#ifdef __MAC_OS_X_VERSION_MAX_ALLOWED
  NSLog(@"MAC_OS_X_VER_MAX_ALLOW.(%d)", __MAC_OS_X_VERSION_MAX_ALLOWED);
#else
  NSLog(@"MAC_OS_X_VER_MAX_ALLOW.(ND)");
#endif
  NSLog(@"<XPLog> End: logCheckedPoundDefines");
  [pool release];
}

@end

NSString *XPStringFromErrorPointer(XPErrorPointer ptr)
{
  id error = nil;
  if (!ptr) {
    return @"NULL";
  }
  error = *ptr;
#ifdef MAC_OS_X_VERSION_10_15
  // TODO: This sometimes crashes on older systems
  // Maybe I am doing it wrong?
  if (error) {
    return [error description];
  }
#endif
  return @"nil";
}
