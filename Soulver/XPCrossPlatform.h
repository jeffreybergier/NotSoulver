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

#import <AppKit/AppKit.h>

/// MARK: Simple Typedefs

// Memory management annotations
// These just help me keep the ownership clear
// They don't do anything
/// The object creates this itself and owns it
#define mm_new
/// The object copies the original
#define mm_copy
/// The object retains the original
#define mm_retain
/// The object keeps an unsafe unretained reference to the original
#define mm_unretain

#ifdef NSIntegerMax
typedef NSInteger XPInteger;
typedef NSUInteger XPUInteger;
#else
typedef int XPInteger;
typedef unsigned int XPUInteger;
#endif

#ifdef CGFLOAT_MAX
typedef CGFloat XPFloat;
#else
typedef float XPFloat;
#endif

#ifdef MAC_OS_X_VERSION_10_0
typedef NSRangePointer XPRangePointer;
#else
typedef NSRange* XPRangePointer;
#endif

#ifdef MAC_OS_X_VERSION_10_2
#define XPKeyedArchiver NSKeyedArchiver
#define XPKeyedUnarchiver NSKeyedUnarchiver
#else
#define XPKeyedArchiver NSArchiver
#define XPKeyedUnarchiver NSUnarchiver
#endif

#ifdef MAC_OS_X_VERSION_10_4
#define XPLocale NSLocale
// Docs says NSTextAlignmentCenter is available in 10.0.
// But its not even available in 10.2, so I put it here.
// It could be 10.3 or 10.4 or later. No way to know
// until I get to that version of OSX
#define XPTextAlignmentCenter NSTextAlignmentCenter
#else
#define XPLocale NSDictionary
#define XPTextAlignmentCenter NSCenterTextAlignment
#endif

#ifdef MAC_OS_X_VERSION_10_9
#define XPModalResponseOK NSModalResponseOK
#define XPModalResponseCancel NSModalResponseCancel
#else
#define XPModalResponseOK NSOKButton
#define XPModalResponseCancel NSCancelButton
#endif

#ifdef MAC_OS_X_VERSION_10_13
typedef NSAttributedStringKey XPAttributedStringKey;
#else
typedef NSString* XPAttributedStringKey;
#endif

extern const NSRange XPNotFoundRange;
BOOL XPIsNotFoundRange(NSRange range);
BOOL XPIsFoundRange(NSRange range);
BOOL XPContainsRange(NSRange lhs, NSRange rhs);

@interface NSValue (CrossPlatform)
-(id)XP_initWithRange:(NSRange)range;
+(id)XP_valueWithRange:(NSRange)range;
-(NSRange)XP_rangeValue;
@end

@interface NSNumber (CrossPlatform)
+(NSNumber*)XP_numberWithInteger:(XPInteger)integer;
-(XPInteger)XP_integerValue;
-(NSString*)SVR_descriptionForDrawing;
@end

#ifdef NS_ENUM
/// These match XPAlertButtonDefault
/// NSAlertDefaultReturn
typedef NS_ENUM(XPInteger, XPAlertReturn) {
XPAlertReturnDefault   =  1,
XPAlertReturnAlternate =  0,
XPAlertReturnOther     = -1,
XPAlertReturnError     = -2
};
#else
typedef enum {
  XPAlertReturnDefault   = (XPInteger)1,
  XPAlertReturnAlternate = (XPInteger)0,
  XPAlertReturnOther     = (XPInteger)-1,
  XPAlertReturnError     = (XPInteger)-2
} XPAlertReturn;
#endif

#ifdef NS_ENUM
typedef NS_ENUM(XPInteger, XPUserInterfaceStyle) {
  XPUserInterfaceStyleUnspecified = 0,
  XPUserInterfaceStyleLight = 1,
  XPUserInterfaceStyleDark = 2
};
#else
typedef enum {
  XPUserInterfaceStyleUnspecified = 0,
  XPUserInterfaceStyleLight = 1,
  XPUserInterfaceStyleDark = 2
} XPUserInterfaceStyle;
#endif

XPAlertReturn XPRunQuitAlert(void);
NSArray* XPRunOpenPanel(void);

@interface XPAttributeEnumerator: NSEnumerator
{
  XPAttributedStringKey _key;
  NSAttributedString *_string;
  XPUInteger _index;
  BOOL _usesLongestEffectiveRange;
}
-(id)initWithAttributedString:(NSAttributedString*)attributedString
              forAttributeKey:(XPAttributedStringKey)key
   usingLongestEffectiveRange:(BOOL)usesLongest;
+(id)enumeratorWithAttributedString:(NSAttributedString*)attributedString
                    forAttributeKey:(XPAttributedStringKey)key
         usingLongestEffectiveRange:(BOOL)usesLongest;
