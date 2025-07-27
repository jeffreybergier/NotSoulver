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

// MARK: Antifeature Flags

#define AFF_NSApplicationMainRequiresNIB
#define AFF_MainMenuNotRetainedBySystem
#define AFF_MainMenuRequiresSetAppleMenu
#define AFF_MainMenuNoApplicationMenu
#define AFF_UIStyleAquaNone
#define AFF_UIStyleDarkModeNone
#define AFF_NSScrollViewDrawsBackgroundNone
#define AFF_NSScrollViewMagnificationNone
#define AFF_NSWindowNoFullScreen
#define AFF_C_isnan_isinf_None
#define AFF_C_percentP_None
#define AFF_C__FILE__FUNCTION__Legacy
#define AFF_ObjCNoDispatch
#define AFF_ObjCNSMethodSignatureUndocumentedClassMethod
#define AFF_ObjCNSIntegerNone
#define AFF_ObjCCGFloatNone
#define AFF_ObjCNSEnumNone
#define AFF_NSDocumentNone     // OpenStep did not include NSDocument
#define AFF_NSDocumentNoURL    // NSDocument works but URL's API's dont work for some reason
#define AFF_NSDocumentNoiCloud // NSDocument does not yet support duplicate and other modern iCloud features
#define AFF_NSRegularExpressionNone // SLRE cannot handle non-ascii characters
#define AFF_NSBezierPathNone
#define AFF_NSBezierPathRoundRectNone
#define AFF_NSKeyedArchiverNone
#define AFF_NSSecureCodingNone
#define AFF_UnicodeUINone
#define AFF_UnicodeDocumentNone // TODO: Not used yet
#define AFF_NSTextViewInsertTextLegacy
#define AFF_NSTextViewFindNone
#define AFF_NSTextViewFindNoInline
#define AFF_NSTextViewSubstitutionsAndGrammarNone
#define AFF_NSButtonStylesNone
#define AFF_NSTextFieldRoundedStyleUgly
#define AFF_NSWindowStyleTexturedNone
#define AFF_NSWindowStyleUtilityNone
#define AFF_NSWindowCollectionBehaviorNone
#define AFF_NSWindowControllerNone
#define AFF_NSWindowContentViewControllerNone
#define AFF_NSViewControllerNone
#define AFF_FormalProtocolsNone
#define AFF_NSImageTemplateNone
#define AFF_StateRestorationNone
#define AFF_NSErrorNone
#define AFF_NSStringUTF8StringNone
#define AFF_NSStringLengthOfBytesNone
#define AFF_NSFontDescriptorNone
#define AFF_NSWorkspaceWebURLNone
#define AFF_APINSValueNSRangeNone
#define AFF_APIWritingRenameNone
#define AFF_APIPasteboardRenameNone
#define AFF_APIUpdatedForSwiftNone
#define TMP_AFF_TEST_NSBezierPathTestsBroken
#define TMP_AFF_TEST_NSAttributedStringIsEqualBroken

// MARK: Don't Disable These Platform Features

#if defined(__m68k__) || defined(__ppc__) || defined (MAC_OS_X_VERSION_10_12)
#undef TMP_AFF_TEST_NSAttributedStringIsEqualBroken
#endif

#ifdef NSIntegerMax
#undef AFF_ObjCNSIntegerNone
#endif

#ifdef CGFLOAT_MAX
#undef AFF_ObjCCGFloatNone
#endif

#ifdef NS_ENUM
#undef AFF_ObjCNSEnumNone
#endif

#ifdef MAC_OS_X_VERSION_10_2
#undef AFF_MainMenuNotRetainedBySystem
#undef AFF_MainMenuNoApplicationMenu
#undef AFF_NSKeyedArchiverNone
#undef AFF_C_isnan_isinf_None
#undef AFF_C_percentP_None
#endif

#ifdef MAC_OS_X_VERSION_10_4
#undef AFF_C__FILE__FUNCTION__Legacy
#undef AFF_NSFontDescriptorNone
#endif

