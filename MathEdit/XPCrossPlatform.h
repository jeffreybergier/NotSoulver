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

// MARK: Launch Arguments

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

// MARK: Basic Types

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

// MARK: Antifeature Flags

#define AFF_MainMenuFailsNSApplicationMain
#define AFF_MainMenuNotRetainedBySystem
#define AFF_MainMenuRequiresSetAppleMenu
#define AFF_ScrollViewNoMagnification
#define AFF_NSWindowNoFullScreen
#define AFF_ObjCNoDispatch
#define AFF_ObjCNSMethodSignatureUndocumentedClassMethod
#define AFF_NSDocumentNone     // OpenStep did not include NSDocument
#define AFF_NSDocumentNoURL    // NSDocument works but URL's API's dont work for some reason
#define AFF_NSDocumentNoiCloud // NSDocument does not yet support duplicate and other modern iCloud features
#define AFF_NSRegularExpressionNone // SLRE cannot handle non-ascii characters
#define AFF_NSBezierPathNone

#ifdef MAC_OS_X_VERSION_10_2
#undef AFF_MainMenuNotRetainedBySystem
#undef AFF_NSDocumentNone
#undef AFF_NSBezierPathNone
#endif

#ifdef MAC_OS_X_VERSION_10_4
#undef AFF_NSDocumentNoURL
#endif

#ifdef MAC_OS_X_VERSION_10_6
#undef AFF_ObjCNSMethodSignatureUndocumentedClassMethod
#undef AFF_MainMenuRequiresSetAppleMenu
#endif

#ifdef MAC_OS_X_VERSION_10_8
#undef AFF_MainMenuFailsNSApplicationMain
#undef AFF_ScrollViewNoMagnification
#undef AFF_ObjCNoDispatch
#undef AFF_NSDocumentNoiCloud
#endif

#ifdef MAC_OS_X_VERSION_10_15
#undef AFF_NSWindowNoFullScreen
#endif

// MARK: NSDocument

#define XPSupportsTextFindNone 0
#define XPSupportsTextFindPanel 1
#define XPSupportsTextFinder 2

#ifdef MAC_OS_X_VERSION_10_8
#define XPSupportsTextFind XPSupportsTextFinder
#elif defined(MAC_OS_X_VERSION_10_4)
#define XPSupportsTextFind XPSupportsTextFindPanel
#else
#define XPSupportsTextFind XPSupportsTextFindNone
#endif

#define XPUserInterfaceGlass 2
#define XPUserInterfaceAqua 1
#define XPUserInterfaceNone 0

#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 260000
#define XPUserInterface XPUserInterfaceGlass
#elif defined(MAC_OS_X_VERSION_10_2)
#define XPUserInterface XPUserInterfaceAqua
#else
#define XPUserInterface XPUserInterfaceNone
#endif

#ifdef AFF_NSDocumentNone
typedef XPUInteger XPDocumentChangeType;
#define XPWindowController NSResponder // Using typedef here cause build error in OpenStep
#define XPChangeDone 0
#define XPChangeCleared 2
#define XPNewWindowController(_window) nil
#else
typedef NSDocumentChangeType XPDocumentChangeType;
#define XPWindowController NSWindowController
#define XPChangeDone NSChangeDone
#define XPChangeCleared NSChangeCleared
#define XPNewWindowController(_window) [[NSWindowController alloc] initWithWindow:_window]
#endif

// MARK: Deprecated Constants and Types

#ifdef MAC_OS_X_VERSION_10_2
typedef NSBezelStyle XPBezelStyle;
#define XPKeyedArchiver NSKeyedArchiver
#define XPKeyedUnarchiver NSKeyedUnarchiver
#define XPBoxType NSBoxType
#define XPBoxSeparator NSBoxSeparator
#define XPSupportsUnicodeUI
#define XPSupportsTexturedWindows
#define XPSupportsUtilityWindows
#define XPSupportsButtonStyles
#define XPSupportsApplicationMenu
#else
typedef XPUInteger XPBezelStyle;
#define XPKeyedArchiver NSArchiver
#define XPKeyedUnarchiver NSUnarchiver
#define XPBoxType XPUInteger
#define XPBoxSeparator 0
#endif

