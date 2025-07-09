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

#import "XPCrossPlatform.h"
#import "MATHSolver.h"
#import "MATHSolverExpressionTagger.h"

@implementation MATHSolverExpressionTagger

+(void)step1_tagOperatorsAtRanges:(NSSet*)ranges
               inAttributedString:(NSMutableAttributedString*)string;
{
  MATHSolverOperator operator = -1;
  NSValue *next = nil;
  NSRange range = XPNotFoundRange;
  NSEnumerator *e = [ranges objectEnumerator];
  while ((next = [e nextObject])) {
    range = [next XP_rangeValue];
    operator = MATHSolverOperatorForRawString([[string string] substringWithRange:range]);
    [string addAttribute:XPAttributedStringKeyForTag(MATHSolverTagOperator)
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
    XPLogAssrt1(![number MATH_isNotANumber], @"MATHSolverExpressionTagger: step2: `%@` is NaN", numberString);
    [string removeAttribute:XPAttributedStringKeyForTag(MATHSolverTagOperator)
                      range:range];
    [string addAttribute:XPAttributedStringKeyForTag(MATHSolverTagNumber)
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
    [string addAttribute:XPAttributedStringKeyForTag(MATHSolverTagBracket)
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
    [string addAttribute:XPAttributedStringKeyForTag(MATHSolverTagExpression)
                   value:NSStringFromRange([next XP_rangeValue])
                   range:[next XP_rangeValue]];
  }
}

@end