#ifdef MAC_OS_X_VERSION_10_15
#undef AFF_NSSecureCodingNone
#endif

// MARK: Can Comment Out Up To Here

#ifdef MAC_OS_X_VERSION_10_2
#undef AFF_UIStyleAquaNone
#undef AFF_NSDocumentNone
#undef AFF_NSBezierPathNone
#undef AFF_UnicodeUINone
#undef AFF_NSButtonStylesNone
#undef AFF_NSWindowStyleTexturedNone
#undef AFF_NSWindowStyleUtilityNone
#undef AFF_NSWindowControllerNone
#undef AFF_APINSValueNSRangeNone
#undef AFF_NSStringUTF8StringNone
#undef AFF_NSWorkspaceWebURLNone
#undef AFF_NSScrollViewDrawsBackgroundNone
#endif

#ifdef MAC_OS_X_VERSION_10_4
#undef AFF_NSDocumentNoURL
#undef AFF_NSTextViewFindNone
#undef AFF_NSErrorNone
#undef AFF_NSStringLengthOfBytesNone
#endif

#ifdef MAC_OS_X_VERSION_10_6
#undef AFF_ObjCNSMethodSignatureUndocumentedClassMethod
#undef AFF_MainMenuRequiresSetAppleMenu
#undef AFF_NSTextViewInsertTextLegacy
#undef AFF_NSTextViewSubstitutionsAndGrammarNone
#undef AFF_NSViewControllerNone
#undef AFF_FormalProtocolsNone
#undef AFF_NSImageTemplateNone
#undef AFF_NSWindowCollectionBehaviorNone
#undef AFF_APIPasteboardRenameNone
#undef AFF_NSBezierPathRoundRectNone
#endif

#ifdef MAC_OS_X_VERSION_10_8
#undef AFF_NSApplicationMainRequiresNIB
#undef AFF_NSScrollViewMagnificationNone
#undef AFF_ObjCNoDispatch
#undef AFF_NSDocumentNoiCloud
#undef AFF_NSTextViewFindNoInline
#undef AFF_StateRestorationNone
#undef AFF_APIWritingRenameNone
#define AFF_NSWindowStyleTexturedNone
#endif

#ifdef MAC_OS_X_VERSION_10_15
#undef AFF_NSWindowNoFullScreen
#undef AFF_NSWindowContentViewControllerNone
#undef AFF_NSTextFieldRoundedStyleUgly
#undef AFF_UIStyleDarkModeNone
#undef AFF_APIUpdatedForSwiftNone
#endif

#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 150000
#undef TMP_AFF_TEST_NSBezierPathTestsBroken
#endif

#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 260000
#define AFF_UIStyleAquaNone
#endif

// MARK: AFF_Basic Types

#ifdef AFF_ObjCNSIntegerNone
typedef int XPInteger;
typedef unsigned int XPUInteger;
#else
typedef NSInteger XPInteger;
typedef NSUInteger XPUInteger;
#endif

#ifdef AFF_ObjCCGFloatNone
typedef float XPFloat;
#else
typedef CGFloat XPFloat;
#endif

typedef NSRange* XPRangePointer;
extern const NSRange XPNotFoundRange;
BOOL XPIsNotFoundRange(NSRange range);
BOOL XPContainsRange(NSRange lhs, NSRange rhs);

#ifdef AFF_ObjCNSEnumNone
#define XP_ENUM(_type, _name) _type _name; enum
#else
#define XP_ENUM(_type, _name) NS_ENUM(_type, _name)
#endif

// MARK: AFF_Archiver

#ifdef AFF_NSKeyedArchiverNone
#define XPKeyedArchiver NSArchiver
#define XPKeyedUnarchiver NSUnarchiver
#else
#define XPKeyedArchiver NSKeyedArchiver
#define XPKeyedUnarchiver NSKeyedUnarchiver
#endif