-(id)nextObject;
-(id)nextObjectEffectiveRange:(XPRangePointer)range;
@end

@interface NSAttributedString (CrossPlatform)
-(XPAttributeEnumerator*)SVR_enumeratorForAttribute:(XPAttributedStringKey)key;
-(XPAttributeEnumerator*)SVR_enumeratorForAttribute:(XPAttributedStringKey)key
                         usingLongestEffectiveRange:(BOOL)useLongest;
@end

@interface NSString (CrossPlatform)
-(NSString*)SVR_descriptionHighlightingRange:(NSRange)range;
-(const char*)XP_UTF8String;
@end

@interface NSMutableString (CrossPlatform)
-(void)XP_replaceOccurrencesOfString:(NSString*)searchString
                          withString:(NSString*)replaceString;
+(void)XPTEST_replaceOccurrencesOfStringWithString;
@end

@interface NSDecimalNumber (Soulver)
/// In OpenStep, NaN comparisons are weird, so this uses a string comparison
-(BOOL)SVR_isNotANumber;
-(NSString*)SVR_description;
+(id)SVR_decimalNumberWithString:(NSString*)string;
-(NSDecimalNumber*)SVR_decimalNumberByRaisingToPower:(NSDecimalNumber*)power
                                        withBehavior:(id<NSDecimalNumberBehaviors>)behavior;
@end

/// NSFont is stored in UserDefaults as archived Data.
/// The recommended way to do this is with NSFontDescriptor, however
/// systems before 10.3 that did not have NSFontDescriptor will just
/// fallback to the archiving and unarchiving the NSFont itself
@interface NSFont (CrossPlatform)
-(NSData*)XP_data;
+(id)XP_fontWithData:(NSData*)data;
@end

@interface NSColor (CrossPlatform)
-(NSData*)XP_data;
+(id)XP_colorWithData:(NSData*)data;
@end

@interface CrossPlatform: NSObject
+(void)executeUnitTests;
@end

@interface XPKeyedArchiver (CrossPlatform)
+(NSData*)XP_archivedDataWithRootObject:(id)object;
@end

@interface XPKeyedUnarchiver (CrossPlatform)
+(id)XP_unarchivedObjectOfClass:(Class)cls fromData:(NSData*)data;
@end

@interface NSBundle (CrossPlatform)
-(BOOL)XP_loadNibNamed:(NSString*)nibName
                 owner:(id)owner
       topLevelObjects:(NSArray**)topLevelObjects;
@end

// MARK: XPLogging

// In C99 the ability was added for Macros to have Variadic arguments
// https://stackoverflow.com/questions/78581920/what-is-the-stdc-version-value-for-c23
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#define C99 1
#else
#define C99 0
#endif

#ifndef DEBUG
#define DEBUG -1
#endif

#ifndef LOGLEVEL
#define LOGLEVEL -1
#endif

#if LOGLEVEL >= -1 && C99 == 0
#define XPLogAlwys(_formatString) NSLog(@"%@", _formatString)
#define XPLogAlwys1(_formatString, _one) NSLog(_formatString, _one)
#define XPLogAlwys2(_formatString, _one, _two) NSLog(_formatString, _one, _two)
#define XPLogAlwys3(_formatString, _one, _two, _three) NSLog(_formatString, _one, _two, _three)
#define XPLogAlwys4(_formatString, _one, _two, _three, _four) NSLog(_formatString, _one, _two, _three, _four)
#endif
#if LOGLEVEL >= -1 && C99 == 1
#define XPLogAlwys(_formatString) NSLog(@"%@", _formatString)
#define XPLogAlwys1(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogAlwys2(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogAlwys3(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogAlwys4(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#endif
#if (DEBUG >= -1 || LOGLEVEL >= 1) && C99 == 0
#define XPLogDebug(_formatString) NSLog(@"%@", _formatString)
#define XPLogDebug1(_formatString, _one) NSLog(_formatString, _one)
#define XPLogDebug2(_formatString, _one, _two) NSLog(_formatString, _one, _two)
#define XPLogDebug3(_formatString, _one, _two, _three) NSLog(_formatString, _one, _two, _three)
#define XPLogDebug4(_formatString, _one, _two, _three, _four) NSLog(_formatString, _one, _two, _three, _four)
#define XPLogPause(_formatString) NSLog(@"LOG-PAUSE: %@", _formatString); [XPLog pause]
#define XPLogPause1(_formatString, _one) NSLog([@"LOG-PAUSE: " stringByAppendingString:_formatString], _one); [XPLog pause]
#define XPLogPause2(_formatString, _one, _two) NSLog([@"LOG-PAUSE: " stringByAppendingString:_formatString], _one, _two); [XPLog pause]
#define XPLogPause3(_formatString, _one, _two, _three) NSLog([@"LOG-PAUSE: " stringByAppendingString:_formatString], _one, _two, _three); [XPLog pause]
#define XPLogPause4(_formatString, _one, _two, _three, _four) NSLog([@"LOG-PAUSE: " stringByAppendingString:_formatString], _one, _two, _three, _four); [XPLog pause]
#endif

