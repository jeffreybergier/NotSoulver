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

#ifdef NS_ENUM
  #define XP_ENUM(_type, _name) NS_ENUM(_type, _name)
#else
  #define XP_ENUM(_type, _name) _type _name; enum
#endif

#ifdef MAC_OS_X_VERSION_10_2
#define XPKeyedArchiver NSKeyedArchiver
#define XPKeyedUnarchiver NSKeyedUnarchiver
#define XPSupportsNSDocument
#define XPSupportsNSBezierPath
#else
#define XPKeyedArchiver NSArchiver
#define XPKeyedUnarchiver NSUnarchiver
#endif

#ifdef MAC_OS_X_VERSION_10_3
#define XPRTFDocumentAttributes [NSDictionary dictionaryWithObject:NSRTFTextDocumentType forKey:NSDocumentTypeDocumentAttribute]
typedef NSRangePointer XPRangePointer;
#else
#define XPRTFDocumentAttributes nil
typedef NSRange* XPRangePointer;
#endif

#ifdef MAC_OS_X_VERSION_10_4
// Docs says NSTextAlignmentCenter is available in 10.0.
// But its not even available in 10.2, so I put it here.
// It could be 10.3 or 10.4 or later. No way to know
// until I get to that version of OSX
#define XPTextAlignmentCenter NSTextAlignmentCenter
#define XPBitmapImageFileTypeTIFF NSBitmapImageFileTypeTIFF
#else
#define XPTextAlignmentCenter NSCenterTextAlignment
#define XPBitmapImageFileTypeTIFF NSTIFFFileType
#endif

#ifdef MAC_OS_X_VERSION_10_5
#define XPStringCompareOptions NSStringCompareOptions
#else
#define XPStringCompareOptions unsigned int
#endif

#ifdef MAC_OS_X_VERSION_10_6
#define XPPasteboardTypeRTF NSPasteboardTypeRTF
#define XPPasteboardTypeString NSPasteboardTypeString
#else
#define XPPasteboardTypeRTF NSRTFPboardType
#define XPPasteboardTypeString NSStringPboardType
#endif

#ifdef MAC_OS_X_VERSION_10_8
#define XPSecureCoding NSSecureCoding
#else
#define XPSecureCoding NSCoding
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

#ifdef MAC_OS_X_VERSION_10_14
#define XPSupportsDarkMode
#endif

extern const NSRange XPNotFoundRange;
BOOL XPIsNotFoundRange(NSRange range);
BOOL XPContainsRange(NSRange lhs, NSRange rhs);

@interface NSValue (CrossPlatform)
+(id)XP_valueWithRange:(NSRange)range;
-(NSRange)XP_rangeValue;
@end

@interface NSNumber (CrossPlatform)
+(NSNumber*)XP_numberWithInteger:(XPInteger)integer;
-(XPInteger)XP_integerValue;
@end

/// These match XPAlertButtonDefault
/// NSAlertDefaultReturn
typedef XP_ENUM(XPInteger, XPAlertReturn) {
XPAlertReturnDefault   =  1,
XPAlertReturnAlternate =  0,
XPAlertReturnOther     = -1,
XPAlertReturnError     = -2
};

typedef XP_ENUM(XPInteger, XPUserInterfaceStyle) {
  XPUserInterfaceStyleUnspecified = 0,
  XPUserInterfaceStyleLight = 1,
  XPUserInterfaceStyleDark = 2
};

XPAlertReturn XPRunQuitAlert(void);
XPAlertReturn XPRunCopyWebURLToPasteboardAlert(NSString* webURL);
NSArray* XPRunOpenPanel(NSString *extension);

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

@interface XPCharacterSetEnumerator: NSEnumerator
{
  mm_retain NSString *_string;
  mm_retain NSCharacterSet *_set;
  XPStringCompareOptions _options;
  NSRange _index;
}
-(id)initWithString:(NSString*)string
       characterSet:(NSCharacterSet*)aSet
            options:(XPStringCompareOptions)mask;
+(id)enumeratorWithString:(NSString*)string
             characterSet:(NSCharacterSet*)aSet
                  options:(XPStringCompareOptions)mask;
-(NSValue*)nextObject;
@end

