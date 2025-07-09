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

#import "MATHSolver.h"
#import "MATHSolverScanner.h"

NSSet *SVRSolverScannerNegativeNumberPrefixSet = nil;

@implementation SVRSolverScanner

// MARK: Load
+(void)initialize;
{
  SVRSolverScannerNegativeNumberPrefixSet = [[NSSet alloc] initWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @")", nil];
}

// MARK: Initialization
-(id)initWithString:(NSString*)string;
{
  self = [super init];
  XPParameterRaise(self);
  _string = [string copy];
  _numbers = nil;
  _operators = nil;
  _operators = nil;
  _expressions = nil;
  _brackets = nil;
  return self;
}

+(id)scannerWithString:(NSString*)string;
{
  return [[[SVRSolverScanner alloc] initWithString:string] autorelease];
}

-(NSSet*)expressionRanges;
{
  if (!_expressions) {
    [self __populateExpressions];
  }
  return [[_expressions retain] autorelease];
}

-(NSSet*)numberRanges;
{
  if (!_numbers) {
    [self __populateNumbers];
  }
  return [[_numbers retain] autorelease];
}

-(NSSet*)operatorRanges;
{
  if (!_operators) {
    [self __populateOperators];
  }
  return [[_operators retain] autorelease];
}

-(NSSet*)bracketRanges;
{
  if (!_brackets) {
    [self __populateBrackets];
  }
  return [[_brackets retain] autorelease];
}

// MARK: Convenience Properties
-(NSString*)string;
{
  return [[_string retain] autorelease];
}
-(NSString*)description;
{
  return [super description];
}

// MARK: Private

-(void)__populateExpressions;
{
  NSEnumerator *matches = [[[XPRegularExpression MATH_regexForExpressions]
                            matchesInString:_string]
                            objectEnumerator];
  XPTextCheckingResult *match = nil;
  NSMutableSet *output = [NSMutableSet new];
  NSRange range = XPNotFoundRange;
  XPLogAssrt(!_expressions, @"_expressions loaded twice");
  
  while ((match = [matches nextObject])) {
    range = [match range];
    // Trim the = sign off
    range.length -= 1;
    XPLogExtra1(@"= %@", [_string MATH_descriptionHighlightingRange:range]);
    [output addObject:[NSValue XP_valueWithRange:range]];
  }
  _expressions = output; // should make immutable copy but avoiding
}

-(void)__populateNumbers;
{
  NSSet *negativeNumberPrefixSet = SVRSolverScannerNegativeNumberPrefixSet;
  NSMutableSet *output = [NSMutableSet new];
  XPRegularExpression *regex = [XPRegularExpression MATH_regexForNumbers];
  NSEnumerator *matches = nil;
  XPTextCheckingResult *match = nil;
  NSEnumerator *expressions = [[self expressionRanges] objectEnumerator];
  NSValue *expression = nil;
  NSDecimalNumber *matchedNumber = nil;
  NSRange range = XPNotFoundRange;
  XPLogAssrt(!_numbers, @"_numbers loaded twice");

  while ((expression = [expressions nextObject])) {
    matches = [[regex matchesInString:_string
                              options:0
                                range:[expression XP_rangeValue]]
               objectEnumerator];
    while ((match = [matches nextObject])) {
      range = [match range];
      matchedNumber = [NSDecimalNumber decimalNumberWithString:[_string substringWithRange:range]];
      XPLogAssrt(![matchedNumber MATH_isNotANumber], @"matchedNumber: NaN");
      if (range.location > 0
          && [matchedNumber compare:[NSDecimalNumber zero]] == NSOrderedAscending
          && [negativeNumberPrefixSet member:[_string substringWithRange:NSMakeRange(range.location-1, 1)]] != nil)
      {
        // The regex matches (5+5)-7 as 3 numbers 5,5,-7 but the -7 is actually 7
        // This check adjusts for this edge case
        range.location += 1;
        range.length -= 1;
        XPLogExtra2(@"`%@`->`%@`", matchedNumber, [_string substringWithRange:range]);
      }
      XPLogExtra1(@"%@", [_string MATH_descriptionHighlightingRange:range]);
      [output addObject:[NSValue XP_valueWithRange:range]];
    }
  }
  
  _numbers = output; // should make immutable copy but avoiding
}

 -(void)__populateOperators;
 {
   NSMutableSet *output = [NSMutableSet new];
   XPRegularExpression *regex = [XPRegularExpression MATH_regexForOperators];
   NSEnumerator *matches = nil;
   XPTextCheckingResult *match = nil;
   NSEnumerator *expressions = [[self expressionRanges] objectEnumerator];
   NSValue *expression = nil;
   NSRange range = XPNotFoundRange;
   XPLogAssrt(!_operators, @"_operators loaded twice");

   while ((expression = [expressions nextObject])) {
     matches = [[regex matchesInString:_string
                               options:0
                                 range:[expression XP_rangeValue]]
                objectEnumerator];
     while ((match = [matches nextObject])) {
       range = [match rangeAtIndex:0];
       XPLogExtra1(@"%@", [_string MATH_descriptionHighlightingRange:range]);
       [output addObject:[NSValue XP_valueWithRange:range]];
     }
   }
   _operators = output; // should make immutable copy but avoiding
 }

-(void)__populateBrackets;
{
  NSMutableSet *output = [NSMutableSet new];
  XPRegularExpression *regex = [XPRegularExpression MATH_regexForBrackets];
  NSEnumerator *matches = nil;
  XPTextCheckingResult *match = nil;
  NSEnumerator *expressions = [[self expressionRanges] objectEnumerator];
  NSValue *expression = nil;
  NSRange range = XPNotFoundRange;
  XPLogAssrt(!_brackets, @"_brackets loaded twice");

  while ((expression = [expressions nextObject])) {
    matches = [[regex matchesInString:_string
                              options:0
                                range:[expression XP_rangeValue]]
               objectEnumerator];
    while ((match = [matches nextObject])) {
      range = [match range];
      XPLogExtra1(@"%@", [_string MATH_descriptionHighlightingRange:range]);
      [output addObject:[NSValue XP_valueWithRange:range]];
    }
  }
  
  _brackets = output; // should make immutable copy but avoiding
}

// MARK: Dealloc
-(void)dealloc;
{
  XPLogExtra1(@"<%@>", XPPointerString(self));
  [_string release];
  [_numbers release];
  [_operators release];
  [_expressions release];
  [_brackets release];
  _string = nil;
  _numbers = nil;
  _operators = nil;
  _expressions = nil;
  _brackets = nil;
  [super dealloc];
}

@end

@implementation XPRegularExpression (Soulver)

+(id)MATH_regexForNumbers;
{
  return [self regularExpressionWithPattern:@"(-?\\d+\\.\\d+|-?\\d+)" options:0 error:NULL];
}
+(id)MATH_regexForOperators;
{
  return [self regularExpressionWithPattern:@"(L|R|\\+|-|/|\\*|\\^)[-\\(\\d]" options:0 error:NULL];
}

+(id)MATH_regexForExpressions;
{
  return [self regularExpressionWithPattern:@"[\\dLR\\.\\^\\*-\\+/\\(\\)]+=" options:0 error:NULL];
}

+(id)MATH_regexForBrackets;
{
  return [self regularExpressionWithPattern:@"[\\(\\)]" options:0 error:NULL];
}

@end
