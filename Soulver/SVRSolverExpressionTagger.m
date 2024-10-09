//
//  XPRegex.m
//  NotSoulver
//
//  Created by Jeffrey Bergier on 2024/09/27.
//

#import "SVRSolverExpressionTagger.h"
#import "SVRCrossPlatform.h"
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
    [string addAttribute:XPAttributedStringKeyForTag(SVRSolverTagBracket)
                   value:next
                   range:[next XP_rangeValue]];
  }
}

@end

@implementation SVRSolverExpressionTagger (Tests)
+(NSMutableAttributedString*)executeTests;
{
  NSString *_userInput = @"(-3.2+4)/7.3=";
  NSAttributedString *userInput = [[[NSAttributedString alloc] initWithString:_userInput] autorelease];
  NSMutableAttributedString *input = [[userInput mutableCopy] autorelease];
  NSSet *ranges = nil;
  NSDictionary *output = nil;
  
  [XPLog alwys:@"SVRExpressionTagger Tests: Starting"];
  
  // Numbers
  ranges = [NSSet setWithObjects:
            [NSValue XP_valueWithRange:NSMakeRange(1, 4)],
            [NSValue XP_valueWithRange:NSMakeRange(6, 1)],
            [NSValue XP_valueWithRange:NSMakeRange(9, 3)],
            nil];
  [SVRSolverExpressionTagger tagNumbersAtRanges:ranges inAttributedString:input];
  
  // Operators
  ranges = [NSSet setWithObjects:
            [NSValue XP_valueWithRange:NSMakeRange(5, 1)],
            [NSValue XP_valueWithRange:NSMakeRange(8, 1)],
            nil];
  
  [SVRSolverExpressionTagger tagOperatorsAtRanges:ranges inAttributedString:input];
  
  // Brackets
  ranges = [NSSet setWithObjects:
            [NSValue XP_valueWithRange:NSMakeRange(0, 1)],
            [NSValue XP_valueWithRange:NSMakeRange(7, 1)],
            nil];
  
  [SVRSolverExpressionTagger tagBracketsAtRanges:ranges inAttributedString:input];
  
  // Expressions
  ranges = [NSSet setWithObject:[NSValue XP_valueWithRange:NSMakeRange(0, 12)]];
  
  [SVRSolverExpressionTagger tagExpressionsAtRanges:ranges inAttributedString:input];
  
  // Iterate through the string to verify attributes
  output = [input attributesAtIndex:0 effectiveRange:NULL];
  NSAssert([output count] == 2, @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagBracket)]
            isEqualToValue:[NSValue XP_valueWithRange:NSMakeRange(0, 1)]], @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagExpression)]
            isEqualToValue:[NSValue XP_valueWithRange:NSMakeRange(0, 12)]], @"");
  
  output = [input attributesAtIndex:1 effectiveRange:NULL];
  NSAssert([output count] == 2, @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagNumber)]
            isEqualToNumber:[NSDecimalNumber decimalNumberWithString:@"-3.2"]], @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagExpression)]
            isEqualToValue:[NSValue XP_valueWithRange:NSMakeRange(0, 12)]], @"");
  
  output = [input attributesAtIndex:2 effectiveRange:NULL];
  NSAssert([output count] == 2, @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagNumber)]
            isEqualToNumber:[NSDecimalNumber decimalNumberWithString:@"-3.2"]], @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagExpression)]
            isEqualToValue:[NSValue XP_valueWithRange:NSMakeRange(0, 12)]], @"");
  
  output = [input attributesAtIndex:3 effectiveRange:NULL];
  NSAssert([output count] == 2, @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagNumber)]
            isEqualToNumber:[NSDecimalNumber decimalNumberWithString:@"-3.2"]], @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagExpression)]
            isEqualToValue:[NSValue XP_valueWithRange:NSMakeRange(0, 12)]], @"");
  
  output = [input attributesAtIndex:4 effectiveRange:NULL];
  NSAssert([output count] == 2, @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagNumber)]
            isEqualToNumber:[NSDecimalNumber decimalNumberWithString:@"-3.2"]], @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagExpression)]
            isEqualToValue:[NSValue XP_valueWithRange:NSMakeRange(0, 12)]], @"");
  
  output = [input attributesAtIndex:5 effectiveRange:NULL];
  NSAssert([output count] == 2, @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagOperator)]
            isEqualToNumber:[NSNumber XP_numberWithInteger:SVRSolverOperatorAdd]], @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagExpression)]
            isEqualToValue:[NSValue XP_valueWithRange:NSMakeRange(0, 12)]], @"");
  
  output = [input attributesAtIndex:6 effectiveRange:NULL];
  NSAssert([output count] == 2, @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagNumber)]
            isEqualToNumber:[NSDecimalNumber decimalNumberWithString:@"4"]], @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagExpression)]
            isEqualToValue:[NSValue XP_valueWithRange:NSMakeRange(0, 12)]], @"");
  
  output = [input attributesAtIndex:7 effectiveRange:NULL];
  NSAssert([output count] == 2, @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagBracket)]
            isEqualToValue:[NSValue XP_valueWithRange:NSMakeRange(7, 1)]], @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagExpression)]
            isEqualToValue:[NSValue XP_valueWithRange:NSMakeRange(0, 12)]], @"");
  
  output = [input attributesAtIndex:8 effectiveRange:NULL];
  NSAssert([output count] == 2, @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagOperator)]
            isEqualToNumber:[NSNumber XP_numberWithInteger:SVRSolverOperatorDivide]], @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagExpression)]
            isEqualToValue:[NSValue XP_valueWithRange:NSMakeRange(0, 12)]], @"");
  
  output = [input attributesAtIndex:9 effectiveRange:NULL];
  NSAssert([output count] == 2, @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagNumber)]
            isEqualToNumber:[NSDecimalNumber decimalNumberWithString:@"7.3"]], @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagExpression)]
            isEqualToValue:[NSValue XP_valueWithRange:NSMakeRange(0, 12)]], @"");
  
  output = [input attributesAtIndex:10 effectiveRange:NULL];
  NSAssert([output count] == 2, @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagNumber)]
            isEqualToNumber:[NSDecimalNumber decimalNumberWithString:@"7.3"]], @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagExpression)]
            isEqualToValue:[NSValue XP_valueWithRange:NSMakeRange(0, 12)]], @"");
  
  output = [input attributesAtIndex:11 effectiveRange:NULL];
  NSAssert([output count] == 2, @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagNumber)]
            isEqualToNumber:[NSDecimalNumber decimalNumberWithString:@"7.3"]], @"");
  NSAssert([[output objectForKey:XPAttributedStringKeyForTag(SVRSolverTagExpression)]
            isEqualToValue:[NSValue XP_valueWithRange:NSMakeRange(0, 12)]], @"");
  
  output = [input attributesAtIndex:12 effectiveRange:NULL];
  NSAssert([output count] == 0, @"");
  
  [XPLog alwys:@"SVRExpressionTagger Tests: Passed"];
  return input;
}
@end