#ifdef MAC_OS_X_VERSION_10_4
#define XPRTFDocumentAttributes [NSDictionary dictionaryWithObject:NSRTFTextDocumentType forKey:NSDocumentTypeDocumentAttribute]
#define XPError NSError
typedef NSError** XPErrorPointer;
typedef NSRangePointer XPRangePointer;
#else
#define XPRTFDocumentAttributes nil
#define XPError NSNumber
typedef NSNumber** XPErrorPointer;
typedef NSRange* XPRangePointer;
#endif

#ifdef MAC_OS_X_VERSION_10_6
typedef NSViewController XPViewController;
#define XPSupportsNSViewController
#define XPStringCompareOptions NSStringCompareOptions
#define XPPasteboardTypeRTF NSPasteboardTypeRTF
#define XPPasteboardTypeString NSPasteboardTypeString
#define XPWindowCollectionBehavior NSWindowCollectionBehavior
#define XPSupportsFormalProtocols // Protocols like NSWindowDelegate were formally added
#define XPSupportsTemplateImage
#define XPSupportsTextViewGrammarChecks
#else
typedef XPUInteger XPStringCompareOptions;
#define XPViewController NSResponder
#define XPPasteboardTypeRTF NSRTFPboardType
#define XPPasteboardTypeString NSStringPboardType
#define XPWindowCollectionBehavior XPUInteger
#endif

#ifdef MAC_OS_X_VERSION_10_8
#define XPSupportsStateRestoration
typedef void (^XPWindowRestoreCompletionHandler)(NSWindow *window, XPError *error);
#define XPSecureCoding NSSecureCoding
#define XPSaveOperationType NSSaveOperationType
#define XPDataWritingAtomic NSDataWritingAtomic
#define XPSupportsUnicodeDocument // TODO: Update to NSRegularExpression
#undef  XPSupportsTexturedWindows
#else
typedef void (*XPWindowRestoreCompletionHandler)(NSWindow *window, XPError *error);
#define XPSecureCoding NSCoding
#define XPSaveOperationType XPUInteger
#define XPDataWritingAtomic NSAtomicWrite
#endif

#ifdef MAC_OS_X_VERSION_10_15
#define XPTextAlignmentCenter NSTextAlignmentCenter
#define XPTextAlignmentLeft NSTextAlignmentLeft
#define XPTextAlignmentRight NSTextAlignmentRight
#define XPModalResponse NSModalResponse
#define XPModalResponseOK NSModalResponseOK
#define XPModalResponseCancel NSModalResponseCancel
#define XPWindowCollectionBehaviorFullScreenNone NSWindowCollectionBehaviorFullScreenNone
#define XPButtonTypePushOnPushOff NSButtonTypePushOnPushOff
#define XPWindowStyleMask NSWindowStyleMask
#define XPBitmapImageFileTypeTIFF NSBitmapImageFileTypeTIFF
#define XPWindowStyleMaskTitled NSWindowStyleMaskTitled
#define XPWindowStyleMaskClosable NSWindowStyleMaskClosable
#define XPWindowStyleMaskMiniaturizable NSWindowStyleMaskMiniaturizable
#define XPWindowStyleMaskResizable NSWindowStyleMaskResizable
#define XPWindowStyleMaskUtilityWindow NSWindowStyleMaskUtilityWindow
#define XPTextFieldBezelStyle NSTextFieldBezelStyle
#define XPEventModifierFlagOption NSEventModifierFlagOption
#define XPEventModifierFlagCommand NSEventModifierFlagCommand
#define XPEventModifierFlagShift NSEventModifierFlagShift
#define XPSupportsAttractiveRoundTextFields
#else
#define XPTextAlignmentCenter NSCenterTextAlignment
#define XPTextAlignmentLeft NSLeftTextAlignment
#define XPTextAlignmentRight NSRightTextAlignment
#define XPModalResponse XPInteger
#define XPModalResponseOK NSOKButton
#define XPModalResponseCancel NSCancelButton
#define XPWindowCollectionBehaviorFullScreenNone 0
#define XPButtonTypePushOnPushOff NSPushOnPushOffButton
#define XPWindowStyleMask XPUInteger
#define XPBitmapImageFileTypeTIFF NSTIFFFileType
#define XPWindowStyleMaskTitled NSTitledWindowMask
#define XPWindowStyleMaskClosable NSClosableWindowMask
#define XPWindowStyleMaskMiniaturizable NSMiniaturizableWindowMask
#define XPWindowStyleMaskResizable NSResizableWindowMask
#define XPWindowStyleMaskUtilityWindow NSUtilityWindowMask
#define XPEventModifierFlagOption NSAlternateKeyMask
#define XPEventModifierFlagCommand NSCommandKeyMask
#define XPEventModifierFlagShift NSShiftKeyMask
#define XPTextFieldBezelStyle XPBezelStyle
#endif

