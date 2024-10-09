/* SVRCrossPlatform.h created by me on Fri 06-Sep-2024 */

// MARK: Forward Declarations
@class SVRMathString;

/// MARK: Simple Typedefs

#if OS_IOS
#import <UIKit/UIKit.h>
#define XPColor UIColor
#define XPPasteboard UIPasteboard
#else
#import <AppKit/AppKit.h>
#define XPColor NSColor
#define XPPasteboard NSPasteboard
#endif

#if OS_OPENSTEP
typedef float XPFloat;
typedef int XPInteger;
typedef unsigned int XPUInteger;
typedef NSString *XPAttributedStringKey;
#define XPPasteboardTypeString NSStringPboardType
#define XPPasteboardTypeRTF NSRTFPboardType
#define XPRTFTextDocumentType @"NSRTF"
#define XPDocumentTypeDocumentAttribute @"NSDocumentType"
#define XPLocale NSDictionary
#else
typedef CGFloat XPFloat;
typedef NSInteger XPInteger;
typedef NSUInteger XPUInteger;
typedef NSAttributedStringKey XPAttributedStringKey;
#define XPPasteboardTypeString NSPasteboardTypeString
#define XPPasteboardTypeRTF NSPasteboardTypeRTF
#define XPRTFTextDocumentType NSRTFTextDocumentType
#define XPDocumentTypeDocumentAttribute NSDocumentTypeDocumentAttribute
#define XPLocale NSLocale
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

@interface XPLog: NSObject
// TODO: Add these Macros
// FOUNDATION_EXPORT void NSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;
/// Always does an NSLog
+(void)alwys:(NSString*)formatString, ...;
/// NSLog when in DEBUG or EXTRA flag found
+(void)debug:(NSString*)formatString, ...;
/// NSLog only when DEBUG and EXTRA flag found
/// Requires `-DEXTRA` CFLAG option in GCC
+(void)extra:(NSString*)formatString, ...;
/// Requires `fb +[XPLog pause:]` in GDB to Pause Debugger
+(void)pause:(NSString*)formatString, ...;
/// Raises an exception with format (crashes in production)
+(void)error:(NSString*)formatString, ...;
@end

@interface NSNumber (CrossPlatform)
+(NSNumber*)XP_numberWithInteger:(XPInteger)integer;
-(XPInteger)XP_integerValue;
@end

#if OS_OPENSTEP
/// These match XPAlertButtonDefault
/// NSAlertDefaultReturn
typedef enum {
  XPAlertReturnDefault   = (XPInteger)1,
  XPAlertReturnAlternate = (XPInteger)0,
  XPAlertReturnOther     = (XPInteger)-1,
  XPAlertReturnError     = (XPInteger)-2
} XPAlertReturn;
#else
typedef NS_ENUM(XPInteger, XPAlertReturn) {
  XPAlertReturnDefault   =  1,
  XPAlertReturnAlternate =  0,
  XPAlertReturnOther     = -1,
  XPAlertReturnError     = -2
};
#endif

@interface XPAlert: NSObject

+(XPAlertReturn)runAppModalWithTitle:(NSString*)title
                             message:(NSString*)message
                       defaultButton:(NSString*)defaultButton
                     alternateButton:(NSString*)alternateButton
                         otherButton:(NSString*)otherButton;
/// Returns ENUM NSAlertDefaultReturn
+(XPAlertReturn)runSheetModalForWindow:(NSWindow*)window
                             withTitle:(NSString*)title
                               message:(NSString*)message
                         defaultButton:(NSString*)defaultButton
                       alternateButton:(NSString*)alternateButton
                           otherButton:(NSString*)otherButton;

@end

@interface XPSavePanel: NSObject
+(NSString*)lastDirectory;
+(void)setLastDirectory:(NSString*)lastDirectory;
/// Returns nil if user cancels
+(NSString*)filenameByRunningSheetModalSavePanelForWindow:(NSWindow*)window;
/// Returns nil if user cancels
+(NSString*)filenameByRunningSheetModalSavePanelForWindow:(NSWindow*)window
                                     withExistingFilename:(NSString*)filename;
@end

@interface XPOpenPanel: XPSavePanel
/// Returns empty array if user cancels
+(NSArray*)filenamesByRunningAppModalOpenPanel;
/// Returns empty array if user cancels
+(NSArray*)filenamesByRunningAppModalOpenPanelWithExistingFilename:(NSString*)filename;
@end

