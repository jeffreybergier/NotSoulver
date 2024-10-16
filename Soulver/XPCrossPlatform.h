/* SVRCrossPlatform.h created by me on Fri 06-Sep-2024 */

// MARK: Forward Declarations
@class SVRMathString;

/// MARK: Simple Typedefs

#if OS_IOS
#import <UIKit/UIKit.h>
#define XPColor UIColor
#else
#import <AppKit/AppKit.h>
#define XPColor NSColor
#endif

// TODO: Consider changing this to NSError in OS X
#define XPError NSNumber

#if OS_OPENSTEP
typedef float XPFloat;
typedef int XPInteger;
typedef unsigned int XPUInteger;
typedef NSString* XPAttributedStringKey;
typedef NSRange* XPRangePointer;
typedef NSNumber** XPErrorPointer;
#define XPLocale NSDictionary
#else
typedef CGFloat XPFloat;
typedef NSInteger XPInteger;
typedef NSUInteger XPUInteger;
typedef NSRangePointer XPRangePointer;
typedef NSNumber** XPErrorPointer;
typedef NSAttributedStringKey XPAttributedStringKey;
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
// TODO: Refactor into log levels
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
-(NSString*)SVR_descriptionForDrawing;
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

@interface XPColor (CrossPlatform)
+(XPColor*)SVR_colorWithRed:(XPFloat)red
                      green:(XPFloat)green
                       blue:(XPFloat)blue
                      alpha:(XPFloat)alpha;
@end

// MARK: Error Handling
@interface XPError (XPError)
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