#ifdef MAC_OS_X_VERSION_10_14
#define XPSupportsDarkMode
#define XPSupportsNSSecureCoding
typedef NSAttributedStringKey XPAttributedStringKey;
#else
typedef NSString* XPAttributedStringKey;
#endif

#ifdef MAC_OS_X_VERSION_10_15
#define XPBezelStyleFlexiblePush NSBezelStyleRegularSquare
#define XPTextFieldRoundedBezel NSTextFieldRoundedBezel
#elif defined(MAC_OS_X_VERSION_10_2)
#define XPBezelStyleFlexiblePush NSRegularSquareBezelStyle
#define XPTextFieldRoundedBezel NSRoundedBezelStyle
#else
#define XPBezelStyleFlexiblePush -1
#define XPTextFieldRoundedBezel -1
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
-(XPAttributeEnumerator*)MATH_enumeratorForAttribute:(XPAttributedStringKey)key;
-(XPAttributeEnumerator*)MATH_enumeratorForAttribute:(XPAttributedStringKey)key
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
+(NSString*)MATH_rootRawString;
+(NSString*)MATH_rootDisplayString;
+(NSString*)MATH_logRawString;
+(NSString*)MATH_logDisplayString;
-(NSString*)MATH_descriptionHighlightingRange:(NSRange)range;
-(const char*)XP_cString;
-(XPUInteger)XP_cStringLength;
-(BOOL)XP_containsNonASCIICharacters;
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

@interface NSWorkspace (CrossPlatform)
/// OpenStep basically was pre-internet and did not expect
/// websites to be opened with this method.
-(BOOL)XP_openWebURL:(NSString*)webURL;
@end

#ifndef AFF_NSBezierPathNone
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
-(void)XP_setAllowsUndo:(BOOL)flag;
-(void)XP_setUsesFindPanel:(BOOL)flag;
-(void)XP_setUsesFindBar:(BOOL)flag;
-(void)XP_setContinuousSpellCheckingEnabled:(BOOL)flag;
-(void)XP_setGrammarCheckingEnabled:(BOOL)flag;
-(void)XP_setAutomaticSpellingCorrectionEnabled:(BOOL)flag;
@end

@interface NSTextField (CrossPlatform)
-(void)XP_setBezelStyle:(XPTextFieldBezelStyle)style;
@end

@interface NSButton (CrossPlatform)
-(void)XP_setBezelStyle:(XPBezelStyle)style;
@end

@interface NSBox (CrossPlatform)
-(void)XP_setBoxType:(XPBoxType)type;
@end

@interface NSWindow (CrossPlatform)
-(void)XP_setRestorationClass:(Class)aClass;
-(void)XP_setIdentifier:(NSString*)anIdentifier;
-(void)XP_setAppearanceWithUserInterfaceStyle:(XPUserInterfaceStyle)aStyle;
-(void)XP_setCollectionBehavior:(XPWindowCollectionBehavior)collectionBehavior;
-(void)XP_setContentViewController:(XPViewController*)viewController;
@end

@interface NSScrollView (CrossPlatform)
-(void)XP_setDrawsBackground:(BOOL)drawsBackground;
-(void)XP_setAllowsMagnification:(BOOL)flag;
-(void)XP_setMagnification:(XPFloat)newValue;
-(XPFloat)XP_magnification;
@end

