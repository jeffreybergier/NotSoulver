//
// GPLv3 License Notice
//
// Copyright (c) 2025 Jeffrey Bergier
//
// This file is part of MathEdit.
// MathEdit is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License,
// or (at your option) any later version.
// MathEdit is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
// You should have received a copy of the GNU General Public License
// along with MathEdit. If not, see <https://www.gnu.org/licenses/>.
//

#import "MATHSolverExpressionTagger.h"
#import "XPCrossPlatform.h"
#import "SVRSolver.h"

@implementation SVRSolverExpressionTagger

+(void)step1_tagOperatorsAtRanges:(NSSet*)ranges
               inAttributedString:(NSMutableAttributedString*)string;
{
  SVRSolverOperator operator = -1;
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

+(void)step2_tagNumbersAtRanges:(NSSet*)ranges
             inAttributedString:(NSMutableAttributedString*)string;
{
  NSString *numberString = nil;
  NSDecimalNumber *number = nil;
  NSValue *next = nil;
  NSRange range = XPNotFoundRange;
  NSEnumerator *e = [ranges objectEnumerator];
  while ((next = [e nextObject])) {
    range = [next XP_rangeValue];
    numberString = [[string string] substringWithRange:range];
    number = [NSDecimalNumber decimalNumberWithString:numberString];
    XPLogAssrt1(![number SVR_isNotANumber], @"SVRSolverExpressionTagger: step2: `%@` is NaN", numberString);
    [string removeAttribute:XPAttributedStringKeyForTag(SVRSolverTagOperator)
                      range:range];
    [string addAttribute:XPAttributedStringKeyForTag(SVRSolverTagNumber)
                   value:number
                   range:range];
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

@end
