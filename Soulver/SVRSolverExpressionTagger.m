//
// MIT License
//
// Copyright (c) 2024 Jeffrey Bergier
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
// THIS SOFTWARE IS NOT RELATED TO THE APPLICATION CALLED 'Solver' by Zac Cohan,
// THIS SOFTWARE IS MERELY INSPIRED BY THAT APPLICATION AND WAS CREATED AS A
// LEARNING EXERCISE. YOU SHOULD PURCHASE AND USE 'Solver' by Zac Cohan
// AT https://soulver.app INSTEAD OF USING THIS SOFTWARE.
//

#import "SVRSolverExpressionTagger.h"
#import "XPCrossPlatform.h"
#import "SVRSolver.h"

@implementation SVRSolverExpressionTagger

+(void)step2_tagNumbersAtRanges:(NSSet*)ranges
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
      XPLogDebug1(@"NaN: %@", number);
    }
    [string removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagOperator) range:range];
    [string addAttribute:XPAttributedStringKeyForTag(SVRSolverTagNumber)
                   value:number
                   range:range];
  }
}

+(void)step1_tagOperatorsAtRanges:(NSSet*)ranges
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

+(void)step4_tagExpressionsAtRanges:(NSSet*)ranges
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

+(void)step3_tagBracketsAtRanges:(NSSet*)ranges
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