// These are not implemented, but silence compiler warnings
@interface NSResponder (XPFirstResponder)
-(IBAction)undo:(id)sender;
-(IBAction)redo:(id)sender;
#ifdef AFF_NSDocumentNoiCloud
-(IBAction)duplicateDocument:(id)sender;
-(IBAction)renameDocument:(id)sender;
-(IBAction)moveDocument:(id)sender;
-(IBAction)browseDocumentVersions:(id)sender;
-(void)setContentViewController:(id)aVC;
#endif
@end

// MARK: XPLogging

@interface XPLog: NSObject
+(void)logCheckedPoundDefines;
@end

NSString *XPStringFromErrorPointer(XPErrorPointer ptr);

// OpenStep does not understand the %p format string so this works around that
#ifdef MAC_OS_X_VERSION_10_2
#define XPPointerString(_self) ([NSString stringWithFormat:@"%p", (void*)_self])
#else
#define XPPointerString(_self) ([NSString stringWithFormat:@"0x%08x", (unsigned int)(_self)])
#endif

#ifdef MAC_OS_X_VERSION_10_4
#define XPLogFunc [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]
#define XPLogFile [[[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"/"] lastObject]
#else
#define XPLogFunc [NSString stringWithCString:__PRETTY_FUNCTION__]
#define XPLogFile [[[NSString stringWithCString:__FILE__] componentsSeparatedByString:@"/"] lastObject]
#endif

#define __XPLogBase(_prefix, _formatString)                             NSLog(@"[%@] {%@:%d} %@ %@", _prefix, XPLogFile, __LINE__, XPLogFunc, _formatString)
#define __XPLogBase1(_prefix, _formatString, _one)                      NSLog(@"[%@] {%@:%d} %@ %@", _prefix, XPLogFile, __LINE__, XPLogFunc, [NSString stringWithFormat:_formatString, _one])
#define __XPLogBase2(_prefix, _formatString, _one, _two)                NSLog(@"[%@] {%@:%d} %@ %@", _prefix, XPLogFile, __LINE__, XPLogFunc, [NSString stringWithFormat:_formatString, _one, _two])
#define __XPLogBase3(_prefix, _formatString, _one, _two, _three)        NSLog(@"[%@] {%@:%d} %@ %@", _prefix, XPLogFile, __LINE__, XPLogFunc, [NSString stringWithFormat:_formatString, _one, _two, _three])
#define __XPLogBase4(_prefix, _formatString, _one, _two, _three, _four) NSLog(@"[%@] {%@:%d} %@ %@", _prefix, XPLogFile, __LINE__, XPLogFunc, [NSString stringWithFormat:_formatString, _one, _two, _three, _four])

// Define ParameterAssert that crashes in release mode
// These are used in init methods to skip the if (self) {} check
#ifdef DEBUG
#define XPParameterRaise(_parameter)  if (!_parameter) { __XPLogBase1(@"RAISE", @"%@", _parameter); } NSParameterAssert(_parameter)
#define XPCParameterRaise(_parameter) if (!_parameter) { __XPLogBase1(@"RAISE", @"%@", _parameter); } NSCParameterAssert(_parameter)
#else
#define XPParameterRaise(_parameter)  if (!_parameter) { __XPLogBase1(@"RAISE", @"%@", _parameter); [NSException raise:@"XPParameterRaise" format:@"%@", _parameter]; }
#define XPCParameterRaise(_parameter) if (!_parameter) { __XPLogBase1(@"RAISE", @"%@", _parameter); [NSException raise:@"XPParameterRaise" format:@"%@", _parameter]; }
#endif