#ifdef AFF_NSSecureCodingNone
#define XPSecureCoding NSCoding
#else
#define XPSecureCoding NSSecureCoding
#endif

// MARK: AFF_UI Styles

#ifdef AFF_NSButtonStylesNone
typedef XPUInteger XPBezelStyle;
typedef XPUInteger XPBoxType;
#define XPBoxSeparator 0
#else
typedef NSBezelStyle XPBezelStyle;
typedef NSBoxType XPBoxType;
#define XPBoxSeparator NSBoxSeparator
#endif

#ifdef AFF_NSButtonStylesNone
#define XPBezelStyleFlexiblePush -1
#define XPTextFieldRoundedBezel -1
#elif defined(AFF_NSTextFieldRoundedStyleUgly)
#define XPBezelStyleFlexiblePush NSRegularSquareBezelStyle
#define XPTextFieldRoundedBezel NSRoundedBezelStyle
#else
#define XPBezelStyleFlexiblePush NSBezelStyleRegularSquare
#define XPTextFieldRoundedBezel NSTextFieldRoundedBezel
#endif

// MARK: AFF_ViewController / WindowController

#ifdef AFF_NSWindowControllerNone
typedef NSResponder *XPWindowController;
#define XPNewWindowController(_window) nil
#else
typedef NSWindowController *XPWindowController;
#define XPNewWindowController(_window) [[NSWindowController alloc] initWithWindow:_window]
#endif

#ifdef AFF_NSViewControllerNone
typedef NSResponder *XPViewController;
#else
typedef NSViewController *XPViewController;
#endif

#ifdef AFF_NSWindowCollectionBehaviorNone
typedef XPUInteger XPWindowCollectionBehavior;
#else
typedef NSWindowCollectionBehavior XPWindowCollectionBehavior;
#endif

#ifdef AFF_StateRestorationNone
typedef void (*XPWindowRestoreCompletionHandler)(NSWindow *window, id error);
#else
typedef void (^XPWindowRestoreCompletionHandler)(NSWindow *window, id error);
#endif

// MARK: AFF_Error

#ifdef AFF_NSErrorNone
typedef NSNumber *XPError;
typedef NSNumber **XPErrorPointer;
#else
typedef NSError *XPError;
typedef NSError **XPErrorPointer;
#endif

// MARK: AFF_NSDocument

#ifdef AFF_NSDocumentNone
typedef XPUInteger XPDocumentChangeType;
#define XPChangeDone 0
#define XPChangeCleared 2
#else
typedef NSDocumentChangeType XPDocumentChangeType;
#define XPChangeDone NSChangeDone
#define XPChangeCleared NSChangeCleared
#endif

#ifdef AFF_NSDocumentNoURL
#define XPRTFDocumentAttributes nil
#else
#define XPRTFDocumentAttributes [NSDictionary dictionaryWithObject:NSRTFTextDocumentType forKey:NSDocumentTypeDocumentAttribute]
#endif

// MARK: AFF_API Renames

#ifdef AFF_APIPasteboardRenameNone
typedef XPUInteger XPStringCompareOptions;
#define XPPasteboardTypeRTF NSRTFPboardType
#define XPPasteboardTypeString NSStringPboardType
#else
typedef NSStringCompareOptions XPStringCompareOptions;
#define XPPasteboardTypeRTF NSPasteboardTypeRTF
#define XPPasteboardTypeString NSPasteboardTypeString
#endif

#ifdef AFF_APIWritingRenameNone
typedef XPUInteger XPSaveOperationType;
#define XPDataWritingAtomic NSAtomicWrite
#else
typedef NSSaveOperationType XPSaveOperationType;
#define XPDataWritingAtomic NSDataWritingAtomic
#endif

