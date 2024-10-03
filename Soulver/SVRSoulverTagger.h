//
//  XPRegex.h
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import <Foundation/Foundation.h>


typedef enum {
  // Stores NSDecimalNumber
  SVRSoulverTagNumber,
  // Stores NSValue of SVRSoulverOperator
  SVRSoulverTagOperator,
  // Stores NSValue of the range of the expression
  SVRSoulverTagExpression,
  // Stores NSValue of the range of the bracket
  SVRSoulverTagBracket,
} SVRSoulverTag;

NSString *SVR_stringForTag(SVRSoulverTag tag);
SVRSoulverTag SVR_tagForString(NSString *string);

@interface SVRSoulverTagger: NSObject

+(void)tagNumbersAtRanges:(NSSet*)ranges
       inAttributedString:(NSMutableAttributedString*)string;
+(void)tagOperatorsAtRanges:(NSSet*)ranges
         inAttributedString:(NSMutableAttributedString*)string;
+(void)tagExpressionsAtRanges:(NSSet*)ranges
           inAttributedString:(NSMutableAttributedString*)string;
+(void)tagBracketsAtRanges:(NSSet*)ranges
        inAttributedString:(NSMutableAttributedString*)string;
+(NSDictionary*)attributesWithTag:(SVRSoulverTag)tag andValue:(id)value;

@end

@interface SVRSoulverTagger (Tests)
+(void)executeTests;
@end
