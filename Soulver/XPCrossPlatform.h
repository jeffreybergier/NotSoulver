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

#if OS_OPENSTEP
typedef float XPFloat;
typedef int XPInteger;
typedef unsigned int XPUInteger;
typedef NSString* XPAttributedStringKey;
typedef NSRange* XPRangePointer;
#define XPLocale NSDictionary
#define XPTextAlignmentCenter NSCenterTextAlignment
#define XPModalResponseOK NSOKButton
#define XPModalResponseCancel NSCancelButton
#define XPKeyedArchiver NSArchiver
#define XPKeyedUnarchiver NSUnarchiver
#else
typedef CGFloat XPFloat;
typedef NSInteger XPInteger;
typedef NSUInteger XPUInteger;
typedef NSRangePointer XPRangePointer;
typedef NSAttributedStringKey XPAttributedStringKey;
#define XPLocale NSLocale
#define XPTextAlignmentCenter NSTextAlignmentCenter
#define XPModalResponseOK NSModalResponseOK
#define XPModalResponseCancel NSModalResponseCancel
#define XPKeyedArchiver NSKeyedArchiver
#define XPKeyedUnarchiver NSKeyedUnarchiver
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

@interface NSMutableString (CrossPlatform)
-(void)XP_replaceOccurrencesOfString:(NSString*)searchString
                          withString:(NSString*)replaceString;
+(void)XPTEST_replaceOccurrencesOfStringWithString;
@end

@interface XPColor (CrossPlatform)
+(XPColor*)SVR_colorWithRed:(XPFloat)red
                      green:(XPFloat)green
                       blue:(XPFloat)blue
                      alpha:(XPFloat)alpha;
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
/// If font responds to fontDescriptor returns NSFontDescriptor.
/// Otherwise returns self (NSFont)
-(id)XP_fontDescriptor;
/// If descriptor is NSFontDescriptor, inits a font with descriptor
/// Otherwise, returns the descriptor directly (assuming its a font)
+(id)XP_fontWithDescriptor:(id)descriptor;
@end

@interface CrossPlatform: NSObject
+(void)executeUnitTests;
@end

