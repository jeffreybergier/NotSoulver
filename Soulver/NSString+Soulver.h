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
+(id)SVR_stringWithString:(NSString*)aString;
+(id)SVR_stringWithString:(NSString*)aString color:(NSColor*)aColor;
@end

// MARK: NSString
@interface NSString (Soulver)
-(BOOL)SVR_containsOnlyCharactersInSet:(NSSet*)set;
-(BOOL)SVR_beginsWithCharacterInSet:(NSSet*)set;
-(NSString*)SVR_stringByMappingCharactersInDictionary:(NSDictionary*)map;
@end

// MARK: NSMutableString
@interface NSMutableString (Soulver)
-(void)SVR_insertSolution:(NSString*)solution
                  atRange:(NSRange)range
                    error:(NSNumber**)error;
@end

// MARK: NSStringEnumerator
@interface SVRStringEnumeratorRange: NSObject
{
  NSRange _range;
  NSString *_substring;
}
-(NSRange)range;
-(NSString*)substring;
-(NSString*)description;
-(id)initWithRange:(NSRange)range substring:(NSString*)substring;
+(id)rangeWithRange:(NSRange)range substring:(NSString*)substring;
@end

@interface SVRStringEnumerator: NSEnumerator
{
  NSString *_string;
  NSRange _range;
}
-(SVRStringEnumeratorRange*)nextObject;
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
+(NSSet*)SVRSolutionInsertCheck;
+(NSSet*)SVRAllowedCharacters;
@end

// MARK: NSDictionaryHelper
@interface NSDictionary (Soulver)
+(NSDictionary*)SVROperatorDecodeMap;
+(NSDictionary*)SVROperatorEncodeMap;
@end