#ifdef AFF_APIUpdatedForSwiftNone
typedef NSString* XPAttributedStringKey;
#define XPTextAlignmentCenter NSCenterTextAlignment
#define XPTextAlignmentLeft NSLeftTextAlignment
#define XPTextAlignmentRight NSRightTextAlignment
typedef XPInteger XPModalResponse;
#define XPModalResponseOK NSOKButton
#define XPModalResponseCancel NSCancelButton
#define XPWindowCollectionBehaviorFullScreenNone 0
#define XPButtonTypePushOnPushOff NSPushOnPushOffButton
typedef XPUInteger XPWindowStyleMask;
#define XPBitmapImageFileTypeTIFF NSTIFFFileType
#define XPWindowStyleMaskTitled NSTitledWindowMask
#define XPWindowStyleMaskClosable NSClosableWindowMask
#define XPWindowStyleMaskMiniaturizable NSMiniaturizableWindowMask
#define XPWindowStyleMaskResizable NSResizableWindowMask
#define XPWindowStyleMaskUtilityWindow NSUtilityWindowMask
typedef XPBezelStyle XPTextFieldBezelStyle;
#define XPEventModifierFlagOption NSAlternateKeyMask
#define XPEventModifierFlagCommand NSCommandKeyMask
#define XPEventModifierFlagShift NSShiftKeyMask
#else
typedef NSAttributedStringKey XPAttributedStringKey;
#define XPTextAlignmentCenter NSTextAlignmentCenter
#define XPTextAlignmentLeft NSTextAlignmentLeft
#define XPTextAlignmentRight NSTextAlignmentRight
typedef NSModalResponse XPModalResponse;
#define XPModalResponseOK NSModalResponseOK
#define XPModalResponseCancel NSModalResponseCancel
#define XPWindowCollectionBehaviorFullScreenNone NSWindowCollectionBehaviorFullScreenNone
#define XPButtonTypePushOnPushOff NSButtonTypePushOnPushOff
typedef NSWindowStyleMask XPWindowStyleMask;
#define XPBitmapImageFileTypeTIFF NSBitmapImageFileTypeTIFF
#define XPWindowStyleMaskTitled NSWindowStyleMaskTitled
#define XPWindowStyleMaskClosable NSWindowStyleMaskClosable
#define XPWindowStyleMaskMiniaturizable NSWindowStyleMaskMiniaturizable
#define XPWindowStyleMaskResizable NSWindowStyleMaskResizable
#define XPWindowStyleMaskUtilityWindow NSWindowStyleMaskUtilityWindow
typedef NSTextFieldBezelStyle XPTextFieldBezelStyle;
#define XPEventModifierFlagOption NSEventModifierFlagOption
#define XPEventModifierFlagCommand NSEventModifierFlagCommand
#define XPEventModifierFlagShift NSEventModifierFlagShift
#endif

// MARK: Object Categories

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
-(void)XP_setAutomaticLinkDetectionEnabled:(BOOL)flag;
-(void)XP_setAutomaticDataDetectionEnabled:(BOOL)flag;
-(void)XP_setAutomaticQuoteSubstitutionEnabled:(BOOL)flag;
-(void)XP_setAutomaticDashSubstitutionEnabled:(BOOL)flag;
-(void)XP_setAutomaticTextReplacementEnabled:(BOOL)flag;
-(IBAction)XP_checkTextInDocument:(id)sender;
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
-(void)XP_setContentViewController:(XPViewController)viewController;
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
#ifdef AFF_C_percentP_None
#define XPPointerString(_self) ([NSString stringWithFormat:@"0x%08x", (unsigned int)(_self)])
#else
#define XPPointerString(_self) ([NSString stringWithFormat:@"%p", (void*)_self])
#endif

#ifdef AFF_C__FILE__FUNCTION__Legacy
#define XPLogFunc [NSString stringWithCString:__PRETTY_FUNCTION__]
#define XPLogFile [[[NSString stringWithCString:__FILE__] componentsSeparatedByString:@"/"] lastObject]
#else
#define XPLogFunc [NSString stringWithCString:__PRETTY_FUNCTION__ encoding:NSUTF8StringEncoding]
#define XPLogFile [[[NSString stringWithCString:__FILE__ encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"/"] lastObject]
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