// Define Always Macros
#define XPLogAlwys(_formatString)                             __XPLogBase (@"ALWYS", _formatString)
#define XPLogAlwys1(_formatString, _one)                      __XPLogBase1(@"ALWYS", _formatString, _one)
#define XPLogAlwys2(_formatString, _one, _two)                __XPLogBase2(@"ALWYS", _formatString, _one, _two)
#define XPLogAlwys3(_formatString, _one, _two, _three)        __XPLogBase3(@"ALWYS", _formatString, _one, _two, _three)
#define XPLogAlwys4(_formatString, _one, _two, _three, _four) __XPLogBase4(@"ALWYS", _formatString, _one, _two, _three, _four)
#define XPLogRaise(_formatString)                             __XPLogBase (@"RAISE", _formatString); [NSException raise:@"MATHException" format:_formatString]
#define XPLogRaise1(_formatString, _one)                      __XPLogBase1(@"RAISE", _formatString, _one); [NSException raise:@"MATHException" format:_formatString, _one]
#define XPLogRaise2(_formatString, _one, _two)                __XPLogBase2(@"RAISE", _formatString, _one, _two); [NSException raise:@"MATHException" format:_formatString, _one, _two]
#define XPLogRaise3(_formatString, _one, _two, _three)        __XPLogBase3(@"RAISE", _formatString, _one, _two, _three); [NSException raise:@"MATHException" format:_formatString, _one, _two, _three]
#define XPLogRaise4(_formatString, _one, _two, _three, _four) __XPLogBase4(@"RAISE", _formatString, _one, _two, _three, _four); [NSException raise:@"MATHException" format:_formatString, _one, _two, _three, _four]

#ifdef DEBUG
#define XPLogAssrt(_condition, _formatString)                              if (!(_condition)) { __XPLogBase (@"ASSRT", _formatString); } NSAssert(_condition, _formatString)
#define XPLogAssrt1(_condition, _formatString, _one)                       if (!(_condition)) { __XPLogBase1(@"ASSRT", _formatString, _one); } NSAssert1(_condition, _formatString, _one)
#define XPLogAssrt2(_condition, _formatString, _one, _two)                 if (!(_condition)) { __XPLogBase2(@"ASSRT", _formatString, _one, _two); } NSAssert2(_condition, _formatString, _one, _two)
#define XPLogAssrt3(_condition, _formatString, _one, _two, _three)         if (!(_condition)) { __XPLogBase3(@"ASSRT", _formatString, _one, _two, _three); } NSAssert3(_condition, _formatString, _one, _two, _three)
#define XPLogAssrt4(_condition, _formatString, _one, _two, _three, _four)  if (!(_condition)) { __XPLogBase4(@"ASSRT", _formatString, _one, _two, _three, _four); } NSAssert4(_condition, _formatString, _one, _two, _three, _four)
#define XPCLogAssrt(_condition, _formatString)                             if (!(_condition)) { __XPLogBase (@"ASSRT", _formatString); } NSCAssert(_condition, _formatString)
#define XPCLogAssrt1(_condition, _formatString, _one)                      if (!(_condition)) { __XPLogBase1(@"ASSRT", _formatString, _one); } NSCAssert1(_condition, _formatString, _one)
#define XPCLogAssrt2(_condition, _formatString, _one, _two)                if (!(_condition)) { __XPLogBase2(@"ASSRT", _formatString, _one, _two); } NSCAssert2(_condition, _formatString, _one, _two)
#define XPCLogAssrt3(_condition, _formatString, _one, _two, _three)        if (!(_condition)) { __XPLogBase3(@"ASSRT", _formatString, _one, _two, _three); } NSCAssert3(_condition, _formatString, _one, _two, _three)
#define XPCLogAssrt4(_condition, _formatString, _one, _two, _three, _four) if (!(_condition)) { __XPLogBase4(@"ASSRT", _formatString, _one, _two, _three, _four); } NSCAssert4(_condition, _formatString, _one, _two, _three, _four)
#else
#define XPLogAssrt(_condition, _formatString)
#define XPLogAssrt1(_condition, _formatString, _one)
#define XPLogAssrt2(_condition, _formatString, _one, _two)
#define XPLogAssrt3(_condition, _formatString, _one, _two, _three)
#define XPLogAssrt4(_condition, _formatString, _one, _two, _three, _four)
#define XPCLogAssrt(_condition, _formatString)
#define XPCLogAssrt1(_condition, _formatString, _one)
#define XPCLogAssrt2(_condition, _formatString, _one, _two)
#define XPCLogAssrt3(_condition, _formatString, _one, _two, _three)
#define XPCLogAssrt4(_condition, _formatString, _one, _two, _three, _four)
#endif

