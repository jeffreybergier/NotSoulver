//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRSolverExpressionTagger.h"
#import "XPCrossPlatform.h"
#import "SVRSolver.h"

@implementation SVRSolverExpressionTagger

+(void)tagNumbersAtRanges:(NSSet*)ranges
       inAttributedString:(NSMutableAttributedString*)string;
{
  NSDecimalNumber *number = nil;
  NSValue *next = nil;
  NSRange range = XPNotFoundRange;
  NSEnumerator *e = [ranges objectEnumerator];
  while ((next = [e nextObject])) {
    range = [next XP_rangeValue];
    number = [NSDecimalNumber decimalNumberWithString:[[string string] substringWithRange:range]];
    if ([number SVR_isNotANumber]) {
      [XPLog pause:@"NaN: %@", number];
    }
    [string addAttribute:XPAttributedStringKeyForTag(SVRSolverTagNumber)
                   value:number
                   range:range];
  }
}

+(void)tagOperatorsAtRanges:(NSSet*)ranges
         inAttributedString:(NSMutableAttributedString*)string;
{
  SVRSolverOperator operator = (SVRSolverOperator)-1;
  NSValue *next = nil;
  NSRange range = XPNotFoundRange;
  NSEnumerator *e = [ranges objectEnumerator];
  while ((next = [e nextObject])) {
    range = [next XP_rangeValue];
    operator = SVRSolverOperatorForRawString([[string string] substringWithRange:range]);
    [string addAttribute:XPAttributedStringKeyForTag(SVRSolverTagOperator)
                   value:NSNumberForOperator(operator)
                   range:range];
  }
}

+(void)tagExpressionsAtRanges:(NSSet*)ranges
           inAttributedString:(NSMutableAttributedString*)string;
{
  NSValue *next = nil;
  NSEnumerator *e = [ranges objectEnumerator];
  while ((next = [e nextObject])) {
    [string addAttribute:XPAttributedStringKeyForTag(SVRSolverTagExpression)
                   value:NSStringFromRange([next XP_rangeValue])
                   range:[next XP_rangeValue]];
  }
}

+(void)tagBracketsAtRanges:(NSSet*)ranges
        inAttributedString:(NSMutableAttributedString*)string;
{
  NSValue *next = nil;
  NSEnumerator *e = [ranges objectEnumerator];
  while ((next = [e nextObject])) {
    [string addAttribute:XPAttributedStringKeyForTag(SVRSolverTagBracket)
                   value:NSStringFromRange([next XP_rangeValue])
                   range:[next XP_rangeValue]];
  }
}

@end
