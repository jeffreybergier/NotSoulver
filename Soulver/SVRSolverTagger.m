//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRSolverTagger.h"
#import "SVRCrossPlatform.h"
#import "SVRSolver.h"

@implementation SVRSolverTagger

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
    [string addAttribute:SVR_stringForTag(SVRSoulverTagNumber)
                   value:number
                   range:range];
  }
}

+(void)tagOperatorsAtRanges:(NSSet*)ranges
         inAttributedString:(NSMutableAttributedString*)string;
{
  SVRSoulverOperator operator = (SVRSoulverOperator)-1;
  NSValue *next = nil;
  NSRange range = XPNotFoundRange;
  NSEnumerator *e = [ranges objectEnumerator];
  while ((next = [e nextObject])) {
    range = [next XP_rangeValue];
    operator = SVR_operatorForString([[string string] substringWithRange:range]);
    [string addAttribute:SVR_stringForTag(SVRSoulverTagNumber)
                   value:[NSNumber XP_numberWithInteger:operator]
                   range:range];
  }
}

+(void)tagExpressionsAtRanges:(NSSet*)ranges
           inAttributedString:(NSMutableAttributedString*)string;
{
  NSValue *next = nil;
  NSEnumerator *e = [ranges objectEnumerator];
  while ((next = [e nextObject])) {
    [string addAttribute:SVR_stringForTag(SVRSoulverTagExpression)
                   value:next
                   range:[next XP_rangeValue]];
  }
}

+(void)tagBracketsAtRanges:(NSSet*)ranges
        inAttributedString:(NSMutableAttributedString*)string;
{
  NSValue *next = nil;
  NSEnumerator *e = [ranges objectEnumerator];
  while ((next = [e nextObject])) {
    [string addAttribute:SVR_stringForTag(SVRSoulverTagBracket)
                   value:next
                   range:[next XP_rangeValue]];
  }
}

@end

@implementation SVRSolverTagger (Tests)
+(void)executeTests;
{
  [XPLog alwys:@"SVRSolverTagger Tests: Starting"];
  [XPLog alwys:@"SVRSolverTagger Tests: Passed"];
}
@end