@interface NSString (CrossPlatform)
+(NSString*)SVR_rootRawString;
+(NSString*)SVR_rootDisplayString;
+(NSString*)SVR_logRawString;
+(NSString*)SVR_logDisplayString;
-(NSString*)SVR_descriptionHighlightingRange:(NSRange)range;
-(const char*)XP_UTF8String;
-(NSEnumerator*)XP_enumeratorForCharactersInSet:(NSCharacterSet*)aSet;
-(NSEnumerator*)XP_enumeratorForCharactersInSet:(NSCharacterSet*)aSet
                                        options:(XPStringCompareOptions)mask;
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

@interface NSCoder (CrossPlatform)
/// On 10.1, 10.0, and OpenStep the key is ignored. Order matters!
-(id)XP_decodeObjectOfClass:(Class)aClass forKey:(NSString*)key;
/// On 10.1, 10.0, and OpenStep the key is ignored. Order matters!
-(void)XP_encodeObject:(id)object forKey:(NSString*)key;
@end

@interface XPKeyedArchiver (CrossPlatform)
+(NSData*)XP_archivedDataWithRootObject:(id)object;
@end

@interface XPKeyedUnarchiver (CrossPlatform)
+(id)XP_unarchivedObjectOfClass:(Class)cls fromData:(NSData*)someData;
@end

@interface NSBundle (CrossPlatform)
-(BOOL)XP_loadNibNamed:(NSString*)nibName
                 owner:(id)owner
       topLevelObjects:(NSArray**)topLevelObjects;
@end

@interface NSWorkspace (CrossPlatform)
-(BOOL)XP_openFile:(NSString*)file;
@end

#ifdef XPSupportsNSBezierPath
@interface NSBezierPath (CrossPlatform)

+(id)XP_bezierPathWithRoundedRect:(NSRect)rect
                          xRadius:(XPFloat)xRadius
                          yRadius:(XPFloat)yRadius;

+(id)__REAL_bezierPathWithRoundedRect:(NSRect)rect
                              xRadius:(XPFloat)xRadius
                              yRadius:(XPFloat)yRadius;

+(id)__MANUAL_bezierPathWithRoundedRect:(NSRect)rect
                                xRadius:(XPFloat)xRadius
                                yRadius:(XPFloat)yRadius;
@end
#endif

@interface NSTextView (CrossPlatform)
-(void)XP_insertText:(id)string;
@end

// MARK: XPLogging

// In C99 the ability was added for Macros to have Variadic arguments
// https://stackoverflow.com/questions/78581920/what-is-the-stdc-version-value-for-c23

#define VARGYES 1
#define VARGNO  0

#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#define C99 VARGYES
#else
#define C99 VARGNO
#endif

#ifndef DEBUG
#define DEBUG 0
#endif

#ifndef TESTING
#define TESTING 0
#endif

/*
 * Log Levels
 * 1 Always (cannot be disabled)
 * 1 Raise  (always enabled and throws an exception)
 * 2 Debug  (or if debug flag present)
 * 2 Pause  (enabled when debug is enabled but also pauses debugger)
 * 3 Extra  (used for really heavy logging
 *
 * You can directly define the loglevel using other CFLAGS
 *
 * Logging implemented as Macros so that unprinted
 * log commands are deleted during compilation
 */

#define LOGLEVELEXTRA 3
#define LOGLEVELDEBUG 2
#define LOGLEVELALWYS 1

// Define Loglevel as always if its not defined
#ifndef LOGLEVEL
#define LOGLEVEL LOGLEVELALWYS
#endif

// If Loglevel has a weird value, reset it to always
#if LOGLEVEL != LOGLEVELALWYS && LOGLEVEL != LOGLEVELDEBUG && LOGLEVEL != LOGLEVELEXTRA
#undef  LOGLEVEL
#define LOGLEVEL LOGLEVELALWYS
#endif

// Define Always Macros
#if LOGLEVEL >= LOGLEVELALWYS && C99 == VARGNO
#define XPLogAlwys(_formatString) NSLog(@"%@", _formatString)
#define XPLogAlwys1(_formatString, _one) NSLog(_formatString, _one)
#define XPLogAlwys2(_formatString, _one, _two) NSLog(_formatString, _one, _two)
#define XPLogAlwys3(_formatString, _one, _two, _three) NSLog(_formatString, _one, _two, _three)
#define XPLogAlwys4(_formatString, _one, _two, _three, _four) NSLog(_formatString, _one, _two, _three, _four)
#endif