#if (DEBUG >= -1 || LOGLEVEL >= 1) && C99 == 1
#define XPLogDebug(_formatString) NSLog(@"%@", _formatString)
#define XPLogDebug1(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogDebug2(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogDebug3(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogDebug4(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogPause(_formatString) NSLog(@"%@", _formatString); [XPLog pause]
#define XPLogPause1(_formatString, ...) NSLog(_formatString, __VA_ARGS__); [XPLog pause]
#define XPLogPause2(_formatString, ...) NSLog(_formatString, __VA_ARGS__); [XPLog pause]
#define XPLogPause3(_formatString, ...) NSLog(_formatString, __VA_ARGS__); [XPLog pause]
#define XPLogPause4(_formatString, ...) NSLog(_formatString, __VA_ARGS__); [XPLog pause]
#endif

#if LOGLEVEL >= 2 && C99 == 1
#define XPLogExtra(_formatString) NSLog(@"%@", _formatString)
#define XPLogExtra1(_formatString, _one) NSLog(_formatString, _one)
#define XPLogExtra2(_formatString, _one, _two) NSLog(_formatString, _one, _two)
#define XPLogExtra3(_formatString, _one, _two, _three) NSLog(_formatString, _one, _two, _three)
#define XPLogExtra4(_formatString, _one, _two, _three, _four) NSLog(_formatString, _one, _two, _three, _four)
#endif

#if LOGLEVEL >= 2 && C99 == 0
#define XPLogExtra(_formatString) NSLog(@"%@", _formatString)
#define XPLogExtra1(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogExtra2(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogExtra3(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogExtra4(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#endif

#ifndef XPLogDebug
#define XPLogDebug(_formatString)
#define XPLogDebug1(_formatString, _one)
#define XPLogDebug2(_formatString, _one, _two)
#define XPLogDebug3(_formatString, _one, _two, _three)
#define XPLogDebug4(_formatString, _one, _two, _three, _four)
#endif

#ifndef XPLogPause
#define XPLogPause(_formatString)
#define XPLogPause1(_formatString, _one)
#define XPLogPause2(_formatString, _one, _two)
#define XPLogPause3(_formatString, _one, _two, _three)
#define XPLogPause4(_formatString, _one, _two, _three, _four)
#endif

#ifndef XPLogExtra
#define XPLogExtra(_formatString)
#define XPLogExtra1(_formatString, _one)
#define XPLogExtra2(_formatString, _one, _two)
#define XPLogExtra3(_formatString, _one, _two, _three)
#define XPLogExtra4(_formatString, _one, _two, _three, _four)
#endif


#if C99 > 0
#define XPLogRaise(_formatString) [NSException raise:@"SVRException" format:_formatString]
#define XPLogRaise1(_formatString, ...) [NSException raise:@"SVRException" format:_formatString, __VA_ARGS__]
#define XPLogRaise2(_formatString, ...) [NSException raise:@"SVRException" format:_formatString, __VA_ARGS__]
#define XPLogRaise3(_formatString, ...) [NSException raise:@"SVRException" format:_formatString, __VA_ARGS__]
#define XPLogRaise4(_formatString, ...) [NSException raise:@"SVRException" format:_formatString, __VA_ARGS__]
#else
#define XPLogRaise(_formatString) [NSException raise:@"SVRException" format:_formatString]
#define XPLogRaise1(_formatString, _one) [NSException raise:@"SVRException" format:_formatString, _one]
#define XPLogRaise2(_formatString, _one, _two) [NSException raise:@"SVRException" format:_formatString, _one, _two]
#define XPLogRaise3(_formatString, _one, _two, _three) [NSException raise:@"SVRException" format:_formatString, _one, _two, _three]
#define XPLogRaise4(_formatString, _one, _two, _three, _four) [NSException raise:@"SVRException" format:_formatString, _one, _two, _three, _four]
#endif

@interface XPLog: NSObject
/// Requires `fb +[XPLog pause]` in GDB to Pause Debugger
+(void)pause;
+(void)executeUnitTests;
+(void)logCheckedPoundDefines;
@end