// Define Debug Macros
#if LOGLEVEL >= LOGLEVELDEBUG
#define XPLogDebug(_formatString)                             __XPLogBase (@"DEBUG", _formatString)
#define XPLogDebug1(_formatString, _one)                      __XPLogBase1(@"DEBUG", _formatString, _one)
#define XPLogDebug2(_formatString, _one, _two)                __XPLogBase2(@"DEBUG", _formatString, _one, _two)
#define XPLogDebug3(_formatString, _one, _two, _three)        __XPLogBase3(@"DEBUG", _formatString, _one, _two, _three)
#define XPLogDebug4(_formatString, _one, _two, _three, _four) __XPLogBase4(@"DEBUG", _formatString, _one, _two, _three, _four)
#else
#define XPLogDebug(_formatString)
#define XPLogDebug1(_formatString, _one)
#define XPLogDebug2(_formatString, _one, _two)
#define XPLogDebug3(_formatString, _one, _two, _three)
#define XPLogDebug4(_formatString, _one, _two, _three, _four)
#endif

#if LOGLEVEL >= LOGLEVELEXTRA
#define XPLogExtra(_formatString)                             __XPLogBase (@"EXTRA", _formatString)
#define XPLogExtra1(_formatString, _one)                      __XPLogBase1(@"EXTRA", _formatString, _one)
#define XPLogExtra2(_formatString, _one, _two)                __XPLogBase2(@"EXTRA", _formatString, _one, _two)
#define XPLogExtra3(_formatString, _one, _two, _three)        __XPLogBase3(@"EXTRA", _formatString, _one, _two, _three)
#define XPLogExtra4(_formatString, _one, _two, _three, _four) __XPLogBase4(@"EXTRA", _formatString, _one, _two, _three, _four)
#else
#define XPLogExtra(_formatString)
#define XPLogExtra1(_formatString, _one)
#define XPLogExtra2(_formatString, _one, _two)
#define XPLogExtra3(_formatString, _one, _two, _three)
#define XPLogExtra4(_formatString, _one, _two, _three, _four)
#endif

// MARK: XPTest

#if TESTING == 1
#define XPTestInt(_lhs, _rhs)         NSAssert5(_lhs == _rhs, @"[FAIL] '%d'!='%d' {%@:%d} %@", (int)_lhs, (int)_rhs, XPLogFile, __LINE__, XPLogFunc)
#define XPTestBool(_lhs)              NSAssert3(_lhs, @"[FAIL] Bool was NO {%@:%d} %@", XPLogFile, __LINE__, XPLogFunc)
#define XPTestFloat(_lhs, _rhs)       NSAssert5(_lhs == _rhs, @"[FAIL] '%g'!='%g' {%@:%d} %@", _lhs, _rhs, XPLogFile, __LINE__, XPLogFunc)
#define XPTestObject(_lhs, _rhs)      NSAssert5([_lhs isEqual:_rhs], @"[FAIL] '%@'!='%@' {%@:%d} %@", _lhs, _rhs, XPLogFile, __LINE__, XPLogFunc)
#define XPTestNotNIL(_lhs)            NSAssert3(_lhs, @"[FAIL] Object was NIL {%@:%d} %@", XPLogFile, __LINE__, XPLogFunc)
#define XPTestString(_lhs, _rhs)      NSAssert5([_lhs isEqualToString:_rhs], @"[FAIL] '%@'!='%@' {%@:%d} %@", _lhs, _rhs, XPLogFile, __LINE__, XPLogFunc)
#define XPTestRange(_lhs, _loc, _len) NSAssert5(NSEqualRanges(_lhs, NSMakeRange(_loc, _len)), @"[FAIL] %@!=%@ {%@:%d} %@", NSStringFromRange(_lhs), NSStringFromRange(NSMakeRange(_loc, _len)), XPLogFile, __LINE__, XPLogFunc)
#define XPTestAttrString(_lhs, _rhs)  NSAssert5([_lhs isEqualToAttributedString:_rhs], @"[FAIL] '%@'!='%@' {%@:%d} %@", _lhs, _rhs, XPLogFile, __LINE__, XPLogFunc)
#endif