#if LOGLEVEL >= LOGLEVELALWYS && C99 == VARGYES
#define XPLogAlwys(_formatString) NSLog(@"%@", _formatString)
#define XPLogAlwys1(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogAlwys2(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogAlwys3(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogAlwys4(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#endif

// Define Debug Macros
#if LOGLEVEL >= LOGLEVELDEBUG && C99 == VARGNO
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

#if LOGLEVEL >= LOGLEVELDEBUG && C99 == VARGYES
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

// Define Extra macros
#if LOGLEVEL >= LOGLEVELEXTRA && C99 == VARGYES
#define XPLogExtra(_formatString) NSLog(@"%@", _formatString)
#define XPLogExtra1(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogExtra2(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogExtra3(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#define XPLogExtra4(_formatString, ...) NSLog(_formatString, __VA_ARGS__)
#endif

#if LOGLEVEL >= LOGLEVELEXTRA && C99 == VARGNO
#define XPLogExtra(_formatString) NSLog(@"%@", _formatString)
#define XPLogExtra1(_formatString, _one) NSLog(_formatString, _one)
#define XPLogExtra2(_formatString, _one, _two) NSLog(_formatString, _one, _two)
#define XPLogExtra3(_formatString, _one, _two, _three) NSLog(_formatString, _one, _two, _three)
#define XPLogExtra4(_formatString, _one, _two, _three, _four) NSLog(_formatString, _one, _two, _three, _four)
#endif

// Check if Debug and Extra macros are not defined yet
// then define them as empty macros

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

// Define Raise Exception Macros
#if C99 == VARGYES
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
+(void)logCheckedPoundDefines;
@end

// MARK: XPTest

#if TESTING==1
// TODO: Move these into XPLog macros above
#ifdef MAC_OS_X_VERSION_10_4
#define XPTestFunc [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]
#define XPTestFile [[[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"/"] lastObject]
#else
#define XPTestFunc [NSString stringWithCString:__PRETTY_FUNCTION__]
#define XPTestFile [[[NSString stringWithCString:__FILE__] componentsSeparatedByString:@"/"] lastObject]
#endif

#define XPTestInt(_lhs, _rhs)    NSAssert5(_lhs == _rhs, @"[FAIL] '%d'!='%d' {%@:%d} %@", (int)_lhs, (int)_rhs, XPTestFile, __LINE__, XPTestFunc)
#define XPTestBool(_lhs)         NSAssert3(_lhs, @"[FAIL] Bool was NO {%@:%d} %@", XPTestFile, __LINE__, XPTestFunc)
#define XPTestFloat(_lhs, _rhs)  NSAssert5(_lhs == _rhs, @"[FAIL] '%g'!='%g' {%@:%d} %@", _lhs, _rhs, XPTestFile, __LINE__, XPTestFunc)
#define XPTestObject(_lhs, _rhs) NSAssert5([_lhs isEqual:_rhs], @"[FAIL] '%@'!='%@' {%@:%d} %@", _lhs, _rhs, XPTestFile, __LINE__, XPTestFunc)
#define XPTestNotNIL(_lhs)       NSAssert3(_lhs, @"[FAIL] Object was NIL {%@:%d} %@", XPTestFile, __LINE__, XPTestFunc)
#define XPTestString(_lhs, _rhs) NSAssert5([_lhs isEqualToString:_rhs], @"[FAIL] '%@'!='%@' {%@:%d} %@", _lhs, _rhs, XPTestFile, __LINE__, XPTestFunc)
#define XPTestRange(_lhs, _loc, _len) NSAssert5(NSEqualRanges(_lhs, NSMakeRange(_loc, _len)), @"[FAIL] %@!=%@ {%@:%d} %@", NSStringFromRange(_lhs), NSStringFromRange(NSMakeRange(_loc, _len)), XPTestFile, __LINE__, XPTestFunc)
#define XPTestAttrString(_lhs, _rhs)  NSAssert5([_lhs isEqualToAttributedString:_rhs], @"[FAIL] '%@'!='%@' {%@:%d} %@", _lhs, _rhs, XPTestFile, __LINE__, XPTestFunc)
#endif
