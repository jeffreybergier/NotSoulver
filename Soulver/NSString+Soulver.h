//
//  NSAttributedString+Soulver.h
//  MathTree
//
//  Created by Jeffrey Bergier on 2024/08/02.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

// MARK: NSAttributedString
@interface NSAttributedString (Soulver)
+(id)withString:(NSString*)aString;
+(id)withString:(NSString*)aString andColor:(NSColor*)aColor;
@end

@interface NSMutableAttributedString (Soulver)
+(id)withString:(NSString*)aString;
+(id)withString:(NSString*)aString andColor:(NSColor*)aColor;
@end

@interface SVRStringEnumeratorObject: NSObject
{
  NSRange _range;
  NSString *_substring;
}
-(NSRange)range;
-(NSString*)substring;
-(NSString*)description;
-(id)initWithRange:(NSRange)range substring:(NSString*)substring;
+(id)objectWithRange:(NSRange)range substring:(NSString*)substring;
@end

// MARK: Custom Enumerator
@interface SVRStringEnumerator: NSEnumerator
{
  NSString *_string;
  NSRange _range;
}
-(SVRStringEnumeratorObject*)nextObject;
-(id)initWithString:(NSString*)string;
+(id)enumeratorWithString:(NSString*)string;
@end

// MARK: NSError
// OPENSTEP does not have NSError so I am just using NSNumber
@interface NSNumber (NSError)
+(NSNumber*)errorInvalidCharacter;
+(NSNumber*)errorMismatchedBrackets;
+(NSNumber*)errorMissingNumberBeforeOrAfterOperator;
+(NSNumber*)errorPatching;
@end

// MARK: NSSetHelper
@interface NSSet (Soulver)
+(NSSet*)SVROperators;
+(NSSet*)SVRPlusMinus;
+(NSSet*)SVRMultDiv;
+(NSSet*)SVRExponent;
+(NSSet*)SVRNumerals;
+(NSSet*)SVRPatchCheck;
+(NSSet*)SVRAllowedCharacters;
@end

// MARK: Logging
@interface NSString (SVRLog)
/// Replaces newlines from logged strings with \n
-(void)SVRLog;
@end