@interface NSUserDefaults (Soulver)
-(NSString*)SVR_savePanelLastDirectory;
-(BOOL)SVR_setSavePanelLastDirectory:(NSString*)newValue;
-(XPColor*)SVR_colorForSolutionPrimary;
-(BOOL)SVR_setColorForSolutionPrimary:(XPColor*)newValue;
-(XPColor*)SVR_backgroundColorForSolutionPrimary;
-(BOOL)SVR_setBackgroundColorForSolutionPrimary:(XPColor*)newValue;
-(XPColor*)SVR_colorForSolutionSecondary;
-(BOOL)SVR_setColorForSolutionSecondary:(XPColor*)newValue;
-(XPColor*)SVR_colorForBracket;
-(BOOL)SVR_setColorForBracket:(XPColor*)newValue;
-(XPColor*)SVR_colorForOperator;
-(BOOL)SVR_setColorForOperator:(XPColor*)newValue;
-(XPColor*)SVR_colorForNumeral;
-(BOOL)SVR_setColorForNumeral:(XPColor*)newValue;
-(XPColor*)SVR_colorForText;
-(BOOL)SVR_setColorForText:(XPColor*)newValue;
// TODO: These are fake and not stored in UserDefaults
-(NSFont*)SVR_fontForText;
-(BOOL)SVR_setFontForText:(NSFont*)newValue;
-(NSDictionary*)SVR_operatorDecodeMap;
-(NSDictionary*)SVR_operatorEncodeMap;
-(NSNumber*)SVR_errorMismatchedBrackets;
-(NSNumber*)SVR_errorInvalidCharacter;
-(NSNumber*)SVR_errorMissingNumber;
-(NSNumber*)SVR_errorPatching;
-(XPLocale*)SVR_decimalNumberLocale;
-(void)SVR_configure;
// MARK: Private
+(NSDictionary*)__SVR_standardDictionary;
+(XPLocale*)__SVR_legacyDecimalNumberLocale;
+(NSDictionary*)__SVR_standardOperatorDecodeMap;
+(NSDictionary*)__SVR_standardOperatorEncodeMap;
@end

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
-(id)nextObjectEffectiveRange:(NSRange*)range;
@end

@interface NSAttributedString (CrossPlatform)
-(NSData*)SVR_pasteboardRepresentation;
-(XPAttributeEnumerator*)SVR_enumeratorForAttribute:(XPAttributedStringKey)key;
-(XPAttributeEnumerator*)SVR_enumeratorForAttribute:(XPAttributedStringKey)key
                         usingLongestEffectiveRange:(BOOL)useLongest;
@end

@interface XPPasteboard (Pasteboard)
-(BOOL)SVR_setAttributedString:(NSAttributedString*)aString;
/// Hack that just sets the raw string as plain text into the pasteboard
-(BOOL)SVR_setMathString:(SVRMathString*)aString;
/// Hack that just get the raw string as plain text from the pasteboard
-(SVRMathString*)SVR_mathString;
@end

@interface NSString (CrossPlatform)
-(NSString*)SVR_descriptionHighlightingRange:(NSRange)range;
-(NSString*)SVR_stringByTrimmingCharactersInSet:(NSCharacterSet*)set;
-(const char*)XP_UTF8String;
@end

@interface NSBundle (CrossPlatform)
-(BOOL)SVR_loadNibNamed:(NSString*)nibName
                  owner:(id)owner
        topLevelObjects:(NSArray**)topLevelObjects;
@end

@interface XPColor (CrossPlatform)
+(XPColor*)SVR_colorWithRed:(XPFloat)red
                      green:(XPFloat)green
                       blue:(XPFloat)blue
                      alpha:(XPFloat)alpha;
@end

// MARK: Error Handling
@interface XPError: NSObject
+(NSNumber*)SVR_errorInvalidCharacter;
+(NSNumber*)SVR_errorMismatchedBrackets;
+(NSNumber*)SVR_errorMissingNumber;
+(NSNumber*)SVR_errorPatching;
+(NSString*)SVR_descriptionForError:(NSNumber*)error;
@end

// MARK: NSDecimalNumber
@interface NSDecimalNumber (Soulver)
/// In OpenStep, NaN comparisons are weird, so this uses a string comparison
-(BOOL)SVR_isNotANumber;
-(NSString*)SVR_description;
+(id)SVR_decimalNumberWithString:(NSString*)string;
-(NSDecimalNumber*)SVR_decimalNumberByRaisingToPower:(NSDecimalNumber*)power;
@end
